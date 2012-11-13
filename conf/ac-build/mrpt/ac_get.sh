#!/bin/bash

source /etc/apt-cross/ac-build/ac_get.sh

cd $AC_INSTALL_DIR

echo "Make sure you have deb-src lines in your /etc/apt/sources.list files"
echo "to make \"apt-get source\" work"

apt-get source mrpt
