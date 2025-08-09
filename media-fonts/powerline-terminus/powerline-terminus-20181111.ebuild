# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

FONT_SIZES=( 18 20 22 24 28 32 )

DESCRIPTION="Console Unicode Terminus font with symbols for Powerline/Airline"
HOMEPAGE="https://github.com/powerline/powerline"
COMMON_URI="https://raw.githubusercontent.com/powerline/fonts/master/Terminus"
gen_src_uri() {
	for f in ${FONT_SIZES[*]}; do
		echo "pcf? ( ${COMMON_URI}/PCF/ter-powerline-x${f}n.pcf.gz ${COMMON_URI}/PCF/ter-powerline-x${f}b.pcf.gz )"
		echo "psf? ( ${COMMON_URI}/PSF/ter-powerline-v${f}n.psf.gz ${COMMON_URI}/PSF/ter-powerline-v${f}b.psf.gz )"
	done
}

SRC_URI="$(gen_src_uri)"
RESTRICT="mirror strip binchecks"
LICENSE="OFL-1.1 GPL-2 MIT"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~loong ~mips ppc ppc64 ~riscv ~s390 ~sparc x86 ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="+pcf +psf"
FONTDIR="${EPREFIX}/usr/share/consolefonts"
REQUIRED_USE="!X"

src_unpack(){
	mkdir -p ${S}
	for a in ${A}; do
		use pcf && ( [[ ${a%*.psf.gz}==${a} ]] && cp ${DISTDIR}/${a} ${S} || continue )
		use psf && ( [[ ${a%*.pcf.gz}==${a} ]] && cp ${DISTDIR}/${a} ${S} || continue )
	done
}

src_prepare(){
	default
	use pcf && FONT_SUFFIX="pcf.gz "
	use psf && FONT_SUFFIX+="psf.gz"
}
