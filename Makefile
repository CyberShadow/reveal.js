DMD=dmd
SLIDES = $(shell find slides -type f)

.SUFFIXES:

all : index.html plugin/highlight/highlight.js

index.html : Makefile gen.d index-template.html $(SLIDES)
	rdmd gen.d

plugin/highlight/highlight.js : plugin/highlight/highlight_integration.js highlight.js/build/highlight.pack.js
	cat $^ > $@

highlight.js/build/highlight.pack.js : $(shell find highlight.js/src -name '*.js')
	cd highlight.js && node tools/build.js d

watch :
	while true; do find Makefile gen.d index-template.html slides | entr -d make ; done
