{
  description = "A Nix-flake-based Astro development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

  outputs =
    { self, ... }@inputs:

    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [ inputs.self.overlays.default ];
            };
          }
        );

      scriptDir = ./scripts;
    in
    {
      overlays.default = final: prev: rec {
        nodejs = prev.nodejs;
        yarn = (prev.yarn.override { inherit nodejs; });
      };

      devShells = forEachSupportedSystem (
        { pkgs }:
        let
          mkScript =
            name: file:
            pkgs.writeShellApplication {
              inherit name;
              bashOptions = [
                "errexit"
                "pipefail"
              ];
              text = builtins.readFile file;
            };

          astro-init = mkScript "astro-init" (scriptDir + "/astro-init.sh");
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              nodejs
              nodePackages.pnpm
              yarn
              git
              astro-init
            ];

            shellHook = ''
              if [ -f package.json ] && [ ! -d node_modules ]; then
                echo "Installing dependencies..."
                npm install
                echo ""
              fi

              if [ -f astro.config.mjs ] || [ -f astro.config.ts ]; then
                echo "Astro: npm run dev | build | preview"
                echo "Lint: npm run lint | format"
              else
                echo "Run: astro-init"
              fi
            '';
          };
        }
      );
    };
}
