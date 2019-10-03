#! /bin/bash

get_gsl_version() {
   cd $GSL_SRC_DIR

    echo "Retrieving GSL $1"
    wget -q $GSL_MIRROR/gsl-$1.tar.gz \
         --retry-connrefused \
         --timeout=900 

    if [[ -d gsl-$1 ]] ; then
        rm -rf gsl-$1
    fi
    echo
    echo "Extracting..."
    tar zxpf gsl-$1.tar.gz
    cd gsl-$1
    echo
    echo "Configuring..."
    ./configure --prefix $(readlink -f $GSL_INST_DIR/gsl-$1) 
    echo
    echo "Building..."
    make -j2 >& make.log
    echo
    echo "Installing..."
    make -j2 install >& install.log
    rm -rf gsl-$1
}

export GSL=2.5
export GSL_CURRENT=2.5
export GSL_INST_DIR=$(readlink -f gsl)
export GSL_SRC_DIR="$GSL_INST_DIR/src"
export DIST_DIR=$GSL_INST_DIR
export GSL_MIRROR=http://mirrors.kernel.org/gnu/gsl
mkdir -p $GSL_SRC_DIR

get_gsl_version $GSL
