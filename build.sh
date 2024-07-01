#!/bin/bash -e

[ -z "$KLVANCTOOLS_REPO" ] && KLVANCTOOLS_REPO=https://github.com/stoth68000/klvanc-tools.git
[ -z "$KLVANCTOOLS_BRANCH" ] && KLVANCTOOLS_BRANCH=
[ -z "$KLVANC_REPO" ] && KLVANC_REPO=https://github.com/stoth68000/libklvanc.git
[ -z "$KLVANC_BRANCH" ] && KLVANC_BRANCH=
[ -z "$ZLIB_REPO" ] && ZLIB_REPO=https://github.com/madler/zlib
[ -z "$ZLIB_BRANCH" ] && ZLIB_BRANCH=v1.2.11

BMSDK_REPO=https://github.com/LTNGlobal-opensource/bmsdk.git
DEP_BUILDROOT=$PWD/target-root
export PKG_CONFIG_PATH=$DEP_BUILDROOT/lib/pkgconfig

if [ ! -d zlib ]; then
	git clone $ZLIB_REPO zlib
	pushd zlib
	if [ "$ZLIB_BRANCH" != "" ]; then
	    echo "Switching to branch [$ZLIB_BRANCH]..."
	    git checkout $ZLIB_BRANCH
	fi
	./configure --static --prefix=${DEP_BUILDROOT}
	make
	make install
	popd
fi

# Make available the BlackMagic SDK
if [ ! -d bmsdk ]; then
    git clone $BMSDK_REPO
fi
BMSDK_10_8_5=$PWD/bmsdk/10.8.5
BMSDK_10_1_1=$PWD/bmsdk/10.1.1

if [ ! -d libklvanc ]; then
	git clone $KLVANC_REPO
	if [ "$KLVANC_BRANCH" != "" ]; then
	    echo "Switching to branch [$KLVANC_BRANCH]..."
	    pushd libklvanc
	    git checkout $KLVANC_BRANCH
	    popd
	fi
fi

if [ ! -d klvanc-tools ]; then
	git clone $KLVANCTOOLS_REPO
	if [ "$KLVANCTOOLS_BRANCH" != "" ]; then
	    echo "Switching to branch [$KLVANCTOOLS_BRANCH]..."
	    pushd klvanc-tools
	    git checkout $KLVANCTOOLS_BRANCH
	    popd
	fi
fi

pushd libklvanc
	if [ ! -f .skip ]; then
		./autogen.sh --build
		./configure --enable-shared=no --prefix=$DEP_BUILDROOT
		make -j8
		make install
		touch .skip
	fi
popd

pushd klvanc-tools
	if [ ! -f .skip ]; then
		export CFLAGS="-I${DEP_BUILDROOT}/include"
		export LDFLAGS="-L${DEP_BUILDROOT}/lib"

# Nielsen support
#		export CFLAGS="$CFLAGS -I/storage/dev/NIELSEN/sdk/package/include"
#		export LDFLAGS="$LDFLAGS -L/storage/dev/NIELSEN/sdk/package/lib"
#		export CFLAGS="$CFLAGS -I/storage/dev/NIELSEN/basic-decoder-sdk/package/include"
#		export LDFLAGS="$LDFLAGS -L/storage/dev/NIELSEN/basic-decoder-sdk/package/lib"

		export CXXFLAGS="$CFLAGS"

		./autogen.sh --build
		./configure --enable-shared=no --prefix=$DEP_BUILDROOT --with-bmsdk=$BMSDK_10_8_5
		make -j8
		make install
		touch .skip
	fi
popd
