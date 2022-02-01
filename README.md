
# Project Status: DEPRECATED

The ideas live on in [`flake-modules-core`](https://github.com/hercules-ci/flake-modules-core)

<details><summary>Old description</summary>

# project.nix

*A configuration manager for your projects*

The goal of this project is to automate common project setup tasks.
In doing so we hope to reduce needless variation in configuration between projects.

# Installation

If you're starting a new project, you will need to set up the basic scaffolding for it. A tool will be provided to automate this. (planned)

Your project will provide a version of project.nix via the `nix-shell` command (or direnv).

# Using it

Your project will have a file `nix/project.nix`. It is a Nix module (which is like a NixOS module (aka `configuration.nix`) but without any of the Nix*OS* modules).

By default, the configuration is applied when you run `nix-shell` in your project root or on `direnv allow`.

# Features

 - pre-commit integration
 - various formatters
 - documentation tools (planned, mdsh)
 - editor support (planned)
     - vscode (planned)
         - tasks.json (planned)

</details>
