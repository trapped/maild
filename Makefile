.PHONY: all deps

CRYSTAL ?= crystal

all: deps maild db.tool test

maild:
	mkdir -p bin
	$(CRYSTAL) build -o bin/maild src/maild.cr

db.tool:
	mkdir -p bin
	$(CRYSTAL) build -o bin/db.tool src/db_tool.cr

test:
	$(CRYSTAL) spec spec/maild_spec.cr

deps:
	shards install
