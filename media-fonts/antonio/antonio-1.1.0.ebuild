# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

MY_PN="${PN}Font"

DESCRIPTION="A 'refined' version of the Anton font, a large typeface designed for banners and headlines"
HOMEPAGE="https://github.com/vernnobile/antonioFont"
EGIT_COMMIT="4b3e07ab5647a613931153a09067a785f54b980a"
SRC_URI="https://github.com/vernnobile/${MY_PN}/archive/${EGIT_COMMIT}.tar.gz -> ${MY_PN}-${EGIT_COMMIT}.tar.gz"
IUSE="+otf +ttf"
REQUIRED_USE="|| ( otf ttf )"

LICENSE="|| ( LGPL-2.1 OFL-1.1 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos"

# No binaries, only fonts
RESTRICT="strip binchecks mirror"

S="${WORKDIR}/${MY_PN}-${EGIT_COMMIT}"

DOCS="README.md"

src_install() {
	for dir in Bold Light Regular; do
		use otf && FONT_S="${S}/${dir}/src/" FONT_SUFFIX="otf" font_src_install
		use ttf && FONT_S="${S}/${dir}/src/" FONT_SUFFIX="ttf" font_src_install
	done
}

