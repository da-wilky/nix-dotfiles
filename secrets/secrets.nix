let
  # Users
  samuel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHpC8wD8E/BsQ7dLAjatwIzhvL0cR20rwtFauf0Oa1p";
  users = [ samuel ];

  # Systems
  blu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICaN+jZ5BDtdWRWlZMZdgnsKNCrw62LzD5T5MVZf+Lco";
  home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE13KcqVy6GOB/ZOFf9QoSP+jSFpRBJ2dE0jjXx/bdzv";
  systems = [ blu home ];
in
{
  "samuel.age".publicKeys = [ samuel ];
  "blu.age".publicKeys = [ blu ];
  "home.age".publicKeys = [ home ];
}
