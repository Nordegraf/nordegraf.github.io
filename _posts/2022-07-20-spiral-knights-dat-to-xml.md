---
layout: post
title:  Looking into how the game Spiral Knights is built
date:   2022-07-20 15:00:00 +0200
categories: spiral_knights
tags: spiral_knights
excerpt_separator: <!--more-->
---

More than 10 years ago in 2012 I stumbled upon a game called Spiral Knights in the Free-to-Play section of the Steam Store.
The beautiful neon-like color scheme, cute artstyle and lovely story got me hooked quite fast. And so Spiral Knights became the second MMO I played a bit more extensively after Lego Universe closed its gates the same year.

<!--more-->

Developed by Three Rings Design and published by SEGA Spiral Knights is a quite grind heavy Top-Down Hack and Slash type game which sends you on a quest through an ever changing set of gradually more difficult missions in the so called Clockworks on the planet Cradle... Well at least the advertising says that. While definitely being quite diverse the actual reality is that the same missions are rotated on a daily or weekly basis depending on the mission type. At some point specific routes through the clockwork revealed themselves as the most efficient for getting crafting materials resulting in me grinding only these ones for hours. I still enjoyed my time on Cradle and I have been revisiting the game ever so often over the past 10 years.

Sadly the game got less popular over time to a point were today the games servers are mostly empty. Moreover Three Rings Design dissolved in 2016 and a new company called Grey Havens consisting of old Three Rings employees formed to keep some of their games alive. By now only Spiral Knights and Puzzle Pirates are kept on life support.

Being interested in how games work behind the curtain I set out to look into Spiral Knights game files to see what I'm able to understand. I'll summarize my findings a bit below.

In 2005 Three Rings launched a website called gamegardens.com and wiki.gamegardens.com as a plattform for making games using their developed Java libraries. Sadly the website is gone, but some captures are availabe on the WaybackMachine. For gamegardens ThreeRings published their libraries publicly on GitHub. Their core libraries are:

- <a class="link" href="https://github.com/threerings/narya">Narya</a> (mainly for networking)
- <a class="link" href="https://github.com/threerings/nenya">Nenya</a> (mainly for media management)
- <a class="link" href="https://github.com/threerings/vilya">Vilya</a> (some frameworks for specific game types)
- <a class="link" href="https://github.com/threerings/clyde">Clyde</a> (various utility)
- <a class="link" href="https://github.com/threerings/getdown">getdown</a> (downloading and updating)

(They must be huge Tolkien fans)

Moreover a core library they used is <a class="link" href="https://legacy.lwjgl.org">LWJGL2</a>.

There are more libraries in the games folders, but the ones listed above are probably the most important ones.
In the code subdirectory of the games main files is a library called ```projectx-pcode.jar```. My best guess is, that most of the games core functionality is build upon the libraries in this .jar, which includes code of their open source libraries.

Clyde includes utility for importing and converting the games .dat binary files to a human readable .xml format. As a first step I set out to use this utility for converting the games .dat files to .xml. In Clyde the import and export is done using the ```com.threerings.export.BinaryImport``` and ```com.threerings.export.XMLExport``` classes. In the games file these libraries are contained in the ```com.threerings.export.b``` and ```com.threerings.export.aA``` .class files. Using a bash script I installed the games ```projectx-pcode.jar``` into a local maven repository making its source code available for usage. Then I simply wrote a small app searching the games directory for .dat files and then converting all of them to .xml. The apps code is available on my <a class="link" href="https://github.com/Nordegraf/SKdatToXML">GitHub</a> including the bash script.

The converted files contain a lot of information about missions, items, worlds, models, etc. and mostly reference configuration classes also contained in the ```projectx-pcode.jar```. A nice small project would be a page listing all of the games missions or items or similar, but for now I'll leave this as is.
