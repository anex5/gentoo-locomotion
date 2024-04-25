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
fi
KEYWORDS="~amd64 ~arm64 ~arm ~loong ~ppc64 ~riscv ~x86"

DESCRIPTION="A drop-in replacement for the wlroots scene API that allows wayland compositors to render surfaces with eye-candy effects"
HOMEPAGE="https://github.com/wlrfx/scenefx"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
IUSE="+drm +gbm +gles2 examples +libinput vulkan x11-backend xcb-errors xwayland"
REQUIRED_USE="
	|| ( gles2 vulkan )
	xcb-errors? ( || ( x11-backend xwayland ) )
"

DEPEND="
    >=dev-libs/wayland-1.22
    >=gui-libs/wlroots-0.17.0
    <gui-libs/wlroots-0.18.0
    >=x11-libs/libdrm-2.4.114
    x11-libs/libxkbcommon
    >=x11-libs/pixman-0.42.0
	drm? (
		media-libs/libdisplay-info
		sys-apps/hwdata
		>=dev-libs/libliftoff-0.4
	)
	vulkan? (
		media-libs/vulkan-loader
		dev-util/glslang:=
	)
	libinput? ( dev-libs/libinput:= )
	xcb-errors? ( x11-libs/xcb-util-errors )
	x11-backend? (
		x11-libs/libxcb:=
		x11-libs/xcb-util-renderutil
	)
	xwayland? (
		x11-libs/libxcb:=
		x11-libs/xcb-util-wm
		x11-base/xwayland
	)
"
RDEPEND="${DEPEND}"
BDEPEND="
    dev-build/meson
    dev-build/ninja
    vulkan? ( >=dev-util/vulkan-headers-1.3.255 )
"

RESTRICT="mirror"

src_configure() {
	local backends=""
	use x11-backend && backends+="x11"
	use drm && backends+=",drm"
	use libinput && backends+=",libinput"

	local renderers=""
	use gles2 && renderers+="gles2"
	use vulkan && renderers+=",vulkan"

	local emesonargs=(
		#$(meson_feature man man-pages)
		$(meson_feature xcb-errors)
		$(meson_feature xwayland)
		$(meson_use examples)
		-Dbackends="${backends#,}"
		-Drenderers="${renderers#,}"
		-Dallocators="$(usex gbm gbm auto)"
	)

	meson_src_configure
}
