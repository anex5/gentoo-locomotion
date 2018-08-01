# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Gfxboot themes for Gentoo Linux"
HOMEPAGE="http://www.github.com/anex5"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="media-gfx/gfxboot"
#	!<sys-apps/calculate-utils-3.5.2.6"

RDEPEND="${DEPEND}"

S=${FILESDIR}

src_compile() {
	emake -j1
}

src_install() {
	dodir /usr/share/themes/gfxboot-themes-aur
	insinto /usr/share/themes/gfxboot-themes-aur
	doins -r $(find install/* | grep -v -e back.jpg -e install/log -e bootlogo.tar.gz)
}
