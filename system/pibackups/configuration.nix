# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      #<nixos-hardware/raspberry-pi/4>
      ./hardware-configuration.nix
      ./program.nix
      ../configuration.nix
      ../program.nix
    ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.grub.zfsSupport = true;
  boot.kernelParams = [
    "cgroup_enable=cpuset"
    "cgroup_enable=memory"
    "cgroup_memory=1"
  ];
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  programs.zsh.shellAliases = {
    nixupdate = "sudo nixos-rebuild switch --flake ~/dotfiles/#pibackups";
    nixeditc = "nvim ~/dotfiles/system/pibackups/configuration.nix";
    nixeditp = "nvim ~/dotfiles/system/pibackups/program.nix";
    poweroff = "reboot";
  };

  sops.secrets.wireless-config-dd = {
    sopsFile = ../../secrets/dd-wireless.yml;
    restartUnits = [ "wpa_supplicant-wlan0.service" ]; 
  };

  networking = {
    hostId = "0c5f8584"; # Needed for zfs
    hostName = "pibackups"; # Define your hostname.
    # Pick only one of the below networking options.
    wireless = {
      enable = true;  # Enables wireless support via wpa_supplicant.
      interfaces = [ "wlan0" ];
      secretsFile = config.sops.secrets.wireless-config-dd.path;
      networks."FRITZiBox 7590".pskRaw = "ext:home_psk";
    };
    #networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    
    # Open ports in the firewall.
    firewall.allowedTCPPorts = [ 22 ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # firewall.enable = false;
  };

  # Samba (drive shares)
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
	security = "user";
	"invalid users" = [
	  "root"
	];

	"hosts allow" = "192.168.0.0/16 100.85.0.0/16 127.0.0.1 localhost";
	"hosts deny" = "0.0.0.0/0";
	"guest ok" = "no";
      };

      NetworkShared = {
	"path" = "/data/backups/NetworkShared";
	"browsable" = "yes";
	"read only" = "no";
	"create mask" = "0644";
	"directory mask" = "0755";
      };
    };
  };

  # So Windows machines can detect it
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  sops.secrets.backup-password-pibackups = {
    sopsFile = ../../secrets.yml;
  };

  services.restic.backups = {
    backup = {
      initialize = true;
      user = "root";
      paths = [
	"/home/samuel"
	"/var/lib/docker/volumes/immich_model-cache"
      ];
      exclude = [
	"/home/*/.cache"
	"/home/*/.zsh_history"
      ];
      repository = "/data/backups/pibackups";
      passwordFile = config.sops.secrets.backup-password-pibackups.path;
      pruneOpts = [
	"--keep-within-hourly 3d"
	"--keep-within-daily 14d"
	"--keep-within-weekly 1m"
	"--keep-within-monthly 1y"
      ];
      timerConfig = {
	# On 6 o'clock
	#OnCalendar = "*-*-* 06:20:00";
	OnCalendar = "*-*-* 00:37:00";
	# Reschedule times missed cuz of downtime
	Persistent = true;
      };
    };
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  security.sudo.wheelNeedsPassword = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

