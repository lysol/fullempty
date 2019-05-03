.PHONY: build clean sync

BUILD_DIR = ./build/
# ssh target
SYNC_TARGET = loam:~/public_html/
POST_INDEX = posts.csv

all: posttime build sync clean

build:
	@ echo Building.
	@BUILD_DIR=$(BUILD_DIR) POST_INDEX=$(POST_INDEX) ./src/index.sh

sync:
	@echo Syncing to server
	rsync -atv $(BUILD_DIR) $(SYNC_TARGET)

posttime:
	@echo Fixing timestamps on files
	./src/posttime.sh

clean:
	@echo Cleaning.
	rm -rf $(BUILD_DIR)*

