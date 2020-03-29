# Copyright 2009-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils toolchain-funcs

DESCRIPTION="Library of geometric algorithms. It includes a simple yet efficient Mesh data structure."
HOMEPAGE="https://gforge.inria.fr/projects/geogram/"
SRC_URI="https://gforge.inria.fr/frs/download.php/file/38269/geogram_1.7.4.tar.gz"
KEYWORDS="~amd64 ~x86"

SLOT="0"
LICENSE="BSD"
IUSE="doc"

DEPEND="
	media-libs/glu:=
	media-libs/glfw:=
	doc? (
		>=app-doc/doxygen-1.7.0
	)
"

RESTRICT="mirror"

S=${WORKDIR}/${PN}_${PV}

src_prepare(){
    cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DGEOGRAM_LIB_ONLY=ON
		-DGEOGRAM_USE_SYSTEM_GLFW3=ON
		-DVORPALINE_PLATFORM=Linux64-gcc-dynamic
		-DGEOGRAM_USE_SYSTEM_GLFW3=ON
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile 
	use doc && cmake-utils_src_compile doxigen
}

src_install() {
	cmake-utils_src_install
	mv ${D}/usr/lib/ ${D}/usr/$(get_libdir) || die
}