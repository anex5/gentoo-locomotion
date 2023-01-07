# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ETYPE=sources
K_DEFCONFIG="orangepi_lite_defconfig"
K_SECURITY_UNSUPPORTED=1
EXTRAVERSION="-${PN}/-*"

K_EXP_GENPATCHES_NOUSE=1
K_GENPATCHES_VER=1
K_DEBLOB_AVAILABLE=0
K_WANT_GENPATCHES="base extras"

inherit kernel-2 linux-info
detect_version
detect_arch

DESCRIPTION="Sunxi kernel sources"
HOMEPAGE="https://github.com/megous/linux"
SRC_URI="
	https://github.com/megous/linux/archive/refs/tags/orange-pi-6.1-20221211-1046.tar.gz -> linux-${KV_FULL}.tar.gz
	${GENPATCHES_URI}
"

KEYWORDS="arm arm64"

RESTRICT="mirror"

UNIPATCH_EXCLUDE="
	10*
	15*
	2000
	29*
	1700*
	3000
	4567"

#PATCHES=(
#	"${FILESDIR}/v6.1-samitolvanen-linux-lto-v9.patch"
#)

pkg_setup() {
	ewarn ""
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "If you need support, please contact the sunxi developers directly."
	ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	ewarn "the ebuilds. Thank you."
	ewarn ""

	kernel-2_pkg_setup
}

universal_unpack() {
	unpack linux-${KV_FULL}.tar.gz

	# We want to rename the unpacked directory to a nice normalised string
	# bug #762766
	mv "${WORKDIR}"/linux-orange-pi-6.1-20221211-1046 "${WORKDIR}"/linux-${KV_FULL} || die

	# remove all backup files
	find . -iname "*~" -exec rm {} \; 2>/dev/null
}

src_prepare() {
	default
	kernel-2_src_prepare
}

pkg_postinst() {
	kernel-2_pkg_postinst
}

pkg_postrm() {
	kernel-2_pkg_postrm
}

