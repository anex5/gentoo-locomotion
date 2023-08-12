# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="tiniest x86-64-linux emulator"
HOMEPAGE="https://github.com/jart/blink"
SRC_URI="https://github.com/jart/blink/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=""
RESTRICT="mirror"

src_configure() {
	./configure || die "configure failed"
}

src_install() {
	emake PREFIX="${D}"/usr install
}
