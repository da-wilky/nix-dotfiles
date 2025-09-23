# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  boot = {
    supportedFilesystems = ["zfs"];
    #kernelParams = ["boot=zfs"];
    zfs.extraPools = [ "wdred" ];
    kernelParams = [
      # To capture memory consumption per docker container (beszel)
      "cgroup_enable=cpuset"
      "cgroup_enable=memory"
      "cgroup_memory=1"
    ];
    consoleLogLevel = 4;
  };


  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-uuid/31A5-2B40";
      fsType = "vfat";
      options = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
    "/" = {
      device = "nvme/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
  };
}

