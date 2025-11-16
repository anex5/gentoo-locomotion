# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.2-gtk3"
MY_PN="OrcaSlicer"
MY_PV="$(ver_rs 3 -)"

inherit cmake wxwidgets desktop xdg-utils

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/SoftFever/OrcaSlicer"
else
	SRC_URI="https://github.com/SoftFever/OrcaSlicer/archive/refs/tags/v${MY_PV}.tar.gz -> ${P}.tar.gz"
	#KEYWORDS="~amd64 ~arm64 ~x86"
	S="${WORKDIR}/${MY_PN}-${MY_PV}"
fi

DESCRIPTION="A G-code generator for 3D printers."
HOMEPAGE="discord.gg/P4VE9UY9gJ"

LICENSE="AGPL-3 Boost-1.0 GPL-2 LGPL-3 MIT"
SLOT="0"
IUSE="X debug -gui -step static-libs -spacenav test"

RESTRICT="!test? ( test ) mirror"

RDEPEND="
	dev-cpp/eigen:3
	dev-cpp/tbb:=
	dev-libs/boost:=[nls]
	dev-libs/cereal
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/gmp:=
	dev-libs/mpfr:=
	media-gfx/openvdb:=
	media-gfx/libbgcode
	net-misc/curl[adns]
	media-libs/glew:0=
	media-libs/libjpeg-turbo:=
	media-libs/libnoise:=
	media-libs/libpng:0=
	media-libs/qhull:=
	media-gfx/opencsg
	sci-libs/libigl
	sci-libs/nlopt
	sci-libs/opencascade:=
	sci-mathematics/cgal:=
	sci-mathematics/z3:=
	sys-apps/dbus
	sys-libs/zlib:=
	gui? (
		x11-libs/gtk+:3
		x11-libs/wxGTK:${WX_GTK_VER}=[X?,opengl,webkit]
		net-libs/webkit-gtk:4.1
	)
	spacenav? ( dev-libs/libspnav[X?] )
	media-libs/nanosvg:=
"
DEPEND="${RDEPEND}
	media-libs/qhull[static-libs]
	test? ( =dev-cpp/catch-3.8* )
"

PATCHES=(
	"${FILESDIR}/${PN}-2.9.2-slic3r-fixes.patch"
	"${FILESDIR}/${PN}-2.9.2-LLVM-fixes.patch"
	"${FILESDIR}/${PN}-2.9.2-headless-fixes.patch"
)

src_prepare() {
	use gui || ( sed -e '/find_package(OpenGL REQUIRED)/d' -i CMakeLists.txt || die )

	cp "${FILESDIR}/BoostProcessCompat.hpp" "${S}/src/libslic3r/BoostProcessCompat.hpp" || die

	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug "RelWithDebInfo" "Release")

	append-flags -fno-strict-aliasing

	use gui && setup-wxwidgets

	local mycmakeargs=(
		-DCMAKE_POLICY_VERSION_MINIMUM=3.5
		-DOPENVDB_FIND_MODULE_PATH="/usr/$(get_libdir)/cmake/OpenVDB"
		-DSLIC3R_BUILD_TESTS=$(usex test)
		-DSLIC3R_ENABLE_FORMAT_STEP=$(usex step)
		-DSLIC3R_FHS=ON
		-DSLIC3R_GTK=3
		-DSLIC3R_GUI=$(usex gui)
		-DSLIC3R_OPENGL_ES=$(usex !X)
		-DSLIC3R_PCH=OFF
		-DSLIC3R_STATIC=$(usex static-libs)
		-DSLIC3R_WX_STABLE=ON
		-DSLIC3R_PRECOMPILED_HEADERS=ON
		-DORCA_TOOLS=0
		-DBBL_RELEASE_TO_PUBLIC=1
		-DBBL_INTERNAL_TESTING=0
		#-Wno-dev
	)
	tc-is-cross-compiler && mycmakeargs+=(
		-DIS_CROSS_COMPILE=ON
	)

	cmake_src_configure
}

src_test() {
	CMAKE_SKIP_TESTS=(
		"^libslic3r_tests$"
	)
	cmake_src_test
}
