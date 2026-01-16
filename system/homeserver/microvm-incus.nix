{ config, lib, pkgs, inputs, ... }:

let
  # Configuration variables - change these to customize your setup
  vmName = "k3s-cluster-1";
  storagePath = "/data/microvms/${vmName}";
  hostExternalInterface = "enp2s0"; # Host's internet-facing interface
  
  # SSH authorized keys for VM root access
  sshAuthorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAWEue89TqiVnWtTnBka40kV9md2ImfV2cpVgR/kgUS samuel@nixos"
  ];
  
  # VM network configuration
  vmNetwork = {
    subnet = "192.168.100";
    hostIp = "192.168.100.1";
    vmIp = "192.168.100.10";
    bridgeName = "virbr-incus";
    tapId = "vm-incus";
  };
  
  # Container network configuration
  containerNetwork = {
    subnet = "10.20.30";
    gatewayIp = "10.20.30.1";
    bridgeName = "incusbr0";
  };
  
  # VM resources
  vmResources = {
    vcpu = 4;
    memory = 8192; # MB
    diskSize = 102400; # MB (100GB)
  };
  
  # Container defaults
  containerDefaults = {
    memory = "2GiB";
    cpus = 2;
    diskSize = "20GiB";
    image = "images:ubuntu/24.04";
  };
in
{
  # MicroVM configuration for running Incus with privileged containers
  microvm.vms.${vmName} = {
    # Autostart the VM on boot
    autostart = true;

    # MicroVM-specific configuration
    config = { config, lib, pkgs, ... }: {
      # Import the incus module
      imports = [ ../../modules/incus.nix ];

      # Basic VM settings
      microvm = {
        # hypervisor = "qemu";
        hypervisor = "cloud-hypervisor";
        
        vcpu = vmResources.vcpu;
        mem = vmResources.memory;

        # Network interface - tap device connected to host bridge
        interfaces = [{
          type = "tap";
          id = vmNetwork.tapId;
          mac = "02:00:00:00:00:01";
        }];

        # Shared directory with host (optional, for file transfer)
        shares = [{
          source = "${storagePath}/shared";
          mountPoint = "/host-shared";
          tag = "host-shared";
          proto = "virtiofs";
        }];

        # Volumes for persistent storage
        volumes = [{
          image = "${storagePath}/rootfs.img";
          mountPoint = "/";
          size = vmResources.diskSize;
        }];
      };

      # Network configuration
      networking = {
        hostName = vmName;
        useNetworkd = false;

        # Static IP for eth0
        interfaces.eth0.ipv4.addresses = [{
          address = vmNetwork.vmIp;
          prefixLength = 24;
        }];

        # Gateway as string only
        defaultGateway = vmNetwork.hostIp;

        nameservers = [ "8.8.8.8" "1.1.1.1" ];
      };

      # Enable IP forwarding in the VM
      boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

      # Enable Incus with the existing module
      myModules.incus = {
        enable = true;
        ui.enable = false;

        preseed = {
          storagePool = "default";
          storageDriver = "dir";
          networkBridge = containerNetwork.bridgeName;
          networkAddress = "${containerNetwork.gatewayIp}/24";
        };

        # Define the privileged containers
        instances = {
          ubuntu-1 = {
            name = "ubuntu-1";
            type = "container";
            memory = containerDefaults.memory;
            cpus = containerDefaults.cpus;
            diskSize = containerDefaults.diskSize;
            image = containerDefaults.image;
            autostart = true;
            ipAddress = "${containerNetwork.subnet}.101";
            config = {
              "security.privileged" = "true";
              "security.nesting" = "true";
            };
          };

          ubuntu-2 = {
            name = "ubuntu-2";
            type = "container";
            memory = containerDefaults.memory;
            cpus = containerDefaults.cpus;
            diskSize = containerDefaults.diskSize;
            image = containerDefaults.image;
            autostart = true;
            ipAddress = "${containerNetwork.subnet}.102";
            config = {
              "security.privileged" = "true";
              "security.nesting" = "true";
            };
          };

          ubuntu-3 = {
            name = "ubuntu-3";
            type = "container";
            memory = containerDefaults.memory;
            cpus = containerDefaults.cpus;
            diskSize = containerDefaults.diskSize;
            image = containerDefaults.image;
            autostart = true;
            ipAddress = "${containerNetwork.subnet}.103";
            config = {
              "security.privileged" = "true";
              "security.nesting" = "true";
            };
          };
        };
      };

      # Basic packages
      environment.systemPackages = with pkgs; [ incus htop vim curl wget ];

      # SSH access
      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "prohibit-password";
          PasswordAuthentication = false;
        };
      };

      # Add your SSH key for root access
      users.users.root.openssh.authorizedKeys.keys = sshAuthorizedKeys;

      system.stateVersion = "25.11";
    };
  };

  # Host-side networking configuration using systemd-networkd
  # Enable networkd without replacing the old backend globally
  systemd.network.enable = true;
  # Important: DO NOT set `networking.useNetworkd = true;`

  # Bridge for the MicroVMs
  systemd.network.netdevs."10-${vmNetwork.bridgeName}" = {
    netdevConfig = {
      Name = vmNetwork.bridgeName;
      Kind = "bridge";
    };
  };

  # Host IP in the VM network
  systemd.network.networks."10-${vmNetwork.bridgeName}" = {
    matchConfig.Name = vmNetwork.bridgeName;
    address = [ "${vmNetwork.hostIp}/24" ];

    routes = [
      {
        Destination = "${containerNetwork.subnet}.0/24";
        Gateway = vmNetwork.vmIp;
        GatewayOnLink = true;
      }
    ];
  };

  # All vm-* TAPs attached to the bridge
  systemd.network.networks."20-vm-taps" = {
    matchConfig.Name = "${vmNetwork.tapId}";
    networkConfig.Bridge = vmNetwork.bridgeName;
  };

  # Enable IP forwarding on the host
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  # NAT for MicroVM network
  networking.nat = {
    enable = true;
    internalInterfaces = [ vmNetwork.bridgeName ];
    externalInterface = hostExternalInterface;
  };

  # Allow traffic on the VM bridge
  networking.firewall.trustedInterfaces = [ vmNetwork.bridgeName ];

  # Create storage directories with proper ownership for microvm user
  systemd.tmpfiles.rules = [
    "d /data/microvms 0755 microvm kvm -"
    "d ${storagePath} 0755 microvm kvm -"
    "d ${storagePath}/shared 0755 microvm kvm -"
  ];
}
