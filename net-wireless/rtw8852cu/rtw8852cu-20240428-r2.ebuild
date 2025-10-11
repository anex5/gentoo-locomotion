# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1 flag-o-matic

MODULES_KERNEL_MAX=6.17
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

src_prepare() {
	default
	sed -e '/^\# gcc-1[0-9]/,/^$/ s:^:\#:' -i Makefile || die "Failed to patch Makefile."
	if [[ -n ${KV_FULL} ]] && kernel_is -gt 6 12; then
		eapply "${FILESDIR}/rtl-fix-kernel-6.13-build-4c0f3cf.patch"
	fi
	if [[ -n ${KV_FULL} ]] && kernel_is -gt 6 14; then
		eapply "${FILESDIR}/rtl-fix-kernel-6.15-build-c014d09.patch"
	fi
	#if [[ -n ${KV_FULL} ]] && kernel_is -gt 6 15; then
	#	eapply "${FILESDIR}/rtl-fix-kernel-6.16-build-efd68a7.patch"
	#fi
}

src_compile() {
	filter-flags -O3 -fno-plt #912949
	filter-lto
	CC=${KERNEL_CC} CXX=${KERNEL_CXX} strip-unsupported-flags

	local modlist=( 8852cu=kernel/drivers/net/wireless/realtek/rtlwifi/rtw8852cu:. )

	local modargs=(
		KERNELDIR="${KV_OUT_DIR}"
		KVER=${KV_FULL}
		KSRC=${KERNEL_DIR}
	)

	linux-mod-r1_src_compile
}

