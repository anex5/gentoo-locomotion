# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )

MY_PN="OpenSfM"

inherit cmake distutils-r1 flag-o-matic

DISTUTILS_USE_SETUPTOOLS=no
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1

DESCRIPTION="Open source Structure-from-Motion pipeline"
HOMEPAGE="https://www.opensfm.org"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/mapillary/${MY_PN}"
	EGIT_SUBMODULES=( '*' '-opensfm/src/third_party/pybind11' )
	EGIT_BRANCH="main"
	KEYWORDS=""
	CERES_PV=2.3.0
else
	SRC_URI="https://github.com/mapillary/${MY_PN}/archive/v${PV}/${P}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
	CERES_PV=2.1.0
	S=${WORKDIR}/${MY_PN}-${PV}
fi

QA_PRESTRIPPED="usr/lib/python.*/site-packages/opensfm/.*"

LICENSE="BSD-2"

SLOT="0"

IUSE="debug doc test lto"

#media-libs/opengv[python,${PYTHON_USEDEP}]
DEPEND="
	dev-libs/boost[${PYTHON_USEDEP}]
	>=media-libs/opencv-3.0.0:=[contrib,contribsfm,contribxfeatures2d,eigen,features2d,openmp,python,${PYTHON_USEDEP}]
	<=sci-libs/ceres-solver-${CERES_PV}:=
	>=sci-libs/suitesparseconfig-7.6.0:=
	>=sci-libs/amd-3.3.1:=
	>=sci-libs/camd-3.3.1:=
	>=sci-libs/colamd-3.3.1:=
	>=sci-libs/ccolamd-3.3.1:=
	>=sci-libs/cholmod-5.2.0:=
	>=sci-libs/cxsparse-4.3.1:=
	>=sci-libs/spqr-4.3.2:=
	>=sci-libs/metis-5.2.1:=
	>=dev-python/cloudpickle-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/exifread-2.1.2[${PYTHON_USEDEP}]
	>=dev-python/joblib-0.14.1[${PYTHON_USEDEP}]
	>=dev-python/loky-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/networkx-1.11[${PYTHON_USEDEP}]
	>=dev-python/pillow-8.1.1[${PYTHON_USEDEP}]
	>=dev-python/pyproj-1.9.5.1[${PYTHON_USEDEP}]
	>=dev-python/pytest-3.0.7[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.6.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.1[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/repoze-lru[${PYTHON_USEDEP}]
	>=dev-python/fpdf2-2.4.6[${PYTHON_USEDEP}]
	doc? (
		>=dev-python/sphinx-3.4.3[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
	)
	>=dev-python/xmltodict-0.10.2[${PYTHON_USEDEP}]
	dev-python/wheel[${PYTHON_USEDEP}]
	media-libs/vlfeat
	media-libs/akaze
"
RDEPEND="${PYTHON_DEPS}"
BDEPEND="
	${PYTHON_DEPS}
	${DISTUTILS_DEPS}
	dev-python/pybind11[${PYTHON_USEDEP}]
	dev-cpp/glog[gflags]
	virtual/pkgconfig
	virtual/libc
"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="
	mirror
	test ( test )
"

pkg_setup() {
	python_setup
}

src_prepare() {
	use doc || sed -i -e "/from sphinx\.setup_command import BuildDoc/d" -e "/\"build_doc\": BuildDoc\,/d" setup.py || die "Sed failed"
	sed -e '/"bin\/opensfm"\,/a		"bin\/opensfm_main\.py",' -i setup.py || die "Sed failed"
	sed -e "s/\(\"-DPYTHON_EXECUTABLE=\)\" + sys.executable/\1${EPREFIX}\/usr\/bin\/${EPYTHON}\"/" -i setup.py || die "Sed failed"
	# Include system python headers
	sed -e "/add_subdirectory(third_party\/akaze)/a include_directories($(python_get_includedir))" -i opensfm/src/CMakeLists.txt || die "Sed failed"
	# Unbundle vlfeat
	sed -e '/add_definitions(-DVL_DISABLE_AVX)/d' -e '/add_definitions(-DINPLACE_VLFEAT)/d' \
		-e '/include_directories(third_party\/vlfeat)/d' -e "s/add_subdirectory(third_party\/vlfeat)/find_library (VLFEAT_LIB vl NAMES libvl PATHS \"\/usr\/$(get_libdir)\" REQUIRED)/" \
		-i opensfm/src/CMakeLists.txt || die "Sed failed"
	sed -e '/target_link_libraries(/,/)/ s/vl$/\$\{VLFEAT_LIB\}/g' -i opensfm/src/features/CMakeLists.txt || die "Sed failed"
	rm -rf "opensfm/src/third_party/vlfeat" || die

	# Unbundle akaze
	#sed -e '/include_directories(third_party\/akaze)/d' -e "s/add_subdirectory(third_party\/akaze)/find_library (AKAZE_LIB akaze NAMES libAKAZE\.so PATHS \"\/usr\/$(get_libdir)\" REQUIRED)/" \
#		-i opensfm/src/CMakeLists.txt || die "Sed failed"
#	sed -e '/target_link_libraries(.*features/,/)/ s/akaze$/\$\{AKAZE_LIB\}/' \
#		-e '/target_link_libraries(features/,/)/ { /)/a target_include_directories(features PRIVATE /usr/include/akaze)' -e '}' \
#		-e '/target_link_libraries(pyfeatures/,/)/ { /)/a target_include_directories(pyfeatures PRIVATE /usr/include/akaze)' -e '}' \
#		-i opensfm/src/features/CMakeLists.txt || die "Sed failed"
#	sed -e 's/third_party\/akaze\/lib\/AKAZE\.h/akaze\/AKAZE\.h/g' -i opensfm/src/features/{akaze_bind.h,src/akaze_bind.cc} || die "Sed failed"
#	rm -rf "opensfm/src/third_party/akaze" || die

	if [[ ${PV} = *9999 ]]; then
		#Enable cxx17 as CERES-2.0 req it
		sed -e "s|\(set(CMAKE_CXX_STANDARD \)14|\117|" -i opensfm/src/CMakeLists.txt || die "Sed failed"
		# Unbundle pybind11
		sed	-e "s|add_subdirectory(third_party\/pybind11)|find_package (pybind11 CONFIG REQUIRED)|" -i opensfm/src/CMakeLists.txt || die "Sed failed"
		sed -e "/^target_link_libraries(/,/)/s|pybind11|pybind11::embed|g" -i opensfm/src/{bundle,dense,features,foundation,geometry,robust,sfm,geo,map}/CMakeLists.txt || die "Sed failed"
		#eapply "${FILESDIR}/opensfm-fix-vl-src-path.patch"
		eapply "${FILESDIR}/opensfm-fix-hahog-vl-covdet.patch"
	else
		#Enable cxx17 as CERES-2.0 req it
		sed -e "s|\(set(CMAKE_CXX_STANDARD \)11|\114|" -i opensfm/src/CMakeLists.txt || die "Sed failed"
		#unbundle pybind11
		sed	-e "s|add_subdirectory(third_party\/pybind11)|find_package (pybind11 CONFIG REQUIRED)|" -i opensfm/src/CMakeLists.txt || die "Sed failed"
		sed -e "/^target_link_libraries(/,/)/s|pybind11|pybind11::pybind11|g" -i opensfm/src/{dense,features,foundation,geometry,robust,sfm}/CMakeLists.txt || die "Sed failed"
	fi
	rm -rf "opensfm/src/third_party/pybind11" || die

	# Build C extension with gentoo cmake eclass
	sed -e "/^configure_c_extension()$/d" -i setup.py || die "Sed failed"
	sed -e "/^build_c_extension()$/d" -i setup.py || die "Sed failed"

	CMAKE_USE_DIR="${S}/opensfm/src"
	cmake_src_prepare
	distutils-r1_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_CXX_STANDARD_REQUIRED=ON
		-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=$(usex lto)
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_POLICY_DEFAULT_CMP0057="NEW"
		-DCMAKE_POLICY_DEFAULT_CMP0069="NEW" # Enable CMake lto
		-DCMAKE_POLICY_DEFAULT_CMP0148="OLD" # Enable Cmake FindPython for pybind11
		-DPYBIND11_FINDPYTHON=ON
		-DCMAKE_SKIP_RPATH=ON
		-DOPENSFM_BUILD_TESTS="$(usex test)"
	)
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)
	cmake_src_configure
	distutils-r1_src_configure
}

src_compile() {
	cmake_src_compile
	distutils-r1_src_compile
}

src_install() {
	distutils-r1_src_install
	rm -rf "${D}/$(python_get_sitedir)"/*.egg-info || die
	python_optimize
}

