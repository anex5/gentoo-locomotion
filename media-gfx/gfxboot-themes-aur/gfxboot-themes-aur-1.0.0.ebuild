# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Gfxboot themes for Gentoo Linux"
HOMEPAGE="https://www.github.com/anex5"

EGIT_REPO_URI="https://www.github.com/anex5/gfxboot-themes-aur.git"

inherit git-r3

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

BDEPEND="media-gfx/gfxboot
		dev-lang/perl
		dev-vcs/git"

RDEPEND="${DEPEND}"

src_compile() {
		chmod 0755 po/bin/{rm_text,po2txt,fixpot,change_text,add_text} || die
		emake -j1
}

src_install() {
		dodir /usr/share/themes/gfxboot-themes-aur
		insinto /usr/share/themes/gfxboot-themes-aur
		doins -r install/bootlogo
}
