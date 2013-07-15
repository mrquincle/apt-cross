#!/bin/bash

################################################################################
# Configuration option 
################################################################################

extracted_dir_mask=opencv*

################################################################################
# Enables colors
################################################################################

# Example usage:
# echo -e ${RedF}This text will be red!${Reset}
# echo -e ${BlueF}${BoldOn}This will be blue and bold!${BoldOff} - and this is just blue!${Reset}
# echo -e ${RedB}${BlackF}This has a red background and black font!${Reset}and everything after the reset is normal text!
colors() {
	Escape="\033";
	BlackF="${Escape}[30m"; RedF="${Escape}[31m";   GreenF="${Escape}[32m";
	YellowF="${Escape}[33m";  BlueF="${Escape}[34m";    Purplef="${Escape}[35m";
	CyanF="${Escape}[36m";    WhiteF="${Escape}[37m";
	BlackB="${Escape}[40m";     RedB="${Escape}[41m";     GreenB="${Escape}[42m";
	YellowB="${Escape}[43m";    BlueB="${Escape}[44m";    PurpleB="${Escape}[45m";
	CyanB="${Escape}[46m";      WhiteB="${Escape}[47m";
	BoldOn="${Escape}[1m";      BoldOff="${Escape}[22m";
	ItalicsOn="${Escape}[3m";   ItalicsOff="${Escape}[23m";
	UnderlineOn="${Escape}[4m";     UnderlineOff="${Escape}[24m";
	BlinkOn="${Escape}[5m";   BlinkOff="${Escape}[25m";
	InvertOn="${Escape}[7m";  InvertOff="${Escape}[27m";
	Reset="${Escape}[0m";
}
colors

################################################################################
# Checking and including stuff
################################################################################

target=$1
if [[ "$target" == "" ]]; then
	echo "Use $0 with argument \"target\""
	exit 1
fi

NATIVE_BUILD=
if [[ "$target" == "native" ]]; then
	NATIVE_BUILD=true
fi

source /etc/apt-cross/ac-build/ac_get.sh
if [ ! $NATIVE_BUILD ]; then
	source /etc/apt-cross/ac-platform/$target.sh
fi

cd $AC_INSTALL_DIR
echo -e ${YellowF}"Go to $extracted_dir_mask" ${Reset}
cd $extracted_dir_mask
echo -e ${YellowF}" Working directory: `pwd`" ${Reset}

################################################################################
# Use cmake system
################################################################################

if [ ! $NATIVE_BUILD ]; then
	echo "Copy cmake cross-compile files"
	cp --remove-destination /etc/apt-cross/ac-build/$target.toolchain.cmake .
	cp --remove-destination /etc/apt-cross/ac-build/$target.initial.cmake .
fi

LOG_FILE=make.log


# Sets "CORES" and "AVAILABLE_CORES"
set_cores() {
	CORES=4
	AVAILABLE_CORES=`nproc`
	echo -e ${GreenF}"We will compile on ${CORES} of a total of ${AVAILABLE_CORES} cores \n" \
	 "Note that Unity/Ubuntu grinds to a halt if this reaches the total number of cores available)"${Reset}
}
 
set_verbosity() {
	MAKE_VERBOSITY="VERBOSE=1"
	MAKE_VERBOSITY=
}
 
set_timing() {
        MAKE_TIMING=time
}
 
# Create log file and write everything to it
# Prerequisite for check_errors and check_warnings
set_logging() {
	rm -f ${LOG_FILE}
	PIPE_TO_FILE="3>&1 1>&2 2>&3 | tee ${LOG_FILE}"
}
 
# A log file is a prerequisite, assumes we are still in the build directory
# so create the script file in the parent directory ..
check_errors() {
	echo "Check for errors"
	CHECK_FOR_ERROR="egrep '(error|instantiated from|relocation truncated)'"
	CHECK_FOR_ERROR_CMD="cat ${LOG_FILE} | ${CHECK_FOR_ERROR} | head -n 1"
	ERRORS=`eval ${CHECK_FOR_ERROR_CMD}`
	ERROR_SCRIPT=../check_error.sh
	rm -f ${ERROR_SCRIPT}
	if [ -n "$ERRORS" ]; then
		ERROR_FILE=`eval ${CHECK_FOR_ERROR_CMD} | cut -d':' -f1`
		ERROR_LINE=`eval ${CHECK_FOR_ERROR_CMD} | cut -d':' -f2`
		echo "#!/bin/bash" >> ${ERROR_SCRIPT}
		echo "# -- automatically generated --" >> ${ERROR_SCRIPT}
		echo "gedit ${ERROR_FILE} +${ERROR_LINE}" >> ${ERROR_SCRIPT}
		echo "echo \"Open ${ERROR_FILE} at line ${ERROR_LINE}\"" >> ${ERROR_SCRIPT}
		echo "echo \"because of error: \"" >> ${ERROR_SCRIPT}
		ESCAPE_ERRORS=`echo ${ERRORS} | sed 's|["'\''\`]||g'`
		echo "echo \"   ${ESCAPE_ERRORS} \"" >> ${ERROR_SCRIPT}
		chmod a+x ${ERROR_SCRIPT}
		echo "There are errors! Run ./check_error.sh"
	else
		echo "There are no errors found"
	fi
}
 
check_warnings() {
        echo "Check for warnings"
        WARNINGS=`cat ${LOG_FILE} | grep "warning"`
        WARNING_SCRIPT=../check_warning.sh
        rm -f ${WARNING_SCRIPT}
        if [ -n "$WARNINGS" ]; then
                WARNING_FILE=`cat ${LOG_FILE} | grep "warning" | cut -d':' -f1`
                WARNING_LINE=`cat ${LOG_FILE} | grep "warning" | cut -d':' -f2`
                echo "gedit ${WARNING_FILE} +${WARNING_LINE}" >> ${WARNING_SCRIPT}
                chmod a+x ${WARNING_SCRIPT}
                echo "There are warnings! Run ./check_warning.sh"
        else
                echo "There are no warnings found"
        fi
}
 
make_install_and_check() {
	INSTALL="install/strip"
        MAKE_COMMAND="${MAKE_VERBOSITY} ${MAKE_TIMING} make -j${CORES} ${INSTALL} ${PIPE_TO_FILE}"
        echo "We will perform the following command: "
        echo "  ${MAKE_COMMAND}"
        eval ${MAKE_COMMAND}
 
        check_errors
        check_warnings
}

#final_install() {
#	echo "Install is done already"
#	make install-strip
#}
 
build() {
 	# Create another directory to build out-of-source
        BUILD_DIR="build_${target}"
        mkdir -p ${BUILD_DIR}
        cd ${BUILD_DIR}
 
        set_cores
        set_verbosity
        set_timing
        set_logging
 
	if [ ! $NATIVE_BUILD ]; then	
		echo "We use the toolchain and disable the tests because of some awkward error"
		echo "Note that CMAKE_TOOLCHAIN_FILE will only be used on the first run"
		echo "it is not allowed to change an existing build tree"
		echo "see: http://www.cmake.org/pipermail/cmake/2011-February/042554.html"
		cmake -C ../$target.initial.cmake -DCMAKE_TOOLCHAIN_FILE=../$target.toolchain.cmake \
			-DCMAKE_CXX_FLAGS="-O2 -g" ..
	else
	        cmake -DCMAKE_CXX_FLAGS="-O2 -g" ..		
	fi
 
        make_install_and_check
#	final_install
 
        echo "The result of our compilation efforts:"
        cd ..
        file ${BUILD_DIR}/bin/* | head
	echo "Note that this does concern only a subset (10) and not from the install path, but the build path"
}

if [ ! $NATIVE_BUILD ]; then	
	echo "Build for platform $target"
else
	echo "Build for native platform"
fi

build

