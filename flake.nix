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
          xdg.configFile."waywall/init.lua".text = config.programs.mcsr.waywall.config.text;
          xdg.configFile."waywall/init.lua".source = config.programs.mcsr.waywall.config.source;

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
