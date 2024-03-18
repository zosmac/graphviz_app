# causes socklen_t missing with M4 configure
#ARCHFLAGS=-arch arm64 -arch x86_64
ARCHFLAGS=-arch arm64

# tools URLs

include Makefile-packages.incl

# build directories

DOWN_DIR=$(HOME)/.downloads
TOOLS_DIR=$(HOME)/.local
PREFIX=/usr/local

# build tools

CURL=curl
TAR=tar
MKDIR=mkdir -p
BISON=bison
CMAKE=cmake
MESON=meson
NINJA=ninja
PIP=pip3

# GNU tools binaries

M4=m4
AUTOCONF=autoconf
AUTOMAKE=automake
LIBTOOL=libtoolize
PKGCONFIG=pkg-config

# tools directories

dirtools=$(TOOLS_DIR)/$(basename $(basename $(notdir $(1))))
M4_DIR=$(call dirtools, $(M4_URL))
AUTOCONF_DIR=$(call dirtools, $(AUTOCONF_URL))
AUTOMAKE_DIR=$(call dirtools, $(AUTOMAKE_URL))
LIBTOOL_DIR=$(call dirtools, $(LIBTOOL_URL))
PKGCONFIG_DIR=$(call dirtools, $(PKGCONFIG_URL))
BISON_DIR=$(call dirtools, $(BISON_URL))
CMAKE_DIR=$(call dirtools, $(CMAKE_URL))
PYUSER_DIR:=$(shell python3 -m sysconfig | sed -n -E 's/.*userbase = "([^"]*)"/\1/'p)
NINJA_DIR=$(call dirtools, $(NINJA_URL))

#
# build variables
#

PATH:=$(PYUSER_DIR)/bin:$(TOOLS_DIR)/bin:$(PATH)
CFLAGS=-O3 $(ARCHFLAGS)
CXXFLAGS=-O3 $(ARCHFLAGS)
OBJCFLAGS=-O3 $(ARCHFLAGS)
LDFLAGS=$(ARCHFLAGS)

#
# tool build variables
#

ENV=PATH=$(PATH) CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" OBJCFLAGS="$(OBJCFLAGS)" LDFLAGS="$(LDFLAGS)"
CONFIG=./configure --prefix=$(TOOLS_DIR) --disable-dependency-tracking --enable-static --disable-shared

#
# targets
#
# The default target installs the GNU tools necessary to build graphviz.
# To build graphviz with CMake, instead specify the cmake target.
# If also building the optionals, specify the all target for additional required tools.
#

.PHONY: gnu
gnu: $(TOOLS_DIR)/bin/$(AUTOMAKE) $(TOOLS_DIR)/bin/$(LIBTOOL) $(TOOLS_DIR)/bin/$(PKGCONFIG) $(TOOLS_DIR)/bin/$(BISON)

.PHONY: cmake
cmake: $(TOOLS_DIR)/bin/$(CMAKE) $(TOOLS_DIR)/bin/$(BISON)

.PHONY: all
all: gnu cmake $(PYUSER_DIR)/bin/$(MESON) $(TOOLS_DIR)/bin/$(NINJA)

$(DOWN_DIR):
	$(MKDIR) $@

$(TOOLS_DIR):
	$(MKDIR) $@

clean:
	$(PIP) uninstall -y packaging
	$(PIP) uninstall -y $(MESON)
	rm -rf $(TOOLS_DIR)

distclean: clean
	rm -rf $(DOWN_DIR)

#
# tools targets
#

#
# m4
#

$(TOOLS_DIR)/bin/$(M4): $(M4_DIR)
	@echo
	@echo BUILDING M4...
	@echo
	cd $< && $(ENV) $(CONFIG)
	$(ENV) $(MAKE) -C $< install

$(M4_DIR): $(DOWN_DIR)/$(notdir $(M4_DIR)).tar.xz | $(TOOLS_DIR)
	@echo
	@echo UNTARRING M4...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(M4_DIR)).tar.xz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING M4...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(M4_URL) || rm -f $@

#
# autoconf
#

$(TOOLS_DIR)/bin/$(AUTOCONF): $(AUTOCONF_DIR) $(TOOLS_DIR)/bin/$(M4)
	@echo
	@echo BUILDING AUTOCONF...
	@echo
	cd $< && $(ENV) $(CONFIG)
	$(ENV) $(MAKE) -C $< install

$(AUTOCONF_DIR): $(DOWN_DIR)/$(notdir $(AUTOCONF_DIR)).tar.xz | $(TOOLS_DIR)
	@echo
	@echo UNTARRING AUTOCONF...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(AUTOCONF_DIR)).tar.xz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING AUTOCONF...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(AUTOCONF_URL) || rm -f $@

#
# automake
#

$(TOOLS_DIR)/bin/$(AUTOMAKE): $(AUTOMAKE_DIR) $(TOOLS_DIR)/bin/$(AUTOCONF)
	@echo
	@echo BUILDING AUTOMAKE...
	@echo
	cd $< && $(ENV) $(CONFIG)
	$(ENV) $(MAKE) -C $< install

$(AUTOMAKE_DIR): $(DOWN_DIR)/$(notdir $(AUTOMAKE_DIR)).tar.xz | $(TOOLS_DIR)
	@echo
	@echo UNTARRING AUTOMAKE...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(AUTOMAKE_DIR)).tar.xz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING AUTOMAKE...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(AUTOMAKE_URL) || rm -f $@

#
# libtool
#

$(TOOLS_DIR)/bin/$(LIBTOOL): $(LIBTOOL_DIR)
	@echo
	@echo BUILDING LIBTOOL...
	@echo
	cd $< && $(ENV) $(CONFIG)
	$(ENV) $(MAKE) -C $< install

$(LIBTOOL_DIR): $(DOWN_DIR)/$(notdir $(LIBTOOL_DIR)).tar.xz | $(TOOLS_DIR)
	@echo
	@echo UNTARRING LIBTOOL...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(LIBTOOL_DIR)).tar.xz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING LIBTOOL...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(LIBTOOL_URL) || rm -f $@

#
# pkgconfig
#

$(TOOLS_DIR)/bin/$(PKGCONFIG): $(PKGCONFIG_DIR)
	@echo
	@echo BUILDING PKGCONFIG...
	@echo
	cd $< && $(ENV) CFLAGS="-Wno-int-conversion $(CFLAGS)" CXXFLAGS="-Wno-int-conversion $(CXXFLAGS)" $(CONFIG) --with-internal-glib
	$(ENV) CFLAGS="-Wno-int-conversion $(CFLAGS)" CXXFLAGS="-Wno-int-conversion $(CXXFLAGS)" $(MAKE) -C $< install

$(PKGCONFIG_DIR): $(DOWN_DIR)/$(notdir $(PKGCONFIG_DIR)).tar.gz | $(TOOLS_DIR)
	@echo
	@echo UNTARRING PKGCONFIG...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(PKGCONFIG_DIR)).tar.gz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING PKGCONFIG...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(PKGCONFIG_URL) || rm -f $@

#
# bison (macOS bison is too old)
#

$(TOOLS_DIR)/bin/$(BISON): $(BISON_DIR)
	@echo
	@echo BUILDING BISON...
	@echo
	cd $< && $(ENV) $(CONFIG)
	$(ENV) $(MAKE) -C $< install

$(BISON_DIR): $(DOWN_DIR)/$(notdir $(BISON_DIR)).tar.xz | $(TOOLS_DIR)
	@echo
	@echo UNTARRING BISON...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(BISON_DIR)).tar.xz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING BISON...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(BISON_URL) || rm -f $@

#
# cmake
#

$(TOOLS_DIR)/bin/$(CMAKE): $(CMAKE_DIR)
	@echo
	@echo BUILDING CMAKE...
	@echo
	cd $< && $(ENV) ./bootstrap --prefix=$(TOOLS_DIR)
	$(ENV) $(MAKE) -C $< install

$(CMAKE_DIR): $(DOWN_DIR)/$(notdir $(CMAKE_DIR)).tar.gz | $(TOOLS_DIR)
	@echo
	@echo UNTARRING CMAKE...
	@echo
	$(TAR) xzf $< --cd $|
	touch -am $@

$(DOWN_DIR)/$(notdir $(CMAKE_DIR)).tar.gz: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING CMAKE...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(CMAKE_URL) || rm -f $@

#
# tools for building optional packages
#

#
# python packaging
#

$(PYUSER_DIR)/lib/python/site-packages/packaging:
	@echo
	@echo INSTALLING PACKAGING...
	@echo
	$(PIP) install --user packaging

#
# meson (tool)
#

$(PYUSER_DIR)/bin/$(MESON):
	@echo
	@echo INSTALLING MESON...
	@echo
	$(PIP) install --user $(MESON)

#
# ninja (tool)
#

$(TOOLS_DIR)/bin/$(NINJA): $(DOWN_DIR)/$(notdir $(NINJA_DIR)).zip
	@echo
	@echo UNZIPPING NINJA...
	@echo
	$(TAR) xzf $< --cd $(@D)
	touch -am $@

$(DOWN_DIR)/$(notdir $(NINJA_DIR)).zip: | $(DOWN_DIR)
	@echo
	@echo TRANSFERRING NINJA...
	@echo
	$(CURL) --output-dir $| --remote-name --location $(NINJA_URL) || rm -f $@

