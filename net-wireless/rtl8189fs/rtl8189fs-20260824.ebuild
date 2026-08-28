# Copyright 1999-2026 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1 flag-o-matic

MODULES_KERNEL_MAX=7.2
MODULES_KERNEL_MIN=6.18

COMMIT="cac32cbe7b0047c3d97a28ef1bd89e6fe2edd168"

DESCRIPTION="Realtek 8189es wifi chip driver"
HOMEPAGE="https://github.com/jwrdegoede/rtl8189ES_linux"
SRC_URI="https://github.com/jwrdegoede/rtl8189ES_linux/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.gh.tar.gz"
S="${WORKDIR}/rtl8189ES_linux-${COMMIT}"

KEYWORDS="~amd64 ~arm ~arm64 ~x86"
SLOT="0"
LICENSE="GPL-2"

DEPEND="virtual/linux-sources"

RESTRICT="mirror bindist"

pkg_setup() {
	linux-info_pkg_setup
	linux-mod-r1_pkg_setup

	CONFIG_CHECK="~!SSB ~!X86_INTEL_LPSS"
	CONFIG_CHECK2="LIB80211 ~!MAC80211 ~LIB80211_CRYPT_TKIP WIRELESS_EXT COMPAT_NET_DEV_OPS CFG80211"

	filter-flags -fno-plt
	filter-lto
	strip-unsupported-flags
}

src_prepare() {
	# Replace wrong EXTRA_CFLAGS (stopped working with kernels >= 6.15)
	# with proper CFLAGS_MODULE (available since 2.6.36).
	# Bug 957883
	sed -E -e 's/(^|[^A-Za-z0-9_])EXTRA_CFLAGS([^A-Za-z0-9_]|$)/\1CFLAGS_MODULE\2/g' -i Makefile || die

	default
}

src_compile() {
	local modlist=( 8189es=kernel/drivers/net/wireless/realtek/rtlwifi/rtl8189es:. )
	local modargs=( KVER="${KV_FULL}" KSRC="${KERNEL_DIR}" )
	linux-mod-r1_src_compile
}
