{
  buildFHSEnv,
  fetchSteam,
  lib,
  makeWrapper,
  stdenvNoCC,
  steamworks-sdk-redist,
  xdg-user-dirs,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "satisfactory-server";
  version = "23855705";

  binPath = lib.makeBinPath [ xdg-user-dirs ];

  # https://steamdb.info/depot/1690802/history/
  src = fetchSteam {
    inherit (finalAttrs) name;
    appId = "1690800";
    depotId = "1690802";
    manifestId = "2689605844763498299";
    hash = "sha256-rE18FQWY36S4qy7A96zn/7mk6LUcRYb2hyF+l54CZeo=";
  };

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt}
    cp -r . $out/opt/satisfactory-server
    chmod +x $out/opt/satisfactory-server/Engine/Binaries/Linux/FactoryServer-Linux-Shipping

    makeWrapper \
      $out/opt/satisfactory-server/Engine/Binaries/Linux/FactoryServer-Linux-Shipping \
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
