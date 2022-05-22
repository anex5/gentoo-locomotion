# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit linux-mod

COMMIT="1269e117454069cd47f1822ffa31e29ec19a10da"

DESCRIPTION="Realtek 8189ftv module for Linux kernel"
HOMEPAGE="https://github.com/jwrdegoede/rtl8189ES_linux"
SRC_URI="https://github.com/jwrdegoede/rtl8189ES_linux/archive/${COMMIT}.tar.gz -> rtl8189ftv-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64 ~arm ~aarch64"

DEPEND="virtual/linux-sources"

S="${WORKDIR}/rtl8189ES_linux-${COMMIT}"

RESTRICT="mirror"

pkg_setup() {
	if use kernel_linux; then
		BUILD_TARGETS="clean modules"
		MODULE_NAMES="8189es(net/wireless)"
		BUILD_PARAMS="KVER=${KV_FULL} KSRC=${KERNEL_DIR} V=1"

		linux-mod_pkg_setup
	else
		die "Could not determine proper ${PN} package"
	fi
}

