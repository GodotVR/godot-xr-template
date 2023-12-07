# Godot XR Template

![GitHub forks](https://img.shields.io/github/forks/godotvr/godot-xr-template?style=plastic)
![GitHub Repo stars](https://img.shields.io/github/stars/godotvr/godot-xr-template?style=plastic)
![GitHub contributors](https://img.shields.io/github/contributors/godotvr/godot-xr-template?style=plastic)
![GitHub](https://img.shields.io/github/license/godotvr/godot-xr-template?style=plastic)

This repository contains a template Godot project for building a simple VR game.


## Versions

Official releases are tagged and can be found [here](https://github.com/GodotVR/godot-xr-template/releases).

The following branches are in active development:
|  Branch  |  Description                  |  Godot version  |
|----------|-------------------------------|-----------------|
|   main   | Current development branch    |  Godot 4.2+     |
|    4.1   | Godot 4.1 development branch  |  Godot 4.1      |
|    3.x   | Godot 3.x development branch  |  Godot 3.5+     |


# Assets

This project uses the following assets:
 - [Godot XR Tools](https://godotengine.org/asset-library/asset/1515)
 - [OpenXR Loaders](https://github.com/GodotVR/godot_openxr_loaders)


# Getting Started

Start by downloading this asset from github; or by installing it from the Godot
Asset Library.

The game should be playable with a splash screen and two example scenes the player
can move between.

The game should be customized by:
 - Modifying the splash-screen texture to represent the game
 - Modifying the icon.png for the game
 - Add game state variables to the game_state.gd singleton class
 - Replacing the demo zones with zones suitable to the game


# Exporting to Android

The template contains a copy of the XR loaders plugin
and preconfigured exports for android based headsets that support OpenXR.

Before this can be used you do need to install the android build template.
Select the menu `Editor->Manage Export Templates...` to download the templates.
Select the menu `Project->Install Android Build Template...` to install the template.

Make sure you set the correct entry in the export templates to runable
if you want to use one click deploy to your device.

Please refer to the official documentation for Godots prerequisits for exporting to android:
https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html

# Recommended Asset Locations

Common areas to find assets are:
 - [Godot Asset Library](https://godotengine.org/asset-library/asset)
 - [AmbientCG](https://ambientcg.com/) for object and sky textures
 - [FreePD.com](https://freepd.com/) for sound tracks
 - [FreeSound](https://freesound.org/) for sound effects
 - [Kenney.nl](https://kenney.nl/) 


# More Information

Information on the Godot XR Tools can be found on [the website](https://godotvr.github.io/godot-xr-tools/).

