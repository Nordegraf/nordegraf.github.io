---
layout: post
title:  "My UG4 settings for compiling and debugging in Visual Studio Code"
date:   2022-02-28 02:00:00 +0100
categories: ug4 vscode
tags: ug4 vscode
excerpt_separator: <!--more-->
---

This is my settings.json file for compiling and debugging UG4 using VS Code and the [Makefile Tools Plugin](https://github.com/microsoft/vscode-makefile-tools) . To be fair I do this mostly because I'll probably forget these settings at some point, but maybe they will be useful to someone at some point.

<!--more-->

{% gist b66236f040063668b975bd028017bc35 settings.json %}

This is configured to run my UG4 app [unsat_flow](https://github.com/Nordegraf/unsat_flow) after compiling. Modify the *binaryArgs* option under *makefile.launchConfigurations* to run a different app.

The Compile in Parallel configuration compiles using six cores. This seems to be close to the maximal number of cores one can use at the same time with 16GB of RAM. More cores slow down the compilation due to large RAM usage during compilation of the ugcore and especially the bridge libraries.

## Some issues I ran into
Building the Makefile should be done using cmake beforehand. Read the [ughub instructions](https://github.com/UG4/ughub#compilation-of-ug4) for detailed information on how to do that. Optionally the [CMake Tools](https://github.com/microsoft/vscode-cmake-tools) Plugin for VS Code can be used to generate the Makefile, but then the automatic execution of the uginstall script for SuperLU could result in errors.

The user defined options for *makefile.launchConfigurations* option does not work with relative paths. Therefore the full path to the ugshell binary an the working directory must be given through the *binaryPath* and accordingly the *cwd* options.

