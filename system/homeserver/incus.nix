{ config, lib, pkgs, inputs, ... }:

let
  # Configuration variables - change these to customize your setup
  hostExternalInterface = "enp2s0"; # Host's internet-facing interface

  # SSH authorized keys for VM root access
  sshAuthorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAWEue89TqiVnWtTnBka40kV9md2ImfV2cpVgR/kgUS samuel@nixos"
  ];

  # Incus network configuration
  incusNetwork = {
    subnet = "10.18.18";
    gatewayIp = "${incusNetwork.subnet}.1";
    bridgeName = "incusbr0";
  };

  # VM defaults
  vmDefaults = {
    memory = "8GiB";
    cpus = 6;
    diskSize = "100GiB";
    image = "images:kali/cloud";
  };

  cloudInit = ''
    #cloud-config
    package_update: true
    packages:
      - openssh-server

    users:
      - name: samuel
        gecos: Samuel
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:${
          lib.concatMapStrings (key: "\n      - ${key}") sshAuthorizedKeys
        }

    runcmd:
      - systemctl enable ssh || systemctl enable sshd
      - systemctl restart ssh || systemctl restart sshd
  '';
in {
  # Enable Incus directly on the host
  myModules.incus = {
    enable = true;
    ui.enable = false;
    users = [ "samuel" ];

    preseed = {
      storagePool = "default";
      storageDriver = "dir";
      networkBridge = incusNetwork.bridgeName;
      networkAddress = "${incusNetwork.gatewayIp}/24";

      # Optional: Add custom storage pools with specific paths
      additionalStoragePools = [
        {
          name = "second-storage";
          driver = "dir";
          config = {
            source = "/data/incus/storage"; # Custom path for VM storage
          };
        }
      ];
    };

    # Define the Kali Linux container
    instances = {
      "kali" = {
        name = "kali";
        type = "lxc";
        memory = vmDefaults.memory;
        cpus = vmDefaults.cpus;
        diskSize = vmDefaults.diskSize;
        image = vmDefaults.image;
        autostart = false;
        ipAddress = "${incusNetwork.subnet}.10";
        diskPool = "second-storage";
        config = { "cloud-init.user-data" = cloudInit; };
      };
    };
  };

  # Kernel modules needed for incus VMs (usually auto-loaded, but explicitly loading ensures availability)
  # boot.kernelModules = [ "vhost_vsock" "vhost_net" "vhost" ];

  # Enable IP forwarding on the host (REQUIRED for NAT/internet access)
  # boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  # NAT for Incus network
  networking.nat = {
    enable = true;
    internalInterfaces = [ incusNetwork.bridgeName ];
    externalInterface = hostExternalInterface;
  };

  # Allow traffic on the Incus bridge
  networking.firewall.trustedInterfaces = [ incusNetwork.bridgeName ];

  # Basic packages including incus CLI tools
  # environment.systemPackages = with pkgs; [ incus htop vim curl wget ];
}
