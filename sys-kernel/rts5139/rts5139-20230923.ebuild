# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

MODULES_KERNEL_MAX=6.9
MODULES_KERNEL_MIN=3.16

COMMIT="6dd73fd9f877b01ad5a0ba3e26d564384e54935f"

DESCRIPTION="Driver for Realtek rts5139 USB cardreader"
HOMEPAGE="https://realtek.com"
SRC_URI="https://github.com/ljmf00/rts5139/archive/${COMMIT}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 x86"

DEPEND="virtual/linux-sources"

RDEPEND="!<sys-kernel/${P}"

S="${WORKDIR}/${PN}-${COMMIT}"

RESTRICT="mirror bindist"

pkg_setup() {
	linux-mod-r1_pkg_setup
	CONFIG_CHECK=""
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

