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

patch_module_build() {
    cd debug
    destdir=/home/travis/perl5/perlbrew/perls/5.26.3/lib/site_perl/5.26.3/Module/Build
    sudo cp Base.pm $destdir
    cd ..
}

install_my_module_build() {
    git clone https://github.com/hakonhagland/my-module-build.git
    cd my-module-build
    cpanm -n .
}

cd $TRAVIS_BUILD_DIR
install_my_module_build

#/home/travis/perl5/perlbrew/perls/5.26.3/lib/site_perl/5.26.3/Module/Build/Base.pm
#/home/travis/build/hakonhagland/math-gsl-test
mkdir -p $GSL_SRC_DIR
mkdir -p $GSL_INST_DIR

echo "Testing agains GSL $GSL; Building with GSL $GSL_CURRENT"
echo

get_gsl_version $GSL
if [ $GSL != $GSL_CURRENT ] ; then
    get_gsl $GSL_CURRENT
fi

cpanm -n PkgConfig
echo "TRAVIS_BUILD_DIR=$PWD"

export LD_LIBRARY_PATH=$GSL_INST_DIR/gsl-${GSL_CURRENT}/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
PATH=$GSL_INST_DIR/gsl-${GSL_CURRENT}/bin:$PATH
perl Build.PL

./Build installdeps --cpan_client cpanm
mkdir -p xs
mkdir -p lib/Math/GSL
#perl --version
#perl -MFile::Path=mkpath -e'mkpath("Math-GSL-0.40", 0, oct(777))'
#ls -ld Math-GSL-0.40
./Build
#patch_module_build
#ls -l
#echo "PWD=$PWD"
#ls -l lib/Math/GSL
#mkdir -p Math-GSL-0.40/lib/Math/GSL
./Build dist # create a CPAN dist with latest supported GSL release
# perl -d ./Build dist
#which perl
