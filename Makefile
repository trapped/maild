.PHONY: all deps

CRYSTAL ?= crystal

all: deps maild test

maild:
	mkdir -p bin
	$(CRYSTAL) build -o bin/maild src/maild.cr

test:
	$(CRYSTAL) spec spec/maild_spec.cr

deps:
	shards install
