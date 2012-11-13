#!/bin/bash

################################################################################
# Configuration option 
################################################################################

extracted_dir_mask=libjpeg6*

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

echo "Configure"
./configure --host $HOST --prefix "${PREFIX_PATH}/usr"

echo "Make and install"
make
make install
