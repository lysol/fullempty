.PHONY: build clean sync

BUILD_DIR=./bin

build:
	@./src/index

clean:
	@./clean

sync:
	./sync

