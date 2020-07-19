
SHELL := /bin/sh
UNAME := $(shell uname)
.SUFFIXES:
.SUFFIXES: .pdf .tex .dvi

TEXENV_DIR := $(HOME)/.dotfiles/bash/texenvs
TMP := /tmp

TEX := platex -recorder -shell-escape

TEX_FILE  := $(wildcard *.tex)
PDF_FILE  := $(patsubst %.tex, %.pdf, $(TEX_FILE))
PPTX_FILE := $(patsubst %.tex, %.pptx, $(TEX_FILE))

PNG_TEX   := $(shell find . -type f -name '*.tex')
PNG_FILE  := $(patsubst %.tex, %.png, $(PNG_TEX))

COMPILE_CNT := 1

ifeq ($(UNAME), Linux)
OPEN := xdg-open 2>/dev/null
else
ifeq ($(UNAME), Darwin)
OPEN := evince
else
OPEN := open
endif
endif

.PHONY: init pdf punctuation open clean distclean rebuild test

all: pdf

init: OUTPUT = report.tex
init:
	@echo 'Creating latex environment ...'
	-mkdir img 2>/dev/null && touch img/.keep
	@echo 'OUTPUT='$(OUTPUT)
	-cp -i $(TEXENV_DIR)/template.tex $(OUTPUT)

init-presen:
	@echo 'Creating presen environment ...'
	-mkdir img 2>/dev/null && touch img/.keep
	-mkdir pages 2>/dev/null && touch pages/.keep
	-cp -i $(TEXENV_DIR)/presen/.gitignore .
	-cp -R -i $(TEXENV_DIR)/presen/* .

init-standalone: OUTPUT = standalone.tex
init-standalone:
	@echo 'Creating standalone environment ...'
	-cp -i $(TEXENV_DIR)/standalone/.gitignore .
	-cp -i $(TEXENV_DIR)/standalone/standalone.tex $(OUTPUT)

install:
	sudo tlmgr install newtx collection-latexrecommended collection-fontsrecommended collection-langjapanese comment pgfplots dvipdfmx markdown csvsimple paralist

install-presen:
	sudo tlmgr install newtx beamer bxdpx-beamer
	pip3 install python-pptx

install-standalone:
	sudo tlmgr install standalone

%.dvi: %.tex
	@for i in `seq 1 $(COMPILE_CNT)`; do \
		yes q | head | $(TEX) $<; \
	done
	@for i in `seq 1 3`; do \
		if grep -F 'Rerun to get cross-references right.' $(<:.tex=.log) || \
			grep -F 'Package rerunfilecheck Warning' $(<:.tex=.log); \
		then \
			yes q | head | $(TEX) $<; \
		else \
			exit 0; \
		fi; \
	done

%.png: %.tex
	mkdir -p $(TMP)/$$$$ && \
	platex -shell-escape -halt-on-error -output-directory=$(TMP)/$$$$ $< && \
	dvipdfmx -d5 -o $(TMP)/$$$$/$(basename $(notdir $<)).pdf $(TMP)/$$$$/$(basename $(notdir $<)).dvi && \
	convert -density 200 $(TMP)/$$$$/$(basename $(notdir $<)).pdf[0] -quality 90 $@ && \
	touch $@ \
	&& rm -r $(TMP)/$$$$ \
	|| rm -r $(TMP)/$$$$

%.pdf: %.dvi
	dvipdfmx -d5 $<
	-test -f title.pdf && pdfunite title.pdf $@ /tmp/$$$$.pdf && mv /tmp/$$$$.pdf $@ || true
	-test -d _markdown_report && $(RM) -r _markdown_report || true

%.pptx: %.pdf presen-note.txt
	./bin/pdf2pptx.sh

pdf: $(PDF_FILE)

pptx presen: $(PPTX_FILE)

png: $(PNG_FILE)

punctuation punc pun: $(TEX_FILE)
	$(foreach file, $?, \
		cat "$(file)" | sed -e 's/。/．/g' | sed -e 's/、/，/g' > /tmp/$$$$.tex \
		&& mv /tmp/$$$$.tex "$(file)"; \
	)
	$(foreach file, $(wildcard */*.tex), \
		cat "$(file)" | sed -e 's/。/．/g' | sed -e 's/、/，/g' > /tmp/$$$$.tex \
		&& mv /tmp/$$$$.tex "$(file)"; \
	)

open: $(PDF_FILE)
	$(OPEN) $(PDF_FILE) &

clean:
	$(RM) *.{aux,log,dvi,fls}

distclean: clean
	$(RM) $(PDF_FILE)

rebuild re:
	touch $(TEX_FILE)
	$(MAKE) pdf

test:
	latex-test $(TEX_FILE)

jlisting.sty:
	cp $(TEXENV_DIR)/jlisting.sty .
