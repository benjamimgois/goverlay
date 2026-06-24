prefix = /usr/local
bindir = /bin
libexecdir = /libexec
datadir = /share

all: goverlay start_goverlay.sh bgmod bgmod-uninstaller pascube_bin

goverlay: *.pas *.lfm goverlay.lpi goverlay.lpr goverlay.ico
	lazbuild -B goverlay.lpi --bm=Release $(LAZBUILDOPTS)

pascube_bin:
	lazbuild -B pascube_src/pascube.lpi $(LAZBUILDOPTS)
	cp pascube_src/pascube ./pascube

bgmod: bgmod.lpr
	fpc -O3 bgmod.lpr
	mkdir -p data/bgmod
	cp bgmod data/bgmod/bgmod
	cp bgmod.conf data/bgmod/bgmod.conf

bgmod-uninstaller: bgmod-uninstaller.lpr
	fpc -O3 bgmod-uninstaller.lpr
	mkdir -p data/bgmod
	cp bgmod-uninstaller data/bgmod/bgmod-uninstaller

data/goverlay.sh: data/goverlay.sh.in
	sed s%@libexecdir@%$(prefix)$(libexecdir)%g data/goverlay.sh.in > data/goverlay.sh

start_goverlay.sh: data/goverlay.sh.in
	sed s%@libexecdir@%.%g data/goverlay.sh.in > start_goverlay.sh
	chmod +x start_goverlay.sh

clean:
	rm -f goverlay
	rm -f pascube
	rm -f pascube_src/pascube
	rm -rf pascube_src/lib/
	rm -rf pascube_src/backup/
	rm -f pascube_src/pascube.lps
	rm -f bgmod
	rm -f bgmod-uninstaller
	rm -f data/bgmod/bgmod
	rm -f data/bgmod/bgmod-uninstaller
	rm -f data/bgmod/bgmod.conf
	rm -f start_goverlay.sh
	rm -f data/goverlay.sh
	rm -rf lib/
	rm -rf backup/
	rm -f goverlay.lps
	rm -f goverlay_*.tar.xz

install: goverlay data/goverlay.sh bgmod bgmod-uninstaller
	install -D -m=755 goverlay $(DESTDIR)$(prefix)$(libexecdir)/goverlay
	install -D -m=755 pascube $(DESTDIR)$(prefix)$(libexecdir)/pascube
	install -D -m=755 bgmod $(DESTDIR)$(prefix)$(libexecdir)/bgmod
	install -D -m=755 bgmod-uninstaller $(DESTDIR)$(prefix)$(libexecdir)/bgmod-uninstaller
	install -D -m=755 data/goverlay.sh $(DESTDIR)$(prefix)$(bindir)/goverlay
	install -D -m=644 data/io.github.benjamimgois.goverlay.desktop $(DESTDIR)$(prefix)$(datadir)/applications/io.github.benjamimgois.goverlay.desktop
	install -D -m=644 data/io.github.benjamimgois.goverlay.metainfo.xml $(DESTDIR)$(prefix)$(datadir)/metainfo/io.github.benjamimgois.goverlay.metainfo.xml
	install -D -m=644 data/goverlay.1 $(DESTDIR)$(prefix)$(datadir)/man/man1/goverlay.1
	install -D -m=644 data/icons/128x128/goverlay.png $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/128x128/apps/io.github.benjamimgois.goverlay.png
	install -D -m=644 data/icons/256x256/goverlay.png $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/256x256/apps/io.github.benjamimgois.goverlay.png
	install -D -m=644 data/icons/512x512/goverlay.png $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/512x512/apps/io.github.benjamimgois.goverlay.png
	install -d $(DESTDIR)$(prefix)$(datadir)/goverlay/assets
	cp -r assets/* $(DESTDIR)$(prefix)$(datadir)/goverlay/assets/
	install -d $(DESTDIR)$(prefix)$(datadir)/goverlay/data/icons
	cp -r data/icons/* $(DESTDIR)$(prefix)$(datadir)/goverlay/data/icons/
	install -d $(DESTDIR)$(prefix)$(datadir)/goverlay/bgmod
	cp -r data/bgmod/* $(DESTDIR)$(prefix)$(datadir)/goverlay/bgmod/
	rm -f $(DESTDIR)$(prefix)$(datadir)/goverlay/bgmod/bgmod
	rm -f $(DESTDIR)$(prefix)$(datadir)/goverlay/bgmod/bgmod-uninstaller

uninstall:
	rm -f $(DESTDIR)$(prefix)$(libexecdir)/goverlay
	rm -f $(DESTDIR)$(prefix)$(libexecdir)/pascube
	rm -f $(DESTDIR)$(prefix)$(libexecdir)/bgmod
	rm -f $(DESTDIR)$(prefix)$(libexecdir)/bgmod-uninstaller
	rm -f $(DESTDIR)$(prefix)$(bindir)/goverlay
	rm -f $(DESTDIR)$(prefix)$(datadir)/applications/io.github.benjamimgois.goverlay.desktop
	rm -f $(DESTDIR)$(prefix)$(datadir)/metainfo/io.github.benjamimgois.goverlay.metainfo.xml
	rm -f $(DESTDIR)$(prefix)$(datadir)/man/man1/goverlay.1
	rm -f $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/128x128/apps/io.github.benjamimgois.goverlay.png
	rm -f $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/256x256/apps/io.github.benjamimgois.goverlay.png
	rm -f $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/512x512/apps/io.github.benjamimgois.goverlay.png
	rm -rf $(DESTDIR)$(prefix)$(datadir)/goverlay

tests:
	appstreamcli validate --pedantic data/io.github.benjamimgois.goverlay.metainfo.xml
	desktop-file-validate data/io.github.benjamimgois.goverlay.desktop

tarball: goverlay start_goverlay.sh
	tar -cJf goverlay_${VERSION}.tar.xz goverlay start_goverlay.sh

.PHONY: all data/goverlay.sh start_goverlay.sh clean install uninstall tests tarball
