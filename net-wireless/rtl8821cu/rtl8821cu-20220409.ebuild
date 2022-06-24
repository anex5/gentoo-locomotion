# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit linux-mod

COMMIT="8c2226a74ae718439d56248bd2e44ccf717086d5"

DESCRIPTION="Realtek RTL8811CU/RTL8821CU USB wifi adapter driver"
HOMEPAGE="https://github.com/brektrou/rtl8821CU"
SRC_URI="https://github.com/brektrou/rtl8821CU/archive/${COMMIT}.tar.gz -> rtl8821cu-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64 ~arm ~aarch64"

DEPEND="virtual/linux-sources"

S="${WORKDIR}/rtl8821CU-${COMMIT}"

PATCHES=(
	"${FILESDIR}/rtl8821cu-5.18-kernel-fix.patch"
)

pkg_setup() {
	if use kernel_linux; then
		MODULE_NAMES="8821cu(net/wireless)"
		BUILD_PARAMS="KERN_DIR=${KERNEL_DIR} KSRC=${KERNEL_DIR} V=1 KBUILD_VERBOSE=1"
		linux-mod_pkg_setup
	else
		die "Could not determine proper ${PN} package"
	fi

}

