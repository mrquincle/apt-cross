#Check http://www.cmake.org/Wiki/CMake_Cross_Compiling

# this one is important
SET(CMAKE_SYSTEM_NAME Linux)
#this one not so much
SET(CMAKE_SYSTEM_VERSION 1)

# type of compiler we want to use 
# use bfin-linux-uclibc-* for everything that runs within the uClinux OS
# use bfin-uclinux-* to create FLAT files instead of ELF files
# use bfin-elf-* to create barebone files (no OS expected)
SET (COMPILER_TYPE bfin-linux-uclibc)
SET (COMPILER_TYPE_PREFIX ${COMPILER_TYPE}-)

# Load config file from user if it exists
SET(CONFIG_FILE "/etc/apt-cross/ac-build/paths")
IF (NOT EXISTS "${CONFIG_FILE}")
	MESSAGE(FATAL "Cannot find ${CONFIG_FILE}")
ENDIF()

FILE(STRINGS ${CONFIG_FILE} ConfigContents)
FOREACH(Item ${ConfigContents})
	STRING(REGEX REPLACE "^[ ]+" "" UnindentedItem ${Item})
	# only keep everything before # sign
	STRING(REGEX MATCH "^[^#]+" NameAndValue ${UnindentedItem})
	IF (NOT "${NameAndValue}" STREQUAL "")
		# name is thing before = sign, value comes after
		STRING(REGEX MATCH "^[^=]+" Name ${NameAndValue})
		STRING(REPLACE "${Name}=" "" Value ${NameAndValue})
		IF (NOT "${Name}" STREQUAL "" AND NOT "${Value}" STREQUAL "")
			MESSAGE(STATUS "Set ${Name}=${Value}")
			SET(${Name} "${Value}")
		ENDIF()
	ENDIF()
ENDFOREACH()

# set the path to the cross-compiler
SET(BFIN "/opt/uClinux/${COMPILER_TYPE}")
SET(PATH "${PATH}:${BFIN}/bin")

# specify the cross compiler, linker, etc.
SET(CMAKE_C_COMPILER		${COMPILER_TYPE_PREFIX}gcc)
SET(CMAKE_CXX_COMPILER		${COMPILER_TYPE_PREFIX}g++)
SET(CMAKE_LINKER		${COMPILER_TYPE_PREFIX}ld)

# find the libraries
# http://qmcpack.cmscc.org/getting-started/using-cmake-toolchain-file

IF ("${CROSS_COMPILE_WORKSPACE}" STREQUAL "") 
	MESSAGE(FATAL "CROSS_COMPILE_WORKSPACE should have been defined in ${CONFIG_FILE}")
ENDIF()

# set the installation root (should contain usr/local and usr/lib directories)
SET(DESTDIR ${CROSS_COMPILE_WORKSPACE}/blackfin)

# here will the header files be installed on "make install"
SET(CMAKE_INSTALL_PREFIX ${DESTDIR}/usr/local)

# add the libraries from the installation directory (if they have been build before)
LINK_DIRECTORIES("${DESTDIR}/usr/local/lib")

# the following doesn't seem to work so well
SET(CMAKE_INCLUDE_PATH ${DESTDIR}/usr/local/include)

# indicate where the linker is allowed to search for library / headers
SET(CMAKE_FIND_ROOT_PATH 
	${BFIN}/${COMPILER_TYPE}/runtime
	${DESTDIR})

# search for programs in the build host directories
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

