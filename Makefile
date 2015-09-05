.PHONY: all deps
all: deps
	mkdir -p bin
	LIBRARY_PATH="/opt/crystal/embedded/lib" ~/crystal/bin/crystal build -o bin/maild src/maild.cr

test:
	LIBRARY_PATH="/opt/crystal/embedded/lib" ~/crystal/bin/crystal spec spec/maild_spec.cr

deps:
	shards install
