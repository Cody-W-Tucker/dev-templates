# Ruby on Rails

A Nix flake template for Ruby on Rails development with reproducible gem management.

## Usage

Initialize in your project:
```shell
nix flake init --template "https://flakehub.com/f/Cody-W-Tucker/dev-templates/*#ruby-on-rails"
```

## What's included

- [ruby-nix](https://github.com/inscapist/ruby-nix) for reproducible gem management
- Ruby 3.3.1
- `bundix` - tool to generate `gemset.nix` from `Gemfile.lock`
- `yarn` for JavaScript packages
- `rufo` - Ruby formatter
- Helper scripts: `bundle-lock`, `bundle-update`

## Setup

1. After initializing, create your `Gemfile` with Rails:
   ```ruby
   source 'https://rubygems.org'
   gem 'rails', '~> 7.0'
   ```

2. Generate `Gemfile.lock`:
   ```shell
   bundle-lock
   ```

3. Generate `gemset.nix`:
   ```shell
   bundix
   ```

4. Enter the development shell:
   ```shell
   nix develop
   # or with direnv:
   direnv allow
   ```

5. Create your Rails app:
   ```shell
   rails new .
   ```

## How it works

The template uses a workflow that ensures reproducibility:
```
Gemfile → [bundle lock] → Gemfile.lock → [bundix] → gemset.nix → [nix develop] → reproducible Rails environment
```

Your gems are compiled and cached by Nix, so your entire team gets the exact same versions instantly.

## Updating gems

When you need to update gems:
```shell
bundle-update  # Updates Gemfile.lock
bundix         # Regenerates gemset.nix
```

## See also

- [ruby-nix documentation](https://github.com/inscapist/ruby-nix)
- [bobvanderlinden/nixpkgs-ruby](https://github.com/bobvanderlinden/nixpkgs-ruby) - for available Ruby versions
