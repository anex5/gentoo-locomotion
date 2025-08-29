# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Sans serif font by Jovanny Lemonad"
HOMEPAGE="https://github.com/googlefonts/rubik"
FONT_FACES=(Black BlackItalic Bold BoldItalic Italic Light LightItalic Medium MediumItalic Regular)
COMMON_URI="https://github.com/googlefonts/rubik/raw/refs/heads/main/old/version-2/fonts"

gen_src_uri() {
	for f in ${FONT_FACES[*]}; do
		echo "otf? ( ${COMMON_URI}/otf/Rubik-${f}.otf )"
		echo "ttf? ( ${COMMON_URI}/ttf/Rubik-${f}.ttf )"
	done
}

SRC_URI="$(gen_src_uri)"

LICENSE="|| ( LGPL-2.1 OFL-1.1 )"
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
