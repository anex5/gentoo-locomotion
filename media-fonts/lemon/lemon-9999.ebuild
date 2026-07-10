# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Sans serif font by Eduardo Rodríguez Tunni"
HOMEPAGE="https://github.com/etunni/lemon"

SRC_URI="
ttf? (
	https://github.com/etunni/lemon/raw/refs/heads/master/fonts/ttf/Lemon-Regular.ttf
)
otf? (
	https://github.com/etunni/lemon/raw/refs/heads/master/fonts/otf/Lemon-Regular.otf
)
"
KEYWORDS="*"

LICENSE="OFL-1.1"
IUSE="+otf ttf"
REQUIRED_USE="|| ( otf ttf )"
SLOT="0"
FONT_SUFFIX=""

# No binaries, only fonts
RESTRICT="strip binchecks mirror"

src_unpack() {
	local f
	mkdir "${S}" || die
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${S}/${f}"
	done
}

src_install() {
	use otf && FONT_SUFFIX+="otf "
	use ttf && FONT_SUFFIX+="ttf"
	font_src_install
}

