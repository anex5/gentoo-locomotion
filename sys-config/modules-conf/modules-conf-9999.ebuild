# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A configuration files for kernel modules"
HOMEPAGE="https://github.com/anex5"
KEYWORDS="amd64 x86"

LICENSE="GPL-2+"
SLOT="0"
IUSE="video_cards_i915 video_cards_nouveau video_cards_amdgpu video_cards_radeon video_cards_virtualbox +alsa +vfio +kvm +zswap +drm bbswitch +blacklist"

S=${WORKDIR}

src_unpack() {
	:
}

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	:
}

pkg_preinst() {
	insinto /etc/modprobe.d
	use alsa && doins ${FILESDIR}/alsa-base.conf
	use drm && doins ${FILESDIR}/drm_kms_helper.conf
	use kvm && doins ${FILESDIR}/kvm.conf
	use vfio && doins ${FILESDIR}/vfio.conf
	use zswap && doins ${FILESDIR}/zswap.conf
	use bbswitch && doins ${FILESDIR}/bbswitch.conf
	use video_cards_i915 && doins ${FILESDIR}/i915.conf
	use video_cards_nouveau && doins ${FILESDIR}/nouveau.conf
	use video_cards_nvidia && doins ${FILESDIR}/nvidia.conf
	use video_cards_amdgpu && doins ${FILESDIR}/amdgpu.conf
	use video_cards_radeon && doins ${FILESDIR}/radeon.conf
	use video_cards_virtualbox && doins ${FILESDIR}/vboxvideo.conf
	use blacklist && doins ${FILESDIR}/blacklist.conf
}

pkg_postinst()
{
	echo
	elog "Installing this package will modify files in /etc/modprobe.d directory."
	elog "If config-protect-if-modified feature of portage is enabled, then run etc-update to apply changes."
	echo
}
