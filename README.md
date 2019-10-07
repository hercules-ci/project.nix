
# Project Status: Work in Progress

This project is experimental and needs work to do anything like what it promises.


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

# Extending it

The module system doesn't actually distinguish between configurations (like `nix/project.nix`) and other modules.

So to extend `project.nix` is a process of small refactorings:

 - Create a boilerplate module `nix/project-foo.nix` with contents `{ config, lib, options, pkgs, ... }: { }`.
 - Add `imports = [ ./project-foo.nix ];` to your `nix/project.nix`.
 - Move configuration from `project.nix` into the new module.
 - Add option definitions for things that are project-specific.
 - When satisfied, make a PR to `project.nix` (`modules/foo.nix`) or a related project using the by-convention location `nix/project-module.nix`.

<!-- TODO: example of how to deal with missing options aka the expression problem -->

# Features

 - pre-commit integration
 - various formatters
 - documentation tools (planned, mdsh)
 - editor support (planned)
     - vscode (planned)
         - tasks.json (planned)

