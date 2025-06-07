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
	S="${WORKDIR}/${PN}"
	KEYWORDS="~amd64 ~arm64 ~arm ~x86"
fi

IUSE="+grapheme-clustering +completions ime man systemd test themes"
LICENSE="MIT"
SLOT="0"
RESTRICT="
	!test? ( test )
	mirror
"

DEPEND="
	dev-libs/wayland
	<media-libs/fcft-4.0.0
	>=media-libs/fcft-3.0.0
	media-libs/fontconfig
	x11-libs/libxkbcommon
	x11-libs/pixman
	systemd? ( sys-apps/systemd:= )
	grapheme-clustering? (
		dev-libs/libutf8proc:=
		media-libs/fcft[harfbuzz]
	)
"
RDEPEND="${DEPEND}
	|| (
		>=sys-libs/ncurses-6.3[-minimal]
		~gui-apps/foot-terminfo-${PV}
	)
"
BDEPEND="
	man? ( app-text/scdoc )
	>=dev-libs/tllist-1.1.0
	>=dev-libs/wayland-protocols-1.32
	dev-util/wayland-scanner
"

src_prepare() {
	default
	echo -e "Name[ru_RU]=Фут" >> "${PN}.desktop"
	echo -e "GenericName[ru_RU]=Терминал" >> "${PN}.desktop"
	echo -e "Name[ru_RU]=Фут Клиент" >> "${PN}client.desktop"
	echo -e "GenericName[ru_RU]=Терминал" >> "${PN}client.desktop"
	echo -e "Name[ru_RU]=Фут Сервер" >> "${PN}-server.desktop"
	echo -e "GenericName[ru_RU]=Терминал" >> "${PN}-server.desktop"
	# disable the systemd dep, we install the unit file manually
	#sed -i "s/systemd', required: false)$/', required: false)/" "${S}"/meson.build || die
	use completions || ( sed -e "/subdir('completions')/d" -i meson.build || die "Sed failed..." )
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

	use systemd && ( sed 's|@bindir@|/usr/bin|g' "${S}"/foot-server.service.in > foot-server.service || die )
}

src_install() {
	local DOCS=( CHANGELOG.md README.md LICENSE )
	meson_src_install

	if use systemd; then
		systemd_douserunit foot-server.service "${S}"/foot-server.socket
	else
		exeinto /etc/user/init.d
		newexe "${FILESDIR}"/footserver.user.initd footserver
	fi
}
