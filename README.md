# GOverlay

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
		- [Gentoo](#gentoo)
		- [Solus](#solus)
	- [Tarball](#tarball)
	- [Source](#source)
		- [Prerequisites](#prerequisites-1)
		- [Building](#building)
		- [Running](#running)
 - [Credits](#credits)
 - [Donations](#donations)

## Screenshot

<a href="https://ibb.co/tJW6VBd"><img src="https://i.ibb.co/9rC0QnM/goverlay-0-3-7.png" alt="goverlay-0-3-7" border="0"></a>
<a href="https://ibb.co/xgcJvxV"><img src="https://i.ibb.co/C9XhdRx/goverlay-0-3-2.png" alt="goverlay-0-3-2" border="0"></a>

## Prerequisites

Here are the dependencies needed in order to make GOverlay run:

 - [**`mangohud`**](https://github.com/flightlessmango/MangoHud) - Configure MangoHud
 - [**`mesa-demos`**](https://github.com/freedesktop/mesa-demos) - OpenGL preview
 - [**`vulkan-tools`**](https://github.com/LunarG/VulkanTools) - Vulkan preview
 - [**`vkBasalt`**](https://github.com/DadSchoorse/vkBasalt) - Configure vkBasalt

## Installation 

### Distributions

#### Arch / Manjaro / Other Arch derivatives

Binary AUR package: [`goverlay-bin`](https://aur.archlinux.org/packages/goverlay-bin/)

Development AUR package: [`goverlay-git`](https://aur.archlinux.org/packages/goverlay-git/) 

You can also grab the latest compiled binary package from the [`chaotic-aur`](https://lonewolf.pedrohlc.com/chaotic-aur/) unofficial user repository.

#### Fedora

To install [`goverlay`](https://fedora.pkgs.org/31/fedora-updates-x86_64/goverlay-0.2.3-1.fc31.x86_64.rpm.html), run the following command as root:

```bash
dnf install goverlay
```

#### Gentoo

To install [`goverlay`](https://gitlab.com/TheGreatMcPain/thegreatmcpain-overlay/-/tree/master/games-util/goverlay):

1. Install the TheGreatMcPain overlay: [thegreatmcpain-overlay#installation](https://gitlab.com/TheGreatMcPain/thegreatmcpain-overlay#installation)
2. [Unmask](https://wiki.gentoo.org/wiki/Knowledge_Base:Unmasking_a_package) [`games-util/goverlay`](https://gitlab.com/TheGreatMcPain/thegreatmcpain-overlay/-/tree/master/games-util/goverlay)
3. Run the following command as root:
```bash
emerge --verbose games-util/goverlay
```

#### Solus

To install [`goverlay`](https://dev.getsol.us/source/goverlay/), run the following command as root:

```bash
eopkg it goverlay
```

## Tarball

1. Download the latest tarball from [Releases](https://github.com/benjamimgois/goverlay/releases).

2. Extract the file by running the following command:

```bash
tar -zxvf goverlay*.tar.gz
```

3. Execute the binary by running the following command:

```bash
./goverlay
```

## Source

### Prerequisites

Before building, you will need to install the following:

 - [Lazarus](https://github.com/graemeg/lazarus) - IDE

### Building

To build GOverlay, clone the git repository by running following command:

```bash
git clone https://github.com/benjamimgois/goverlay.git
```

Then, change directory and build GOverlay by running the following commands:

```bash
cd goverlay

lazbuild -B goverlay.lpi
```

### Running

To run GOverlay, run the following command:

```bash
./goverlay
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

This project was built using [Lazarus](https://github.com/graemeg/lazarus).

<a href="hhttps://www.lazarus-ide.org/"><img src="https://i.ibb.co/9ykXNtw/Laz-banner.png" alt="Laz-banner" border="0"></a>

## Donations

If this project was useful to you, don't hesitate to donate to me :)

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=Q5EYYEJ5NSJAU&source=url)

