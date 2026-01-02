<p align="center">
 <img width="320" height="225" alt="image" src="/data/goverlay_header.webp" />
</p>

<p align="center">
  <a href="https://github.com/benjamimgois/Goverlay/releases">
    <img
      src="https://img.shields.io/github/v/release/benjamimgois/Goverlay?color=4CAF50&label=Latest%20release&style=for-the-badge"
      alt="Latest release">
  </a>

  <a href="https://flathub.org/apps/io.github.benjamimgois.goverlay">
    <img src="https://img.shields.io/badge/Flathub-Stable-blue?style=for-the-badge&logo=flathub" alt="Flathub status">
  </a>

  <a href="https://aur.archlinux.org/packages/goverlay-git">
    <img
      src="https://img.shields.io/aur/version/goverlay-git?color=1793d1&label=AUR&style=for-the-badge"
      alt="AUR version">
  </a>

<a href="https://github.com/benjamimgois/Goverlay/releases">
  <img
    src="https://img.shields.io/badge/AppImage-Stable-orange?style=for-the-badge&logo=linux"
    alt="AppImage stable">
</a>

  <a href="https://github.com/benjamimgois/Goverlay/blob/main/LICENSE">
    <img
      src="https://img.shields.io/github/license/benjamimgois/Goverlay?color=2196f3&label=License&style=for-the-badge"
      alt="License">
  </a>
</p>

---

**Goverlay** helps Linux gamers get the most out of their systems by providing an easy-to-use graphical interface to configure **MangoHud**, **vkBasalt**, and **OptiScaler**.

Whether you’re looking for performance monitoring, visual enhancements, or smarter upscaling, Goverlay makes everything accessible in just a few clicks.

This project exists thanks to the amazing work of the original maintainers and contributors behind the core tools.  
I’m just a network engineer who loves Linux and gaming — this is my way of giving something back to the community.

---

## Table of Contents

- [Screenshots](#screenshots)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Universal Methods](#universal-methods)
    - [Flatpak](#flatpak)
    - [AppImage](#appimage)
  - [Distributions](#distributions)
    - [Arch and derivatives](#arch-and-derivatives)
    - [OpenSUSE](#opensuse)
    - [Solus](#solus)
    - [Fedora / Debian / Ubuntu](#fedora--debian--ubuntu)
  - [Tarball](#tarball)
  - [Building from Source](#building-from-source)
- [Credits](#credits)
- [Donations](#donations)

---

## Screenshots

<details>
<summary><strong>Click to view screenshots</strong></summary>

<img width="1129" height="843" alt="Screenshot 1" src="/data/screenshots/1.webp" />
<img width="1129" height="843" alt="Screenshot 2" src="/data/screenshots/2.webp" />
<img width="1129" height="843" alt="Screenshot 3" src="/data/screenshots/3.webp" />
<img width="1129" height="843" alt="Screenshot 4" src="/data/screenshots/4.webp" />
<img width="1129" height="843" alt="Screenshot 5" src="/data/screenshots/5.webp" />
<img width="1129" height="843" alt="Screenshot 6" src="/data/screenshots/6.webp" />
<img width="1129" height="843" alt="Screenshot 7" src="/data/screenshots/7.webp" />

</details>



---

## Prerequisites

### Required

- [**`mangohud`**](https://github.com/flightlessmango/MangoHud) — Performance overlay / monitoring  
- [**`vkBasalt`**](https://github.com/DadSchoorse/vkBasalt) — Vulkan post-processing effects
- [**`mesa-demos`**](https://gitlab.freedesktop.org/mesa/demos) — OpenGL demo tools  
- [**`vulkan-tools`**](https://github.com/LunarG/VulkanTools) — Vulkan demo tools  
- [**`git`**](https://github.com/git/git) — Used to clone repositories (e.g., ReShade)  
- [**`qt6pas`**](https://gitlab.com/freepascal.org/lazarus/lazarus/-/tree/main/lcl/interfaces/qt6/cbindings) — Qt6 bindings for Free Pascal / Lazarus

### Optional / Used by specific features

- [**`zenergy`**](https://github.com/BoukeHaarsma23/zenergy) — Displays AMD CPU power metrics  
- [**`pascube`**](https://github.com/benjamimgois/pascube) — Simple OpenGL spinning cube used for configuration previews  



---

## Installation

## Universal Methods

### Flatpak

You can download it from [**`Flathub`**](https://flathub.org/en/apps/io.github.benjamimgois.goverlay)


```bash
# Install Goverlay
flatpak install flathub io.github.benjamimgois.goverlay

# Install required runtimes for MangoHud and vkBasalt support
flatpak --user install flathub org.freedesktop.Platform.VulkanLayer.MangoHud//25.08 \
org.freedesktop.Platform.VulkanLayer.vkBasalt//25.08 -y
```


### AppImage

Download the AppImage from the  and make it executable:

```bash
chmod +x Goverlay_1_3.AppImage
./Goverlay_1_3.AppImage
```

## Distributions

### Arch and derivatives

**Option 1 – Official Repository**
```bash
sudo pacman -S goverlay
```
**Option 2 – AUR**
```
yay -S goverlay-git
```

### OpenSUSE
```bash
sudo zypper install goverlay
```

### Solus
```bash
sudo eopkg it goverlay
```



> [!IMPORTANT]
> **Fedora / Debian / Ubuntu users:** Official repositories for these distros often ship outdated versions. It is **strongly recommended** to use the [Flatpak](#flatpak) or [AppImage](#appimage) instead.


---

#### Libqt6pas
The `libqt6pas` package is not available in some distributions official repositories.  
You can get it from [David Bannon’s repository](https://github.com/davidbannon/libqt6pas/releases):

Ubuntu example:
```
bash
sudo apt-get update
wget https://github.com/davidbannon/libqt6pas/releases/download/v6.2.8/libqt6pas6_6.2.8-1_amd64.deb
sudo dpkg -i libqt6pas6_6.2.8-1_amd64.deb
tar -zxvf Goverlay*.tar.gz
./Goverlay
```

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

### OptiScaler Team & Contributors

Goverlay integrates several components from the OptiScaler ecosystem and community-driven projects that enable upscaling, frame generation and NVIDIA APIs on Linux.

**OptiScaler**

Core upscaling and frame-generation project for Linux.

https://github.com/optiscaler/OptiScaler

**fakenvapi**

User-space implementation of NVAPI used by OptiScaler and other tools.

https://github.com/optiscaler/fakenvapi

**Decky-Framegen (xXJSONDeruloXx)**

Pioneer project that inspired much of the OptiScaler installation logic.

https://github.com/xXJSONDeruloXx/Decky-Framegen

**fgmod (FakeMichau)**

Another important reference implementation for frame-generation utilities on Linux.

https://github.com/FakeMichau/fgmod

**DLSS-Enabler (Artur Graniszewski)**

Tooling that expands compatibility layers for DLSS and NVAPI-based features.

https://github.com/artur-graniszewski/DLSS-Enabler



### Lazarus IDE

This project was built using the [Lazarus IDE](https://www.lazarus-ide.org/).

<a href="https://www.lazarus-ide.org/"><img src="https://i.ibb.co/9ykXNtw/Laz-banner.png" alt="Laz-banner" border="0"></a>

---

## Donations

If this project has been useful to you, consider supporting its development ❤️

<a href='https://ko-fi.com/T6T8ERJJ7' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi6.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=Q5EYYEJ5NSJAU&source=url)
