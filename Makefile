NAME:=$(shell basename $(CURDIR))

build:
	rm -rf build
	mkdir -p build
	odin build src/ -out:build/$(NAME)

run: build
	./build/$(NAME)

