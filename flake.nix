{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    glfw-patched = (nixpkgs.callPackage ./packages/glfw-patched/default.nix { });
    overlay = (final: prev: {
      prismlauncher = (prev.prismlauncher.override { glfw-minecraft = glfw-patched; });
    }); in {
    overlays.default = overlay;
    homeModules.mcsr =
      { config
      , pkgs
      , ...
      }:
      {
        options = {
          programs.mcsr.enable = nixpkgs.lib.mkEnableOption "mcsr";
        };
        config = nixpkgs.lib.mkIf config.programs.mcsr.enable {
          nixpkgs.overlays = [ overlay ];
          home.packages = with pkgs; [
            obs-studio
            prismlauncher
            waywall
            (callPackage ./packages/modcheck/default.nix { })
            (callPackage ./packages/ninjabrainbot/default.nix { })
            glfw-patched
          ];
        };
      };
  };
}
