DotFiles = $(wildcard dot/*.dot)
DotSVGs = $(patsubst dot/%.dot, dotSvg/%.svg, $(DotFiles)) # list of object files

dotSvg/sub.svg : dot/sub.dot
	@dot -Kdot $< -o $@ -Tsvg

dotSvg/%.svg : dot/%.dot
	@dot -Kneato $< -o $@ -Tsvg

.PHONY: all
all: $(DotSVGs)
watch:
	while true; do \
		make all; \
		sleep 0.5; \
	done
