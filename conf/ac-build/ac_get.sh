#!/bin/bash

source /etc/apt-cross/ac_color
source /etc/apt-cross/ac-build/paths

export AC_INSTALL_DIR="$AC_INSTALL_DIR"
mkdir -p "$AC_INSTALL_DIR"

echo -e ${OrangeF}"Create $AC_INSTALL_DIR if it does not exist and export as AC_INSTALL_DIR variable"${FReset}

