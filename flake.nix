{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    homeModules.mcsr =
      { config
      , pkgs
      , ...
      }:
      let glfw-patched = pkgs.glfw.overrideAttrs (finalAttrs: previousAttrs: {
          pname = "glfw-mcsr";
          patches = previousAttrs.patches ++ [
            (pkgs.fetchpatch
              {
                url = "https://raw.githubusercontent.com/tesselslate/waywall/be3e018bb5f7c25610da73cc320233a26dfce948/contrib/glfw.patch";
                sha256 = "sha256-8Sho5Yoj/FpV7utWz3aCXNvJKwwJ3ZA3qf1m2WNxm5M=";
              })
          ];
      });
      in {
        options.programs.mcsr = {
          enable = nixpkgs.lib.mkEnableOption "mcsr";
          
          waywall.config = {
            text = nixpkgs.lib.mkOption {
              default = null;
              type = nixpkgs.lib.types.nullOr nixpkgs.lib.types.lines;
              description = ''
                Text of the config file.
              '';
            };
            source = nixpkgs.lib.mkOption {
              type = nixpkgs.lib.types.path;
              description = ''
                Path of the source file of the config file. 
              '';
            };
          };
        };
        config = nixpkgs.lib.mkIf config.programs.mcsr.enable {
          home.packages = with pkgs; [
            obs-studio
            (prismlauncher.override { glfw3-minecraft = glfw-patched; })
            (callPackage ./packages/modcheck/default.nix { })
            (callPackage ./packages/ninjabrainbot/default.nix { })
            (callPackage ./packages/waywall/default.nix { })
            glfw-patched

            /*(waywall.overrideAttrs (finalAttrs: previousAttrs: {
                buildInputs = previousAttrs.buildInputs ++ [
                    # I thought these might somehow fix the ninjabrainbot issue but they don't ¯\_(ツ)_/¯
                    xorg.libXcomposite
                    xorg.libXres
                ];
                patches = (previousAttrs.patches or [ ]) ++ [
                    ./ninjabrainbot-hack.patch
                ];
            }))*/
            # runtime dependencies of waywall
            # this is definitely necessary, I tested it
            xwayland
            # The stuff below doesn't seem to make a difference but I include it anyway just in case
            # these are the compile time dependencies of the package (according to waywall docs all dependencies need to be present at compile and runtime)
            libGL
            libspng
            libxkbcommon
            luajit
            wayland
            wayland-protocols
            xorg.libxcb
            # these might be necessary based on the waywall docs
            xorg.libXcomposite
            xorg.libXres
          ];
        };
      };
  };
}
