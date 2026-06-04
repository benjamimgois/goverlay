SRC_DIR := src
OUT_DIR := bin
DOC_DIR := docs

TARGET  := $(OUT_DIR)/poca
LPI     := $(SRC_DIR)/pocarun.lpi

SOURCES := $(wildcard $(SRC_DIR)/**/*.pas) $(wildcard $(SRC_DIR)/*.pas)

DOC_SRC := $(wildcard docs/*.adoc)
DOC_OUT := $(DOC_SRC:.adoc=.html)

all: $(TARGET)

$(TARGET): $(SOURCES) $(LPI)
	mkdir -p $(OUT_DIR)
	~/fpcupdeluxe/lazarus/lazbuild -q --pcp="~/fpcupdeluxe/config_lazarus" --os=linux -B $(LPI)

test:
	@$(TARGET) tests/run.poca

docs: $(DOC_OUT)

$(DOC_OUT): %.html: %.adoc
	asciidoctor -a webfonts! $<

$DOCHTML: $(ADOCSRC)
	asciidoctor -a webfonts! docs/$@

clean:
	rm -f $(TARGET)

.PHONY: all test clean
