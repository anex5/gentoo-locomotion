# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit linux-mod linux-info toolchain-funcs

COMMIT="81da785e6b348aa2f27d89566e1e58783a1169df"

DESCRIPTION="Realtek RTL8811CU/RTL8821CU USB wifi adapter driver"
HOMEPAGE="https://github.com/morrownr/8821cu-20210916"
SRC_URI="https://github.com/morrownr/8821cu-${PV}/archive/${COMMIT}.tar.gz -> rtl8821cu-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"

DEPEND="virtual/linux-sources"

S="${WORKDIR}/8821cu-${PV}-${COMMIT}"

RESTRICT="mirror bindist"

MODULE_NAMES="8821cu(net/wireless)"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KVER=${KV_FULL}"
	BUILD_TARGETS="all"
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
}

