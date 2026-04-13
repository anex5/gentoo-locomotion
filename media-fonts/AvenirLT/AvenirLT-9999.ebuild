# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="A linear sans in the tradition of Erbar and Futura by Adrian Frutiger"
HOMEPAGE="https://github.com/Kyles-World/Avenir-Font"
FONT_FACES=(Bold BoldOblique ExtraBold ExtraBoldOblique ExtraLight ExtraLightOblique Light LightOblique Medium MediumOblique Oblique Regular)
COMMON_URI="https://github.com/Kyles-World/Avenir-Font/raw/refs/heads/main"

gen_src_uri() {
	for f in ${FONT_FACES[*]}; do
		echo "otf? ( ${COMMON_URI}/Avenir%20LT%20(Pro%20Version)/AvenirLTPro-${f}.otf )"
		echo "ttf? ( ${COMMON_URI}/Avenir%20LT%20(Linotype)/AvenirLT-${f}.ttf )"
	done
}

SRC_URI="$(gen_src_uri)"

LICENSE="Unlicense"
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
