# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Kernel mode EOIP (Ethernet Over IP) tunnel management utility."
HOMEPAGE="https://github.com/ndmsystems/eoip-ctl/blob/1.0-1/README.md"

SRC_URI="https://github.com/ndmsystems/eoip-ctl/archive/refs/heads/master.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~arm ~x86 ~mips"
RESTRICT="mirror"

S="${WORKDIR}/${PN}-master"

src_compile() {
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}"
}

src_install() {
	dosbin "${PN}"
}

pkg_postinst() {
	elog "Userland tunnel management utility for \"eoip.ko\" kernel module"
}
