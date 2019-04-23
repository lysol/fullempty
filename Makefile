.PHONY: build clean sync

build_dir = ./bin
# ssh target
rsync_target = loam:~/public_html/

all: build sync clean

build:
	@ echo build
	@./src/index

clean:
	rm -rf $(build_dir)/*

sync:
	rsync -atv ./bin/ $(rsync_target)

