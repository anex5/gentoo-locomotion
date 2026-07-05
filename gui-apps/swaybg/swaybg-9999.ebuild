# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson toolchain-funcs

DESCRIPTION="A wallpaper utility for Wayland"
HOMEPAGE="https://github.com/swaywm/swaybg"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/swaywm/${PN}.git"
else
	inherit verify-sig
	SRC_URI="https://github.com/swaywm/${PN}/releases/download/v${PV}/${P}.tar.gz
		https://github.com/swaywm/${PN}/releases/download/v${PV}/${P}.tar.gz.sig"

	KEYWORDS="amd64 ~arm64 ~arm ~loong ~ppc64 ~riscv x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="gdk-pixbuf man"

RDEPEND="
	dev-libs/wayland
	x11-libs/cairo
	gdk-pixbuf? ( x11-libs/gdk-pixbuf:2 )
"
DEPEND="${RDEPEND}
	!<gui-wm/sway-1.1_alpha1
	>=dev-libs/wayland-protocols-1.31
"
BDEPEND="
	dev-util/wayland-scanner
	virtual/pkgconfig
	man? ( app-text/scdoc )
"

if [[ ${PV} != 9999 ]]; then
	BDEPEND+=" verify-sig? ( sec-keys/openpgp-keys-emersion )"
	VERIFY_SIG_OPENPGP_KEY_PATH="/usr/share/openpgp-keys/emersion.asc"
fi

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
