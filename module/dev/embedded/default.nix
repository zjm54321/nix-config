{
  pkgs,
  vars,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.dev.probe-rs;
  probe-rs-udev-rules = pkgs.writeTextFile {
    name = "69-probe-rs.rules";
    text = builtins.readFile ./69-probe-rs.rules;
    destination = "/etc/udev/rules.d/69-probe-rs.rules";
  };
in
{
  options.dev.probe-rs.enable = mkEnableOption "启用 probe-rs 嵌入式开发工具";

  config = mkIf cfg.enable {
    users.groups.plugdev = { };
    users.users.${vars.username}.extraGroups = [ "plugdev" ];

    services.udev.packages = [ probe-rs-udev-rules ];
  };
}
