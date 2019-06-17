# Copyright 2019 The Gentoo Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
EAPI="6"

EGIT_REPO_URI="https://chromium.googlesource.com/chromiumos/platform/minigbm"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-r3"
fi

inherit flag-o-matic toolchain-funcs ${GIT_ECLASS}

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
		media-libs/mesa
		x11-drivers/opengles-headers
	)"

EGIT_CHECKOUT_DIR=${S}

src_prepare() {
	default
}

multilib_src_configure() {
	local emesonargs=(
		-DDRV_AMDGPU=$(usex video_cards_amdgpu true false)
		-DDRV_EXYNOS=$(usex video_cards_exynos true false)
		-DDRV_I915=$(usex video_cards_intel true false)
		-DDRV_MARVELL=$(usex video_cards_marvell true false)
		-DDRV_MEDIATEK=$(usex video_cards_mediatek auto false)
		-DDRV_MSM=$(usex video_cards_msm auto false)
		-DDRV_RADEON=$(usex video_cards_radeon true false)
		-DDRV_RADEON=$(usex video_cards_radeonsi true false)
		-DDRV_ROCKCHIP=$(usex video_cards_rockchip true false)
		-DDRV_TEGRA=$(usex video_cards_tegra true false)
		-DDRV_VC4=$(usex video_cards_vc4 true false)
		-DDRV_VIRGL=$(usex video_cards_virgl auto false)
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_test() {
	meson_src_test
}

multilib_src_install() {
	insinto "${EPREFIX}/lib/udev/rules.d"
	doins "${FILESDIR}/50-vgem.rules"
	dosym libminigbm.so.1.0.0 "${LIBDIR}/libminigbm.so"
	meson_src_install
}