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
		- [Solus](#solus)
		- [Ubuntu](#ubuntu)
	- [Tarball](#tarball)
	- [Source](#source)
		- [Prerequisites](#prerequisites-1)
		- [Building](#building)
		- [Running](#running)
 - [Credits](#credits)
 - [Donations](#donations)

## Screenshot

<a href="https://ibb.co/MfQzLJW"><img src="https://i.ibb.co/gdh0CcH/goverlay062-1c.jpg" alt="goverlay062-1c" border="0"></a>
<a href="https://ibb.co/DY1L22Q"><img src="https://i.ibb.co/T1wr33t/goverlay062-2b.jpg" alt="goverlay062-2b" border="0"></a>
<a href="https://ibb.co/MDPknx5"><img src="https://i.ibb.co/4Z4RWng/goverlay062-3b.jpg" alt="goverlay062-3b" border="0"></a>

## Prerequisites

Here are the dependencies needed in order to make GOverlay run:

 - [**`mangohud`**](https://github.com/flightlessmango/MangoHud) - Configure MangoHud
 - [**`mesa-demos`**](https://github.com/freedesktop/mesa-demos) - OpenGL preview
 - [**`vulkan-tools`**](https://github.com/LunarG/VulkanTools) - Vulkan preview
 - [**`vkBasalt`**](https://github.com/DadSchoorse/vkBasalt) - Configure vkBasalt
 - [**`replay-sorcery`**](https://github.com/matanui159/ReplaySorcery) - Instant replay solution
 - [**`git`**](https://github.com/git/git) - Clone reshade repository
 - [**`qt5pas`**](https://svn.freepascal.org/svn/lazarus/trunk/lcl/interfaces/qt5/cbindings/) - Free Pascal Qt5 binding library updated by lazarus IDE

## Installation 

### Distributions

#### Arch / Manjaro / Other Arch derivatives

[`goverlay-bin`](https://aur.archlinux.org/packages/goverlay-bin/) is in the AUR. You can install it using your favourite AUR helper. You can also grab the latest git code with [`goverlay-git`](https://aur.archlinux.org/packages/goverlay-git/). The repository  [`chaotic-aur`](https://lonewolf.pedrohlc.com/chaotic-aur/) provides the binaries from the latest GIT code.

```bash
pamac install goverlay-bin
```

#### Fedora

To install [`goverlay`](https://fedora.pkgs.org/31/fedora-updates-x86_64/goverlay-0.2.3-1.fc31.x86_64.rpm.html), run the following command as root:

```bash
dnf install goverlay
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

To install goverlay in Ubuntu (20.04 and up) and derivatives use the PPA from Martin Wimpress. Run the following commands:

```bash
sudo add-apt-repository ppa:flexiondotorg/mangohud
sudo apt-get update
sudo apt-get install goverlay
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
make
```

### Running

Starting in 0.6.2 version you'll need mangohud installed to run GOverlay, run the following command:

```bash
mangohud --dlsym ./goverlay --style fusion
```


### Wayland

QT5PAS still isn't compatible with wayland display server, but you can run the application by forcing the x11 backend. Credits by [**`Darklink999999`**](https://github.com/Darklink999999)

```bash
QT_QPA_PLATFORM=xcb mangohud --dlsym goverlay --style fusion
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

#### matanui159

Special thanks to matanui159, creator of the ReplaySorcery project.

https://github.com/matanui159/ReplaySorcery

#### Lazarus

This project was built using [Lazarus](https://www.lazarus-ide.org/).

<a href="hhttps://www.lazarus-ide.org/"><img src="https://i.ibb.co/9ykXNtw/Laz-banner.png" alt="Laz-banner" border="0"></a>

## Donations

If this project was useful to you, don't hesitate to donate to me :)

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=Q5EYYEJ5NSJAU&source=url)

