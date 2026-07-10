# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Sans serif font by Vernon Adams"
HOMEPAGE="https://github.com/googlefonts/mulish"
COMMIT="5503f7a18ce79870148b9f9cb8e592ac44c044c3"
SRC_URI="https://github.com/googlefonts/${PN}/archive/${COMMIT}.tar.gz -> ${PN}-${COMMIT:0:7}.gh.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"
KEYWORDS="*"

IUSE="+otf ttf"
REQUIRED_USE="|| ( otf ttf )"

LICENSE="OFL-1.1"
SLOT="0"

# No binaries, only fonts
RESTRICT="strip binchecks mirror"


DOCS="README.md"

src_install() {
	if use otf; then
		FONT_S="${S}/fonts/otf" FONT_SUFFIX="otf" font_src_install
	fi
	if use ttf; then
		FONT_S="${S}/fonts/ttf" FONT_SUFFIX="ttf" font_src_install
	fi
}

