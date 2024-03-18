#######################################################################
# Copyright (c) 2011 AT&T Intellectual Property
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors: Details at http://www.graphviz.org/
#######################################################################

ARCH:=$(shell uname -m)

# optional packages URLs

include Makefile-packages.incl

# build directories

DOWN_DIR=$(HOME)/.downloads
OPTS_DIR=$(HOME)/.optionals
DEST_DIR=$(OPTS_DIR)/destdir
PREFIX=/usr/local

# build tools

CURL=curl
TAR=tar
MKDIR=mkdir -p
CMAKE=cmake
MESON=meson
NINJA=ninja
PIP=pip3

# tools binaries

PKGCONFIG=pkg-config

# tools directories

PYUSER_DIR:=$(shell python3 -m sysconfig | sed -n -E 's/.*userbase = "([^"]*)"/\1/'p)

# optional packages libraries

CAIRO=libcairo.dylib
PANGO=libpango-1.0.dylib
GTS=libgts.dylib
TIFF=libtiff.dylib
JPEG=libjpeg.dylib
X265=libx265.dylib
DE265=libde265.dylib
HEIF=libheif.dylib
WEBP=libwebp.dylib
GD=libgd.dylib

# optional packages directories

dirbuild=$(OPTS_DIR)/$(basename $(basename $(notdir $(1))))
CAIRO_DIR=$(call dirbuild, $(CAIRO_URL))
PANGO_DIR=$(call dirbuild, $(PANGO_URL))
GTS_DIR=$(call dirbuild, $(GTS_URL))
TIFF_DIR=$(call dirbuild, $(TIFF_URL))
JPEG_DIR=$(call dirbuild, $(JPEG_URL))
X265_DIR=$(call dirbuild, $(X265_URL))
DE265_DIR=$(call dirbuild, $(DE265_URL))
HEIF_DIR=$(call dirbuild, $(HEIF_URL))
WEBP_DIR=$(call dirbuild, $(WEBP_URL))
GD_DIR=$(call dirbuild, $(GD_URL))

#
# build variables
#

PATH:=$(DEST_DIR)$(PREFIX)/bin:$(PYUSER_DIR)/bin:$(TOOLS_DIR)/bin:$(PATH)
CFLAGS=-O3 -arch $(ARCH) -I$(DEST_DIR)$(PREFIX)/include
LDFLAGS=-arch $(ARCH)

#
# optional packages build variables
#

OPTS_CFLAGS=$(CFLAGS) -DHAVE_ICONV_T_DEF -I$(DEST_DIR)$(PREFIX)/include/libpng16
OPTS_ENV=PATH=$(PATH) CFLAGS="$(OPTS_CFLAGS)" LDFLAGS="$(LDFLAGS)"\
 PKG_CONFIG=$(TOOLS_DIR)/bin/$(PKGCONFIG) PKG_CONFIG_PATH=$(DEST_DIR)$(PREFIX)/lib/pkgconfig PKG_CONFIG_SYSROOT_DIR=$(DEST_DIR)

OPTS_CONFIG=$(OPTS_ENV) ./configure --prefix=$(PREFIX) --disable-dependency-tracking\
 --enable-shared --disable-static
OPTS_CMAKE=$(OPTS_ENV) $(CMAKE) --install-prefix=$(PREFIX)\
 -DCMAKE_BUILD_TYPE=Release -DCMAKE_MACOSX_RPATH=FALSE -DCMAKE_INSTALL_NAME_DIR=$(PREFIX)/lib
OPTS_MESON=$(OPTS_ENV) $(MESON) setup _build --prefix $(PREFIX)

#
# targets
#
# The all target builds several additional optional packages for graphviz.
#

.PHONY: all
all: $(PYUSER_DIR)/bin/$(MESON) $(TOOLS_DIR)/bin/$(NINJA) $(DEST_DIR)$(PREFIX)/lib/$(PANGO) $(DEST_DIR)$(PREFIX)/lib/$(GTS) $(DEST_DIR)$(PREFIX)/lib/$(GD)
	$(RM_LA)

$(DOWN_DIR):
	$(MKDIR) $@

$(OPTS_DIR):
	$(MKDIR) $@

clean:
	rm -rf $(OPTS_DIR)

#
# gts
#

$(DEST_DIR)$(PREFIX)/lib/$(GTS): $(GTS_DIR)
	@echo
	@echo BUILDING GTS...
	@echo
	cd $< && $(OPTS_CONFIG) --with-glib-prefix=$(DEST_DIR)$(PREFIX) --disable-glibtest
	$(OPTS_ENV) $(MAKE) DESTDIR=$(DEST_DIR) -C $< install

$(GTS_DIR): $(DOWN_DIR)/$(notdir $(GTS_DIR)).tar.gz | $(OPTS_DIR)
	@echo
	@echo UNTARRING GTS...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(GTS_DIR)).tar.gz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING GTS...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(GTS_URL) || rm -f $@

#
# pango
#
# downloads and installs subprojects:
#   glib - :pcre2, :gvdb, :libffi, :proxy-libintl
#   fribidi, harfbuzz

$(DEST_DIR)$(PREFIX)/lib/$(PANGO): $(PANGO_DIR)/_build
	@echo
	@echo BUILDING PANGO...
	@echo
	$(OPTS_ENV) DESTDIR=$(DEST_DIR) $(NINJA) -C $< install

$(PANGO_DIR)/_build: $(PANGO_DIR) $(DEST_DIR)$(PREFIX)/lib/$(CAIRO) $(PYUSER_DIR)/lib/python/site-packages/packaging | $(TOOLS_DIR)/bin/$(PKGCONFIG)
	@echo
	@echo CONFIGURING PANGO...
	@echo
	cd $< && $(OPTS_MESON) -Dfontconfig=enabled -Dfreetype=enabled -Dxft=disabled\
 -Dglib:tests=false -Dglib:glib_assert=false -Dglib:glib_checks=false

$(PANGO_DIR): $(DOWN_DIR)/$(notdir $(PANGO_DIR)).tar.xz | $(OPTS_DIR)
	@echo
	@echo UNTARRING PANGO...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(PANGO_DIR)).tar.xz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING PANGO...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(PANGO_URL) || rm -f $@

#
# cairo
#
# downloads and installs subprojects:
#   fontconfig, freetype2, libpng, pixman
#

$(DEST_DIR)$(PREFIX)/lib/$(CAIRO): $(CAIRO_DIR)/_build
	@echo
	@echo BUILDING CAIRO...
	@echo
	$(OPTS_ENV) DESTDIR=$(DEST_DIR) $(NINJA) -C $< install

$(CAIRO_DIR)/_build: $(CAIRO_DIR) | $(TOOLS_DIR)/bin/$(PKGCONFIG)
	@echo
	@echo CONFIGURING CAIRO...
	@echo
	cd $< && $(OPTS_MESON) -Dtests=disabled -Dglib=disabled -Dfreetype=enabled -Dfontconfig=enabled

$(CAIRO_DIR): $(DOWN_DIR)/$(notdir $(CAIRO_DIR)).tar.xz | $(OPTS_DIR)
	@echo
	@echo UNTARRING CAIRO...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(CAIRO_DIR)).tar.xz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING CAIRO...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(CAIRO_URL) || rm -f $@

#
# gd
#

$(DEST_DIR)$(PREFIX)/lib/$(GD): $(GD_DIR)/_build
	@echo
	@echo BUILDING GD...
	@echo
	$(OPTS_ENV) $(MAKE) DESTDIR=$(DEST_DIR) -C $< install

$(GD_DIR)/_build: $(GD_DIR) $(DEST_DIR)$(PREFIX)/lib/$(PANGO) $(DEST_DIR)$(PREFIX)/lib/$(HEIF) $(DEST_DIR)$(PREFIX)/lib/$(WEBP) | $(TOOLS_DIR)/bin/$(PKGCONFIG)
	@echo
	@echo CONFIGURING GD...
	@echo
	cd $< && $(OPTS_CMAKE) -S. -B_build\
 -DENABLE_ICONV=ON\
 -DENABLE_HEIF=ON -DHEIF_LIBRARY=$(DEST_DIR)$(PREFIX)/lib/$(HEIF)\
 -DENABLE_WEBP=ON -DWEBP_INCLUDE_DIR=$(DEST_DIR)$(PREFIX)/include -DWEBP_LIBRARY=$(DEST_DIR)$(PREFIX)/lib/$(WEBP)\
 -DCMAKE_SHARED_LINKER_FLAGS="-L$(DEST_DIR)$(PREFIX)/lib -lsharpyuv"
# -DENABLE_FONTCONFIG=ON\
# -DENABLE_FREETYPE=ON -DFREETYPE_INCLUDE_DIRS=$(DEST_DIR)$(PREFIX)/include/freetype2 -DFREETYPE_LIBRARY=$(DEST_DIR)$(PREFIX)/lib/libfreetype.dylib\
# -DENABLE_PNG=ON -DPNG_PNG_INCLUDE_DIR=$(DEST_DIR)$(PREFIX)/include -DPNG_LIBRARY=$(DEST_DIR)$(PREFIX)/lib/$(PNG)\
# -DENABLE_JPEG=ON -DJPEG_INCLUDE_DIR=$(DEST_DIR)$(PREFIX)/include -DJPEG_LIBRARY=$(DEST_DIR)$(PREFIX)/lib/$(JPEG)\
# -DENABLE_TIFF=ON -DTIFF_INCLUDE_DIR=$(DEST_DIR)$(PREFIX)/include -DTIFF_LIBRARY=$(DEST_DIR)$(PREFIX)/lib/$(TIFF)\

$(GD_DIR): $(DOWN_DIR)/$(notdir $(GD_DIR)).tar.gz | $(OPTS_DIR)
	@echo
	@echo UNTARRING GD...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(GD_DIR)).tar.gz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING GD...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(GD_URL) || rm -f $@

#
# tiff
#

$(DEST_DIR)$(PREFIX)/lib/$(TIFF): $(TIFF_DIR)/_build
	@echo
	@echo BUILDING TIFF...
	@echo
	$(OPTS_ENV) $(MAKE) DESTDIR=$(DEST_DIR) -C $< install

$(TIFF_DIR)/_build: $(TIFF_DIR) | $(TOOLS_DIR)/bin/$(PKGCONFIG)
	@echo
	@echo CONFIGURING TIFF...
	@echo
	cd $< && $(OPTS_CMAKE) -S. -B_build\
 -Djpeg=OFF -Dwebp=OFF

$(TIFF_DIR): $(DOWN_DIR)/$(notdir $(TIFF_DIR)).tar.gz | $(OPTS_DIR)
	@echo
	@echo UNTARRING TIFF...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(TIFF_DIR)).tar.gz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING TIFF...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(TIFF_URL) || rm -f $@

#
# jpeg
#

$(DEST_DIR)$(PREFIX)/lib/$(JPEG): $(JPEG_DIR)
	@echo
	@echo BUILDING JPEG...
	@echo
	cd $< && $(OPTS_CONFIG)
	$(OPTS_ENV) $(MAKE) DESTDIR=$(DEST_DIR) -C $< install

$(JPEG_DIR): $(DOWN_DIR)/$(notdir $(JPEG_DIR)).tar.gz | $(OPTS_DIR)
	@echo
	@echo UNTARRING JPEG...
	@echo
	$(TAR) xzf $< --cd $|
	ln -s jpeg-9f $@
	touch -am $@

$(DOWN_DIR)/$(notdir $(JPEG_DIR)).tar.gz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING JPEG...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(JPEG_URL) || rm -f $@

#
# heif
#

$(DEST_DIR)$(PREFIX)/lib/$(HEIF): $(HEIF_DIR)/_build
	@echo
	@echo BUILDING HEIF...
	@echo
	$(OPTS_ENV) $(MAKE) DESTDIR=$(DEST_DIR) -C $< install

$(HEIF_DIR)/_build: $(HEIF_DIR) $(DEST_DIR)$(PREFIX)/lib/$(X265) $(DEST_DIR)$(PREFIX)/lib/$(DE265) | $(TOOLS_DIR)/bin/$(PKGCONFIG)
	@echo
	@echo CONFIGURING HEIF...
	@echo
	cd $< && $(OPTS_CMAKE) -S. -B_build

$(HEIF_DIR): $(DOWN_DIR)/$(notdir $(HEIF_DIR)).tar.gz | $(OPTS_DIR)
	@echo
	@echo UNTARRING HEIF...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(HEIF_DIR)).tar.gz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING HEIF...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(HEIF_URL) || rm -f $@

#
# x265
#

$(DEST_DIR)$(PREFIX)/lib/$(X265): $(X265_DIR)/_build
	@echo
	@echo BUILDING X265...
	@echo
	$(OPTS_ENV) $(MAKE) DESTDIR=$(DEST_DIR) -C $< install

$(X265_DIR)/_build: $(X265_DIR) | $(TOOLS_DIR)/bin/$(PKGCONFIG)
	@echo
	@echo CONFIGURING X265...
	@echo
	cd $< && $(OPTS_CMAKE) -Ssource -B_build

$(X265_DIR): $(DOWN_DIR)/$(notdir $(X265_DIR)).tar.gz | $(OPTS_DIR)
	@echo
	@echo UNTARRING X265...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(X265_DIR)).tar.gz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING X265...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(X265_URL) || rm -f $@

#
# de265
#

$(DEST_DIR)$(PREFIX)/lib/$(DE265): $(DE265_DIR)/_build
	@echo
	@echo BUILDING DE265...
	@echo
	$(OPTS_ENV) $(MAKE) DESTDIR=$(DEST_DIR) -C $< install

$(DE265_DIR)/_build: $(DE265_DIR) | $(TOOLS_DIR)/bin/$(PKGCONFIG)
	@echo
	@echo CONFIGURING DE265...
	@echo
	cd $< && $(OPTS_CMAKE) -S. -B_build -DDISABLE_SSE=ON

$(DE265_DIR): $(DOWN_DIR)/$(notdir $(DE265_DIR)).tar.gz | $(OPTS_DIR)
	@echo
	@echo UNTARRING DE265...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(DE265_DIR)).tar.gz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING DE265...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(DE265_URL) || rm -f $@

#
# webp
#

$(DEST_DIR)$(PREFIX)/lib/$(WEBP): $(WEBP_DIR)
	@echo
	@echo BUILDING WEBP...
	@echo
	cd $< && $(OPTS_CONFIG)
	$(OPTS_ENV) $(MAKE) DESTDIR=$(DEST_DIR) -C $< install

$(WEBP_DIR): $(DOWN_DIR)/$(notdir $(WEBP_DIR)).tar.gz | $(OPTS_DIR)
	@echo
	@echo UNTARRING WEBP...
	@echo
	$(TAR) xzf $< --cd $| --exclude doc
	touch -am $@

$(DOWN_DIR)/$(notdir $(WEBP_DIR)).tar.gz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING WEBP...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(WEBP_URL) || rm -f $@
