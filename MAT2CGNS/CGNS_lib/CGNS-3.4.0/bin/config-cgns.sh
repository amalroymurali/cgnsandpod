#!/bin/sh
#
# Configure CGNS for travis CI. 
#
set -e
cd src
OPTS=""
if [ $TRAVIS_OS_NAME = "linux" ]; then
      export FLIBS="-Wl,--no-as-needed -ldl"
        export LIBS="-Wl,--no-as-needed -ldl"
	  OPTS="--enable-parallel"
	  fi

export CC="gcc"
export FC="gfortran"

./configure \
    --prefix=$PWD/cgns_build $OPTS \
    --with-hdf5=no \
    --with-fortran \
    --enable-lfs \
    --disable-shared \
    --enable-debug \
    --enable-cgnstools \
