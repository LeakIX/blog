+++
title = "LeakIX Firefox Addon"
description = "An experimental Firefox extension for LeakIX has landed !"

tags = [
"feature",
"leakix",
"addon",
"firefox",
]
date = "2021-11-25 13:30:00"
categories = [
"LeakIX How-to","Feature"
]
keywords = [
"leakix",
"howto",
"firefox",
"extension",
"browser",
]
menu = "main"
images = ["/lkxext/screen.jpg"]
+++

An experimental Firefox extension for LeakIX has landed !

<!--more-->

## Installation

The extension is currently available on Firefox Destkop.

It can be downloaded from the [Mozilla addons directory](https://addons.mozilla.org/en-US/firefox/addon/leakix/).

## Usage

Once installed, a LeakIX icon will be present in the tool bar.

![LeakIX reports](/lkxext/screen.jpg)


It will now check LeakIX.net for every site you visit and report if it finds issue indexed by our engine.

The status can either be :

- Green, nothing found or informative content
- Blue, small risk detected
- Orange, A serious risk has been detected and should be investigated
- Red, A leak is occuring or a critical software update is missing 

The number represent the number of events (minor or major) found  for that domain.

## Privacy

We don't store the domains you're visiting.

## Credits

- [PaulSec](https://github.com/PaulSec/Shodan-Firefox-Addon) for creating the original Shodan extension this extension is based on.

[leakix]: <https://leakix.net/>
