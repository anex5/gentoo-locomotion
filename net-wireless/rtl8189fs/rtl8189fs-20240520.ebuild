# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

MODULES_KERNEL_MAX=6.9
MODULES_KERNEL_MIN=6.1

COMMIT="30a52f789a0b933c4a7eb06cbf4a4d21c8e581aa"

DESCRIPTION="Realtek 8189es wifi chip driver"
HOMEPAGE="https://github.com/jwrdegoede/rtl8189ES_linux"
SRC_URI="https://github.com/jwrdegoede/rtl8189ES_linux/archive/${COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64 ~arm ~arm64"

DEPEND="virtual/linux-sources"

RDEPEND="!<net-wireless/rtl8189fs-${PV}"

S="${WORKDIR}/rtl8189ES_linux-${COMMIT}"

RESTRICT="mirror bindist"

pkg_setup() {
	linux-mod-r1_pkg_setup

	CONFIG_CHECK="~!SSB ~!X86_INTEL_LPSS"
	CONFIG_CHECK2="LIB80211 ~!MAC80211 ~LIB80211_CRYPT_TKIP WIRELESS_EXT COMPAT_NET_DEV_OPS CFG80211"
}

src_compile() {
	local modlist=( 8189es=kernel/drivers/net/wireless/realtek/rtlwifi/rtl8189es:. )
	local modargs=(
		KERNELDIR="${KV_OUT_DIR}"
		KVER=${KV_FULL}
		KSRC=${KERNEL_DIR}
	)

	linux-mod-r1_src_compile
}

