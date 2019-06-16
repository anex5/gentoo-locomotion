# Copyright 2019 The Gentoo Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
EAPI="6"

EGIT_REPO_URI="https://chromium.googlesource.com/chromiumos/platform/minigbm"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-r3"
fi

inherit multilib toolchain-funcs ${GIT_ECLASS}

DESCRIPTION="Mini GBM implementation"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/minigbm"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"

VIDEO_CARDS="
	amdgpu exynos intel marvell mediatek msm
	radeon radeonsi rockchip tegra vc4 virgl
"

IUSE="-asan"

for card in ${VIDEO_CARDS}; do
	IUSE+=" video_cards_${card}"
done

RDEPEND="
	x11-libs/libdrm
	!media-libs/mesa[gbm]"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	video_cards_amdgpu? (
		media-libs/mesa
		x11-drivers/opengles-headers
	)"

EGIT_CHECKOUT_DIR=${S}

src_prepare() {
	default
}

src_configure() {
	export LIBDIR="/usr/$(get_libdir)"
	use video_cards_amdgpu && append-cppflags -DDRV_AMDGPU && export DRV_AMDGPU=1
	use video_cards_exynos && append-cppflags -DDRV_EXYNOS && export DRV_EXYNOS=1
	use video_cards_intel && append-cppflags -DDRV_I915 && export DRV_I915=1
	use video_cards_marvell && append-cppflags -DDRV_MARVELL && export DRV_MARVELL=1
	if [[ ${MTK_MINIGBM_PLATFORM} == "MT8183" ]] ; then
		append-cppflags -DMTK_MT8183 && export MTK_MT8183=1
	fi
	use video_cards_mediatek && append-cppflags -DDRV_MEDIATEK && export DRV_MEDIATEK=1
	use video_cards_msm && append-cppflags -DDRV_MSM && export DRV_MSM=1
	use video_cards_radeon && append-cppflags -DDRV_RADEON && export DRV_RADEON=1
	use video_cards_radeonsi && append-cppflags -DDRV_RADEON && export DRV_RADEON=1
	use video_cards_rockchip && append-cppflags -DDRV_ROCKCHIP && export DRV_ROCKCHIP=1
	use video_cards_tegra && append-cppflags -DDRV_TEGRA && export DRV_TEGRA=1
	use video_cards_vc4 && append-cppflags -DDRV_VC4 && export DRV_VC4=1
	use video_cards_virgl && append-cppflags -DDRV_VIRGL && export DRV_VIRGL=1
	default
}

src_install() {
	
	insinto "${EPREFIX}/etc/udev/rules.d"
	doins "${FILESDIR}/50-vgem.rules"
	default
	dosym $(get_libdir)/libminigbm.so.1.0.0" $(get_libdir)/libminigbm.so
}
