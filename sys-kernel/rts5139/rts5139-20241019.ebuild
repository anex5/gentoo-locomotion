# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

MODULES_KERNEL_MAX=6.10
MODULES_KERNEL_MIN=3.17

COMMIT="2564f4c9d1db4089dd08d453465c033fc10852df"

DESCRIPTION="Driver for Realtek rts5139 USB cardreader"
HOMEPAGE="https://realtek.com"
SRC_URI="https://github.com/asymingt/rts5139/archive/${COMMIT}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 x86"

DEPEND="virtual/linux-sources"

RDEPEND="!<sys-kernel/${P}"

S="${WORKDIR}/${PN}-${COMMIT}"

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

