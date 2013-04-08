#!/bin/bash

################################################################################
# Configuration option 
################################################################################

extracted_dir_mask=v4l-utils*

confpath=/etc/apt-cross/ac-build/v4l-utils/

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

echo "Go to installation path $AC_INSTALL_DIR"
cd $AC_INSTALL_DIR

echo "Go to $extracted_dir_mask"
cd $extracted_dir_mask

################################################################################
# 
################################################################################

# Have /data/blackfin as default installation folder
PREFIX_PATH=/data/$target

echo "patch Makefile < ${confpath}/Makefile.patch"
patch Makefile < ${confpath}/Makefile.patch
echo "patch Make.rules < ${confpath}/Make.rules"
patch Make.rules < ${confpath}/Make.rules.patch

#echo "Configure"
#./configure --host $HOST --prefix "${PREFIX_PATH}/usr"

echo "Make and install"
make
make install
