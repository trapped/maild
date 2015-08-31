.PHONY: all deps
all: deps
	mkdir bin > /dev/null
	crystal build -o bin/maild src/maild.cr

deps:
	shards install
