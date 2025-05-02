# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

MODULES_KERNEL_MAX=6.14
MODULES_KERNEL_MIN=2.6.33

COMMIT="4bff981a91bf9209b52e30ee24ca39df163a8bcd"

DESCRIPTION="Driver for it87/it86 series hardware monitoring chips."
HOMEPAGE="https://github.com/frankcrawford/it87"
SRC_URI="https://github.com/frankcrawford/it87/archive/${COMMIT}.tar.gz -> it87-${PV}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"

DEPEND="virtual/linux-sources"

RDEPEND="!<sys-kernel/it87-driver-${PV}"

S="${WORKDIR}/it87-${COMMIT}"

RESTRICT="mirror bindist"

pkg_setup() {
	linux-mod-r1_pkg_setup

	CONFIG_CHECK="~MODULES ~HWMON ~I2C_CHARDEV ~I2C"
}

src_compile() {
	local modlist=( it87=kernel/drivers/hwmon:. )
	local modargs=(
		KERNELDIR="${KV_OUT_DIR}"
		TARGET=${KV_FULL}
		KERNEL_BUILD=${KERNEL_DIR}
	)

	linux-mod-r1_src_compile
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst

	einfo "If module it87 fails to load at boot, and a manual insertion with modprobe"
	einfo "results in a device or resource busy error, you likely need to add"
	einfo "'acpi_enforce_resources=lax' to your kernel boot paramaters. Grub users"
	einfo "can do this in /etc/default/grub with the GRUB_CMDLINE_LINUX variable."
}
