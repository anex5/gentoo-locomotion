# Copyright 2019-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="C++ Core Guidelines Support Library"
HOMEPAGE="https://github.com/microsoft/GSL"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/microsoft/GSL"
	EGIT_BRANCH="main"
	EGIT_SUBMODULES=()
	KEYWORDS=""
	DOCS=( docs/headers.md )
else
	SRC_URI="https://github.com/microsoft/GSL/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S=${WORKDIR}/${P^^}
	DOCS=( README.md CONTRIBUTING.md LICENSE )
fi

IUSE="test"
LICENSE="MIT"
SLOT="0"

BDEPEND="
	test? ( dev-cpp/gtest )
"

RESTRICT="
	!test? ( test )
	mirror
"

src_configure() {
	CMAKE_BUILD_TYPE=Release

	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DGSL_TEST=$(usex test)
		-DGSL_INSTALL=ON
	)
	cmake_src_configure
}

src_test() {
	cd ${BUILD_DIR}/tests && (./gsl_tests || die "Tests failed")
}
