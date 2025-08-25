{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    pinned-graal-nixpkgs.url = "github:nixos/nixpkgs/5ed627539ac84809c78b2dd6d26a5cebeb5ae269";
  };

  outputs =
    { self, nixpkgs, pinned-graal-nixpkgs }:
    let
      packages = pkgs: rec {
        prismlauncher = (pkgs.prismlauncher.override { glfw3-minecraft = glfw-patched; });
        modcheck = (pkgs.callPackage ./packages/modcheck/default.nix { });
        ninjabrainbot = (pkgs.callPackage ./packages/ninjabrainbot/default.nix { });
        waywall = pkgs.waywall.overrideAttrs (finalAttrs: previousAttrs: {
          version = "0-unstable-2025-08-24";
          src = pkgs.fetchFromGitHub {
            owner = "tesselslate";
            repo = "waywall";
            rev = "ad569de1ddae6b034c7095795a42f044746a55a7";
            hash = "sha256-CzP6PFYC6yVxUAxkJ4Zhm4Zf4Qt8u4WjXUYfkgc6nyU=";
          };
          patches = [ ./0001-nvidia-fix.patch ];
        });
        glfw-patched = pkgs.glfw.overrideAttrs (finalAttrs: previousAttrs: {
          pname = "glfw-mcsr";
          patches = previousAttrs.patches ++ [
            (pkgs.fetchpatch
              {
                url = "https://raw.githubusercontent.com/tesselslate/waywall/be3e018bb5f7c25610da73cc320233a26dfce948/contrib/glfw.patch";
                sha256 = "sha256-8Sho5Yoj/FpV7utWz3aCXNvJKwwJ3ZA3qf1m2WNxm5M=";
              })
          ];
        });
      };
    in
    {
      packages."x86_64-linux" =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
        in
        (packages pkgs);
      homeModules.mcsr =
        { config
        , pkgs
        , ...
        }:
        {
          options.programs.mcsr = {
            enable = nixpkgs.lib.mkEnableOption "mcsr";

            waywall.config = nixpkgs.lib.mkOption {
              default = "";
              type = nixpkgs.lib.types.lines;
              description = ''
                Text of the config file.
              '';
            };
          };
          config = nixpkgs.lib.mkIf config.programs.mcsr.enable
            (
              let graalpkgs = import pinned-graal-nixpkgs { system = "x86_64-linux"; }; in {
                home.packages = with pkgs; [
                  # obs with hardware encoding on nvidia enabled
                  (obs-studio.override {
                    cudaSupport = true;
                  })
                  graalpkgs.graalvm-ce
                  # the presence of xwayland fixes performance issues when running waywall
                  xwayland
                ] ++ (pkgs.lib.attrsets.attrValues (packages pkgs));

                xdg.configFile."waywall/init.lua".text = config.programs.mcsr.waywall.config;
              }
            );
        };
    };
}
