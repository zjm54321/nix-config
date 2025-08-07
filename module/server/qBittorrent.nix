{
  pkgs,
  config,
  ...
}:
{
  services.qbittorrent = {
    package = pkgs.qbittorrent-enhanced-nox;
    openFirewall = if config.services.qbittorrent.enable then true else false;
  };
}
