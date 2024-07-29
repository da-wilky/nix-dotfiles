let
  # Users
  samuel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAWEue89TqiVnWtTnBka40kV9md2ImfV2cpVgR/kgUS";
  users = [ samuel ];

  # Systems
  blu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICaN+jZ5BDtdWRWlZMZdgnsKNCrw62LzD5T5MVZf+Lco";
  home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE13KcqVy6GOB/ZOFf9QoSP+jSFpRBJ2dE0jjXx/bdzv";
  pibackups = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ55y5rKMDqYQThu6uoVGicHpnFT6d3Cm/fGu4LWFDSJ";
  systems = [ blu home pibackups ];
in
{
  "samuel-ssh.age".publicKeys = [ samuel ] ++ systems;
  "dd-wlan.age".publicKeys = [ samuel pibackups ];
}
