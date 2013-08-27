NODEJS         = node
DOC_BIN        = naturaldocs
DOC_DIR        = ./doc/code
DOC_CONFIG_DIR = ./doc/config
DOC_CUSTOM_CSS = custom-1
SOURCE_DIR     = ./src
ASSETS_DIR     = ./assets
ASSETS_OUT     = $(SOURCE_DIR)/assets.js
DOC_INPUTS     = -i $(SOURCE_DIR)
SOURCES        = ${shell find $(SOURCE_DIR) -name "*.js"}

DEFAULT_COMPONENTS = core widget baseclient caching modules debug legacy googledrive dropboxclient
NOCACHE_COMPONENTS = core widget baseclient modules debug legacy googledrive dropboxclient

default: help

help:
	@echo "help           - display this text"
	@echo "all            - build regular, minified and AMD targets, plus all -nocache targets"
	@echo "build          - build remotestorage.js"
	@echo "build-amd      - build remotestorage.js with AMD wrapper"
	@echo "build-nocache  - build remotestorage.js without caching (plus AMD and .min versions of that)"
	@echo "minify         - minify remotestorage.js -> remotestorage.min.js"
	@echo "compile-assets - compile $(ASSETS_DIR)/* into $(ASSETS_OUT)"
	@echo "clean          - remove all builds and editor swapfiles"

all: build build-amd minify build-nocache
build-all: all
minify: remotestorage.min.js
build: remotestorage.js
build-amd: remotestorage.amd.js
build-nocache: remotestorage-nocache.js remotestorage-nocache.min.js remotestorage-nocache.amd.js
compile-assets: $(ASSETS_OUT)

.PHONY: help buildserver build-all compile-assets minify build doc clean

%.min.js: %.js
	uglifyjs $< -o $@ --mangle --wrap --export-all
	mv $@ $@.tmp
	head -n1 $< > $@
	cat $@.tmp >> $@
	rm $@.tmp

remotestorage.js: $(SOURCES)
	$(NODEJS) build/do-build.js remotestorage.js $(DEFAULT_COMPONENTS)

remotestorage.amd.js: $(SOURCES)
	$(NODEJS) build/do-build.js remotestorage.amd.js --amd $(DEFAULT_COMPONENTS)

# remotestorage.min.js: remotestorage.js
# 	uglifyjs remotestorage.js -o remotestorage.min.js --mangle --wrap --export-all
# ## copy version header from original (uglifyjs strips all comments):
# 	mv remotestorage.min.js remotestorage.min.js.tmp
# 	head -n1 remotestorage.js > remotestorage.min.js
# 	cat remotestorage.min.js.tmp >> remotestorage.min.js
# 	rm remotestorage.min.js.tmp

remotestorage-nocache.js: $(SOURCES)
	$(NODEJS) build/do-build.js $@ $(NOCACHE_COMPONENTS)

remotestorage-nocache.amd.js: $(SOURCES)
	$(NODEJS) build/do-build.js $@ --amd $(NOCACHE_COMPONENTS)

$(ASSETS_OUT): $(ASSETS_DIR)/*
	$(NODEJS) build/compile-assets.js $(ASSETS_DIR) $(ASSETS_OUT)

doc:
	mkdir -p $(DOC_DIR) $(DOC_CONFIG_DIR)
	$(DOC_BIN) $(DOC_INPUTS) -o html $(DOC_DIR) -p $(DOC_CONFIG_DIR) -s Default $(DOC_CUSTOM_CSS)

clean:
	rm -f remotestorage.js remotestorage.min.js remotestorage.amd.js remotestorage-nocache.js remotestorage-nocache.amd.js remotestorage-nocache.min.js ${shell find -name "*~"} ${shell find -name "*.swp"}
