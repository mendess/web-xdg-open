ifndef PREFIX
	PREFIX = /usr/local
endif

install:
	cp ./web-xdg-open.desktop /usr/share/applications/
	install -m 555 ./web-xdg-open.sh $(DESTDIR)/$(PREFIX)/bin/web-xdg-open
