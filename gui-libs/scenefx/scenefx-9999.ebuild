# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU Public License v2

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
IUSE="X man examples"

DEPEND="
	>=dev-libs/wayland-1.23.0
	>=x11-libs/libdrm-2.4.122
	media-libs/mesa[egl(+),gles2(+)]
	>=x11-libs/pixman-0.42.0
	media-libs/libglvnd
	x11-libs/libxkbcommon
	X? (
		x11-libs/libxcb:=
		x11-libs/xcb-util-wm
		x11-base/xwayland
	)
"
# Check this on every update
DEPEND+="
	>=gui-libs/wlroots-0.19:=[X?]
	<gui-libs/wlroots-0.20:=[X?]
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-libs/wayland-protocols-1.35
	>=dev-build/meson-0.59.0
	dev-util/glslang
	app-alternatives/ninja
	virtual/pkgconfig
	virtual/libc
"
BDEPEND+="man? ( >=app-text/scdoc-1.9.2 )"

RESTRICT="mirror"

#PATCHES=(
#	"${FILESDIR}/${PN}-0.2.1-corner-passing-logic.patch"
#)

src_configure() {
	local emesonargs=(
		-Drenderers=auto
		$(meson_use examples)
	)

	meson_src_configure
}
