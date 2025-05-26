{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    homeModules.niri = {
      config,
      pkgs,
      ...
    }: let cfg = config.programs.mcsr;
    in {
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
