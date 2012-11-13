#!/bin/bash

source /etc/apt-cross/ac-build/ac_get.sh

source /etc/apt-cross/ac_color

cd $AC_INSTALL_DIR

#echo -e ${BlueF}"This version will obtain the code from an SVN server \n" \
# " so it will not make use of apt-get and henceforth is much more unreliable"${Reset}

#mkdir -p pointcloud
#cd pointcloud
#svn checkout http://svn.pointclouds.org/pcl/tags/pcl-1.6.0


PACKAGE_NAME=libpcl-1.6-all

echo -e ${BlueF}"Install $PACKAGE_NAME"${Reset}
echo -e ${GreenF}"********************************************************************************"
apt-get source $PACKAGE_NAME
echo -e "********************************************************************************"${Reset}

echo -e ${BlueF}"Build dependencies for $PACKAGE_NAME"${Reset}
echo -e ${GreenF}"********************************************************************************"
sudo aptitude build-dep $PACKAGE_NAME
echo -e "********************************************************************************"${Reset}

