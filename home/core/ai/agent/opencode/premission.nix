{
  external_directory = {
    "*" = "ask";
    "/etc/nixos/**" = "allow";
    "/nix/store/**" = "allow";
    "/tmp/**" = "allow";
  };
}
