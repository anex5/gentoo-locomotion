# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 linux-mod

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/ulli-kroll/rtl8821cu"
	EGIT_BRANCH="master"
else
	EGIT_REPO_URI="https://github.com/ulli-kroll/rtl8821cu"
	EGIT_BRANCH="master"
	EGIT_COMMIT="20a35d6859b26690c74e218845d9193775e6bdbf"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Linux kernel module driver rtl8821cu/rtl8822cu for wireless abgn usb dongle device Realtek c811"
HOMEPAGE="https://github.com/ulli-kroll/rtl8821cu"

PATCHES=( "${FILESDIR}/RTL8812AU-02-fix-multiple-definitions.patch" )

SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND="
	virtual/linux-sources
	sys-kernel/linux-headers
"
RDEPEND=""

MODULE_NAMES="rtl8821cu(net/wireless/realtek)"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_TARGETS="all"
	BUILD_PARAMS="KVERSION=${KV_FULL}"
}

src_prepare() {
	# Fix build failure, bug #513542
	sed -i 's/^KDIR.*$/KDIR\ \:= \/usr\/src\/linux/g' Makefile || die
	default
}

src_install() {
	einstalldocs
	linux-mod_src_install
}
