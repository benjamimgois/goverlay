# Goverlay

GOverlay is an open source project aimed to create a Graphical UI to manage Vulkan/OpenGL overlays. It is still in early development, so it lacks a lot of features.

This project was only possible thanks to the other maintainers and contributors that have done the hard work. I am just a Network Engineer that really likes Linux and Gaming.

Table of contents
=================

 - [Screenshot](#screenshot)
 - [Prerequisites](#prerequisites)
 - [Installation](#installation)
	- [Distributions](#distributions)
		- [Arch / Manjaro / Other Arch derivatives](#arch--manjaro--other-arch-derivatives)
		- [Fedora](#fedora)
		- [Solus](#solus)
		- [Ubuntu](#ubuntu)
		- [OpenSUSE](#opensuse)
	- [Tarball](#tarball)
	- [Source](#source)
		- [Prerequisites](#prerequisites-1)
		- [Building](#building)
		- [Running](#running)
 - [Credits](#credits)
 - [Donations](#donations)

## Screenshot

<a href="https://imgbb.host/vCWK9"><img src="https://imgbb.host/images/vCWK9.png" alt="vCWK9.png" border="0" /></a>
<a href="https://imgbb.host/vCkkz"><img src="https://imgbb.host/images/vCkkz.png" alt="vCkkz.png" border="0"></a>
<a href="https://imgbb.host/vCofK"><img src="https://imgbb.host/images/vCofK.png" alt="vCofK.png" border="0"></a>
<a href="https://imgbb.host/vCjt7"><img src="https://imgbb.host/images/vCjt7.png" alt="vCjt7.png" border="0"></a>

## Prerequisites

Here are the dependencies needed in order to make GOverlay run:

 - [**`mangohud`**](https://github.com/flightlessmango/MangoHud) - Configure MangoHud
 - [**`mesa-demos`**](https://gitlab.freedesktop.org/mesa/demos) - OpenGL preview
 - [**`vulkan-tools`**](https://github.com/LunarG/VulkanTools) - Vulkan preview
 - [**`vkBasalt`**](https://github.com/DadSchoorse/vkBasalt) - Configure vkBasalt
 - [**`git`**](https://github.com/git/git) - Clone reshade repository
 - [**`qt6pas`**](https://gitlab.com/freepascal.org/lazarus/lazarus/-/tree/main/lcl/interfaces/qt6/cbindings) - Free Pascal Qt6 binding library updated by lazarus IDE

## Installation 

### Distributions

#### Arch / Manjaro / Other Arch derivatives

To install [`goverlay`](https://archlinux.org/packages/extra/x86_64/goverlay/), run the following command as root:
```bash
pacman -S goverlay
```

#### Fedora

To install [`goverlay`](https://fedora.pkgs.org/31/fedora-updates-x86_64/goverlay-0.2.3-1.fc31.x86_64.rpm.html), run the following command as root:

```bash
dnf install goverlay
```

#### OpenSUSE

##### Tumbleweed

To install [`goverlay`](https://build.opensuse.org/package/show/openSUSE%3AFactory/goverlay), run the following command as root:

```bash
zypper install goverlay
```

##### Leap 15.2

To install [`goverlay`](https://build.opensuse.org/package/show/games%3Atools/goverlay) from the [games:tools](https://build.opensuse.org/project/show/games:tools) repo, run the following commands as root:

```bash
zypper addrepo https://download.opensuse.org/repositories/games:tools/openSUSE_Leap_15.2/games:tools.repo
zypper refresh
zypper install goverlay
```


#### Solus

To install [`goverlay`](https://dev.getsol.us/source/goverlay/), run the following command as root:

```bash
eopkg it goverlay
```

#### Debian

To install [`goverlay`](https://packages.debian.org/sid/amd64/goverlay/download) in debian sid, run the following command as root:

```bash
apt install goverlay
```

#### Ubuntu

To install goverlay in Ubuntu (20.04 and up) and derivatives, you need to install libqt6pas that isn't provided by official repo, but
you can grab it in https://github.com/davidbannon/libqt6pas

```bash
sudo apt-get update
wget https://github.com/davidbannon/libqt6pas/releases/download/v6.2.8/libqt6pas6_6.2.8-1_amd64.deb
sudo dpkg -i libqt6pas6_6.2.8-1_amd64.deb
tar -zxvf goverlay*.tar.gz
./goverlay
```

To avoid a issue with libdl.so on ubuntu based distros it's recomended to build Mangohud from source.
https://github.com/flightlessmango/MangoHud

## Tarball

1. Download the latest tarball from [Releases](https://github.com/benjamimgois/goverlay/releases).

2. Extract the file by running the following command:

```bash
tar -xvf goverlay*.tar.xz
```

3. Properly execute the binary inside the tar file:

```bash
./goverlay
```

Note: Since version 0.6.4 mangohud needs to be installed to run GOverlay.

## Source

### Prerequisites

Before building, you will need to install the following:

 - [Lazarus](https://gitlab.com/freepascal.org/lazarus/lazarus) - IDE

### Building

To build GOverlay, clone the git repository by running following command:

```bash
git clone https://github.com/benjamimgois/goverlay.git
```

Then, change directory and build GOverlay by running the following commands:

```bash
cd goverlay
make
```

### Running

Start GOverlay with:

```bash
./goverlay
```

Note: Since version 0.6.4 mangohud needs to be installed to run GOverlay.

### Installing

To install GOverlay execute:

```bash
make install
```

This will install the start script to `/usr/local/bin/goverlay`, so that it can be launched via `goverlay` in the console. 


## Theme compatibility

Since Goverlay 0.9 the official supported themes are Breeze (plasma) and Adwaita (Gnome). If you run into issues with your current one you can force goverlay to run with a specific theme:

```bash
goverlay --style breeze
```
or
```bash
goverlay --style fusion
```

## Credits

#### Mango

Most of the credits go to Flightless Mango. He is the man and the mind behind MangoHud.

https://flightlessmango.com/

https://github.com/flightlessmango/MangoHud

https://discordapp.com/invite/Gj5YmBb

#### DadSchoorse

Special thanks to DadSchoorse, creator of the vkBasalt project.

https://github.com/DadSchoorse/vkBasalt


#### Lazarus

This project was built using [Lazarus](https://www.lazarus-ide.org/).

<a href="hhttps://www.lazarus-ide.org/"><img src="https://i.ibb.co/9ykXNtw/Laz-banner.png" alt="Laz-banner" border="0"></a>

## Donations

If this project was useful to you, don't hesitate to donate to me :)

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=Q5EYYEJ5NSJAU&source=url)

