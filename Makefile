# Slightly adjusted from: https://github.com/yonaskolb/Mint/blob/master/Makefile (thanks @yonaskolb!)
EXECUTABLE_NAME = pouch
REPO = https://github.com/sunshinejr/Pouch
VERSION = 0.1.0

PREFIX = /usr/local
INSTALL_PATH = $(PREFIX)/bin/$(EXECUTABLE_NAME)
BUILD_PATH = .build/apple/Products/Release/$(EXECUTABLE_NAME)
CURRENT_PATH = $(PWD)
RELEASE_TAR = $(REPO)/archive/$(VERSION).tar.gz
CURRENT_DATE = $(shell date +%F)

.PHONY: install build uninstall publish release

install: build
	mkdir -p $(PREFIX)/bin
	cp -f $(BUILD_PATH) $(INSTALL_PATH)

build:
	swift build --disable-sandbox -c release --arch arm64 --arch x86_64

uninstall:
	rm -f $(INSTALL_PATH)

publish: zip_binary bump_brew
	echo "Published $(VERSION)"

bump_brew:
	brew update
	brew bump-formula-pr --url=$(RELEASE_TAR) Pouch

zip_binary: build
	zip -jr $(EXECUTABLE_NAME).zip $(BUILD_PATH)

release:
	sed -i '' 's|\(version: "\)\(.*\)\("\)|\1$(VERSION)\3|' Sources/Pouch/Commands/Pouch.swift
	sed -i '' 's/## Next/## Next\n\n## $(VERSION) ($(CURRENT_DATE))/g' Changelog.md

	git add .
	git commit -m "Releasing $(VERSION)"
	git tag $(VERSION)
