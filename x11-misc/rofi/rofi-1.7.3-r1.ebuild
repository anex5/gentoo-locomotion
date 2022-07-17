# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson toolchain-funcs

MY_PV="${PV}+wayland1"

DESCRIPTION="A window switcher, run dialog and dmenu replacement (fork with Wayland support)"
HOMEPAGE="https://github.com/lbonn/rofi"
SRC_URI="https://github.com/lbonn/rofi/releases/download/${MY_PV}/${PN}-${MY_PV}.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 x86"
IUSE="X wayland +drun test +windowmode man"
RESTRICT="!test? ( test )"

BDEPEND="
	dev-util/meson
	virtual/pkgconfig
	wayland? ( >=dev-libs/wayland-protocols-1.17 )
"
RDEPEND="
	dev-libs/glib:2
	x11-libs/cairo[X?,svg,xcb(+)]
	x11-libs/gdk-pixbuf:2
	X? (
		x11-libs/libxcb:=
		x11-libs/startup-notification
		x11-libs/xcb-util
		x11-libs/xcb-util-cursor
		x11-libs/xcb-util-wm
		x11-misc/xkeyboard-config
	)
	x11-libs/libxkbcommon[X?]
	x11-libs/pango[X?]
	wayland? (
		>=dev-libs/wayland-protocols-1.17
		>=dev-libs/wayland-1.17.0

	)
"
DEPEND="
	${RDEPEND}
	X? ( x11-base/xorg-proto )
	test? ( >=dev-libs/check-0.11 )
"
RESTRICT="mirror"

S=${WORKDIR}/${PN}-${MY_PV}

src_prepare() {
	use man || sed -i -e "/subdir('doc')/d" -e '/install_man(/{:1;/)/!{N;b1};d}' meson.build || die
	default
}

src_configure() {
	local emesonargs=(
		$(meson_use drun)
		$(meson_use windowmode window)
		$(meson_feature X xcb)
		$(meson_feature wayland)
		$(meson_feature test check)
	)

	meson_src_configure
}

src_install() {
	meson_src_install
	use man && doman doc/*
}
