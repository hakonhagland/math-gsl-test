#!/bin/bash


set -u

: ${GSL_INST_DIR:?environment variable not specified}
: ${GSL_SRC_DIR:?environment variable not specified}
: ${GSL:?environment variable not specified}
: ${GSL_CURRENT:?environment variable not specified}
: ${GSL_MIRROR:=http://mirrors.kernel.org/gnu/gsl}

echo "current dir: $PWD"
banner () {
   echo
   echo "==================================================="
}


die () {
   echo >&2 $@
   banner 
   exit 1
}

get_gsl_version() {
   cd $GSL_SRC_DIR

   banner

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
    ./configure --prefix $GSL_INST_DIR/gsl-$1 
    echo
    echo "Building..."
    make -j2 >& make.log
    echo
    echo "Installing..."
    make -j2 install >& install.log
    rm -rf gsl-$1
    banner
}


mkdir -p $GSL_SRC_DIR
mkdir -p $GSL_INST_DIR

echo "Testing agains GSL $GSL; Building with GSL $GSL_CURRENT"
echo

get_gsl_version $GSL
if [ $GSL != $GSL_CURRENT ] ; then
    get_gsl $GSL_CURRENT
fi

cpanm -n PkgConfig
cd $TRAVIS_BUILD_DIR
echo "TRAVIS_BUILD_DIR=$PWD"

export LD_LIBRARY_PATH=$GSL_INST_DIR/gsl-${GSL_CURRENT}/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
PATH=$GSL_INST_DIR/gsl-${GSL_CURRENT}/bin:$PATH
perl Build.PL && ./Build installdeps --cpan_client cpanm
mkdir -p xs
mkdir -p lib/Math/GSL
./Build
ls -l
echo "PWD=$PWD"
#./Build dist # create a CPAN dist with latest supported GSL release
