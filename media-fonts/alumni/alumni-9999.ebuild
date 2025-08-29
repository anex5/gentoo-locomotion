# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Sans serif font originally inspired by the black face Impact™."
HOMEPAGE="https://github.com/googlefonts/alumni"
FONT_FACES=( Black BlackItalic Bold BoldItalic ExtraBold ExtraBoldItalic ExtraLight ExtraLightItalic Italic Light LightItalic Medium MediumItalic Regular SemiBold SemiBoldItalic Thin ThinItalic )
COMMON_URI="https://github.com/googlefonts/alumni/raw/refs/heads/master/fonts"

gen_src_uri() {
	for f in ${FONT_FACES[*]}; do
		echo "otf? ( ${COMMON_URI}/otf/AlumniSans-${f}.otf )"
		echo "ttf? ( ${COMMON_URI}/ttf/AlumniSans-${f}.ttf )"
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
