# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras experimental"
K_GENPATCHES_VER="5"
#K_DEFCONFIG="orangepi_lite_defconfig"
K_SECURITY_UNSUPPORTED=1
EXTRAVERSION="-${PN}/-*"
#K_EXP_GENPATCHES_NOUSE=1
K_DEBLOB_AVAILABLE=0

PV_MY="$(ver_cut 1-2)"

inherit kernel-2 linux-info
detect_version
detect_arch

KEYWORDS="arm arm64"
HOMEPAGE="https://xff.cz/kernels/"
IUSE="experimental"

DESCRIPTION="Full sources including the Gentoo patchset for the Allwiner Sunxi boards"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"

RESTRICT="mirror"

#UNIPATCH_EXCLUDE="
#	10*
#	15*
#	2400
#	29*
#	1700*
#	3000
#	4567
#"

pkg_pretend() {
	CHECKREQS_DISK_BUILD="4G"
	check-reqs_pkg_pretend
}

src_unpack() {
	kernel-2_src_unpack
	eapply -s "${FILESDIR}/${P}-all.patch"
}

src_prepare() {
	kernel-2_src_prepare
	rm "${S}/tools/testing/selftests/tc-testing/action-ebpf"
}

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "For more info on this patchset, see:"
	einfo "${HOMEPAGE}/${PV_MY}/README"
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
