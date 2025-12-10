# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson desktop xdg-utils

DESCRIPTION="Do live calculations in rofi!"
HOMEPAGE="https://github.com/svenstaro/rofi-calc"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/svenstaro/rofi-calc.git"
	EGIT_SUBMODULES=()
	KEYWORDS=""
else
	COMMIT="e9d785e2de1af442441b127c9b0151b5e507af85"
	SRC_URI="https://github.com/svenstaro/rofi-calc/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
	S="${WORKDIR}/${PN}-${COMMIT}"
fi

LICENSE="MIT"
SLOT="0"
RESTRICT="mirror"

DEPEND="
	x11-libs/cairo
	>=gui-apps/rofi-1.7.6
	>=dev-libs/glib-2.40:2
"
RDEPEND="${DEPEND}
	>=sci-libs/libqalculate-2.0
"

PATCHES=(
	"${FILESDIR}/${PN}-2.5.0-reload-menu-on-history-cmd.patch"
	"${FILESDIR}/${PN}-2.5.0-add-to-history-hint.patch"
)

DOCS=( CHANGELOG.md README.md )

src_install() {
	meson_src_install
	domenu "${FILESDIR}/calc.desktop"
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
