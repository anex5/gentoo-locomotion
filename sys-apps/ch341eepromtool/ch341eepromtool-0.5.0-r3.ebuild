# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="An i2c serial EEPROM programming tool for the WCH CH341A"
HOMEPAGE="https://github.com/stefanct/ch341eepromtool"
SRC_URI="https://github.com/stefanct/${PN}/archive/refs/heads/master.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="doc"
RESTRICT="mirror"
DEPEND=">=dev-libs/libusb-1.0.0"

PATCHES=(
	"${FILESDIR}/libusb_set_option.patch"
	"${FILESDIR}/extern_readbuf.patch"
)

DOCS=( README )

S="${WORKDIR}/${PN}-master"

src_compile() {
	$(tc-getCC) ${CFLAGS} -o ch341eeprom ch341eeprom.c ch341funcs.c -lusb-1.0 || die
}

src_install() {
	insinto /usr/bin
	dobin "${S}"/ch341eeprom
	use doc && dodoc
}

