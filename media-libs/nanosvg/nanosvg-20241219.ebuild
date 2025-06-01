# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

#MY_PV="fltk_${PV:0:4}-${PV:4:2}-${PV:6:2}"

DESCRIPTION="NanoSVG is a simple stupid single-header-file SVG parse."
HOMEPAGE="https://github.com/memononen/nanosvg"
COMMIT="ea6a6aca009422bba0dbad4c80df6e6ba0c82183"
SRC_URI="https://github.com/memononen/nanosvg/archive/${COMMIT}.tar.gz -> ${PN}-${COMMIT}.gh.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~arm ~x86"
CMAKE_BUILD_TYPE=Release
