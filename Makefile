prefix = /usr/local
bindir = /bin
datadir = /share

all: goverlay

goverlay: *.pas *.lfm *.lrs goverlay.lpi goverlay.lpr goverlay.res goverlay.ico
	lazbuild -B goverlay.lpi --bm=Release $(LAZBUILDOPTS)

clean:
	rm -f goverlay
	rm -rf lib/
	rm -rf backup/

install: goverlay
	install -D -m=755 goverlay $(DESTDIR)$(prefix)$(bindir)/goverlay
	install -D -m=644 data/io.github.benjamimgois.goverlay.desktop $(DESTDIR)$(prefix)$(datadir)/applications/io.github.benjamimgois.goverlay.desktop
	install -D -m=644 data/io.github.benjamimgois.goverlay.metainfo.xml $(DESTDIR)$(prefix)$(datadir)/metainfo/io.github.benjamimgois.goverlay.metainfo.xml
	install -D -m=644 data/goverlay.1 $(DESTDIR)$(prefix)$(datadir)/man/man1/goverlay.1
	install -D -m=644 data/icons/128x128/goverlay.png $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/128x128/apps/goverlay.png
	install -D -m=644 data/icons/256x256/goverlay.png $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/256x256/apps/goverlay.png
	install -D -m=644 data/icons/512x512/goverlay.png $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/512x512/apps/goverlay.png

uninstall:
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

.PHONY: all clean install uninstall tests
