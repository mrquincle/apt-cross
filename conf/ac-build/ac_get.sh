#!/bin/bash

source /etc/apt-cross/ac_color

ac_install_dir=/data/source
mkdir -p "$ac_install_dir"
export AC_INSTALL_DIR="$ac_install_dir"

echo -e ${OrangeF}"Create $ac_install_dir if it does not exist and export as AC_INSTALL_DIR variable"${FReset}

