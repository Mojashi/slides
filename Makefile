DotFiles = $(wildcard dot/*.dot)
dotSVGs = $(patsubst dot/%.dot, assets/%.dot.svg, $(DotFiles))

MmdFiles = $(wildcard mmd/*.mmd)
mmdSVGs = $(patsubst mmd/%.mmd, assets/%.mmd.svg, $(MmdFiles))

.PHONY: env
env:
	npm i -g @marp-team/marp-cli;
	npm i -g @mermaid-js/mermaid-cli;
	pip install pandas matplotlib;

assets/time.png: time.csv misc/BIZUDGothic-Regular.ttf time_plot.py
	python time_plot.py

assets/t1.dot.svg: dot/t1.dot
	@dot -Kneato $< -o $@ -Tsvg
assets/t2.dot.svg: dot/t2.dot
	@dot -Kneato $< -o $@ -Tsvg

assets/%.dot.svg: dot/%.dot
	@dot -Kdot $< -o $@ -Tsvg

assets/%.mmd.svg : mmd/%.mmd
	@mmdc -i $< -o $@

.PHONY: all
all: $(dotSVGs) $(mmdSVGs) assets/time.png
watch:
	while true; do \
		make all; \
		sleep 0.5; \
	done

serve:
	marp -s . --html
build: all
	marp slide.md --html --theme academic.css -o index.html

misc/BIZUDGothic.zip:
	wget "https://fonts.google.com/download?family=BIZ%20UDGothic" -O misc/BIZUDGothic.zip

misc/BIZUDGothic-Regular.ttf: misc/BIZUDGothic.zip
	unzip -j -o misc/BIZUDGothic.zip BIZUDGothic-Regular.ttf  -d misc
