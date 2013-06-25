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
* mkdir -p /data # as normal user
* sudo make install

The configuration files will be copied to /etc/apt-cross, you can add your own if you'd like.

## How to use?

After installation, you can compile e.g. opencv by:

* apt-cross opencv blackfin

Or you can compile libjpeg for the Blackfin by:

* apt-cross libjpeg62 blackfin

It doesn't matter where you execute those commands.

The downloaded source files you can now find in /data/source and the compiled results you can find in /data/blackfin e.g.

## Where can I read more?
Nowhere... for now. :-)

## Copyrights
The copyrights (2012) belong to:

- Author: Anne van Rossum
- Almende B.V., http://www.almende.com and DO bots B.V., http://www.dobots.nl
- Rotterdam, The Netherlands
