
TIKZ_DIR := ./media/post/tikz

all: png

png:
	cd $(TIKZ_DIR) && $(MAKE) png
