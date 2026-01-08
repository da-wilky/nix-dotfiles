{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.libvirt;
  
  # VM configuration type
  vmType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Name of the virtual machine";
      };
      
      memory = mkOption {
        type = types.int;
        default = 2048;
        description = "Memory in MB";
      };
      
      cpus = mkOption {
        type = types.int;
        default = 2;
        description = "Number of virtual CPUs";
      };
      
      diskSize = mkOption {
        type = types.str;
        default = "20G";
        description = "Disk size (e.g., 20G, 50G)";
      };
      
      diskPath = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Custom path for VM disk image. If null, uses default location in /var/lib/libvirt/images/";
      };
      
      imagePath = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Local path to the base image/ISO file (e.g., Ubuntu cloud image or installation ISO)";
        example = "/path/to/ubuntu-22.04-server-cloudimg-amd64.img";
      };
      
      imageFormat = mkOption {
        type = types.enum [ "iso" "qcow2" "raw" "vmdk" ];
        default = "iso";
        description = "Format of the provided image file";
      };
      
      autostart = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to autostart this VM on boot";
      };
      
      bridgeInterface = mkOption {
        type = types.str;
        default = "br0";
        description = "Bridge interface to use for VM networking";
      };
    };
  };
in {
  options.myModules.libvirt = {
    enable = mkEnableOption "libvirt virtualization with KVM/QEMU";
    
    users = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of users to add to the libvirtd group";
      example = [ "samuel" "nico" ];
    };
    
    bridge = {
      enable = mkEnableOption "bridge networking for VMs";
      
      interface = mkOption {
        type = types.str;
        default = "br0";
        description = "Name of the bridge interface";
      };
      
      physicalInterface = mkOption {
        type = types.str;
        default = "eth0";
        description = "Physical interface to bridge (e.g., eth0, enp1s0)";
        example = "enp1s0";
      };
    };
    
    vms = mkOption {
      type = types.attrsOf vmType;
      default = {};
      description = "Virtual machines to configure";
      example = literalExpression ''
        {
          ubuntu-vm = {
            name = "ubuntu-vm";
            memory = 4096;
            cpus = 4;
            diskSize = "50G";
            imagePath = "/data/isos/ubuntu-22.04-live-server-amd64.iso";
            imageFormat = "iso";
            autostart = false;
          };
          cloud-vm = {
            name = "cloud-vm";
            memory = 2048;
            cpus = 2;
            diskSize = "30G";
            imagePath = "/data/isos/ubuntu-22.04-server-cloudimg-amd64.img";
            imageFormat = "qcow2";
            autostart = true;
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    # Enable libvirtd
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;
      };
    };

    # Add specified users to libvirtd group
    users.users = mkMerge (map (username: {
      ${username} = {
        extraGroups = [ "libvirtd" ];
      };
    }) cfg.users);

    # Install useful packages
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      virtio-win
      win-spice
      libvirt
      qemu_kvm
    ];

    # Configure bridge networking if enabled
    networking.bridges = mkIf cfg.bridge.enable {
      ${cfg.bridge.interface} = {
        interfaces = [ cfg.bridge.physicalInterface ];
      };
    };
    
    # When bridge is enabled, transfer the DHCP from physical interface to bridge
    # This preserves the host's network connectivity
    networking.interfaces = mkIf cfg.bridge.enable {
      # The bridge gets DHCP (takes over from physical interface)
      ${cfg.bridge.interface} = {
        useDHCP = true;
      };
      
      # Physical interface must NOT have DHCP when it's part of a bridge
      # The bridge takes over all network configuration
      ${cfg.bridge.physicalInterface} = {
        useDHCP = mkForce false;
        ipv4.addresses = mkForce [];
        ipv6.addresses = mkForce [];
      };
    };
    
    # Tell NetworkManager to ignore the physical interface when it's bridged
    networking.networkmanager.unmanaged = mkIf cfg.bridge.enable [
      cfg.bridge.physicalInterface
    ];

    # Open firewall for libvirt if needed
    networking.firewall.checkReversePath = false;

    # Systemd service to set up VMs
    systemd.services = mkMerge (mapAttrsToList (vmName: vmConfig:
      let
        vmDiskPath = if vmConfig.diskPath != null 
                    then vmConfig.diskPath 
                    else "/var/lib/libvirt/images/${vmConfig.name}.qcow2";
      in {
        "libvirt-vm-${vmName}" = mkIf (vmConfig.imagePath != null) {
          description = "Setup VM: ${vmConfig.name}";
          after = [ "libvirtd.service" ];
          requires = [ "libvirtd.service" ];
          wantedBy = [ "multi-user.target" ];
          
          path = with pkgs; [ libvirt qemu_kvm curl gzip ];
          
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          
          script = ''
            # Ensure images directory exists
            mkdir -p /var/lib/libvirt/images
            
            # Create VM disk if it doesn't exist
            if [ ! -f "${vmDiskPath}" ]; then
              echo "Creating VM disk for ${vmConfig.name}..."
              
              # Use base image if path is provided
              if [ -n "${toString vmConfig.imagePath}" ] && [ "${toString vmConfig.imagePath}" != "" ]; then
                if [ ! -f "${toString vmConfig.imagePath}" ]; then
                  echo "ERROR: Base image not found at ${toString vmConfig.imagePath}"
                  exit 1
                fi
                
                # Handle different image formats
                case "${vmConfig.imageFormat}" in
                  iso)
                    # For ISO, create an empty disk - ISO will be attached as CDROM
                    echo "Creating empty disk for ISO installation..."
                    ${pkgs.qemu_kvm}/bin/qemu-img create -f qcow2 "${vmDiskPath}" ${vmConfig.diskSize}
                    ;;
                  qcow2|raw|vmdk)
                    # For disk images, convert to qcow2 and resize
                    echo "Creating VM disk from base image ${toString vmConfig.imagePath}..."
                    ${pkgs.qemu_kvm}/bin/qemu-img convert -f ${vmConfig.imageFormat} -O qcow2 "${toString vmConfig.imagePath}" "${vmDiskPath}"
                    ${pkgs.qemu_kvm}/bin/qemu-img resize "${vmDiskPath}" ${vmConfig.diskSize}
                    ;;
                esac
              else
                # Create empty disk
                echo "Creating empty disk..."
                ${pkgs.qemu_kvm}/bin/qemu-img create -f qcow2 "${vmDiskPath}" ${vmConfig.diskSize}
              fi
            fi
          '';
        };
      }
    ) cfg.vms);

    # Create VM XML definitions and import them
    systemd.tmpfiles.rules = flatten (mapAttrsToList (vmName: vmConfig:
      let
        vmDiskPath = if vmConfig.diskPath != null 
                    then vmConfig.diskPath 
                    else "/var/lib/libvirt/images/${vmConfig.name}.qcow2";
        vmXml = pkgs.writeText "${vmConfig.name}.xml" ''
          <domain type='kvm'>
            <name>${vmConfig.name}</name>
            <memory unit='MiB'>${toString vmConfig.memory}</memory>
            <vcpu placement='static'>${toString vmConfig.cpus}</vcpu>
            <os>
              <type arch='x86_64' machine='q35'>hvm</type>
              <boot dev='${if vmConfig.imageFormat == "iso" then "cdrom" else "hd"}'/>
              ${if vmConfig.imageFormat == "iso" then "<boot dev='hd'/>" else ""}
            </os>
            <features>
              <acpi/>
              <apic/>
            </features>
            <cpu mode='host-passthrough'/>
            <clock offset='utc'>
              <timer name='rtc' tickpolicy='catchup'/>
              <timer name='pit' tickpolicy='delay'/>
              <timer name='hpet' present='no'/>
            </clock>
            <on_poweroff>destroy</on_poweroff>
            <on_reboot>restart</on_reboot>
            <on_crash>destroy</on_crash>
            <devices>
              <emulator>${pkgs.qemu_kvm}/bin/qemu-system-x86_64</emulator>
              <disk type='file' device='disk'>
                <driver name='qemu' type='qcow2'/>
                <source file='${vmDiskPath}'/>
                <target dev='vda' bus='virtio'/>
              </disk>
              ${optionalString (vmConfig.imagePath != null && vmConfig.imageFormat == "iso") ''
              <disk type='file' device='cdrom'>
                <driver name='qemu' type='raw'/>
                <source file='${toString vmConfig.imagePath}'/>
                <target dev='sda' bus='sata'/>
                <readonly/>
              </disk>
              ''}
              <interface type='bridge'>
                <source bridge='${vmConfig.bridgeInterface}'/>
                <model type='virtio'/>
              </interface>
              <serial type='pty'>
                <target type='isa-serial' port='0'>
                  <model name='isa-serial'/>
                </target>
              </serial>
              <console type='pty'>
                <target type='serial' port='0'/>
              </console>
              <channel type='unix'>
                <target type='virtio' name='org.qemu.guest_agent.0'/>
              </channel>
              <channel type='spicevmc'>
                <target type='virtio' name='com.redhat.spice.0'/>
              </channel>
              <input type='tablet' bus='usb'/>
              <input type='mouse' bus='ps2'/>
              <input type='keyboard' bus='ps2'/>
              <graphics type='spice' autoport='yes'>
                <listen type='address' address='0.0.0.0'/>
              </graphics>
              <video>
                <model type='qxl' ram='65536' vram='65536' vgamem='16384' heads='1'/>
              </video>
              <memballoon model='virtio'/>
            </devices>
          </domain>
        '';
        activationScript = pkgs.writeShellScript "activate-${vmConfig.name}" ''
          # Wait for libvirtd to be ready
          while ! ${pkgs.libvirt}/bin/virsh version >/dev/null 2>&1; do
            sleep 1
          done
          
          # Check if VM already exists
          if ! ${pkgs.libvirt}/bin/virsh dominfo ${vmConfig.name} >/dev/null 2>&1; then
            echo "Defining VM ${vmConfig.name}..."
            ${pkgs.libvirt}/bin/virsh define ${vmXml}
          fi
          
          # Set autostart if configured
          ${optionalString vmConfig.autostart ''
            ${pkgs.libvirt}/bin/virsh autostart ${vmConfig.name}
          ''}
        '';
      in [
        "L+ /var/lib/libvirt/hooks/${vmConfig.name}-activate.sh - - - - ${activationScript}"
      ]
    ) cfg.vms);

    # Activation script to define VMs
    system.activationScripts.libvirt-vms = mkIf (cfg.vms != {}) {
      text = concatStringsSep "\n" (mapAttrsToList (vmName: vmConfig: ''
        if [ -f /var/lib/libvirt/hooks/${vmConfig.name}-activate.sh ]; then
          bash /var/lib/libvirt/hooks/${vmConfig.name}-activate.sh || true
        fi
      '') cfg.vms);
      deps = [ "users" ];
    };
  };
}
