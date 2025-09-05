# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="A rounded geometric sans-serif type design intended for large sizes"
HOMEPAGE="https://github.com/googlefonts/comfortaa"
FONT_FACES=(Bold Light Regular)
COMMON_URI="https://github.com/googlefonts/comfortaa/raw/refs/heads/main/fonts"

gen_src_uri() {
	for f in ${FONT_FACES[*]}; do
		echo "otf? ( ${COMMON_URI}/OTF/Comfortaa-${f}.otf )"
		echo "ttf? ( ${COMMON_URI}/TTF/Comfortaa-${f}.ttf )"
	done
}

SRC_URI="$(gen_src_uri)"

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
