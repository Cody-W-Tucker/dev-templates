# Nix flake templates for easy dev environments

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

To initialize (where `${ENV}` is listed in the table below):

```shell
nix flake init --template "https://flakehub.com/f/the-nix-way/dev-templates/*#${ENV}"
```

Here's an example (for the [`rust`](./rust) template):

```shell
# Initialize in the current project
nix flake init --template "https://flakehub.com/f/Cody-W-Tucker/dev-templates/*#rust"

# Create a new project
nix flake new --template "https://flakehub.com/f/Cody-W-Tucker/dev-templates/*#rust" ${NEW_PROJECT_DIRECTORY}
```

## How to use the templates

Once your preferred template has been initialized, you can use the provided shell in two ways:

1. If you have [`nix-direnv`][nix-direnv] installed, you can initialize the environment by running `direnv allow`.
2. If you don't have `nix-direnv` installed, you can run `nix develop` to open up the Nix-defined shell.

## Available templates

| Language/framework/tool | Template                      |
| :---------------------- | :---------------------------- |
| [Bun]                   | [`bun`](./bun/)               |
| Empty (change at will)  | [`empty`](./empty)            |
| [Go]                    | [`go`](./go/)                 |
| [Jupyter]               | [`jupyter`](./jupyter/)       |
| [Nix]                   | [`nix`](./nix/)               |
| [Node.js][node]         | [`node`](./node/)             |
| [Protobuf]              | [`protobuf`](./protobuf/)     |
| [Python]                | [`python`](./python/)         |
| [Ruby]                  | [`ruby`](./ruby/)             |
| [Ruby on Rails]         | [`ruby-on-rails`](./ruby-on-rails/) |
| [Rust]                  | [`rust`](./rust/)             |
| Shell                   | [`shell`](./shell/)           |
| [SWI-prolog]            | [`swi-prolog`](./swi-prolog/) |
| [Zig]                   | [`zig`](./zig/)               |

## Template contents

The sections below list what each template includes. In all cases, you're free to add and remove packages as you see fit; the templates are just boilerplate.

### [`bun`](./bun/)

- [bun]

### [Empty](./empty/)

A dev template that's fully customizable.

### [`go`](./go/)

- [Go]
- Standard Go tools ([goimports], [godoc], and others)
- [golangci-lint]

### [`jupyter`](./jupyter/)

- [Jupyter core][jupyter]

### [`nix`](./nix/)

- [Cachix]
- [dhall-to-nix]
- [lorri]
- [niv]
- [nixfmt]
- [statix]
- [vulnix]

### [`node`](./node/)

- [Node.js][node]
- [npm]
- [pnpm]
- [Yarn]
- [node2nix]

### [`protobuf`](./protobuf/)

- The [Buf CLI][buf]
- [protoc][protobuf]

### [`python`](./python/)

- [Python]
- [pip]

### [`ruby`](./ruby/)

- [Ruby], plus the standard Ruby tools (`bundle`, `gem`, etc.)

### [`ruby-on-rails`](./ruby-on-rails/)

- [Ruby on Rails] with reproducible gem management via [ruby-nix]
- Ruby 3.3.1 (configurable via [nixpkgs-ruby])
- [bundix] - tool to generate `gemset.nix` from `Gemfile.lock`
- [yarn]
- [rufo] (Ruby formatter)

### [`rust`](./rust/)

- [Rust], including [cargo], [Clippy], and the other standard tools. The Rust version is determined as follows, in order:
  - From the `rust-toolchain.toml` file if present
  - From the `rust-toolchain` file if present
  - Version 1.78.0 if neither is present

- [rust-analyzer]
- [cargo-edit]
- [cargo-deny]

### [`shell`](./shell/)

- [shellcheck]

### [`swi-prolog`](./swi-prolog/)

- [swipl][swi-prolog]

### [`zig`](./zig/)

- [Zig]
- [LLDB]
- [ZLS]

[boot]: https://boot-clj.com
[buf]: https://github.com/bufbuild/buf
[bun]: https://bun.sh
[cachix]: https://cachix.org
[cargo]: https://doc.rust-lang.org/cargo
[cargo-deny]: https://crates.io/crates/cargo-deny
[cargo-edit]: https://crates.io/crates/cargo-edit
[bundix]: https://github.com/inscapist/bundix
[clippy]: https://github.com/rust-lang/rust-clippy
[dhall-to-nix]: https://github.com/dhall-lang/dhall-haskell/tree/master/dhall-nix
[dotnet]: https://dotnet.microsoft.com/en-us
[elixir]: https://elixir-lang.org
[gigalixir]: https://gigalixir.com
[go]: https://go.dev
[godoc]: https://pkg.go.dev/golang.org/x/tools/cmd/godoc
[goimports]: https://pkg.go.dev/golang.org/x/tools/cmd/goimports
[golangci-lint]: https://github.com/golangci/golangci-lint
[iex]: https://hexdocs.pm/iex/IEx.html
[jq]: https://jqlang.github.io/jq
[jupyter]: https://jupyter.org
[lorri]: https://github.com/target/lorri
[maven]: https://maven.apache.org
[mix]: https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html
[niv]: https://github.com/nmattia/niv
[nix]: https://nixos.org
[nixfmt]: https://github.com/serokell/nixfmt
[nix-direnv]: https://github.com/nix-community/nix-direnv
[nixpkgs-ruby]: https://github.com/bobvanderlinden/nixpkgs-ruby
[node]: https://nodejs.org
[node2nix]: https://github.com/svanderburg/node2nix
[npm]: https://npmjs.org
[pandoc]: https://pandoc.org
[php]: https://php.net
[pip]: https://pypi.org/project/pip
[platformio]: https://platformio.org
[pnpm]: https://pnpm.io
[protobuf]: https://developers.google.com/protocol-buffers
[pulumi]: https://pulumi.com
[python]: https://python.org
[rust]: https://rust-lang.org
[rust-analyzer]: https://rust-analyzer.github.io
[ruby]: https://www.ruby-lang.org
[ruby-nix]: https://github.com/inscapist/ruby-nix
[ruby on rails]: https://rubyonrails.org
[rufo]: https://github.com/ruby-formatter/rufo
[scala]: https://scala-lang.org
[shellcheck]: https://shellcheck.net
[statix]: https://github.com/nerdypepper/statix
[swi-prolog]: https://www.swi-prolog.org
[swift]: https://swift.org
[typst]: https://typst.app
[vulnix]: https://github.com/flyingcircusio/vulnix
[yarn]: https://yarnpkg.com
[vlang]: https://vlang.io
[zig]: https://ziglang.org
[zls]: https://github.com/zigtools/zls
