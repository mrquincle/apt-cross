#!/bin/bash


#DEPENDENCIES=libflann-dev
#echo -e ${YellowF}"Install dependencies:\n"\
#	"$DEPENDENCIES"${Reset}

#sudo apt-get install ${DEPENDENCIES} -y

PPA=v-launchpad-jochen-sprickerhof-de/pcl

PPA_ENABLED=`egrep --exclude=*.save -v '^#|deb-src|^ *$' /etc/apt/sources.list /etc/apt/sources.list.d/* | grep $PPA`

if [[ -n $PPA_ENABLED ]]; then
	echo -e ${YellowF}"PPA repository $PPA is enabled"${Reset}
else

	echo -e ${YellowF}"Enable PPA repository:\n"\
	"$PPA"${Reset}

	sudo add-apt-repository ppa:$PPA 
	sudo apt-get update
fi

