{ pkgs }:
with pkgs; (
  stdenv.mkDerivation (finalAttrs: rec {
    pname = "modcheck";
    version = "3.0.2";

    src = fetchurl {
      url = "https://github.com/tildejustin/modcheck/releases/download/${version}/modcheck-${version}.jar";
      hash = "sha256-mbuP6ohGNPjKEE5FTZlG9QV8G76zqMR4EoZiYez+q2M=";
    };
    dontUnpack = true;

    nativeBuildInputs = [ makeWrapper ];

    buildPhase = "true";

    installPhase = ''
      install -m 644 -D $src "$out/share/modcheck/modcheck-${version}.jar"

      makeWrapper ${jre}/bin/java $out/bin/modcheck \
        --add-flags "-jar $out/share/modcheck/modcheck-${version}.jar"
    '';

    meta.sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
    ];
  })
)
