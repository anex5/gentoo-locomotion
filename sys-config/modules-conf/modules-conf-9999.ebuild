# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="A configuration files for kernel modules"
HOMEPAGE="https://github.com/anex5"
KEYWORDS="amd64 x86"

SRC_URI=""

LICENSE="GPL-2+"
SLOT="0"
IUSE="video_cards_i915 video_cards_nouveau video_cards_amdgpu video_cards_radeon video_cards_vboxvideo alsa vfio kvm zswap bbswitch blacklist"

pkg_preinst() {
	insinto /etc/modprobe.d
	usex alsa && doins ${FILESDIR}/alsa-base.conf || die
	usex kvm && doins ${FILESDIR}/kvm.conf || die
	usex vfio && doins ${FILESDIR}/vfio.conf || die
	usex zswap && doins ${FILESDIR}/zswap.conf || die
	usex bbswitch && doins ${FILESDIR}/bbswitch.conf || die
	usex video_cards_i915 && doins ${FILESDIR}/i915.conf || die
	usex video_cards_nouveau && doins ${FILESDIR}/nouveau.conf || die
	usex video_cards_amdgpu && doins ${FILESDIR}/amdgpu.conf || die
	usex video_cards_radeon && doins ${FILESDIR}/radeon.conf || die
	usex video_cards_vboxvideo && doins ${FILESDIR}/vboxvideo.conf || die
	usex blacklist && doins ${FILESDIR}/blacklist.conf || die
}

pkg_postinst()
{
	echo
	elog "Installing this package will modify your config files in /etc/modprobe.d directory."
	elog "In order to complete the installation, run etc-update and apply changes."
	echo
}
