# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )

inherit git-r3 cmake python-r1

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/laurentkneip/opengv"
	EGIT_BRANCH="master"
	EGIT_SUBMODULES=()
	KEYWORDS=""
else
	EGIT_REPO_URI="https://github.com/laurentkneip/opengv"
	EGIT_BRANCH="master"
	EGIT_SUBMODULES=()
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Library for solving calibrated central and non-central geometric vision problems"
HOMEPAGE="http://laurentkneip.github.io/opengv"

#PATCHES=( "${FILESDIR}/.patch" )

SLOT="0"
LICENSE="MPL-2"
IUSE="python test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	>=dev-cpp/eigen-3.3.4
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-libs/boost[${PYTHON_USEDEP}]
	')
"
RDEPEND=""
BDEPEND="
	dev-python/pybind11[${PYTHON_USEDEP}]
	>=dev-util/cmake-3.0.0
"

src_configure() {
	CMAKE_BUILD_TYPE=Release
	sed -i -e "s|\(set(CMAKE_CXX_STANDARD \)11|\114|" \
		-e "s|add_subdirectory(pybind11)|find_package (pybind11 CONFIG REQUIRED)|" python/CMakeLists.txt || die
	local mycmakeargs=(
		-DBUILD_PYTHON=$(usex python ON OFF)
		-DBUILD_TESTS=$(usex test ON OFF)
	)
	cmake_src_configure
}

src_install() {
	#insinto /usr/$(get_libdir)
	cmake_src_install
	mv ${D}/usr/lib/ ${D}/usr/$(get_libdir) || die
}
