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
      let glfw-patched = (pkgs.callPackage ./packages/glfw-patched/default.nix { });
      in {
        options = {
          programs.mcsr.enable = nixpkgs.lib.mkEnableOption "mcsr";
        };
        config = nixpkgs.lib.mkIf config.programs.mcsr.enable {
          xdg.configFile."waywall/init.lua".text= ''
            local waywall = require("waywall")
            local helpers = require("waywall.helpers")

            local config = {
                input = {
                    layout = "us",
                    repeat_rate = 40,
                    repeat_delay = 300,

                    sensitivity = 1.0,
                    confine_pointer = false,
                },
                theme = {
                    background = "#303030ff",
                },
            }

            config.actions = {}

            return config
          '';

          home.packages = with pkgs; [
            obs-studio
            (prismlauncher.override { glfw3-minecraft = glfw-patched; })
            waywall
            (callPackage ./packages/modcheck/default.nix { })
            (callPackage ./packages/ninjabrainbot/default.nix { })
            glfw-patched
          ];
        };
      };
  };
}
