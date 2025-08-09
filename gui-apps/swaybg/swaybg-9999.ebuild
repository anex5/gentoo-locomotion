# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson toolchain-funcs

DESCRIPTION="A wallpaper utility for Wayland"
HOMEPAGE="https://github.com/swaywm/swaybg"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/swaywm/${PN}.git"
else
	SRC_URI="https://github.com/swaywm/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64 ~arm ~loong ~ppc64 ~riscv ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="gdk-pixbuf man"

DEPEND="
	dev-libs/wayland
	>=dev-libs/wayland-protocols-1.14
	x11-libs/cairo
	gdk-pixbuf? ( x11-libs/gdk-pixbuf )
"
RDEPEND="
	${DEPEND}
	!<gui-wm/sway-1.1_alpha1
"
BDEPEND="
	dev-util/wayland-scanner
	virtual/pkgconfig
	man? ( app-text/scdoc )
"

src_prepare() {
	default

	tc-is-cross-compiler && ( sed "/find_program(wayland_scanner/s@native\: true@native\: false@" -i meson.build || die "Sed failed..." )
}

src_configure() {
	local emesonargs=(
		-Dman-pages=$(usex man enabled disabled)
		-Dgdk-pixbuf=$(usex gdk-pixbuf enabled disabled)
	)

	meson_src_configure
}
