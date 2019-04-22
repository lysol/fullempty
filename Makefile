.PHONY: build clean sync

BUILD_DIR=./bin

all: build sync clean

build:
	@ echo build
	@./src/index

clean:
	./clean

sync:
	./sync

