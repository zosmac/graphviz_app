# https://github.com/zosmac/graphviz
#
# Build the macOS Graphviz.app and copy to the /Applications folder.
# Assumes that Graphviz is installed in /usr/local/graphviz.
# See https://graphviz.org
# Source available at https://gitlab.com/graphviz/graphviz

ARCH:=$(shell uname -m)
PREFIX=/usr/local/graphviz
PROJECT=graphviz
PRODUCT=Graphviz
APP:=$(PRODUCT).app
XCODEBUILD=xcodebuild

/Applications/$(APP): /tmp/$(PROJECT).dst/Applications/$(APP)
	cp -R $< $@

/tmp/$(PROJECT).dst/Applications/$(APP): *.m *.h Base.lproj/*.xib $(PREFIX)/bin/dot
	$(XCODEBUILD) -project $(PROJECT).xcodeproj -target $(PRODUCT) -configuration Release install USER_HEADER_SEARCH_PATHS=$(PREFIX)/include/graphviz LIBRARY_SEARCH_PATHS=$(PREFIX)/lib ARCHS=$(ARCH)

.PHONY: clean
clean:
	rm -rf build /Applications/$(APP) /tmp/$(PROJECT).dst
