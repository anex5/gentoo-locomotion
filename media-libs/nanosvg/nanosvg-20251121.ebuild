# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="NanoSVG is a simple stupid single-header-file SVG parse."
HOMEPAGE="https://github.com/memononen/nanosvg"
COMMIT="5cefd9847949af6df13f65027fd43af5a7513633"
SRC_URI="https://github.com/memononen/nanosvg/archive/${COMMIT}.tar.gz -> ${PN}-${COMMIT}.gh.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~arm ~x86"
RESTRICT="mirror"
CMAKE_BUILD_TYPE=Release
BDEPEND="
	virtual/libc
	virtual/pkgconfig
"

src_prepare(){
	cmake_src_prepare
	sed -e "s/\(set(ConfigPackageLocation \)lib\/cmake/\1$(get_libdir)\/cmake/" -i CMakeLists.txt || die
}

