# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

MODULES_KERNEL_MAX=6.12
MODULES_KERNEL_MIN=6.1

COMMIT="9a249f5a2096076125dc39f4fb574fc38eeb2304"

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
	linux-mod-r1_pkg_setup

	CONFIG_CHECK="~!SSB ~!X86_INTEL_LPSS"
	CONFIG_CHECK2="LIB80211 ~!MAC80211 ~LIB80211_CRYPT_TKIP WIRELESS_EXT COMPAT_NET_DEV_OPS CFG80211"
}

src_prepare() {
	default
	sed -e '/^\# gcc-13/,/^$/ s:^:\#:' -i Makefile || die "Failed to patch Makefile."
}

src_compile() {
	local modlist=( 8821cu=kernel/drivers/net/wireless/realtek/rtlwifi/rtl8821cu:. )

	local modargs=(
		KERNELDIR="${KV_OUT_DIR}"
		KVER=${KV_FULL}
		KSRC=${KERNEL_DIR}
	)

	linux-mod-r1_src_compile
}

