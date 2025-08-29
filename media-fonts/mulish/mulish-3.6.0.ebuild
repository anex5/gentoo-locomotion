# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Sans serif font by Vernon Adams"
HOMEPAGE="https://github.com/googlefonts/mulish"
EGIT_COMMIT="ab3f1c59394dafbc6cb55feec2135d6116476142"
SRC_URI="https://github.com/googlefonts/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${EGIT_COMMIT}.tar.gz"
IUSE="+otf ttf"
REQUIRED_USE="|| ( otf ttf )"

LICENSE="|| ( LGPL-2.1 OFL-1.1 )"
SLOT="0"
KEYWORDS="*"

# No binaries, only fonts
RESTRICT="strip binchecks mirror"

S="${WORKDIR}/${PN}-${EGIT_COMMIT}"

DOCS="README.md"

src_install() {
	use otf && FONT_S="${S}/fonts/otf" FONT_SUFFIX="otf "
	use ttf && FONT_S="${S}/fonts/ttf" FONT_SUFFIX+="ttf"
	font_src_install
}

