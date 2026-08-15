{
  services.openssh = {
    enable = true;
    ports = [ 2022 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
    openFirewall = true;
  };

  users.users.ming.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImWd7VyOGb0/yFcBXeKFxDKd6YnoKjroJQvpabZdkOH openpgp@canokey"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgt/2h5OROlOs6L9+SCvSihiq5jcS5TqA+pgeDU9ma5 ming@136kf"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8Lh4/f3uEk8joZy9pH3NrRmk5rEsFAGJbr9l6BorOI openpgp@136kf"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvOQM+Ej9fOBgc5IqZaqgBb8/evDR9l4BwCt3dYHu2f openpgp@sgo3"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/IlYiZw4HKkHbg63NgRrRSmJ5I93yNjfF2hb21IeF2 openpgp@e2"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL9HtCAz25EdT3NhsRossJfyUcV3qq07FhcZpbF5dPhH openpgp@home-server"
  ];
}
