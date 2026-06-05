# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="Font-Awesome"
inherit font

DESCRIPTION="The iconic font"
HOMEPAGE="https://fontawesome.com"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/FortAwesome/${MY_PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/FortAwesome/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="*"
	S="${WORKDIR}/${MY_PN}-${PV}"
fi

RESTRICT="mirror"
LICENSE="CC-BY-4.0 OFL-1.1"
SLOT="0/7"
IUSE="+otf ttf"

FONT_CONF="${FILESDIR}/60-fontawesome-7-free-fonts.conf"

REQUIRED_USE="|| ( otf ttf )"

BDEPEND="
	media-libs/woff2
"

src_install() {
	if use otf; then
		FONT_S="${S}/otfs" FONT_SUFFIX="otf" font_src_install
	fi
	if use ttf; then
		woff2_decompress "${S}"/webfonts/fa-*.woff2
		FONT_S="${S}/webfonts" FONT_SUFFIX="ttf" font_src_install
	fi
}
