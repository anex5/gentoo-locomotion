# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Bumblebee-Project/${PN}.git"
	EGIT_BRANCH="develop"
else
	PATCHES=( "${FILESDIR}/${PN}-0.8-kernel-4.12.patch" )
	SRC_URI="https://github.com/Bumblebee-Project/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Toggle discrete NVIDIA Optimus graphics card"
HOMEPAGE="https://github.com/Bumblebee-Project/bbswitch"

SLOT="0"
LICENSE="GPL-3+"
IUSE=""

DEPEND="
	virtual/linux-sources
	sys-kernel/linux-headers
"
RDEPEND=""

MODULE_NAMES="bbswitch(acpi)"

pkg_setup() {
	if ! linux_config_exists; then
		ewarn "Cannot check the linux kernel configuration."
	fi
	BUILD_TARGETS="default"
	BUILD_PARAMS="KVERSION=${KV_FULL}"

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

	linux-mod_pkg_setup
}

src_prepare() {
	# Fix build failure, bug #513542
	sed -i 's/^KDIR.*$/KDIR\ \:= \/usr\/src\/linux/g' Makefile || die

	default
}

src_install() {
	insinto /etc/modprobe.d
	newins "${FILESDIR}"/bbswitch.modprobe bbswitch.conf
	dodoc NEWS README.md

	linux-mod_src_install
}
