.PHONY: all deps
all: deps
  crystal build -o bin/maild src/maild.cr

deps:
  shards install
