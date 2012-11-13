#!/bin/make 

install:
	mkdir -p /etc/apt-cross
	chmod a+rw /etc/apt-cross
	rsync -avzul conf/ /etc/apt-cross

