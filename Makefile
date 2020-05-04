prefix = /usr/local

bindir = /bin
datadir = /share

all: goverlay

goverlay:
	lazbuild -B goverlay.lpi

clean:
	rm -f goverlay
	rm -Rf lib

install: goverlay
	install -D goverlay $(DESTDIR)$(prefix)$(bindir)/goverlay
	install -D data/goverlay.desktop $(DESTDIR)$(prefix)$(datadir)/applications/goverlay.desktop
	install -D data/goverlay.metainfo.xml $(DESTDIR)$(prefix)$(datadir)/metainfo/goverlay.metainfo.xml
	install -D data/icons/128x128/goverlay.png $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/128x128/apps/goverlay.png
	install -D data/icons/256x256/goverlay.png $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/256x256/apps/goverlay.png
	install -D data/icons/512x512/goverlay.png $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/512x512/apps/goverlay.png

uninstall:
	rm -f $(DESTDIR)$(prefix)$(bindir)/goverlay
	rm -f $(DESTDIR)$(prefix)$(datadir)/applications/goverlay.desktop
	rm -f $(DESTDIR)$(prefix)$(datadir)/metainfo/goverlay.metainfo.xml
	rm -f $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/128x128/apps/goverlay.png
	rm -f $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/256x256/apps/goverlay.png
	rm -f $(DESTDIR)$(prefix)$(datadir)/icons/hicolor/512x512/apps/goverlay.png

tests:
	appstreamcli validate --pedantic data/goverlay.metainfo.xml

.PHONY: all clean install uninstall tests
