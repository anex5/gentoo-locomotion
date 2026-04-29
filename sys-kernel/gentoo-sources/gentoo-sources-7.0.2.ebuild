# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras experimental"
K_GENPATCHES_VER="3"

inherit kernel-2
detect_version
detect_arch

DESCRIPTION="Full sources including the Gentoo patchset for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
HOMEPAGE="https://dev.gentoo.org/~alicef/genpatches"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
IUSE="experimental"

PATCHES=(
	"${FILESDIR}/0001-7.0-rc2-nap-v0.2.1.patch"
	"${FILESDIR}/0001-7.0-rc3-Re-swappiness-v1.2.patch"
	"${FILESDIR}/0001-add-sysctl-to-allow-disabling-unprivileged-CLONE_NEW.patch"
	"${FILESDIR}/0001-Cachy-Allow-O3.patch"
	"${FILESDIR}/0001-cgroup-patches.patch"
	"${FILESDIR}/0001-clang-patches.patch"
	"${FILESDIR}/0001-cpu-7.0-merge-graysky-s-patchset.patch"
	"${FILESDIR}/0001-cpuidle-Prefer-teo-over-menu-governor.patch"
	"${FILESDIR}/0001-futex-7.0-Add-entry-point-for-FUTEX_WAIT_MULTIPLE-op.patch"
	"${FILESDIR}/0001-iosched-7.0-introduce-ADIOS-I-O-scheduler.patch"
	"${FILESDIR}/0001-mt76-patches.patch"
	"${FILESDIR}/0001-ntfs-7.0-merge-changes-from-dev-tree.patch"
	"${FILESDIR}/0001-PRJC-for-7.0.patch"
	"${FILESDIR}/0001-r8125-patches.patch"
	"${FILESDIR}/0001-Reflex-CPUFreq-Governor-v0.3.0r2.patch"
	"${FILESDIR}/0001-rt-patches.patch"
	"${FILESDIR}/0001-snd-codecs-patches.patch"
	"${FILESDIR}/0001-vesa-patches.patch"
	"${FILESDIR}/0001-zstd-dev-patches.patch"
)

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
