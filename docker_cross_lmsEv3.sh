#!/bin/bash
echo "----------------------------------------------------------------------------"
echo " Automatically set up development environment for POSIX-platform"
echo "----------------------------------------------------------------------------"
echo ""
# set open build directory
export open_build_dir="open62541/build"
# set forte bin folder
export forte_bin_dir="forte/bin/lmsEv3"
# set to boost-include directory
export forte_boost_test_inc_dirs=""
# set to boost-library directory
export forte_boost_test_lib_dirs=""
# add c compiler path
export CC=/usr/bin/arm-linux-gnueabi-gcc
# add c++ compiler path
export CXX=/usr/bin/arm-linux-gnueabi-g++

# create open build directory if it does not exist
if [ ! -d "$open_build_dir" ]; then
  mkdir -p "$open_build_dir"
fi
# create forte bin directory if it does not exist
if [ ! -d "$forte_bin_dir" ]; then
  mkdir -p "$forte_bin_dir"
fi

if [ -d "$forte_bin_dir" ]; then
  # go to the bin directory
  cd "./$forte_bin_dir"
  # clean and configure forte for ev3
  make clean
  cmake -G "Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE="/home/compiler/toolchain-armel.cmake" -DFORTE_MODULE_LMS_EV3=ON -DFORTE_ARCHITECTURE=Posix -DFORTE_COM_ETH=ON -DFORTE_COM_FBDK=ON -DFORTE_COM_LOCAL=ON -DFORTE_TESTS=OFF -DFORTE_TESTS_INC_DIRS=${forte_boost_test_inc_dirs} -DFORTE_TESTS_LINK_DIRS=${forte_boost_test_inc_dirs} -DFORTE_MODULE_CONVERT=ON -DFORTE_MODULE_MATH=ON -DFORTE_MODULE_IEC61131=ON -DFORTE_MODULE_OSCAT=ON -DFORTE_MODULE_Test=ON -DFORTE_MODULE_UTILS=ON ../../
  # go back to root folder
  cd "./../../.."
else
  echo "unable to create ${forte_bin_dir}"
  exit 1
fi

if [ -d "$open_build_dir" ]; then
  # go to build directory
  cd "./$open_build_dir"
  # clean and configure open
  make clean
  cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Debug -DUA_ENABLE_AMALGAMATION=ON ..
  # make 
  make
  cd "./../.."	#go back to root folder
else
  echo "unable to create ${open_build_dir}"
  exit 1
fi

if [ -d "$forte_bin_dir" ]; then
  # go to bin directory
  cd "./$forte_bin_dir"
  # configure forte for opc_ua
  cmake -DCMAKE_BUILD_TYPE=Debug -DFORTE_ARCHITECTURE=Posix -DFORTE_MODULE_LMS_EV3=ON -DFORTE_MODULE_CONVERT=ON -DFORTE_COM_ETH=ON -DFORTE_MODULE_IEC61131=ON -DFORTE_COM_OPC_UA=ON -DFORTE_COM_OPC_UA_INCLUDE_DIR=/4diac/open62541/build -DFORTE_COM_OPC_UA_LIB_DIR=/4diac/open62541/build/bin -DFORTE_COM_OPC_UA_LIB=libopen62541.so ..
  # make
  make -j	
  cd "./../../.."	#go back to start folder
else
  echo "unable to create ${forte_bin_dir}"
  exit 1
fi
