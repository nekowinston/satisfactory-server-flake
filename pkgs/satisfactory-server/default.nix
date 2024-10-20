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
let
  binPath = lib.makeBinPath [ xdg-user-dirs ];
in
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "satisfactory-server";
  version = "16048690";

  src = fetchSteam {
    inherit (finalAttrs) name;
    appId = "1690800";
    depotId = "1690802";
    manifestId = "6191700643051320774";
    hash = "sha256-DDDxYkqgl7H6upTCCrRQMCFla+I8YP4VVj21O6src7A=";
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
      --prefix PATH : ${binPath}

    runHook postInstall
  '';

  passthru.fhs = buildFHSEnv {
    name = finalAttrs.name;
    runScript = lib.getExe finalAttrs.finalPackage;

    targetPkgs = pkgs: [
      finalAttrs.finalPackage
      pulseaudio
      steamworks-sdk-redist
    ];

    meta = finalAttrs.meta;
  };

  meta = with lib; {
    mainProgram = "satisfactory-server";
    description = "Satisfactory dedicated server";
    homepage = "https://steamdb.info/app/1690800/";
    changelog = "https://store.steampowered.com/news/app/526870?updates=true";
    sourceProvenance = with sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
})
