ifndef PREFIX
	PREFIX = /usr/local
endif
ifndef MANPREFIX
	MANPREFIX = $(PREFIX)/share/man
endif

install:
	mkdir -p /usr/share/applications
	cp ./web-xdg-open.desktop /usr/share/applications/
	mkdir -p $(DESTDIR)/$(PREFIX)/bin
	install -m 555 ./web-xdg-open.sh $(DESTDIR)/$(PREFIX)/bin/web-xdg-open
	mkdir -p $(DESTDIR)/$(MANPREFIX)/man1
	cp -f web-xdg-open.1 $(DESTDIR)/$(MANPREFIX)/man1/
	chmod 644 $(DESTDIR)/$(MANPREFIX)/man1/web-xdg-open.1

uninstall:
	rm -f /usr/share/applications/web-xdg-open.desktop
	rm -f $(DESTDIR)/$(PREFIX)/bin/web-xdg-open
	rm -f $(PREFIX)/$(MANPREFIX)/man1/web-xdg-open.1
