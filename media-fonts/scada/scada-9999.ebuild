# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Sans serif font by Jovanny Lemonad"
HOMEPAGE="https://github.com/googlefonts/scada"
SRC_URI="
ttf? (
	https://github.com/googlefonts/scada/raw/refs/heads/main/fonts/ttf/Scada-Regular.ttf
	https://github.com/googlefonts/scada/raw/refs/heads/main/fonts/ttf/Scada-Bold.ttf
	https://github.com/googlefonts/scada/raw/refs/heads/main/fonts/ttf/Scada-Italic.ttf
	https://github.com/googlefonts/scada/raw/refs/heads/main/fonts/ttf/Scada-BoldItalic.ttf
)
otf? (
	https://github.com/googlefonts/scada/raw/refs/heads/main/fonts/otf/Scada-Regular.otf
	https://github.com/googlefonts/scada/raw/refs/heads/main/fonts/otf/Scada-Bold.otf
	https://github.com/googlefonts/scada/raw/refs/heads/main/fonts/otf/Scada-Italic.otf
	https://github.com/googlefonts/scada/raw/refs/heads/main/fonts/otf/Scada-BoldItalic.otf
)
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
