#!/bin/make 

all:
	@echo "This is just a set of bash scripts and configuration files"
	@echo "No need to build, just run sudo make install"

install:
	mkdir -p /etc/apt-cross
	chmod a+rw /etc/apt-cross
	rsync -avzul conf/ /etc/apt-cross
	cp apt-cross /usr/bin
