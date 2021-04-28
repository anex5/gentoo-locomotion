# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Qt Image IO plugin based on OpenImageIO"
HOMEPAGE="http://www.openimageio.org/"

SRC_URI="https://github.com/alicevision/QtOIIO/archive/v$PV.tar.gz -> $P.tar.gz"
LICENSE=MPL-2.0
SLOT=0
KEYWORDS=~amd64
S=$WORKDIR/QtOIIO-$PV

#PATCHES=$FILESDIR/$PN-cmake-fix.patch

CMAKE_BUILD_TYPE=Release

DEPEND="
	sys-libs/zlib
	media-libs/openexr
	media-libs/openimageio
	dev-qt/qtcore
"

RESTRICT="mirror"

src_prepare() {
	cmake_src_prepare

	sed -i '1 i\#include <cmath>' src/jetColorMap.hpp
	#sed -i 's|imageformats|plugins/imageformats|' src/imageIOHandler/CMakeLists.txt
	sed -i 's|/usr/lib|${EPREFIX}/usr/${get_libdir}|' src/CMakeLists.txt
}
