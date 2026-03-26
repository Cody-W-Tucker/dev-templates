# AGENTS.md - Development Guide for dev-templates

This document provides guidance for AI agents working on the Nix flake templates repository.

## Repository Overview

This repository contains ready-made Nix flake templates for development environments. Each template lives in its own directory (e.g., `rust/`, `python/`, `go/`) with a `flake.nix` file defining the dev shell.

## Build, Lint, and Test Commands

### Enter the Development Environment

```bash
nix develop
# OR if you have direnv:
direnv allow
```

### Available Commands (within nix develop)

| Command | Description |
|---------|-------------|
| `build` | Build all template dev shells (`devShells.${SYSTEM}.default` for each template) |
| `check` | Run `nix flake check --all-systems --no-build` on all templates |
| `format` | Format all `*.nix` files using nixfmt |
| `check-formatting` | Verify all nix files are properly formatted |

`nix flake update` needs to be ran if nixpkgs version in flake.lock is over 30 days old/

### Testing a Single Template

To build/test a specific template:

```bash
cd <template-name>/  # e.g., cd rust/
nix build ".#devShells.${SYSTEM}.default"
# Or just:
nix develop  # to enter the shell directly
```

Replace `${SYSTEM}` with your system (e.g., `x86_64-linux`).

### Checking All Templates

```bash
nix develop
check
```

## Code Style Guidelines

### Nix Code Formatting

- **Formatter**: Use `nixfmt` (standard Nix formatter)
- **Indentation**: 2 spaces (no tabs)
- **Line endings**: LF only
- **Charset**: UTF-8
- **Trailing whitespace**: Trimmed
- **Final newline**: Always insert final newline

These are enforced by `.editorconfig`.

### Nix File Structure Pattern

All template `flake.nix` files should follow this structure:

```nix
{
  description = "A Nix-flake-based {Language} development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

  outputs = { self, ... }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem = f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (system:
          f {
            pkgs = import inputs.nixpkgs { inherit system; };
          });
    in {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [ /* packages here */ ];
        };
      });
    };
}
```

### Naming Conventions

- **Template directories**: lowercase, hyphenated (e.g., `ruby-on-rails/`, `swi-prolog/`)
- **Description format**: "A Nix-flake-based {Language} development environment"
- **Variables**: camelCase for local variables (e.g., `forEachSupportedSystem`)
- **System attributes**: verbatim from supportedSystems list

### Input Sources

- Default nixpkgs: `https://flakehub.com/f/NixOS/nixpkgs/0.1`
- For special tooling (like Rust's fenix), follow the pattern in `rust/flake.nix`

### Adding a New Template

1. Create directory with `flake.nix` following the standard pattern
2. Add entry to root `flake.nix` in the `templates` attrset:
   ```nix
   mylang = {
     path = ./mylang;
     description = "MyLang development environment";
   };
   ```
3. Update `README.md` table and description section
4. Run `check` and `build` to verify

### Comment Style

- Use `/* */` for block comments explaining configuration sections
- Use `#` for line comments within `mkShell` or package lists
- Comments should explain "why", not "what"

### Error Handling

- Use `writeShellApplication` with `bashOptions = [ "errexit" "pipefail" ]` for scripts
- Scripts should fail fast on errors

### Git Conventions

- No `.lock` files in templates (except root `flake.lock`)
- Templates should not commit `result` symlinks
- `.direnv/` directories are gitignored

## Pre-commit Checklist

Before submitting changes:

1. Run `format` to ensure proper formatting
2. Run `check-formatting` to verify
3. Run `check` to validate all flakes
4. Run `build` to ensure all templates build successfully
5. Verify the template you're modifying works: `cd <template>/ && nix develop`

## Template-Specific Notes

- **python**: Uses virtual environment with version pinning (see `version` variable)
- **ruby-on-rails**: Uses ruby-nix for gem management; requires `gemset.nix` for gems
- **rust**: Uses fenix for Rust toolchain; supports `rust-toolchain.toml` overrides
- **node**: Includes npm, pnpm, yarn, and node2nix

## Resources

- [NixOS/nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/)
- [FlakeHub](https://flakehub.com) - for input sources
- [nixfmt](https://github.com/serokell/nixfmt) - code formatter
