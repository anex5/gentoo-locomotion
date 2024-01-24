# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

MY_PN="OpenSfM"

inherit distutils-r1 cmake git-r3

DISTUTILS_USE_SETUPTOOLS=no
DISTUTILS_OPTIONAL=1
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1

DESCRIPTION="Open source Structure-from-Motion pipeline"
HOMEPAGE="https://www.opensfm.org"

EGIT_REPO_URI="https://github.com/mapillary/${MY_PN}"
EGIT_SUBMODULES=()
EGIT_BRANCH="main"
KEYWORDS=""

QA_PRESTRIPPED="usr/lib/python.*/site-packages/opensfm/.*"

LICENSE="BSD-2"

SLOT="0"

KEYWORDS="~amd64"

IUSE="debug doc test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	dev-libs/boost[${PYTHON_USEDEP}]
	media-libs/opencv[python,${PYTHON_USEDEP}]
	media-libs/opengv[python,${PYTHON_USEDEP}]
	>=sci-libs/ceres-solver-2.0.0[sparse]
	>=dev-python/cloudpickle-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/exifread-2.1.2[${PYTHON_USEDEP}]
	>=dev-python/joblib-0.14.1[${PYTHON_USEDEP}]
	>=dev-python/loky-1.0.0[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	>=dev-python/networkx-1.11[${PYTHON_USEDEP}]
	>=dev-python/pillow-8.1.1[${PYTHON_USEDEP}]
	>=dev-python/pyproj-1.9.5.1[${PYTHON_USEDEP}]
	>=dev-python/pytest-3.0.7[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.6.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.1[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/repoze-lru[${PYTHON_USEDEP}]
	>=dev-python/fpdf2-2.1.0[${PYTHON_USEDEP}]
	doc? (
		>=dev-python/sphinx-3.4.3[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
	)
	>=dev-python/xmltodict-0.10.2[${PYTHON_USEDEP}]
	dev-python/wheel[${PYTHON_USEDEP}]
	"
RDEPEND="${DEPEND}"

BDEPEND="
	dev-python/pybind11[${PYTHON_USEDEP}]
	dev-python/cython[${PYTHON_USEDEP}]
	>=dev-build/cmake-3.0.0
	dev-cpp/glog[gflags]
"

RESTRICT="
	mirror
	test ( test )
"

src_prepare() {
	use doc || sed -i -e "/from sphinx\.setup_command import BuildDoc/d" -e "/\"build_doc\": BuildDoc\,/d" setup.py || die
	sed -e '/"bin\/opensfm"\,/a		"bin\/opensfm_main\.py",' -i setup.py || die

	#Enable cxx17 as CERES-2.0 req it
	sed -e "s|\(set(CMAKE_CXX_STANDARD \)14|\117|" -i opensfm/src/CMakeLists.txt || die
	#unbundle pybind11
	sed	-e "s|add_subdirectory(third_party\/pybind11)|find_package (pybind11 CONFIG REQUIRED)|" -i opensfm/src/CMakeLists.txt || die
	sed -e "/^target_link_libraries(/,/)/s|pybind11|pybind11::module pybind11::thin_lto|g" -i opensfm/src/{foundation,bundle,dense,features,geometry,robust,sfm,geo,map}/CMakeLists.txt || die

	# Build C extension with gentoo cmake eclass
	sed -e "/^configure_c_extension()$/d" -i setup.py || die
	sed -e "/^build_c_extension()$/d" -i setup.py || die

	eapply "${FILESDIR}/unbundle-pybind.patch"

	CMAKE_USE_DIR="${S}/opensfm/src"
	cmake_src_prepare
	python_prepare_all
}

python_prepare_all() {
	python_setup
	python_fix_shebang .
	distutils-r1_python_prepare_all
}

src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)
	CMAKE_CXX_STANDARD=17
	CMAKE_CXX_STANDARD_REQUIRED=ON
	CMAKE_SKIP_RPATH=ON

	local mycmakeargs=(
		-DOPENSFM_BUILD_TESTS=$(usex test)
	)
	cmake_src_configure
	distutils-r1_src_configure
}

src_compile() {
	python_setup
	cmake_src_compile
	distutils-r1_src_compile
}

src_install() {
	pushd ${PN}/src >/dev/null || die
	distutils-r1_src_install
	popd >/dev/null || die
}

python_compile_all() {
	local targets=()
	use doc && targets+=( build_doc )
	use test && targets+=( bundle_test )

	if [[ ${targets[@]} ]]; then
		${EPYTHON} esetup.py "${targets[@]}"
	fi
}

python_test() {
	${EPYTHON} esetup.py test
}
