# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

MODULES_KERNEL_MAX=6.9
MODULES_KERNEL_MIN=6.1

COMMIT="d256c2ae282b70f03629e36900da54905ab4187c"

DESCRIPTION="Realtek RTL8811CU/RTL8821CU USB wifi adapter driver"
HOMEPAGE="https://github.com/lwfinger/rtw8852cu"
SRC_URI="https://github.com/lwfinger/rtw8852cu/archive/${COMMIT}.tar.gz -> rtw8852cu-${PV}-${COMMIT}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64 ~arm ~arm64"

DEPEND="virtual/linux-sources"

RDEPEND="!<net-wireless/rtw8852cu-${PV}"

S="${WORKDIR}/rtw8852cu-${COMMIT}"

RESTRICT="mirror bindist"

pkg_setup() {
	linux-mod-r1_pkg_setup

	CONFIG_CHECK="~!SSB ~!X86_INTEL_LPSS"
	CONFIG_CHECK2="LIB80211 ~!MAC80211 ~LIB80211_CRYPT_TKIP WIRELESS_EXT COMPAT_NET_DEV_OPS CFG80211"
}

src_compile() {
	local modlist=( 8852cu=kernel/drivers/net/wireless/realtek/rtlwifi/rtw8852cu:. )

	local modargs=(
		KERNELDIR="${KV_OUT_DIR}"
		KVER=${KV_FULL}
		KSRC=${KERNEL_DIR}
	)

	linux-mod-r1_src_compile
}

