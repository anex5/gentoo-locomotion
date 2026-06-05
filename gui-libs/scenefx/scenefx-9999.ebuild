# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU Public License v2

EAPI=8

inherit meson flag-o-matic

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/wlrfx/scenefx"
else
	#MY_PV=${PV/_rc/-rc}
	COMMIT="ad987a32b9fe0e640fe1abf4092737699dec5a0f"
	SRC_URI="https://github.com/wlrfx/scenefx/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.gh.tar.gz"
	S="${WORKDIR}/${PN}-${COMMIT}"
	KEYWORDS="~amd64 ~arm64 ~arm ~loong ~ppc64 ~riscv ~x86"
fi

DESCRIPTION="A replacement for the wlroots scene API with eye-candy effects."
HOMEPAGE="https://github.com/wlrfx/scenefx"
LICENSE="MIT"
SLOT="0"
IUSE="X man examples"

DEPEND="
	>=dev-libs/wayland-1.23.1
	>=x11-libs/libdrm-2.4.122
	media-libs/mesa[egl(+),gles2(+)]
	>=x11-libs/pixman-0.43.0
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
RDEPEND="
	${DEPEND}
"
BDEPEND="
	app-alternatives/ninja
	>=dev-libs/wayland-protocols-1.35
	>=dev-build/meson-1.3
	dev-util/glslang
	dev-util/wayland-scanner
	virtual/pkgconfig
	virtual/libc
"
BDEPEND+="man? ( >=app-text/scdoc-1.9.2 )"

RESTRICT="mirror"

#PATCHES=(
#	"${FILESDIR}/${PN}-0.2.1-corner-passing-logic.patch"
#)

src_configure() {
	! use elibc_glibc && append-cppflags "-D__always_inline=__attribute__((always_inline))"
	local emesonargs=(
		-Drenderers=auto
		$(meson_use examples)
	)

	meson_src_configure
}
