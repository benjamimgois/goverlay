prefix = /usr/local
bindir = /bin
libexecdir = /libexec
datadir = /share

all: goverlay start_goverlay.sh bgmod bgmod-uninstaller pascube

goverlay: *.pas *.lfm goverlay.lpi goverlay.lpr goverlay.ico
	lazbuild -B goverlay.lpi --bm=Release $(LAZBUILDOPTS)

pascube: pascube_src/pascube.lpi pascube_src/pascube.lpr $(wildcard pascube_src/src/*.pas)
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
	rm -f goverlay goverlay.dbg goverlay.res goverlay.lps goverlay_*.tar.xz
	rm -f pascube pascube_src/pascube pascube_src/pascube.res pascube_src/pascube.lps
	rm -rf pascube_src/lib/ pascube_src/backup/
	rm -f bgmod bgmod-uninstaller bgmod.o bgmod-uninstaller.o
	rm -f data/bgmod/bgmod data/bgmod/bgmod-uninstaller data/bgmod/bgmod.conf
	rm -f start_goverlay.sh data/goverlay.sh
	rm -rf lib/ backup/
	rm -f *.o *.ppu *.or *.compiled *.dbg *.res
	rm -f tests/logic/logic_tests tests/gui/gui_tests tests/gui/gui_tests.compiled
	rm -rf tests/logic/lib/ tests/gui/lib/ tests/logic/backup/ tests/gui/backup/

install: goverlay pascube bgmod bgmod-uninstaller data/goverlay.sh
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
	chmod +x $(DESTDIR)$(prefix)$(datadir)/goverlay/assets/goverlay-steam-shortcut.py
	chmod +x $(DESTDIR)$(prefix)$(datadir)/goverlay/assets/goverlay-steam-launch.sh
	install -d $(DESTDIR)$(prefix)$(datadir)/goverlay/data/icons
	cp -r data/icons/* $(DESTDIR)$(prefix)$(datadir)/goverlay/data/icons/
	install -d $(DESTDIR)$(prefix)$(datadir)/goverlay/data/steam_grid
	cp -r data/steam_grid/* $(DESTDIR)$(prefix)$(datadir)/goverlay/data/steam_grid/
	install -d $(DESTDIR)$(prefix)$(datadir)/goverlay/languages
	cp -r languages/* $(DESTDIR)$(prefix)$(datadir)/goverlay/languages/
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

test: test-logic test-gui

test-logic:
	lazbuild tests/logic/logic_tests.lpi --widgetset=qt6 $(LAZBUILDOPTS)
	./tests/logic/logic_tests

test-gui:
	lazbuild tests/gui/gui_tests.lpi --widgetset=qt6 $(LAZBUILDOPTS)
	./tests/gui/gui_tests

tarball: goverlay start_goverlay.sh
	tar -cJf goverlay_${VERSION}.tar.xz goverlay start_goverlay.sh

.PHONY: all data/goverlay.sh start_goverlay.sh clean install uninstall tests test test-logic test-gui tarball
