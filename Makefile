all: build test-build

build:
	coffee -j ./tourist.js -c src

test-build:
	coffee -c -o test/lib test/src

watch:
	coffee -j ./tourist.js -cw src

test-watch:
	coffee -o test/lib -cw test/src

.PHONY: build test-build clean watch test-watch