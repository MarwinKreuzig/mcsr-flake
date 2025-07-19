{ pkgs, stdenv, lib }:
stdenv.mkDerivation {
  pname = "waywall";
  version = "0-unstable-2025-07-14";

  patches = [
    # ./ninjabrainbot-hack.patch
  ];

  src = pkgs.fetchFromGitHub {
    owner = "tesselslate";
    repo = "waywall";
    rev = "90fafbe51e044738276688eb407913983044fccb";
    hash = "sha256-ZaHZCIrhcbwbfV7xKmOjyuH06PwvCKAL+mkm+7gmNBI=";
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = with pkgs; [
    libGL
    libspng
    libxkbcommon
    luajit
    wayland
    wayland-protocols
    xorg.libxcb
    xwayland
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 waywall/waywall -t $out/bin

    runHook postInstall
  '';

  meta = {
    description = "Wayland compositor for Minecraft speedrunning";
    longDescription = ''
      Waywall is a Wayland compositor that provides various convenient
      features (key rebinding, Ninjabrain Bot support, etc) for Minecraft
      speedrunning. It is designed to be nested within an existing Wayland
      session and is intended as a successor to resetti.
    '';
    homepage = "https://tesselslate.github.io/waywall/";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "waywall";
  };
}
