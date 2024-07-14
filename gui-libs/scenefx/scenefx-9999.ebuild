# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/wlrfx/scenefx"
else
	MY_PV=${PV/_rc/-rc}
	SRC_URI="https://github.com/wlrfx/scenefx/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${MY_PV}"
	KEYWORDS="~amd64 ~arm64 ~arm ~loong ~ppc64 ~riscv ~x86"
fi

DESCRIPTION="A replacement for the wlroots scene API with eye-candy effects."
HOMEPAGE="https://github.com/wlrfx/scenefx"
LICENSE="MIT"
SLOT="0"
IUSE="+drm +gbm examples +liftoff +libinput vulkan x11-backend xcb-errors X"
REQUIRED_USE="
	xcb-errors? ( || ( x11-backend  ) )
"

DEPEND="
	>=dev-libs/wayland-1.22.0
	>=x11-libs/libdrm-2.4.114
	media-libs/mesa[egl(+),gles2(+),vulkan?]
	>=x11-libs/pixman-0.42.0
	media-libs/libglvnd
	x11-libs/libxkbcommon
	drm? (
		media-libs/libdisplay-info
		sys-apps/hwdata
		liftoff? ( >=dev-libs/libliftoff-0.4 )
	)
	libinput? ( >=dev-libs/libinput-1.14.0:= )
	x11-backend? (
		x11-libs/libxcb:=
		x11-libs/xcb-util-renderutil
	)
	vulkan? (
		dev-util/glslang:=
		dev-util/vulkan-headers
		media-libs/vulkan-loader
	)
	xcb-errors? ( x11-libs/xcb-util-errors )
	X? (
		x11-libs/libxcb:=
		x11-libs/xcb-util-wm
		x11-base/xwayland
	)
"
# Check this on every update
DEPEND+="
	>=gui-libs/wlroots-0.17:=[X?,liftoff?,vulkan?,x11-backend?,xcb-errors?]
	<gui-libs/wlroots-0.18:=[X?,liftoff?,vulkan?,x11-backend?,xcb-errors?]
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-libs/wayland-protocols-1.24
	>=dev-build/meson-0.59.0
	virtual/pkgconfig
	dev-build/ninja
    vulkan? ( >=dev-util/vulkan-headers-1.3.255 )
"

RESTRICT="mirror"

src_configure() {
	local backends=(
		$(usev drm)
		$(usev libinput)
		$(usev x11-backend 'x11')
	)
	local meson_backends=$(IFS=','; echo "${backends[*]}")
	local emesonargs=(
		-Drenderers=$(usex vulkan 'gles2,vulkan' gles2)
		$(meson_feature X xwayland)
		$(meson_feature xcb-errors)
		$(meson_use examples)
		-Dbackends=${meson_backends}
		-Dallocators="$(usex gbm gbm auto)"
	)

	meson_src_configure
}
