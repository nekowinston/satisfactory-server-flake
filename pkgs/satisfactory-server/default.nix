{
  buildFHSEnv,
  fetchSteam,
  lib,
  makeWrapper,
  pulseaudio,
  stdenvNoCC,
  steamworks-sdk-redist,
  xdg-user-dirs,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "satisfactory-server";
  version = "20744297";

  binPath = lib.makeBinPath [ xdg-user-dirs ];

  # https://steamdb.info/depot/1690802/history/
  src = fetchSteam {
    inherit (finalAttrs) name;
    appId = "1690800";
    depotId = "1690802";
    manifestId = "3567604107698424381";
    hash = "sha256-cIQFieQOz/Gh7VDAv2pS6FSE+ALqdMBl8iZkEMdPewA=";
  };

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share $out/bin

    cp -r . $out/share/satisfactory-server
    chmod +x $out/share/satisfactory-server/Engine/Binaries/Linux/FactoryServer-Linux-Shipping

    makeWrapper \
      $out/share/satisfactory-server/Engine/Binaries/Linux/FactoryServer-Linux-Shipping \
      $out/bin/satisfactory-server \
      --add-flags "FactoryGame" \
      --prefix PATH : ${finalAttrs.binPath}

    runHook postInstall
  '';

  passthru.fhs = buildFHSEnv {
    inherit (finalAttrs) name meta;
    runScript = lib.getExe finalAttrs.finalPackage;

    targetPkgs = pkgs: [
      finalAttrs.finalPackage
      pulseaudio
      steamworks-sdk-redist
    ];
  };

  meta = {
    mainProgram = "satisfactory-server";
    description = "Satisfactory dedicated server";
    homepage = "https://steamdb.info/app/1690800/";
    changelog = "https://store.steampowered.com/news/app/526870?updates=true";
    sourceProvenance = [
      lib.sourceTypes.binaryBytecode
      lib.sourceTypes.binaryNativeCode
    ];
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
})
