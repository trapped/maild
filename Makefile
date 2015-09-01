.PHONY: all deps
all: deps
	mkdir -p bin
	LIBRARY_PATH="/opt/crystal/embedded/lib" ~/crystal/bin/crystal build -o bin/maild src/maild.cr

deps:
	shards install
