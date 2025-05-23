# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

DESCRIPTION="Geometric algorithms, includes a simple yet efficient Mesh data structure."
HOMEPAGE="https://gforge.inria.fr/projects/geogram/"
if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/BrunoLevy/${PN}"
	EGIT_BRANCH="main"
	KEYWORDS=""
else
	LIBMESHB_COMMIT="c3e8d187ced5aa231d50b5bef55158af0870ec63"
	AMGCL_COMMIT="ab57038d68ee372ed5df280631051b91f17ed2d1"
	RPLY_COMMIT="4296cc91b5c8c26d4e7d7aac0cee2b194ffc5800"

	SRC_URI="
		https://github.com/BrunoLevy/${PN}/archive/v${PV/_*}.tar.gz -> ${PN}_${PV/_*}.tar.gz
		https://github.com/LoicMarechal/libMeshb/archive/${LIBMESHB_COMMIT}.tar.gz -> ${PN}-libMeshb-${LIBMESHB_COMMIT:0:7}.tar.gz
		https://github.com/ddemidov/amgcl/archive/${AMGCL_COMMIT}.tar.gz -> ${PN}-amgcl-${AMGCL_COMMIT:0:7}.tar.gz
		https://github.com/diegonehab/rply/archive/${RPLY_COMMIT}.tar.gz -> ${PN}-rply-${RPLY_COMMIT:0:7}.tar.gz
	"
	KEYWORDS="~amd64 ~arm64"
fi

SLOT="0"
LICENSE="BSD"
IUSE="apps debug exploragram +fpg gargantua +hlbfgs lua man +tetgen test +triangle +vorpaline"

BDEPEND="
	man? ( >=app-doc/doxygen-1.7.0 )
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


src_unpack() {
	if [[ ${PV} = *9999* ]]; then
		git-r3_src_unpack
	else
		unpack ${A}
		rm -vrf "${S}/src/lib/geogram/third_party/libMeshb"
		rm -vrf "${S}/src/lib/geogram/third_party/amgcl"
		rm -vrf "${S}/src/lib/geogram/third_party/rply"
		ln -s "${WORKDIR}/libMeshb-${LIBMESHB_COMMIT}" "${S}/src/lib/geogram/third_party/libMeshb" || die
		ln -s "${WORKDIR}/amgcl-${AMGCL_COMMIT}" "${S}/src/lib/geogram/third_party/amgcl" || die
		ln -s "${WORKDIR}/rply-${RPLY_COMMIT}" "${S}/src/lib/geogram/third_party/rply" || die
	fi
}

src_prepare(){
	use man || sed -e '/add_subdirectory(doc)/d' -i CMakeLists.txt
	cmake_src_prepare
}

src_configure() {
	append-cflags "-fcommon"
	local mycmakeargs=(
		-DGEOGRAM_LIB_ONLY=$(usex test)
		-DGEOGRAM_USE_SYSTEM_GLFW3=ON
		#-DVORPALINE_PLATFORM="Linux64-gcc-dynamic"
		-DGEOGRAM_WITH_LUA=$(usex lua ON OFF)
		-DGEOGRAM_WITH_EXPLORAGRAM=$(usex exploragram ON OFF)
		-DGEOGRAM_WITH_GARGANTUA=$(usex gargantua ON OFF)
		-DGEOGRAM_WITH_GRAPHICS=$(usex apps ON OFF)
		-DGEOGRAM_WITH_TETGEN=$(usex tetgen ON OFF)
		-DGEOGRAM_WITH_TRIANGLE=$(usex triangle ON OFF)
		-DGEOGRAM_WITH_HLBFGS=$(usex hlbfgs ON OFF)
		-DGEOGRAM_WITH_VORPALINE=$(usex vorpaline ON OFF)
		-DGEOGRAM_WITH_FPG=$(usex fpg ON OFF)
		-DGEOGRAM_WITH_LEGACY_NUMERICS=OFF
	)

	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	use man && cmake_src_compile doxigen
}

