#!/bin/sh
# Author Bladertom from Reddit and Ryan from Intelligent Gaming - Linux Tutorials & Gameplay
# Modified by Benjamim Gois at 02/11/20

sudo apt update && sudo apt upgrade -y
sudo apt install lazarus -y
sudo apt install git -y
git clone --recurse-submodules https://github.com/flightlessmango/MangoHud.git cd MangoHud
./build.sh build
./build.sh package
./build.sh install
cd .. rm -rf MangoHud
git clone https://github.com/DadSchoorse/vkBasalt.git
cd vkBasalt
meson --buildtype=release --prefix=/usr builddir
ninja -C builddir install
cd .. rm -rf vkBasalt
git clone https://github.com/benjamimgois/goverlay.git
cd goverlay lazbuild -B goverlay.lpi
sudo mv goverlay /usr/games/
cd .. rm -rf goverlay
