# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1 flag-o-matic

MODULES_KERNEL_MAX=6.18
MODULES_KERNEL_MIN=6.1

COMMIT="3d1fcf4bc838542ceb03b0b4e9e40600720cf6ae"

DESCRIPTION="Realtek RTL8811CU/RTL8821CU USB wifi adapter driver"
HOMEPAGE="https://github.com/morrownr/8821cu-20210916"
SRC_URI="https://github.com/morrownr/8821cu-${PV}/archive/${COMMIT}.tar.gz -> rtl8821cu-${PV}-${COMMIT}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64 ~arm ~arm64"

DEPEND="virtual/linux-sources"

RDEPEND="!<net-wireless/rtl8821cu-${PV}"

S="${WORKDIR}/8821cu-${PV}-${COMMIT}"

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
	sed -e '/^\# gcc-13/,/^$/ s:^:\#:' -i Makefile || die "Failed to patch Makefile."
	if [[ -n ${KV_FULL} ]] && kernel_is -gt 6 17; then
		eapply "${FILESDIR}/rtl8821cu-fix-build-with-kernel-6.18.patch"
	fi
	default
}

src_compile() {
	local modlist=( 8821cu=kernel/drivers/net/wireless/realtek/rtlwifi/rtl8821cu:. )

	local modargs=( KVER="${KV_FULL}" KSRC="${KERNEL_DIR}" )

	linux-mod-r1_src_compile
}

