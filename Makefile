.PHONY: build clean sync

build_dir = ./build/
# ssh target
rsync_target = loam:~/public_html/

all: build sync clean

build:
	@ echo Building.
	@./src/index

clean:
	@echo Cleaning.
	rm -rf $(build_dir)*

sync:
	@echo Syncing to server
	rsync -atv $(build_dir) $(rsync_target)

