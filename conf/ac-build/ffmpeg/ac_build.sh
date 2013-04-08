#!/bin/bash

################################################################################
# Configuration option 
################################################################################

extracted_dir_mask=libav*

################################################################################
# Checking and including stuff
################################################################################

target=$1

if [[ "$target" == "" ]]
then
	echo "Use $0 with argument \"target\""
	exit 1
fi

source /etc/apt-cross/ac-build/ac_get.sh
source /etc/apt-cross/ac-platform/$target.sh

cd $AC_INSTALL_DIR
echo "Go to $extracted_dir_mask"
cd $extracted_dir_mask

################################################################################
# 
################################################################################

echo "Arrived in directory " $(pwd)

echo "Configure"
./configure --enable-cross-compile --arch=bfin --target-os=linux --cpu=bfin \
	 --extra-ldflags=" -Wl,-elf2flt -mcpu=bf561" --prefix="${PREFIX_PATH}/usr"

echo "Make"
VERBOSE=1 make
echo "Install"
make install
