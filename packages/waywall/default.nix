{ pkgs, stdenv, lib }:
stdenv.mkDerivation {
  pname = "waywall";
  version = "0-unstable-2025-07-14";

  patches = [
    ./ninjabrainbot-hack.patch
  ];

  src = pkgs.fetchFromGitHub {
    owner = "tesselslate";
    repo = "waywall";
    rev = "16607ea6ad34e62b19d3b8ce1d2fdda5a39d41ec";
    hash = "sha256-1ZlyhacDm/8qyBPvpuqQKnSg+9qx78chUK+hH7+ahIY=";
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
    # these are experiments
    mesa
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
