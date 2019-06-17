# Copyright 2019 The Gentoo Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
EAPI="6"

EGIT_REPO_URI="https://chromium.googlesource.com/chromiumos/platform/minigbm"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-r3"
fi

inherit flag-o-matic multilib-minimal toolchain-funcs ${GIT_ECLASS}

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
"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	video_cards_amdgpu? (
		media-libs/mesa:=[${MULTILIB_USEDEP}]
		x11-drivers/opengles-headers
	)"

EGIT_CHECKOUT_DIR=${S}

src_unpack() {
	default
	[[ $PV = 9999* ]] && git-r3_src_unpack
}

src_prepare() {
	default
}

multilib_src_configure() {
	export LIBDIR="/usr/$(get_libdir)"
	export PKG_CONFIG="/usr/bin/pkg-config"
	use video_cards_amdgpu && append-cppflags $(test-flags-CXX -DDRV_AMDGPU) && export DRV_AMDGPU=1
	use video_cards_exynos && append-cppflags $(test-flags-CXX -DDRV_EXYNOS) && export DRV_EXYNOS=1
	use video_cards_intel && append-cppflags $(test-flags-CXX -DDRV_I915) && export DRV_I915=1
	use video_cards_marvell && append-cppflags $(test-flags-CXX -DDRV_MARVELL) && export DRV_MARVELL=1
	if [[ ${MTK_MINIGBM_PLATFORM} == "MT8183" ]] ; then
		append-cppflags $(test-flags-CXX -DMTK_MT8183) && export MTK_MT8183=1
	fi
	use video_cards_mediatek && append-cppflags $(test-flags-CXX -DDRV_MEDIATEK) && export DRV_MEDIATEK=1
	use video_cards_msm && append-cppflags $(test-flags-CXX -DDRV_MSM) && export DRV_MSM=1
	use video_cards_radeon && append-cppflags $(test-flags-CXX -DDRV_RADEON) && export DRV_RADEON=1
	use video_cards_radeonsi && append-cppflags $(test-flags-CXX -DDRV_RADEON) && export DRV_RADEON=1
	use video_cards_rockchip && append-cppflags $(test-flags-CXX -DDRV_ROCKCHIP) && export DRV_ROCKCHIP=1
	use video_cards_tegra && append-cppflags $(test-flags-CXX -DDRV_TEGRA) && export DRV_TEGRA=1
	use video_cards_vc4 && append-cppflags $(test-flags-CXX -DDRV_VC4) && export DRV_VC4=1
	use video_cards_virgl && append-cppflags $(test-flags-CXX -DDRV_VIRGL) && export DRV_VIRGL=1
	default
}

src_prepare() {
	default
}

multilib_src_install() {
	insinto "${EPREFIX}/lib/udev/rules.d"
	doins "${FILESDIR}/50-vgem.rules"
	dosym libminigbm.so.1.0.0 "${LIBDIR}/libminigbm.so"
	default
}
