SLIDES = $(shell find slides -type f)
index.html : Makefile index-template.html $(SLIDES)
	find slides -type f | sort | (set -eux	;					\
		while read FN ; do							\
			case $$FN in							\
			*.md)								\
				echo '<section data-markdown data-separator="^\\n---\\n$$" data-separator-vertical="^\\n--\\n$$">' ; \
				echo '<script type="text/template">'		;	\
				cat $$FN					;	\
				echo '</script></section>'			;	\
				;;							\
			*.html)								\
				cat $$FN					;	\
				;;							\
			*)								\
				echo "<!-- ignoring unknown extension $$FN>"	;	\
				;;							\
			esac								\
		done ) > content.html
	( grep -B 1000 SLIDES index-template.html ; cat content.html ; grep -A 1000 SLIDES index-template.html ) > index.html
	rm content.html

watch :
	while true; do find Makefile index-template.html slides | entr -d make ; done
