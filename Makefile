# https://github.com/zosmac/graphviz
#
# Build the macOS Graphviz.app and copy to the /Applications folder.
# See https://graphviz.org
# Source available at https://gitlab.com/graphviz/graphviz

ARCH ?= $(shell uname -m)

ifneq ($(wildcard /opt/homebrew/bin/dot),)
    PREFIX ?= /opt/homebrew
else ifneq ($(wildcard /usr/local/bin/dot),)
    PREFIX ?= /usr/local
else
    PREFIX ?= /usr/local/graphviz
endif

PROJECT=graphviz
PRODUCT=Graphviz
APP:=$(PRODUCT).app
XCODEBUILD=xcodebuild

ifeq ($(wildcard $(DEVELOPER_DIR)),)
    ifneq ($(wildcard /Applications/Xcode-beta.app/Contents/Developer),)
        export DEVELOPER_DIR ?= /Applications/Xcode-beta.app/Contents/Developer
    else ifneq ($(wildcard /Applications/Xcode.app/Contents/Developer),)
        export DEVELOPER_DIR ?= /Applications/Xcode.app/Contents/Developer
    else ifneq ($(wildcard /Applications/Xcode\ 26.6.app/Contents/Developer),)
        export DEVELOPER_DIR ?= /Applications/Xcode\ 26.6.app/Contents/Developer
    endif
endif

/Applications/$(APP): /tmp/$(PROJECT).dst/Applications/$(APP)
	cp -R $< $@

/tmp/$(PROJECT).dst/Applications/$(APP): *.m *.h Base.lproj/*.xib $(PREFIX)/bin/dot
	$(XCODEBUILD) -project $(PROJECT).xcodeproj -target $(PRODUCT) -configuration Release install \
		USER_HEADER_SEARCH_PATHS=$(PREFIX)/include/graphviz \
		LIBRARY_SEARCH_PATHS=$(PREFIX)/lib \
		LD_RUNPATH_SEARCH_PATHS=$(PREFIX)/lib \
		ARCHS=$(ARCH) \
		MACOSX_DEPLOYMENT_TARGET=11.0 \
		__DIAGNOSE_INVALID_DEPLOYMENT_TARGET_AS_ERROR=NO \
		DSTROOT=/tmp/$(PROJECT).dst

.PHONY: cli
cli: $(PREFIX)/bin/dot
	@mkdir -p /tmp/$(PROJECT).dst/Applications/$(APP)/Contents/MacOS
	@mkdir -p /tmp/$(PROJECT).dst/Applications/$(APP)/Contents/Resources/Base.lproj
	clang -fobjc-arc -fmodules -target $(ARCH)-apple-macos11.0 \
		-I$(PREFIX)/include/graphviz \
		-L$(PREFIX)/lib \
		-Wl,-rpath,@executable_path/../Frameworks -Wl,-rpath,$(PREFIX)/lib \
		-lgvc -lcgraph -lcdt \
		-framework AppKit -framework Foundation -framework PDFKit \
		-framework UniformTypeIdentifiers -framework WebKit \
		*.m -o /tmp/$(PROJECT).dst/Applications/$(APP)/Contents/MacOS/$(PRODUCT)
	cp Info.plist /tmp/$(PROJECT).dst/Applications/$(APP)/Contents/
	cp Graphviz.icns GraphDot.icns GraphGv.icns /tmp/$(PROJECT).dst/Applications/$(APP)/Contents/Resources/
	cp schema/*.xml /tmp/$(PROJECT).dst/Applications/$(APP)/Contents/Resources/
	for f in Base.lproj/*.xib; do \
		ibtool --compile /tmp/$(PROJECT).dst/Applications/$(APP)/Contents/Resources/Base.lproj/$$(basename $$f .xib).nib $$f 2>/dev/null || true; \
	done
	codesign --force --sign - /tmp/$(PROJECT).dst/Applications/$(APP)

.PHONY: clean
clean:
	rm -rf build /Applications/$(APP) /tmp/$(PROJECT).dst

