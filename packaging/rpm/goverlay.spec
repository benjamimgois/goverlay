Name:           goverlay
Version:        VERSION_PLACEHOLDER
Release:        1%{?dist}
Summary:        Graphical UI to manage Vulkan/OpenGL overlays
License:        GPL-3.0-or-later
URL:            https://github.com/benjamimgois/goverlay
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  make
BuildRequires:  fpc
BuildRequires:  lazarus
BuildRequires:  desktop-file-utils
BuildRequires:  libappstream-glib

Requires:       qt6pas >= 6.2.0
Recommends:     vkbasalt
Recommends:     mangohud

%description
GOverlay is an open-source project that aims to create a Graphical UI
to manage Vulkan/OpenGL overlays. It supports vkBasalt, MangoHud,
and other overlay tools.

%prep
%setup -q

%build
make %{?_smp_mflags} prefix=/usr libexecdir=/lib

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT prefix=/usr libexecdir=/lib

%files
%{_bindir}/goverlay
%{_prefix}/lib/goverlay
%{_prefix}/lib/pascube
%{_prefix}/lib/bgmod
%{_prefix}/lib/bgmod-uninstaller
%{_datadir}/applications/io.github.benjamimgois.goverlay.desktop
%{_datadir}/metainfo/io.github.benjamimgois.goverlay.metainfo.xml
%{_mandir}/man1/goverlay.1*
%{_datadir}/icons/hicolor/128x128/apps/io.github.benjamimgois.goverlay.png
%{_datadir}/icons/hicolor/256x256/apps/io.github.benjamimgois.goverlay.png
%{_datadir}/icons/hicolor/512x512/apps/io.github.benjamimgois.goverlay.png
%{_datadir}/goverlay/

%changelog
* Wed Jun 17 2026 Benjamim Gois <benjamim.gois@gmail.com> - VERSION_PLACEHOLDER-1
- Nightly build release
