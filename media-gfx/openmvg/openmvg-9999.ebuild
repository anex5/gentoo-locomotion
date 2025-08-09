# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

DESCRIPTION="Open Multiple View Geometry library"
HOMEPAGE="http://imagine.enpc.fr/~moulonp/openMVG/"
MY_PN="openMVG"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${MY_PN}/${MY_PN}.git"
	EGIT_SUBMODULES=()
	EGIT_BRANCH="master"
	KEYWORDS=""
	SLOT="0/2.1"
else
	SRC_URI="https://github.com/${MY_PN}/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
	S="${WORKDIR}/${MY_PN}-${PV}"
	SLOT="0/$(ver_cut 1-2 ${PV})"
fi


IUSE="debug doc gui +ligt openmp +opencv +sift test examples"

RDEPEND="
	opencv? ( >=media-libs/opencv-3.0.0:=[contrib,contribsfm,contribxfeatures2d,eigen,features2d,openmp?] )
	>=sci-libs/ceres-solver-2.2:=[sparse,lapack]
	media-libs/libpng:=
	dev-cpp/eigen:3
	sci-libs/cxsparse
	sci-libs/lemon[coin]
	sci-libs/flann
	media-libs/tiff:0=
	media-libs/libpng:0=
	media-gfx/graphviz
	sys-libs/zlib
	virtual/jpeg
	gui? (
		dev-qt/qtcore:5
		dev-qt/qtnetwork:5
		dev-qt/qtwidgets:5
	)
"
DEPEND="${RDEPEND}"
BDEPEND="doc? ( app-text/doxygen[dot] )"

LICENSE="
	GPL-2
	ligt? ( CC-BY-4.0 )
"

RESTRICT="
	mirror
	!test? ( test )
"

PATCHES=(
	"${FILESDIR}/${PN}-9999-no-check-git-submodules.patch"
	"${FILESDIR}/${PN}-9999-add-more-cameras-to-sensor-db.patch"
	#"${FILESDIR}/${PN}-9999-add-sfm_gsd-binary.patch"
)

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && ( use openmp && tc-check-openmp )
}

src_prepare() {
	CMAKE_USE_DIR="${S}/src"
	cmake_src_prepare
	#cleanup third_party dir
	rm -r src/dependencies/osi_clp || die
	rm -r src/third_party/{ceres-solver,eigen,flann,jpeg,lemon,png,tiff,zlib} || die

	# Fix libdir
	sed -e "s/DESTINATION lib/DESTINATION \$\{CMAKE_INSTALL_LIBDIR\}/" -i \
		src/third_party/stlplus3/CMakeLists.txt \
		src/third_party/fast/CMakeLists.txt \
		src/third_party/easyexif/CMakeLists.txt \
		src/openMVG/vector_graphics/CMakeLists.txt \
		src/nonFree/sift/CMakeLists.txt \
		|| die "Sed failed."
}

src_configure() {
	mycmakeargs+=(
		-DCMAKE_POLICY_DEFAULT_CMP0177="OLD"
		-DOpenMVG_USE_OPENMP=$(usex openmp)
		-DOpenMVG_BUILD_DOC=$(usex doc)
		-DOpenMVG_BUILD_SHARED=ON
		-DOpenMVG_USE_OPENCV=$(usex opencv)
		-DOpenMVG_USE_OCVSIFT=$(usex sift)
		-DOpenMVG_USE_LIGT=$(usex ligt)
		-DOpenMVG_BUILD_EXAMPLES=$(usex examples)
		-DOpenMVG_BUILD_OPENGL_EXAMPLES=$(usex examples)
		-DOpenMVG_BUILD_TESTS=$(usex test)
		-DOpenMVG_BUILD_GUI_SOFTWARES=$(usex gui)
		-DOpenMVG_BUILD_SOFTWARES=ON
		-DFLANN_INCLUDE_DIR_HINTS="/usr/include/flann"
		-DCOINUTILS_INCLUDE_DIR_HINTS="/usr/include/coin"
		-DCLP_INCLUDE_DIR_HINTS="/usr/include/coin"
		-DOSI_INCLUDE_DIR_HINTS="/usr/include/coin"
		-DLEMON_INCLUDE_DIR_HINTS="/usr/include"
		-DCMAKE_LIBRARY_PATH=/usr/$(get_libdir)
	)
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	# cleanup static libs from install
	find "${D}" -name '*.a' -delete || die
}
