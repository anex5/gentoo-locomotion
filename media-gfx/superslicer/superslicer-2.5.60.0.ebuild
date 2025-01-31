# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.2-gtk3"
MY_PN="SuperSlicer"
SLICER_PROFILES_COMMIT="ca25c7ec55dcc6073da61e39692c321cdb6497dc"

inherit cmake wxwidgets xdg flag-o-matic toolchain-funcs

DESCRIPTION="A mesh slicer to generate G-code for fused-filament-fabrication (3D printers)"
HOMEPAGE="https://github.com/supermerill/SuperSlicer/"
SRC_URI="
	https://github.com/supermerill/SuperSlicer/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/slic3r/slic3r-profiles/archive/${SLICER_PROFILES_COMMIT}.tar.gz -> ${P}-profiles.tar.gz
"

LICENSE="AGPL-3 Boost-1.0 GPL-2 LGPL-3 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="+gui -step test"

RESTRICT="test mirror"

# No dep on sci-libs/libigl, in-tree version cannot build
# static library currently. Using bundled one.
RDEPEND="
	dev-cpp/eigen:3
	dev-cpp/tbb:=
	dev-libs/boost:=[nls]
	dev-libs/cereal
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/gmp:=
	dev-libs/mpfr:=
	dev-libs/imath:=
	media-gfx/openvdb:=
	media-gfx/libbgcode
	net-misc/curl[adns]
	media-libs/glew:0=
	media-libs/libjpeg-turbo:=
	media-libs/libpng:0=
	media-libs/qhull:=
	sci-libs/nlopt
	sci-libs/opencascade:=
	sci-mathematics/cgal:=
	sys-apps/dbus
	sys-libs/zlib:=
	gui? (
		x11-libs/wxGTK:${WX_GTK_VER}[gui?]
	)
	step? (
		sci-libs/opencascade:=[tk]
	)
"
DEPEND="${RDEPEND}
	media-libs/qhull[static-libs]
"

PATCHES=(
	"${FILESDIR}/${PN}-2.5.59.2-cereal.patch"
	"${FILESDIR}/${PN}-2.5.59.2-dont-install-angelscript.patch"
	#"${FILESDIR}/${PN}-2.5.59.2-gcodeviewer-symlink-fix.patch"
	#"${FILESDIR}/${PN}-2.5.59.2-missing-includes-fix.patch"
	"${FILESDIR}/${PN}-2.5.59.2-openexr3.patch"
	"${FILESDIR}/${PN}-2.5.59.2-wxgtk3-wayland-fix.patch"
	"${FILESDIR}/${PN}-2.5.59.2-relax-OpenCASCADE-dep.patch"
	#"${FILESDIR}/${PN}-2.5.59.8-additional-imports-fixes.patch"
	"${FILESDIR}/${PN}-2.5.59.2-boost.patch"
	"${FILESDIR}/${PN}-2.5.59.8-fix-compilation-error-gnu17.patch"
	"${FILESDIR}/${PN}-2.5.59.8-libnest2d-link-xcb.patch"
	"${FILESDIR}/${PN}-2.5.59.8-boost-replace-load-string-file.patch"
	#"${FILESDIR}/${PN}-2.5.59.10-boost-headers.patch"
	#"${FILESDIR}/${PN}-2.5.59.2-fix-dereferencing-in-std-unique_ptr-to-nullptr.patch"
	#"${FILESDIR}/${PN}-2.5.59.2-fix-spiral_vase-null-pointer.patch"
	"${FILESDIR}/${PN}-2.5.59.2-wxGTK-disable-asserts.patch"
	#"${FILESDIR}/${PN}-2.5.60.0-mesh-boolean-fix.patch"
	#"${FILESDIR}/${PN}-2.5.60.0-fan-speed-gui-fix.patch"
	"${FILESDIR}/${PN}-2.5.60.0-code-build-fixes.patch"
	"${FILESDIR}/${PN}-2.5.60.0-gcc-14-include-cstdint.patch"
)

S="${WORKDIR}/${MY_PN}-${PV}"

src_unpack() {
	default

	mv slic3r-profiles-*/* "${S}"/resources/profiles/ || die
}

src_prepare() {
	use gui || sed -e '/find_package(OpenGL REQUIRED)/d' -i CMakeLists.txt
	use step && eapply "${FILESDIR}/${PN}-2.5.59.2-link-occtwrapper-statically.patch"
	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE="Release"

	append-flags -fno-strict-aliasing

	setup-wxwidgets

	local mycmakeargs=(
		-DOPENVDB_FIND_MODULE_PATH="/usr/$(get_libdir)/cmake/OpenVDB"
		-DSLIC3R_BUILD_TESTS=$(usex test)
		-DSLIC3R_ENABLE_FORMAT_STEP=$(usex step)
		-DSLIC3R_FHS=ON
		-DSLIC3R_GTK=3
		-DSLIC3R_GUI=$(usex gui)
		-DSLIC3R_PCH=OFF
		-DSLIC3R_STATIC=OFF
		-DSLIC3R_WX_STABLE=ON
		-Wno-dev
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

src_install() {
	cmake_src_install

	rm "${ED}/usr/lib/udev/rules.d/90-3dconnexion.rules" || die
}
