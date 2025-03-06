# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson xdg systemd toolchain-funcs

DESCRIPTION="Fast, lightweight and minimalistic Wayland terminal emulator"
HOMEPAGE="https://codeberg.org/dnkl/foot"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://codeberg.org/dnkl/foot.git"
	KEYWORDS="-*"
else
	SRC_URI="https://codeberg.org/dnkl/foot/archive/${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}"/${PN}-${MY_PV}
	KEYWORDS="~amd64 ~arm64 ~arm ~x86"
fi
S="${WORKDIR}/${PN}"

LICENSE="MIT"
SLOT="0"
IUSE="+grapheme-clustering ime man systemd test themes"
RESTRICT="
	!test? ( test )
	mirror
"

COMMON_DEPEND="
	dev-libs/wayland
	media-libs/fcft
	media-libs/fontconfig
	x11-libs/libxkbcommon
	x11-libs/pixman
	systemd? ( sys-apps/systemd:= )
	grapheme-clustering? (
		dev-libs/libutf8proc:=
		media-libs/fcft[harfbuzz]
	)
"
DEPEND="
	${COMMON_DEPEND}
	>=dev-libs/tllist-1.1.0
	>=dev-libs/wayland-protocols-1.32
"
RDEPEND="
	${COMMON_DEPEND}
	|| (
		>=sys-libs/ncurses-6.3[-minimal]
		~gui-apps/foot-terminfo-${PV}
	)
"
BDEPEND="
	man? ( app-text/scdoc )
	dev-util/wayland-scanner
"

src_prepare() {
	default
	# disable the systemd dep, we install the unit file manually
	sed -i "s/systemd', required: false)$/', required: false)/" "${S}"/meson.build || die
	tc-is-cross-compiler && ( sed "/find_program(wayland_scanner/s@native\: true@native\: false@" -i meson.build || die "Sed failed..." )
}

src_configure() {
	local emesonargs=(
		$(meson_feature man docs)
		$(meson_feature grapheme-clustering)
		$(meson_use test tests)
		$(meson_use themes)
		$(meson_use ime)
		-Dterminfo=disabled
	)
	meson_src_configure

	sed 's|@bindir@|/usr/bin|g' "${S}"/foot-server.service.in > foot-server.service || die
}

src_install() {
	local DOCS=( CHANGELOG.md README.md LICENSE )
	meson_src_install

	use systemd && systemd_douserunit foot-server.service "${S}"/foot-server.socket
}
