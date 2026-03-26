{
  description = "Ready-made templates for easily creating flake-driven environments";

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
            inherit system;
            pkgs = import inputs.nixpkgs { inherit system; };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs, system }:
        {
          default =
            let
              getSystem = "SYSTEM=$(nix eval --impure --raw --expr 'builtins.currentSystem')";
              forEachDir = exec: ''
                for dir in */; do
                  # Skip result symlinks from previous builds
                  if [ "''${dir}" = "result/" ] || [ "''${dir}" = "result" ]; then
                    continue
                  fi
                  (
                    cd "''${dir}"

                    ${exec}
                  )
                done
              '';

              script =
                name: runtimeInputs: text:
                pkgs.writeShellApplication {
                  inherit name runtimeInputs text;
                  bashOptions = [
                    "errexit"
                    "pipefail"
                  ];
                };
            in
            pkgs.mkShellNoCC {
              packages =
                with pkgs;
                [
                  (script "build" [ ] ''
                    ${getSystem}

                    ${forEachDir ''
                      echo "building ''${dir}"
                      nix build ".#devShells.''${SYSTEM}.default"
                    ''}
                  '')
                  (script "check" [ nixfmt ] (forEachDir ''
                    echo "checking ''${dir}"
                    nix flake check --all-systems --no-build
                  ''))
                  (script "format" [ nixfmt ] ''
                    git ls-files '*.nix' | xargs nix fmt
                  '')
                  (script "check-formatting" [ nixfmt ] ''
                    git ls-files '*.nix' | xargs nixfmt --check
                  '')
                ]
                ++ [ self.formatter.${system} ];
            };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);

      packages = forEachSupportedSystem (
        { pkgs, ... }:
        rec {
          default = dvt;
          dvt = pkgs.writeShellApplication {
            name = "dvt";
            bashOptions = [
              "errexit"
              "pipefail"
            ];
            text = ''
              if [ -z "''${1}" ]; then
                echo "no template specified"
                exit 1
              fi

              TEMPLATE=$1

              nix \
                --experimental-features 'nix-command flakes' \
                flake init \
                --template \
                "https://flakehub.com/f/the-nix-way/dev-templates/0.1#''${TEMPLATE}"
            '';
          };
        }
      );
    }

    //

      {
        templates = rec {
          default = empty;

          astro = {
            path = ./astro;
            description = "Astro development environment";
          };

          bun = {
            path = ./bun;
            description = "Bun development environment";
          };

          elixir = {
            path = ./elixir;
            description = "Elixir development environment";
          };

          empty = {
            path = ./empty;
            description = "Empty dev template that you can customize at will";
          };

          go = {
            path = ./go;
            description = "Go (Golang) development environment";
          };

          jupyter = {
            path = ./jupyter;
            description = "Jupyter development environment";
          };

          nix = {
            path = ./nix;
            description = "Nix development environment";
          };

          node = {
            path = ./node;
            description = "Node.js development environment";
          };

          protobuf = {
            path = ./protobuf;
            description = "Protobuf development environment";
          };

          python = {
            path = ./python;
            description = "Python development environment";
          };

          ruby = {
            path = ./ruby;
            description = "Ruby development environment";
          };

          rust = {
            path = ./rust;
            description = "Rust development environment";
          };

          shell = {
            path = ./shell;
            description = "Shell script development environment";
          };

          swi-prolog = {
            path = ./swi-prolog;
            description = "Swi-prolog development environment";
          };

          zig = {
            path = ./zig;
            description = "Zig development environment";
          };
        };
      };
}
