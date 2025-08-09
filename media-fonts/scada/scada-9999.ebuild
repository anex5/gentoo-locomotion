# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Sans serif font by Jovanny Lemonad"
HOMEPAGE="https://github.com/google/fonts"
SRC_URI="
https://github.com/google/fonts/raw/main/ofl/${PN}/${PN^}-Regular.ttf
https://github.com/google/fonts/raw/main/ofl/${PN}/${PN^}-Bold.ttf
https://github.com/google/fonts/raw/main/ofl/${PN}/${PN^}-Italic.ttf
https://github.com/google/fonts/raw/main/ofl/${PN}/${PN^}-BoldItalic.ttf
"

LICENSE="|| ( LGPL-2.1 OFL-1.1 )"
SLOT="0"
KEYWORDS="*"

# No binaries, only fonts
RESTRICT="strip binchecks mirror"

FONT_SUFFIX="ttf"

src_unpack(){
	mkdir -p ${S}
	cp ${DISTDIR}/${A} ${S}
}
