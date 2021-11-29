prefix = /usr/local
bindir = /bin
libexecdir = /libexec
datadir = /share

all: goverlay start_goverlay.sh

goverlay: *.pas *.lfm *.lrs goverlay.lpi goverlay.lpr goverlay.res goverlay.ico
	lazbuild -B goverlay.lpi --bm=Release $(LAZBUILDOPTS)

data/goverlay.sh: data/goverlay.sh.in
	sed s%@libexecdir@%$(prefix)$(libexecdir)%g data/goverlay.sh.in > data/goverlay.sh

start_goverlay.sh: data/goverlay.sh.in
	sed s%@libexecdir@%.%g data/goverlay.sh.in > start_goverlay.sh
	chmod +x ./start_goverlay.sh

clean:
	rm -f goverlay
	rm -f start_goverlay.sh
	rm -f data/goverlay.sh
	rm -rf lib/
	rm -rf backup/
	rm -rf goverlay.lps

install: goverlay data/goverlay.sh
	install -D -m=755 goverlay $(DESTDIR)$(prefix)$(libexecdir)/goverlay
	install -D -m=755 data/goverlay.sh $(DESTDIR)$(prefix)$(bindir)/goverlay
	install -D -m=644 data/io.github.benjamimgois.goverlay.desktop $(DESTDIR)$(prefix)$(datadir)/applications/io.github.benjamimgois.goverlay.desktop
	install -D -m=644 data/io.github.benjamimgois.goverlay.metainfo.xml $(DESTDIR)$(prefix)$(datadir)/metainfo/io.github.benjamimgois.goverlay.metainfo.xml
	install -D -m=644 data/goverlay.1 $(DESTDIR)$(prefix)$(datadir)/man/man1/goverlay.1
	install -D -m=644 data/icons/128x128/goverlay.png $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/128x128/apps/goverlay.png
	install -D -m=644 data/icons/256x256/goverlay.png $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/256x256/apps/goverlay.png
	install -D -m=644 data/icons/512x512/goverlay.png $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/512x512/apps/goverlay.png

uninstall:
	rm -f $(DESTDIR)$(prefix)$(libexecdir)/goverlay
	rm -f $(DESTDIR)$(prefix)$(bindir)/goverlay
	rm -f $(DESTDIR)$(prefix)$(datadir)/applications/goverlay.desktop
	rm -f $(DESTDIR)$(prefix)$(datadir)/metainfo/goverlay.metainfo.xml
	rm -f $(DESTDIR)$(prefix)$(datadir)/man/man1/goverlay.1
	rm -f $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/128x128/apps/goverlay.png
	rm -f $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/256x256/apps/goverlay.png
	rm -f $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/512x512/apps/goverlay.png

tests:
	appstreamcli validate --pedantic data/io.github.benjamimgois.goverlay.metainfo.xml
	desktop-file-validate data/io.github.benjamimgois.goverlay.desktop

.PHONY: all data/goverlay.sh start_goverlay.sh clean install uninstall tests
