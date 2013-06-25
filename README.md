<!-- Uses markdown syntax for neat display at github -->

# apt-cross
The apt-cross utility is meant for cross-compilation on Debian systems.

## What does it do?
Underlying to apt-cross, "apt-get source" is used which is a standard Debian utility. 

## Is it good?
Compared to bitbake, apt-cross makes use of source code that actually compiles on Debian, or in this case Ubuntu systems. Compilation for the host will naturally work fine, because the packages are build on the servers of Ubuntu with corresponding patches, if necessary. This is by the way important to realize, something patches by the Ubuntu developers are a little sloppy, not taking into account characteristics of embedded platforms, contrary to the original developers.

## What are the alternatives?
There are no known alternatives. 

In hindsight, I found that there was actually, at some time, a apt-cross utility. That version however required like 1GB of diskspace.

## How to install?
To install:

* git clone git@github.com:mrquincle/apt-cross.git
* # adjust the conf/ac-build/paths file, CROSS\_COMPILE\_WORKSPACE and AC\_INSTALL\_DIR to whatever you prefer
* sudo make install
* # after installation you can adjust this file in /etc/apt-cross/ac-build/paths

All the configuration files will be copied to /etc/apt-cross. You can add your own build files to ac-build/package_name.

## How to use?

After installation, you can compile e.g. opencv by:

* apt-cross opencv blackfin

Or you can compile libjpeg for the Blackfin by:

* apt-cross libjpeg62 blackfin

It doesn't matter where you execute those commands.

The downloaded source files you can now find in AC\_INSTALL\_DIR (by default $HOME/mydata/source) and the compiled results you can find by default in $HOME/mydata/blackfin e.g. when the TARGET has been the blackfin microcontroller.

## Where can I read more?
Nowhere... for now. :-)

## Copyrights
The copyrights (2012) belong to:

- Author: Anne van Rossum
- Almende B.V., http://www.almende.com and DO bots B.V., http://www.dobots.nl
- Rotterdam, The Netherlands
