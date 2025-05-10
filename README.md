# Themes

[![built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://builtwithnix.org)
[![nixos-unstable](https://img.shields.io/badge/NixOS-Unstable-blue.svg?style=flat&logo=NixOS&logoColor=white)](https://nixos.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A NixOS flake that manages local wallpapers and automatically generates colorschemes from them.

## Overview

This project provides a clean way to:

1. Manage your wallpaper collection in a Nix-friendly manner
2. Automatically generate Material You inspired color palettes from each wallpaper
3. Use these colorschemes across your NixOS system (terminals, GTK themes, window managers, etc.)

The system leverages matugen for color extraction, following Material Design principles to create harmonious and consistent themes throughout your desktop environment.

## Project Structure

```
.
├── colorschemes/      # Colorscheme generation logic
│   ├── default.nix    # Builds colorschemes for all wallpapers
│   └── generator.nix  # Uses matugen to extract colors
├── wallpapers/        # Wallpaper management
│   ├── default.nix    # Main wallpaper derivation generator
│   ├── images/        # Local wallpaper storage
│   └── list.json      # Wallpaper metadata
└── flake.nix          # Main entry point for Nix
```
