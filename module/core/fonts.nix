{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      source-han-sans
      source-han-serif
      maple-mono.NF-CN
      noto-fonts-color-emoji
    ];

    fontconfig.defaultFonts = {
      serif = [
        "Source Han Serif SC"
        "Source Han Serif TC"
        "Noto Color Emoji"
      ];
      sansSerif = [
        "Source Han Sans SC"
        "Source Han Sans TC"
        "Noto Color Emoji"
      ];
      monospace = [
        "Maple Mono NF CN"
        "Noto Color Emoji"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
