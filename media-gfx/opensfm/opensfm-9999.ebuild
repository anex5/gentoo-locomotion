# Copyright 2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

PYTHON_COMPAT=( python3_{7..9} )

MY_PN="OpenSfM"

inherit distutils-r1 #cmake python-single-r1

DESCRIPTION="Open source Structure-from-Motion pipeline"
HOMEPAGE="https://www.opensfm.org"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/mapillary/OpenSfM"
	EGIT_SUBMODULES=()
	EGIT_BRANCH="master"
	KEYWORDS=""
else
	SRC_URI="https://github.com/mapillary/${MY_PN}/archive/v${PV}/${P}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S=${WORKDIR}/${MY_PN}-${PV}
fi

LICENSE="BSD-2"

SLOT="0"

KEYWORDS="~amd64"

IUSE="doc"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	dev-libs/boost[${PYTHON_USEDEP}]
	media-libs/opencv[python,${PYTHON_USEDEP}]
	media-libs/opengv[python,${PYTHON_USEDEP}]
	>=sci-libs/ceres-solver-2.0.0
	sci-libs/suitesparse
	sci-libs/metis
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
	>=dev-util/cmake-3.0.0
"

RESTRICT="mirror"

PATCHES=(
	"${FILESDIR}/fix-include-libs.patch"
)
#distutils_enable_sphinx doc --no-autodoc
#distutils_enable_tests pytest
src_prepare() {
	default
	use doc || sed -i -e "/from sphinx\.setup_command import BuildDoc/d" -e "/\"build_doc\": BuildDoc\,/d" setup.py || die
	sed -i -e "/\"bin\/opensfm\"\,/a		\"bin\/opensfm_main\.py\"," setup.py || die

	#Enable cxx14-std as CERES-2.0 req it and unbundle pybind11
	sed -i -e "s|\(set(CMAKE_CXX_STANDARD \)11|\114|" \
		-e "s|add_subdirectory(third_party\/pybind11)|find_package (pybind11 CONFIG REQUIRED)|" opensfm/src/CMakeLists.txt || die
	sed -i -e "/^target_link_libraries(/,/)/s|pybind11|pybind11::headers|g" opensfm/src/{foundation,bundle,dense,features,geometry,robust,sfm,geo,map}/CMakeLists.txt || die
}

