# Copyright 1999-2026 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

MODULES_KERNEL_MAX=7.1
MODULES_KERNEL_MIN=2.6.33

COMMIT="20f2f2f4c92c14fcdd26f60d050e693ad2c30bf8"

DESCRIPTION="Driver for it87/it86 series hardware monitoring chips"
HOMEPAGE="https://github.com/frankcrawford/it87"
SRC_URI="https://github.com/frankcrawford/it87/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.gh.tar.gz"
LICENSE="GPL-2"
KEYWORDS="amd64"
SLOT="0"

DEPEND="virtual/linux-sources"

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
