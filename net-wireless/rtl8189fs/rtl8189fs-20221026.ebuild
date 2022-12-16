# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit linux-mod linux-info toolchain-funcs

COMMIT="476020109b3841421af289a7b78c7a25b0c45fac"

DESCRIPTION="Realtek 8189es module for Linux kernel"
HOMEPAGE="https://github.com/jwrdegoede/rtl8189ES_linux"
SRC_URI="https://github.com/jwrdegoede/rtl8189ES_linux/archive/${COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64 ~arm ~aarch64"

DEPEND="virtual/linux-sources"

S="${WORKDIR}/rtl8189ES_linux-${COMMIT}"

RESTRICT="mirror bindist"

pkg_setup() {
	linux_config_exists
	if use kernel_linux; then
		BUILD_TARGETS="clean modules"
		MODULE_NAMES="8189fs(net/wireless)"
		BUILD_PARAMS="KVER=${KV_FULL} KSRC=${KERNEL_DIR} V=1"
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

