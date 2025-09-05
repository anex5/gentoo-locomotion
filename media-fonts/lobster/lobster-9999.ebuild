# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="A bold condensed script font with ligatures and alternates"
HOMEPAGE="https://github.com/googlefonts/lobster"

SRC_URI="
	otf? ( https://github.com/googlefonts/lobster/raw/refs/heads/main/fonts/otf/Lobster-Regular.otf )
	ttf? ( https://github.com/googlefonts/lobster/raw/refs/heads/main/fonts/ttf/Lobster-Regular.ttf )
"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="*"
IUSE="+otf ttf"

REQUIRED_USE="|| ( otf ttf )"

# No binaries, only fonts
RESTRICT="strip binchecks mirror"

src_unpack(){
	local f
	mkdir "${S}" || die
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${S}/${f}"
	done
}

src_install() {
	use otf && FONT_SUFFIX="otf "
	use ttf && FONT_SUFFIX+="ttf"
	font_src_install
}
