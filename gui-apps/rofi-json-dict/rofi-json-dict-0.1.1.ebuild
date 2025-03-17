# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A json dictionary for rofi"
HOMEPAGE="https://github.com/marvinkreis/rofi-json-dict"

if [[ ${PV} == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/marvinkreis/${PN}.git"
else
	SRC_URI="https://github.com/marvinkreis/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"

BDEPEND="virtual/pkgconfig"
COMMON_DEPEND="
	dev-libs/glib:2
	gui-apps/rofi
	dev-libs/json-c
"
DEPEND="
	${COMMON_DEPEND}
	x11-libs/cairo
"
RDEPEND="${COMMON_DEPEND}"

IUSE="debug"

RESTRICT="mirror"

PATCHES=(
	"${FILESDIR}/${PN}-0.1.1-fix-gcc14-build.patch"
)

src_configure() {
	use debug && CMAKE_BUILD_TYPE="RelWithDebInfo" || CMAKE_BUILD_TYPE="Release"
	cmake_src_configure
}

src_install() {
	cmake_src_install
	dobin convert-dict
	fperms +x /usr/bin/convert-dict
}
