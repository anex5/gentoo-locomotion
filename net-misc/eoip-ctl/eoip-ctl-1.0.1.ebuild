# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils git-r3 toolchain-funcs

DESCRIPTION="Kernel mode EOIP (Ethernet Over IP) tunnel management utility."
HOMEPAGE="https://github.com/ndmsystems/eoip-ctl/blob/1.0-1/README.md"

EGIT_REPO_URI="https://github.com/ndmsystems/eoip-ctl"
EGIT_COMMIT="ca35a5efd64c6eb512ca870f9eb86318cdcd7019"

LICENSE="GPL-2"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~arm ~x86 ~mips"

DEPEND=""

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	dosbin "${PN}"
}

pkg_postinst() {
	elog "Userland tunnel management utility for \"eoip.ko\" kernel module"
}
