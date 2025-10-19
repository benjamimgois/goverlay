<p align="center">
  <img src="https://github.com/benjamimgois/goverlay/blob/main/data/goverlay_logo.png" width="320" alt="Goverlay logo">
</p>

<p align="center">
  <a href="https://github.com/benjamimgois/Goverlay/releases">
    <img src="https://img.shields.io/github/v/release/benjamimgois/Goverlay?color=4CAF50&label=Latest%20release&style=for-the-badge" alt="Latest release">

  <a href="https://aur.archlinux.org/packages/goverlay-git">
    <img src="https://img.shields.io/aur/version/goverlay-git?color=1793d1&label=AUR&style=for-the-badge" alt="AUR version">
  </a>
  <a href="https://github.com/benjamimgois/Goverlay/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/benjamimgois/Goverlay?color=2196f3&label=License&style=for-the-badge" alt="License">
  </a>
  <a href="https://github.com/benjamimgois/Goverlay/releases">
    <img src="https://img.shields.io/badge/AppImage-Available-orange?style=for-the-badge&logo=linux" alt="AppImage available">
  </a>
</p>

---

**Goverlay** is an open-source project that provides a graphical user interface (GUI) to manage **Vulkan** and **OpenGL** overlays.  
It’s still under active development, so some features may be missing or incomplete.

This project exists thanks to the amazing work of the original maintainers and contributors behind the core tools.  
I’m just a network engineer who loves Linux and gaming — this is my way of giving something back to the community.

---

## Table of Contents

- [Screenshots](#screenshots)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Distributions](#distributions)
    - [Arch / Manjaro / Other Arch-based distributions](#arch--manjaro--other-arch-based-distributions)
    - [Fedora](#fedora)
    - [Solus](#solus)
    - [Ubuntu](#ubuntu)
    - [OpenSUSE](#opensuse)
  - [Tarball](#tarball)
  - [Building from Source](#building-from-source)
    - [Prerequisites](#prerequisites-1)
    - [Building](#building)
    - [Running](#running)
- [Credits](#credits)
- [Donations](#donations)

---

## Screenshots

![image](https://github.com/user-attachments/assets/e635b1a4-38e7-418b-9e7a-210c65702ad8)
![image](https://github.com/user-attachments/assets/9fa13c5f-b00d-4eab-832b-fa38ccad8331)
[![image.png](https://i.postimg.cc/15sDnYpg/image.png)](https://postimg.cc/qgDNWwD0)
[![image.png](https://i.postimg.cc/RVdKcQRg/image.png)](https://postimg.cc/svBMzWbW)
![image](https://github.com/user-attachments/assets/df99af4d-29dc-41a2-ae88-5f3372d31a02)

---

## Prerequisites

Dependencies required to run **Goverlay**:

- [**`mangohud`**](https://github.com/flightlessmango/MangoHud) — Configure MangoHud  
- [**`mesa-demos`**](https://gitlab.freedesktop.org/mesa/demos) — OpenGL demo tools  
- [**`vulkan-tools`**](https://github.com/LunarG/VulkanTools) — Vulkan demo tools  
- [**`vkBasalt`**](https://github.com/DadSchoorse/vkBasalt) — Configure vkBasalt  
- [**`git`**](https://github.com/git/git) — Used to clone repositories (e.g., ReShade)  
- [**`qt6pas`**](https://gitlab.com/freepascal.org/lazarus/lazarus/-/tree/main/lcl/interfaces/qt6/cbindings) — Qt6 bindings for Free Pascal / Lazarus  
- [**`zenergy`**](https://github.com/BoukeHaarsma23/zenergy) — Displays AMD CPU power metrics  
- [**`pascube`**](https://github.com/benjamimgois/pascube) — A simple OpenGL spinning cube used for configuration previews  

---

## Installation

### Distributions

#### Universal Method — AppImage

Download the AppImage from the [Releases page](https://github.com/benjamimgois/Goverlay/releases/download/1.3/Goverlay_1_3.AppImage) and make it executable:

```bash
chmod +x Goverlay_1_3.AppImage
./Goverlay_1_3.AppImage
```

#### Arch / Manjaro / Other Arch-based Distributions

**Option 1 – Official Repository**

```bash
sudo pacman -S goverlay
```

**Option 2 – Arch User Repository (AUR)**

```bash
yay -S goverlay
```

#### Fedora

```bash
sudo dnf install goverlay
```

#### OpenSUSE

##### Tumbleweed

```bash
sudo zypper install goverlay
```

##### Leap 15.2

Add the *games:tools* repository and install:

```bash
sudo zypper addrepo https://download.opensuse.org/repositories/games:tools/openSUSE_Leap_15.2/games:tools.repo
sudo zypper refresh
sudo zypper install goverlay
```

#### Solus

```bash
sudo eopkg it goverlay
```

#### Debian (Sid)

```bash
sudo apt install goverlay
```

#### Ubuntu (20.04 and newer)

The `libqt6pas` package is not available in official repositories.  
You can get it from [David Bannon’s repository](https://github.com/davidbannon/libqt6pas):

```bash
sudo apt-get update
wget https://github.com/davidbannon/libqt6pas/releases/download/v6.2.8/libqt6pas6_6.2.8-1_amd64.deb
sudo dpkg -i libqt6pas6_6.2.8-1_amd64.deb
tar -zxvf Goverlay*.tar.gz
./Goverlay
```

---

## Tarball

1. Download the latest tarball from the [Releases page](https://github.com/benjamimgois/Goverlay/releases).
2. Extract it:
   ```bash
   tar -xvf Goverlay*.tar.xz
   ```
3. Run the binary:
   ```bash
   ./Goverlay
   ```

> **Note:** Since version 0.6.4, MangoHud must be installed to run Goverlay.

---

## Building from Source

### Prerequisites

- [Lazarus IDE](https://gitlab.com/freepascal.org/lazarus/lazarus)

### Building

```bash
git clone https://github.com/benjamimgois/Goverlay.git
cd Goverlay
make
```

### Running

```bash
./Goverlay
```

### Installing

```bash
sudo make install
```

This installs the startup script to `/usr/local/bin/Goverlay`, allowing you to launch it directly via:

```bash
Goverlay
```

---

## Credits

### FlightlessMango

Huge thanks to **FlightlessMango**, creator and maintainer of **MangoHud** — the foundation that made Goverlay possible.

- https://flightlessmango.com  
- https://github.com/flightlessmango/MangoHud  
- https://discord.com/invite/Gj5YmBb" 

### DadSchoorse

Special thanks to **DadSchoorse**, creator of **vkBasalt**, which adds post-processing effects to Vulkan.

- https://github.com/DadSchoorse/vkBasalt

### Lazarus IDE

This project was built using the [Lazarus IDE](https://www.lazarus-ide.org/).

<a href="https://www.lazarus-ide.org/"><img src="https://i.ibb.co/9ykXNtw/Laz-banner.png" alt="Laz-banner" border="0"></a>

---

## Donations

If this project has been useful to you, consider supporting its development ❤️

<a href='https://ko-fi.com/T6T8ERJJ7' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi6.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=Q5EYYEJ5NSJAU&source=url)
