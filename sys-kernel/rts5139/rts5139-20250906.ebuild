# Copyright 1999-2026 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

MODULES_KERNEL_MAX=6.14.9
MODULES_KERNEL_MIN=3.17

COMMIT="6fe0d80b2de4fc15bb02b7d4da22b9b9be784c9a"

DESCRIPTION="Driver for Realtek rts5139 USB cardreader"
HOMEPAGE="https://realtek.com"
SRC_URI="https://github.com/asymingt/rts5139/archive/${COMMIT}.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

DEPEND="virtual/linux-sources"

RESTRICT="mirror bindist"

pkg_setup() {
	linux-mod-r1_pkg_setup
	CONFIG_CHECK="~MODULES ~CONFIG_RTS_PSTOR !~CONFIG_RTS5139"
}

src_compile() {
	local modlist=( rts5139=drivers/scsi )
	local modargs=(
		KERNELDIR="${KV_OUT_DIR}"
		KERNELRELEASE=${KV_FULL}
	)

	linux-mod-r1_src_compile
}

src_install() {
	dodir /etc/modprobe.d/
	dodir /etc/dracut.conf.d/
	cp "${S}/blacklist-rts5139.conf" "${D}/etc/modprobe.d/" || die "Install failed!"
	#cp "${FILESDIR}/blacklist_rtsx.conf" "${D}/etc/dracut.conf.d/" || die "Install failed!"
	linux-mod-r1_src_install
}
