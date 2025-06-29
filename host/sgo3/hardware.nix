{
  pkgs,
  ...
}:
{
  # Intel UHD Graphics 615
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-ocl
      vpl-gpu-rt
      libvdpau-va-gl
    ];
  };
  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
    ANV_DEBUG = "video-decode,video-encode";
  };
}
