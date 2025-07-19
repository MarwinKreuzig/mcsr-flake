{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    pinned-graal-nixpkgs.url = "github:nixos/nixpkgs/5ed627539ac84809c78b2dd6d26a5cebeb5ae269";
  };

  outputs = { self, nixpkgs, pinned-graal-nixpkgs }:
    {
      packages."x86_64-linux" =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
        in
        rec {
          prismlauncher = (pkgs.prismlauncher.override { glfw3-minecraft = glfw-patched; });
          modcheck = (pkgs.callPackage ./packages/modcheck/default.nix { });
          ninjabrainbot = (pkgs.callPackage ./packages/ninjabrainbot/default.nix { });
          waywall = (pkgs.callPackage ./packages/waywall/default.nix { });
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
      homeModules.mcsr =
        { config
        , pkgs
        , ...
        }:
        let
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
        in
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
                  (prismlauncher.override { glfw3-minecraft = glfw-patched; })
                  graalpkgs.graalvm-ce
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
                  # the presence of xwayland fixes performance issues when running waywall
                  xwayland
                ];

                xdg.configFile."waywall/init.lua".text = config.programs.mcsr.waywall.config;
              }
            );
        };
    };
}
