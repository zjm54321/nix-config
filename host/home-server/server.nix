{
  # 启用 harmonia binary cache 服务
  # server.nix-binary-cache.harmonia.enable = true;
  # 从不同的物理位置提供 nix store 服务
  # server.nix-binary-cache.harmonia.path = "/data";
  # 启用 qBittorrent 服务
  services.qbittorrent.enable = true;
  # 使用 podman 容器启用 Home Assistant
  services.hass.enable = true;
  # 启用 samba
  services.samba.enable = true;
  services.samba.settings."public".path = "/data";
  services.samba-wsdd.enable = true;
  # 启用 webdav 服务
  services.webdav.enable = true;
  services.webdav.settings.directory = "/data/webdav";
}
