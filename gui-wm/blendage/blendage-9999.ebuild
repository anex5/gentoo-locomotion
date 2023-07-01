# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 flag-o-matic toolchain-funcs

DESCRIPTION="dwl-compatible Wayland window manager"
HOMEPAGE="https://github.com/pmozil/blendage"

EGIT_REPO_URI="https://github.com/pmozil/${PN}.git"

LICENSE="CC0-1.0 GPL-3 MIT"
SLOT="0"
IUSE="X"

RDEPEND="
	dev-libs/libinput:=
	dev-libs/wayland
	=gui-libs/wlroots-9999[X(-)?]
	x11-libs/libxkbcommon
	X? (
		x11-libs/libxcb:=
		x11-libs/xcb-util-wm
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-libs/wayland-protocols
	dev-util/wayland-scanner
	virtual/pkgconfig
"

src_configure() {
	sed -i "s:/local::g" config.mk || die

	sed -i "s:pkg-config:$(tc-getPKG_CONFIG):g" config.mk || die

	if use X; then
		append-cppflags '-DXWAYLAND'
		append-libs '-lxcb' '-lxcb-icccm'
	fi
}

src_install() {
	default

	insinto /usr/share/wayland-sessions
	doins "${FILESDIR}"/${PN}.desktop
}
