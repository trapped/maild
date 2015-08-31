.PHONY: all deps
all: deps
	crystal build src/maild.cr

deps:
	shards install
