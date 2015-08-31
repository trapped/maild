.PHONY: all deps
all: deps
	mkdir -p bin
	crystal build -o bin/maild src/maild.cr

deps:
	shards install
