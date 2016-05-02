DMD=dmd
SLIDES = $(shell find slides -type f)

index.html : Makefile gen.d index-template.html $(SLIDES)
	rdmd gen.d

watch :
	while true; do find Makefile gen.d index-template.html slides | entr -d make ; done
