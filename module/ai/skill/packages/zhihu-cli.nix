{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "zhihu-cli";
  version = "0.6.1";

  src = fetchurl {
    url = "https://developer-cdn.zhihu.com/zhihu-cli/releases/stable/cli/${version}/zhihu-cli-${version}-linux-amd64.tar.gz";
    hash = "sha256-ZdjX5r+WyZkJWDW1QMnXSfJKPDfB00IXoj6CXuLq43Y=";
  };

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  # The official linux-amd64 artifact is a stripped, statically linked ELF.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 zhihu-cli "$out/bin/zhihu-cli"
    runHook postInstall
  '';

  meta = {
    description = "Official Zhihu command-line client";
    homepage = "https://open.zhihu.com/";
    platforms = [ "x86_64-linux" ];
    mainProgram = "zhihu-cli";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
