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
      let cfg = config.programs.mcsr;
      in {
        options = {
          programs.mcsr.enable = nixpkgs.lib.mkEnableOption "mcsr";
        };
        config = nixpkgs.lib.mkIf cfg.enable {
          home.packages = with pkgs; [
            obs-studio
            prismlauncher
            waywall
            (callPackage ./packages/modcheck/default.nix { })
            (callPackage ./packages/ninjabrainbot/default.nix { })
            (callPackage ./packages/glfw-patched/default.nix { })
          ];
        };
      };
  };
}
