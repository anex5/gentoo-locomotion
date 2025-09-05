# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="A 'refined' version of the Anton font, a large typeface designed for banners and headlines"
HOMEPAGE="https://github.com/vernnobile/antonioFont"

SRC_URI="
	otf? (
		https://github.com/vernnobile/antonioFont/raw/refs/heads/master/Bold/src/Antonio-Bold.otf
		https://github.com/vernnobile/antonioFont/raw/refs/heads/master/Light/src/Antonio-Light.otf
		https://github.com/vernnobile/antonioFont/raw/refs/heads/master/Regular/src/Antonio-Regular.otf

	)
	ttf? (
		https://github.com/vernnobile/antonioFont/raw/refs/heads/master/Bold/Antonio-Bold.ttf
		https://github.com/vernnobile/antonioFont/raw/refs/heads/master/Light/Antonio-Light.ttf
		https://github.com/vernnobile/antonioFont/raw/refs/heads/master/Regular/Antonio-Regular.ttf
	)
"
IUSE="+otf ttf"
REQUIRED_USE="|| ( otf ttf )"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="*"

# No binaries, only fonts
RESTRICT="strip binchecks mirror"

FONT_SUFFIX=""

src_unpack() {
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

