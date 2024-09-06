{
  fetchSteam,
  lib,
  makeWrapper,
  stdenvNoCC,
  xdg-user-dirs,
}:
let
  binPath = lib.makeBinPath [ xdg-user-dirs ];
in
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "satisfactory-server";
  version = "0.218.21";

  src = fetchSteam {
    inherit (finalAttrs) name;
    appId = "1690800";
    depotId = "1690802";
    manifestId = "3834057001613892701";
    hash = "sha256-LHE64JBPCG92agi6Q9w378UEsU/S05A0AoQWXM+IcSs=";
  };

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share $out/bin

    cp -r . $out/share/satisfactory-server
    chmod +x $out/share/satisfactory-server/Engine/Binaries/Linux/UnrealServer-Linux-Shipping

    makeWrapper \
      $out/share/satisfactory-server/Engine/Binaries/Linux/UnrealServer-Linux-Shipping \
      $out/bin/satisfactory-server \
      --add-flags "FactoryGame" \
      --prefix PATH : ${binPath}

    runHook postInstall
  '';

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
