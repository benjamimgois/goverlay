# GOverlay
GOverlay is an opensource project that aims to create a Graphical UI to help manage Linux overlays. It still in early alpha, so here will be dragons ! Be warned ! :)

This project is only possible due to the hard work of other people that did the really heavy lighting, i am just a Network Engineer that realy likes Linux and Gaming.

Special praze to Flightless Mango, he is the man and the mind behind MangoHUD.

  https://flightlessmango.com/
  
  https://github.com/flightlessmango/MangoHud
  
  https://discordapp.com/invite/Gj5YmBb

<a href="https://ibb.co/XyYQ3Yg"><img src="https://i.ibb.co/1szgdz5/goverlay023.png" alt="goverlay023" border="0"></a>

# Dependencies

    mangohud – Configure MangoHUD
    mesa-demos – OpenGL preview
    vulkan-tools – Vulkan preview


Required by (0)


# Installation 

# First method (repositories)

ARCH / Manjaro Linux and derivatives

<code>goverlay-git</code> is now avaiable on the AUR, install it with your favourite AUR helper. 

Fedora

<code>sudo dnf install goverlay</code>

Ubuntu / Debian


Not avaiale yet


# Second Method (Get the binaries)

1- Download the latest release from

<a href="https://ibb.co/XpSxjpB"><img src="https://i.ibb.co/P4wGF4p/github-release1.png" alt="github-release1" border="0"></a>

<a href="https://ibb.co/R2zDsMB"><img src="https://i.ibb.co/Pxw6Pb9/github-release2.png" alt="github-release2" border="0"></a>

2- Extract the file

tar -zxvf goverlay_0_1_3.tar.gz

3- Execute the binary

./goverlay


# Third method (from source)

1 - Clone and build MangoHud from git

git clone --recurse-submodules https://github.com/flightlessmango/MangoHud.git

cd MangoHud

./build.sh install


2- Clone and build GOverlay from git
Needs lazarus-ide installed

git clone https://github.com/benjamimgois/goverlay.git

cd goverlay

lazbuild -B goverlay.lpi

cd goverlay

./goverlay



This project was built with Lazarus

<a href="hhttps://www.lazarus-ide.org/"><img src="https://i.ibb.co/9ykXNtw/Laz-banner.png" alt="Laz-banner" border="0"></a>
