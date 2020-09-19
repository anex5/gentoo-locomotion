# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 cmake

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/laurentkneip/opengv"
	EGIT_BRANCH="master"
else
	EGIT_REPO_URI="https://github.com/laurentkneip/opengv"
	EGIT_BRANCH="master"
	EGIT_COMMIT=""
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Library for solving calibrated central and non-central geometric vision problems"
HOMEPAGE="http://laurentkneip.github.io/opengv"

#PATCHES=( "${FILESDIR}/.patch" )

SLOT="0"
LICENSE="MPL-2"
IUSE="python test"

DEPEND="
	>=dev-libs/boost-1.60.0
	>=dev-cpp/eigen-3.3.4
"
RDEPEND=""

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
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
