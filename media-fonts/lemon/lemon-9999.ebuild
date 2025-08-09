# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Sans serif font by Eduardo Rodríguez Tunni"
HOMEPAGE="https://github.com/etunni/lemon"

inherit git-r3
EGIT_REPO_URI="https://github.com/etunni/${PN}.git"
EGIT_COMMIT="88027507a29de7878336812a328d25245c106e9b"
KEYWORDS="*"

IUSE="+otf +ttf"
REQUIRED_USE="|| ( otf ttf )"
LICENSE="|| ( LGPL-2.1 OFL-1.1 )"
SLOT="0"
KEYWORDS="*"

# No binaries, only fonts
RESTRICT="strip binchecks mirror"

DOCS="README.md"

src_install() {
	use otf && FONT_S="${S}/fonts/otf" FONT_SUFFIX="otf" font_src_install
	use ttf && FONT_S="${S}/fonts/ttf" FONT_SUFFIX="ttf" font_src_install
}

