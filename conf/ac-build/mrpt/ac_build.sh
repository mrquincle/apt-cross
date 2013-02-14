#!/bin/bash

################################################################################
# Configuration option 
################################################################################

extracted_dir_mask=mrpt*

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

cd $AC_INSTALL_DIR
echo "Display directories in $AC_INSTALL_DIR: "
echo "----------------------------------------"
LIST="ls -d -1 */"
eval $LIST
echo "----------------------------------------"

echo "Go to $extracted_dir_mask"
cd $extracted_dir_mask
package_dir=`pwd`
echo "Arrived in $package_dir"

################################################################################
# Requires cmake build system
################################################################################

echo "Copy cmake cross-compile files"
cp --remove-destination /etc/apt-cross/ac-build/$target.toolchain.cmake .
cp --remove-destination /etc/apt-cross/ac-build/$target.initial.cmake .

LOG_FILE=make.log
 
# Sets "CORES" and "AVAILABLE_CORES"
set_cores() {
	CORES=4
	AVAILABLE_CORES=`nproc`
	echo "We will compile on ${CORES} of a total of ${AVAILABLE_CORES} cores"
	echo "Note that Unity/Ubuntu grinds to a halt if this reaches the total number of cores available)"
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
 
make_and_check() {
        MAKE_COMMAND="${MAKE_VERBOSITY} ${MAKE_TIMING} make -j${CORES} ${PIPE_TO_FILE}"
        echo "We will perform the following command: "
        echo "  ${MAKE_COMMAND}"
        eval ${MAKE_COMMAND}
 
        check_errors
        check_warnings
}

final_install() {
	make install
}
 
build() {
 	# Create another directory to build out-of-source
        BUILD_DIR="build_${target}"
        mkdir -p ${BUILD_DIR}
        cd ${BUILD_DIR}
 
        set_cores
        set_verbosity
        set_timing
        set_logging
 
        echo "We use the toolchain and disable the tests because of some awkward error"
        echo "Note that CMAKE_TOOLCHAIN_FILE will only be used on the first run"
        echo "it is not allowed to change an existing build tree"
        echo "see: http://www.cmake.org/pipermail/cmake/2011-February/042554.html"
	# -mtune=native is disabled by using CMAKE_MRPT_ARCH different from amd64 (so it's set to bfin)
	# this is done in cmakemodules/script_detect_unix_arch.cmake
	# however, I added a flag to MRPT to make cross-compilation easier: CMAKE_MRPT_TARGET_ARCH
	cmake -C ../${target}.initial.cmake -DCMAKE_TOOLCHAIN_FILE=../$target.toolchain.cmake \
		-DEIGEN_USE_EMBEDDED_VERSION:BOOL=FALSE -DBUILD_mrpt-gui:BOOL=FALSE \
		-DBUILD_ARIA:BOOL=FALSE -DBUILD_TESTING:BOOL=FALSE -DBUILD_XSENS:BOOL=FALSE \
		-DMRPT_HAS_ASIAN_FONTS:BOOL=FALSE \
		-DDISABLE_WXWIDGETS:BOOL=TRUE -DDISABLE_SWISSRANGER_3DCAM_LIBS:BOOL=TRUE \
		-DDISABLE_OPENCV:BOOL=TRUE \
		-DBUILD_EXAMPLES:BOOL=FALSE \
		-DCMAKE_MRPT_TARGET_ARCH=blackfin \
		..
 
        make_and_check
	final_install
 
        echo "The result of our compilation efforts:"
        cd ..
        file ${BUILD_DIR}/bin/*

}
 
echo "Build for platform $target"
build

