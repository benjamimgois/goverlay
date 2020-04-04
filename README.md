# GOverlay

GOverlay is an open source project aimed to create a Graphical UI to manage Linux overlays. It is still in early development, so it lacks a lot of features.

This project was only possible thanks to the other maintainers and contributors that have done the hard work. I am just a Network Engineer that really likes Linux and Gaming.

Table of contents
=================

 - [Screenshot](#screenshot)
 - [Prerequisites](#prerequisites)
 - [Installation](#installation)
	- [Distributions](#distributions)
		- [Arch / Manjaro / Other Arch derivatives](#arch--manjaro--other-arch-derivatives)
		- [Fedora](#fedora)
	- [Tarball](#tarball)
	- [Source](#source)
		- [Prerequisites](#prerequisites-1)
		- [Building](#building)
		- [Running](#running)
 - [Credits](#credits)
 - [Donations](#donations)

## Screenshot

<a href="https://ibb.co/XyYQ3Yg"><img src="https://i.ibb.co/1szgdz5/goverlay023.png" alt="goverlay023" border="0"></a>

## Prerequisites

Here are the dependencies needed in order to make GOverlay run:

 - [**`mangohud`**](https://github.com/flightlessmango/MangoHud) - Configure MangoHud
 - **`mesa-demos`** - OpenGL preview
 - **`vulkan-tools`** - Vulkan preview

## Installation 

### Distributions

#### Arch / Manjaro / Other Arch derivatives

[`goverlay-git`](https://aur.archlinux.org/packages/goverlay-git/) is now in the AUR. You can install it using your favourite AUR helper.

#### Fedora

To install [`goverlay`](https://fedora.pkgs.org/31/fedora-updates-x86_64/goverlay-0.2.3-1.fc31.x86_64.rpm.html), following the following command as root:

```bash
dnf install goverlay
```

## Tarball

1. Download the latest tarball in the [Releases](https://github.com/benjamimgois/goverlay/releases) section.

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

#### Lazarus

This project was built using [Lazarus](https://github.com/graemeg/lazarus).

<a href="hhttps://www.lazarus-ide.org/"><img src="https://i.ibb.co/9ykXNtw/Laz-banner.png" alt="Laz-banner" border="0"></a>

## Donations

If this project was useful to you, don't hesitate to donate to me :)

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=Q5EYYEJ5NSJAU&source=url)

