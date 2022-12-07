# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit linux-mod linux-info toolchain-funcs

COMMIT="a9474332a84d245527977d462aa332b345837976"

DESCRIPTION="Driver for it87/it86 series hardware monitoring chips."
HOMEPAGE="https://github.com/frankcrawford/it87"
SRC_URI="https://github.com/frankcrawford/it87/archive/${COMMIT}.tar.gz -> it87-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"

DEPEND="virtual/linux-sources"

S="${WORKDIR}/it87-${COMMIT}"

RESTRICT="mirror bindist"

pkg_setup() {
	linux_config_exists
	if use kernel_linux; then
		MODULE_NAMES="it87(kernel/drivers/hwmon)"
		BUILD_TARGETS="clean modules"
		BUILD_PARAMS="KERNEL_BUILD=${KERNEL_DIR}"
		if linux_chkconfig_present CC_IS_CLANG; then
	  		BUILD_PARAMS+=" CC=${CHOST}-clang"
	  		if linux_chkconfig_present LD_IS_LLD; then
	    		BUILD_PARAMS+=' LD=ld.lld'
	    		if linux_chkconfig_present LTO_CLANG_THIN; then
	      			# kernel enables cache by default leading to sandbox violations
	      			BUILD_PARAMS+=' ldflags-y=--thinlto-cache-dir= LDFLAGS_MODULE=--thinlto-cache-dir='
	    		fi
	  		fi
		fi
		linux-mod_pkg_setup
	else
		die "Could not determine proper ${PN} package"
	fi
}

pkg_postinst() {
	linux-mod_pkg_postinst

	einfo "If module it87 fails to load at boot, and a manual insertion with modprobe"
	einfo "results in a device or resource busy error, you likely need to add"
	einfo "'acpi_enforce_resources=lax' to your kernel boot paramaters. Grub users"
	einfo "can do this in /etc/default/grub with the GRUB_CMDLINE_LINUX variable."
}
