{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.incus;
  
  # Common instance configuration type (for VMs and containers)
  instanceType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Name of the instance (VM or container)";
      };
      
      type = mkOption {
        type = types.enum [ "vm" "container" ];
        default = "container";
        description = "Type of instance: 'vm' for virtual machine or 'container' for LXC container";
      };
      
      memory = mkOption {
        type = types.str;
        default = "2GiB";
        description = "Memory limit (e.g., 2GiB, 4096MiB)";
        example = "4GiB";
      };
      
      cpus = mkOption {
        type = types.int;
        default = 2;
        description = "Number of CPUs/cores";
      };
      
      diskSize = mkOption {
        type = types.str;
        default = "10GiB";
        description = "Root disk size (e.g., 10GiB, 50GB)";
        example = "50GiB";
      };
      
      diskPool = mkOption {
        type = types.str;
        default = "default";
        description = "Storage pool to use for the instance disk";
      };
      
      image = mkOption {
        type = types.str;
        default = "images:ubuntu/24.04";
        description = "Image to use for instance creation (e.g., images:ubuntu/22.04, images:alpine/edge)";
        example = "images:debian/12";
      };
      
      autostart = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to autostart this instance on boot";
      };
      
      profiles = mkOption {
        type = types.listOf types.str;
        default = [ "default" ];
        description = "List of profiles to apply to this instance";
        example = [ "default" "bridged" ];
      };
      
      network = mkOption {
        type = types.str;
        default = "incusbr0";
        description = "Network bridge to attach the instance to";
      };
      
      ipAddress = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Static IPv4 address for the instance (CIDR notation, e.g., 10.18.10.50/24). If null, DHCP will be used.";
        example = "10.18.10.100/24";
      };
      
      config = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Additional instance configuration options";
        example = {
          "security.nesting" = "true";
          "security.privileged" = "true";
        };
      };
    };
  };
  
  # Preseed configuration type
  preseedType = types.submodule {
    options = {
      storagePool = mkOption {
        type = types.str;
        default = "default";
        description = "Name of the default storage pool";
      };
      
      storageDriver = mkOption {
        type = types.enum [ "dir" "zfs" "btrfs" "lvm" ];
        default = "dir";
        description = "Storage driver/backend to use";
      };
      
      storageSize = mkOption {
        type = types.str;
        default = "50GiB";
        description = "Size of the storage pool (for zfs/lvm/btrfs loop devices)";
      };
      
      networkBridge = mkOption {
        type = types.str;
        default = "incusbr0";
        description = "Name of the default bridge network";
      };
      
      networkAddress = mkOption {
        type = types.str;
        default = "10.18.10.1/24";
        description = "IPv4 address and subnet for the bridge (CIDR notation)";
      };
      
      enableIPv6 = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable IPv6 on the bridge network";
      };
      
      networkIPv6Address = mkOption {
        type = types.str;
        default = "fd42:4242:4242:1010::1/64";
        description = "IPv6 address and subnet for the bridge (CIDR notation)";
      };
      
      additionalNetworks = mkOption {
        type = types.listOf types.attrs;
        default = [];
        description = "Additional networks to create beyond the default bridge";
        example = literalExpression ''
          [
            {
              name = "secondary-bridge";
              type = "bridge";
              config = {
                "ipv4.address" = "10.20.30.1/24";
                "ipv4.nat" = "true";
              };
            }
          ]
        '';
      };
      
      additionalProfiles = mkOption {
        type = types.listOf types.attrs;
        default = [];
        description = "Additional profiles to create beyond the default profile";
        example = literalExpression ''
          [
            {
              name = "high-performance";
              devices = {
                eth0 = {
                  name = "eth0";
                  network = "incusbr0";
                  type = "nic";
                };
                root = {
                  path = "/";
                  pool = "default";
                  type = "disk";
                };
              };
              config = {
                "limits.memory" = "8GiB";
                "limits.cpu" = "4";
              };
            }
          ]
        '';
      };
      
      additionalStoragePools = mkOption {
        type = types.listOf types.attrs;
        default = [];
        description = "Additional storage pools to create beyond the default pool";
        example = literalExpression ''
          [
            {
              name = "fast-storage";
              driver = "zfs";
              config = {
                source = "/dev/nvme0n1p1";
              };
            }
          ]
        '';
      };
    };
  };

in {
  options.myModules.incus = {
    enable = mkEnableOption "Incus container and virtualization management";
    
    ui = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the Incus web UI";
      };
      
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Host address for the Incus web UI to listen on. Use '[::]' for all interfaces (IPv4 and IPv6), '0.0.0.0' for all IPv4, or a specific IP address.";
        example = "0.0.0.0";
      };
      
      port = mkOption {
        type = types.int;
        default = 8443;
        description = "Port for the Incus web UI";
        example = 8443;
      };
    };
    
    users = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of users to add to the incus-admin group";
      example = [ "samuel" "nico" ];
    };
    
    preseed = mkOption {
      type = preseedType;
      default = {};
      description = "Preseed configuration for Incus initialization";
    };
    
    instances = mkOption {
      type = types.attrsOf instanceType;
      default = {};
      description = "Instances (VMs and containers) to configure and manage";
      example = literalExpression ''
        {
          ubuntu-container = {
            name = "ubuntu-container";
            type = "container";
            memory = "2GiB";
            cpus = 2;
            diskSize = "20GiB";
            image = "images:ubuntu/22.04";
            autostart = true;
            ipAddress = "10.18.10.50/24";
          };
          debian-vm = {
            name = "debian-vm";
            type = "vm";
            memory = "4GiB";
            cpus = 4;
            diskSize = "50GiB";
            image = "images:debian/12";
            autostart = true;
            ipAddress = "10.18.10.100/24";
            config = {
              "security.secureboot" = "false";
            };
          };
        }
      '';
    };
  };
      
      # 
  config = mkIf cfg.enable {
    # Enable Incus
    virtualisation.incus = {
      enable = true;
      # Enable UI if requested
      ui.enable = cfg.ui.enable;
      
      # Preseed configuration - this initializes Incus on first boot
      preseed = {
        config = optionalAttrs cfg.ui.enable {
          "core.https_address" = "${cfg.ui.host}:${toString cfg.ui.port}";
        };
        
        networks = [
          {
            name = cfg.preseed.networkBridge;
            type = "bridge";
            config = {
              "ipv4.address" = cfg.preseed.networkAddress;
              "ipv4.nat" = "true";
            } // optionalAttrs cfg.preseed.enableIPv6 {
              "ipv6.address" = cfg.preseed.networkIPv6Address;
              "ipv6.nat" = "true";
            };
          }
        ] ++ cfg.preseed.additionalNetworks;
        
        profiles = [
          {
            name = "default";
            devices = {
              eth0 = {
                name = "eth0";
                network = cfg.preseed.networkBridge;
                type = "nic";
              };
              root = {
                path = "/";
                pool = cfg.preseed.storagePool;
                type = "disk";
              };
            };
          }
        ] ++ cfg.preseed.additionalProfiles;
        
        storage_pools = [
          {
            name = cfg.preseed.storagePool;
            driver = cfg.preseed.storageDriver;
            config = optionalAttrs (cfg.preseed.storageDriver != "dir") {
              size = cfg.preseed.storageSize;
            };
          }
        ] ++ cfg.preseed.additionalStoragePools;
      };
    };

    # Add specified users to incus-admin group
    users.users = mkMerge (map (username: {
      ${username} = {
        extraGroups = [ "incus-admin" ];
      };
    }) cfg.users);

    # Install useful packages
    environment.systemPackages = with pkgs; [
      incus
    ];

    # Open firewall for Incus bridge
    networking.firewall.trustedInterfaces = [ cfg.preseed.networkBridge ];
    networking.nftables.enable = mkDefault true;

    # Systemd services for each instance
    systemd.services = mkMerge (mapAttrsToList (instanceName: instanceConfig:
      let
        incusCmd = "${pkgs.incus}/bin/incus";
        jqCmd = "${pkgs.jq}/bin/jq";
        
        # Build config string from attribute set
        configString = optionalString (instanceConfig.config != {}) 
          (concatMapStringsSep " " (key: "-c ${key}=${instanceConfig.config.${key}}") 
            (attrNames instanceConfig.config));
        
        # Build profiles string
        profilesString = concatMapStringsSep " " (profile: "-p ${profile}") instanceConfig.profiles;
        
        # VM-specific timeout (VMs take longer to start)
        timeout = if instanceConfig.type == "vm" then "10min" else "5min";
      in {
        "incus-instance-${instanceName}" = {
          description = "Incus ${toUpper instanceConfig.type}: ${instanceConfig.name}";
          after = [ "incus.service" ];
          requires = [ "incus.service" ];
          wantedBy = [ "multi-user.target" ];
          
          path = with pkgs; [ incus jq ];
          
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            TimeoutStartSec = timeout;
            TimeoutStopSec = "2min";
          };
          
          script = ''
            set -euo pipefail
            
            # Wait for Incus to be ready
            echo "[${instanceConfig.name}] Waiting for Incus daemon..."
            for i in {1..30}; do
              if ${incusCmd} info >/dev/null 2>&1; then
                echo "[${instanceConfig.name}] Incus daemon is ready"
                break
              fi
              if [ $i -eq 30 ]; then
                echo "[${instanceConfig.name}] ERROR: Incus daemon failed to start"
                exit 1
              fi
              sleep 2
            done
            
            # Check if instance exists
            if ! ${incusCmd} info ${instanceConfig.name} >/dev/null 2>&1; then
              echo "[${instanceConfig.name}] Creating ${instanceConfig.type} from image '${instanceConfig.image}'..."
              
              # Create instance
              ${incusCmd} init ${instanceConfig.image} ${instanceConfig.name} \
                --vm=${if instanceConfig.type == "vm" then "true" else "false"} \
                ${profilesString} \
                ${configString}
              
              echo "[${instanceConfig.name}] Configuring resources..."
              ${incusCmd} config set ${instanceConfig.name} limits.cpu ${toString instanceConfig.cpus}
              ${incusCmd} config set ${instanceConfig.name} limits.memory ${instanceConfig.memory}
              
              # Override root disk size
              ${incusCmd} config device override ${instanceConfig.name} root size=${instanceConfig.diskSize}
              
              ${optionalString (instanceConfig.type == "vm") ''
              # VM-specific configuration
              echo "[${instanceConfig.name}] Applying VM-specific settings..."
              ${incusCmd} config set ${instanceConfig.name} limits.memory.hugepages false || true
              ''}
              
              ${optionalString (instanceConfig.ipAddress != null) ''
              # Configure static IP address
              echo "[${instanceConfig.name}] Configuring static IP: ${instanceConfig.ipAddress}"
              ${incusCmd} config device override ${instanceConfig.name} eth0 ipv4.address=${instanceConfig.ipAddress}
              ''}
              
              echo "[${instanceConfig.name}] Instance created successfully"
            else
              echo "[${instanceConfig.name}] Instance already exists, updating configuration..."
              
              # Update resource limits
              ${incusCmd} config set ${instanceConfig.name} limits.cpu ${toString instanceConfig.cpus} || true
              ${incusCmd} config set ${instanceConfig.name} limits.memory ${instanceConfig.memory} || true
              
              # Apply additional config options
              ${concatMapStringsSep "\n" (key: 
                "${incusCmd} config set ${instanceConfig.name} ${key} ${instanceConfig.config.${key}} || true"
              ) (attrNames instanceConfig.config)}
              
              # Update static IP if specified
              ${optionalString (instanceConfig.ipAddress != null) ''
              echo "[${instanceConfig.name}] Updating static IP: ${instanceConfig.ipAddress}"
              ${incusCmd} config device override ${instanceConfig.name} eth0 ipv4.address=${instanceConfig.ipAddress} || true
              ''}
            fi
            
            # Configure autostart
            ${incusCmd} config set ${instanceConfig.name} boot.autostart ${if instanceConfig.autostart then "true" else "false"}
            
            # Start instance if autostart is enabled
            ${optionalString instanceConfig.autostart ''
            # Check if instance is running
            if ${incusCmd} list ${instanceConfig.name} -f json | ${jqCmd} -e '.[0].state.status == "Running"' >/dev/null 2>&1; then
              echo "[${instanceConfig.name}] Instance is already running"
            else
              echo "[${instanceConfig.name}] Starting instance..."
              ${incusCmd} start ${instanceConfig.name}
              
              # Wait for instance to start (especially important for VMs)
              ${optionalString (instanceConfig.type == "vm") ''
              echo "[${instanceConfig.name}] Waiting for VM to boot..."
              for i in {1..60}; do
                if ${incusCmd} list ${instanceConfig.name} -f json | ${jqCmd} -e '.[0].state.status == "Running"' >/dev/null 2>&1; then
                  echo "[${instanceConfig.name}] VM is running"
                  break
                fi
                sleep 2
              done
              ''}
              
              echo "[${instanceConfig.name}] Instance started successfully"
            fi
            ''}
          '';
          
          preStop = ''
            echo "[${instanceConfig.name}] Stopping instance..."
            
            # Check if instance exists and is running
            if ${incusCmd} info ${instanceConfig.name} >/dev/null 2>&1; then
              if ${incusCmd} list ${instanceConfig.name} -f json | ${jqCmd} -e '.[0].state.status == "Running"' >/dev/null 2>&1; then
                echo "[${instanceConfig.name}] Stopping gracefully..."
                ${incusCmd} stop ${instanceConfig.name} --timeout 30 || {
                  echo "[${instanceConfig.name}] Graceful stop failed, forcing stop..."
                  ${incusCmd} stop ${instanceConfig.name} --force || true
                }
              else
                echo "[${instanceConfig.name}] Instance is not running"
              fi
            else
              echo "[${instanceConfig.name}] Instance does not exist"
            fi
          '';
        };
      }
    ) cfg.instances);
  };
}
