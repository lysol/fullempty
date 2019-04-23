.PHONY: build clean sync

BUILD_DIR = ./build/
# ssh target
SYNC_TARGET = loam:~/public_html/

all: build sync clean

build:
	@ echo Building.
	@BUILD_DIR=$(BUILD_DIR) ./src/index.sh

clean:
	@echo Cleaning.
	rm -rf $(BUILD_DIR)*

sync:
	@echo Syncing to server
	rsync -atv $(BUILD_DIR) $(SYNC_TARGET)

