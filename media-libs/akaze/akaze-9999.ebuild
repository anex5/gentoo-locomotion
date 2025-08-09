# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

DESCRIPTION="Accelerated Kaze library for SFM applications"
HOMEPAGE="http://www.robesafe.com/personal/pablo.alcantarilla/kaze.html"
if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/pablofdezalc/akaze"
	EGIT_BRANCH="master"
	KEYWORDS=""
	SLOT="0/1.5"
else
	COMMIT="25d5897483cc8753e2c904aaa10c5a421c3024a8"
	SRC_URI="https://github.com/pablofdezalc/akaze/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
	S="${WORKDIR}/${PN}-${COMMIT}"
	SLOT="0/$(ver_cut 1-2 ${PV})"
fi

LICENSE="BSD"

IUSE="debug doc octave test utils"
RESTRICT="
	!test (test)
	mirror
"

DEPEND="
	>=media-libs/opencv-3.0.0:=[contrib,contribsfm,contribxfeatures2d,eigen,features2d,openmp]
	octave? ( >=sci-mathematics/octave-3.4.0 )
"
BDEPEND="
	octave? ( dev-lang/swig )
	doc? (
		app-doc/doxygen
	)
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-1.0.0-fix-clang-build.patch"
)

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && tc-check-openmp
}

src_prepare() {
	cmake_src_prepare
	# drop hardcoded cflags
	sed -e "s/ -DDEBUG -D_DEBUG//g" -e "s/-msse[2-4]\+//g" -i src/CMakeLists.txt || die "Sed failed."
	# add build doc option
	sed -e "/if(DOXYGEN_FOUND)/i set(BUILD_DOCS, true)" \
		-e "s|if(DOXYGEN_FOUND)|if(DOXYGEN_FOUND AND BUILD_DOCS)|" \
		-i src/CMakeLists.txt || die "Sed failed."
}

src_configure() {
	local mycmakeargs=(
		-DAKAZE_INSTALL_PREFIX="${EPREFIX}/usr/$(get_libdir)"
		-DAKAZE_INCLUDE_PREFIX="${EPREFIX}/usr/include/${PN}"
		-DBUILD_DOCS=$(usex doc)
	)

	MEX=""
	use octave && MKOCTFILE=${EPREFIX}/usr/bin/mkoctfile || MKOCTFILE=""

	CMAKE_BUILD_TYPE=$(usex debug "RelWithDebInfo" "Release")
	cmake_src_configure
}

src_install() {
	cmake_src_install
	#use doc && dodoc

	use utils && dobin "${BUILD_DIR}"/bin/${PN}_{match,features,compare}
}
