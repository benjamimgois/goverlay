all: scene3ddumpanalyzer

CFLAGS ?= -O2 -std=gnu99 -Wall -Wextra -D_DEFAULT_SOURCE

scene3ddumpanalyzer: scene3ddumpanalyzer.c
	$(CC) $(CFLAGS) -o $@ $< -lm

clean:
	rm -f scene3ddumpanalyzer

.PHONY: all clean
