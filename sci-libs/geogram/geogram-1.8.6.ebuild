# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

DESCRIPTION="Geometric algorithms, includes a simple yet efficient Mesh data structure."
HOMEPAGE="https://gforge.inria.fr/projects/geogram/"
SRC_URI="https://github.com/BrunoLevy/${PN}/archive/v${PV/_*}.tar.gz -> ${PN}_${PV/_*}.tar.gz"
KEYWORDS="~amd64 ~x86"

SLOT="0"
LICENSE="BSD"
IUSE="debug doc exploragram graphics +fpg +hlbfgs lua +tetgen test +triangle +vorpaline"

BDEPEND="
	doc? ( >=app-doc/doxygen-1.7.0 )
	lua? ( dev-lang/lua )
	>=dev-build/cmake-3.16
	virtual/pkgconfig
"
DEPEND="
	media-libs/glu:=
	media-libs/glfw:=
"
RDEPEND="${DEPEND}"
RESTRICT="mirror"

S=${WORKDIR}/${PN}-${PV/_*}

src_prepare(){
	use doc || sed -e '/add_subdirectory(doc)/d' -i CMakeLists.txt
	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)
	CMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
	CMAKE_C_FLAGS="-fcommon"

	local mycmakeargs=(
		-DGEOGRAM_LIB_ONLY=$(usex test)
		-DGEOGRAM_USE_SYSTEM_GLFW3=ON
		-DVORPALINE_PLATFORM="Linux64-gcc-dynamic"
		-DGEOGRAM_WITH_LUA=$(usex lua ON OFF)
		-DGEOGRAM_WITH_EXPLORAGRAM=$(usex exploragram ON OFF)
		#-DGARGANTUA=$(usex gargantua ON OFF)
		-DGEOGRAM_WITH_GRAPHICS=$(usex graphics ON OFF)
		-DGEOGRAM_WITH_TETGEN=$(usex tetgen ON OFF)
		-DGEOGRAM_WITH_TRIANGLE=$(usex triangle ON OFF)
		-DGEOGRAM_WITH_HLBFGS=$(usex hlbfgs ON OFF)
		-DGEOGRAM_WITH_VORPALINE=$(usex vorpaline ON OFF)
		-DGEOGRAM_WITH_FPG=$(usex fpg ON OFF)
		-DGEOGRAM_WITH_LEGACY_NUMERICS=OFF
	)

	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	use doc && cmake_src_compile doxigen
}

src_install() {
	cmake_src_install
	mv ${D}/usr/lib/ ${D}/usr/$(get_libdir) || die
}
