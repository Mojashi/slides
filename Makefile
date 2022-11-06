DotFiles = $(wildcard dot/*.dot)
dotSVGs = $(patsubst dot/%.dot, assets/%.dot.svg, $(DotFiles))

MmdFiles = $(wildcard mmd/*.mmd)
mmdSVGs = $(patsubst mmd/%.mmd, assets/%.mmd.svg, $(MmdFiles))


assets/t1.dot.svg: dot/t1.dot
	@dot -Kneato $< -o $@ -Tsvg
assets/t2.dot.svg: dot/t2.dot
	@dot -Kneato $< -o $@ -Tsvg

assets/%.dot.svg: dot/%.dot
	@dot -Kdot $< -o $@ -Tsvg

assets/%.mmd.svg : mmd/%.mmd
	@mmdc -i $< -o $@

.PHONY: all
all: $(dotSVGs) $(mmdSVGs)
watch:
	while true; do \
		make all; \
		sleep 0.5; \
	done
