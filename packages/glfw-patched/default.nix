{ pkgs, lib }:
(
  let
    version = "3.4";
  in
  pkgs.stdenv.mkDerivation {
    pname = "glfw-mcsr";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "glfw";
      repo = "GLFW";
      rev = version;
      hash = "sha256-FcnQPDeNHgov1Z07gjFze0VMz2diOrpbKZCsI96ngz0=";
    };

    # Fix linkage issues on X11 (https://github.com/NixOS/nixpkgs/issues/142583)
    patches =
      [
        # ./x11.patch
        # TODO: include the minecraft patch
        pkgs.stdenv.fetchpatch
        {
          url = "https://raw.githubusercontent.com/tesselslate/waywall/be3e018bb5f7c25610da73cc320233a26dfce948/contrib/glfw.patch";
          hash = "";
        }
      ];

    propagatedBuildInputs = lib.optionals (!pkgs.stdenv.hostPlatform.isWindows) [ pkgs.libGL ];

    nativeBuildInputs =
      [
        pkgs.cmake
        pkgs.pkg-config
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.fixDarwinDylibNames ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.wayland-scanner ];

    buildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
      wayland
      wayland-protocols
      libxkbcommon
      xorg.libX11
      xorg.libXrandr
      xorg.libXinerama
      xorg.libXcursor
      xorg.libXi
      xorg.libXext
      xorg.libXxf86vm
    ]);

    postPatch = lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
      substituteInPlace src/wl_init.c \
        --replace-fail '"libdecor-0.so.0"' '"${lib.getLib pkgs.libdecor}/lib/libdecor-0.so.0"' \
        --replace-fail '"libwayland-client.so.0"' '"${lib.getLib pkgs.wayland}/lib/libwayland-client.so.0"' \
        --replace-fail '"libwayland-cursor.so.0"' '"${lib.getLib pkgs.wayland}/lib/libwayland-cursor.so.0"' \
        --replace-fail '"libwayland-egl.so.1"' '"${lib.getLib pkgs.wayland}/lib/libwayland-egl.so.1"' \
        --replace-fail '"libxkbcommon.so.0"' '"${lib.getLib pkgs.libxkbcommon}/lib/libxkbcommon.so.0"'
    '';

    cmakeFlags = [
      # Static linking isn't supported
      (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    ];

    env = lib.optionalAttrs (!pkgs.stdenv.hostPlatform.isDarwin && !pkgs.stdenv.hostPlatform.isWindows) {
      NIX_CFLAGS_COMPILE = toString [
        "-D_GLFW_GLX_LIBRARY=\"${lib.getLib pkgs.libGL}/lib/libGLX.so.0\""
        "-D_GLFW_EGL_LIBRARY=\"${lib.getLib pkgs.libGL}/lib/libEGL.so.1\""
        "-D_GLFW_OPENGL_LIBRARY=\"${lib.getLib pkgs.libGL}/lib/libGL.so.1\""
        "-D_GLFW_GLESV1_LIBRARY=\"${lib.getLib pkgs.libGL}/lib/libGLESv1_CM.so.1\""
        "-D_GLFW_GLESV2_LIBRARY=\"${lib.getLib pkgs.libGL}/lib/libGLESv2.so.2\""
        "-D_GLFW_VULKAN_LIBRARY=\"${lib.getLib pkgs.vulkan-loader}/lib/libvulkan.so.1\""
        # This currently omits _GLFW_OSMESA_LIBRARY. Is it even used?
      ];
    };

    strictDeps = true;
    __structuredAttrs = true;

    meta = {
      description = "Multi-platform library for creating OpenGL contexts and managing input, including keyboard, mouse, joystick and time";
      homepage = "https://www.glfw.org/";
      license = lib.licenses.zlib;
      platforms = lib.platforms.unix ++ lib.platforms.windows;
    };
  }
)
