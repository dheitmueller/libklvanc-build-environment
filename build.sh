#!/bin/bash -e

if [ ! -d libklvanc ]; then
	git clone https://github.com/stoth68000/libklvanc.git
fi

if [ ! -d klvanc-tools ]; then
	git clone https://github.com/stoth68000/klvanc-tools.git
fi

pushd libklvanc
	if [ ! -f .skip ]; then
		./autogen.sh --build
		./configure --enable-shared=no --prefix=$PWD/../target-root
		make -j8
		make install
		touch .skip
	fi
popd

pushd klvanc-tools
	if [ ! -f .skip ]; then
		export CFLAGS="-I$PWD/../target-root/include"
		export LDFLAGS="-L$PWD/../target-root/lib"

# Nielsen support
#		export CFLAGS="$CFLAGS -I/storage/dev/NIELSEN/sdk/package/include"
#		export LDFLAGS="$LDFLAGS -L/storage/dev/NIELSEN/sdk/package/lib"

		export CXXFLAGS="$CFLAGS"

		./autogen.sh --build
		./configure --enable-shared=no --prefix=$PWD/../target-root
		make -j8
		make install
		touch .skip
	fi
popd
