# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson systemd verify-sig toolchain-funcs xdg

DESCRIPTION="Fast, lightweight and minimalistic Wayland terminal emulator"
HOMEPAGE="https://codeberg.org/dnkl/foot"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://codeberg.org/dnkl/foot.git"
	KEYWORDS="-*"
else
	SRC_URI="https://codeberg.org/dnkl/foot/releases/download/${PV}/${P}.tar.gz
	verify-sig? ( https://codeberg.org/dnkl/foot/releases/download/${PV}/${P}.tar.gz.sig )"
	KEYWORDS="~amd64 ~arm64 ~arm ~x86"
fi

IUSE="+grapheme-clustering +completions ime man systemd test themes utempter verify-sig"
LICENSE="MIT"
SLOT="0"
RESTRICT="
	!test? ( test )
	mirror
"

COMMON_DEPEND="
	dev-libs/wayland
	<media-libs/fcft-4.0.0
	>=media-libs/fcft-3.3.1
	media-libs/fontconfig
	x11-libs/libxkbcommon
	x11-libs/pixman
	systemd? ( sys-apps/systemd:= )
	grapheme-clustering? (
		dev-libs/libutf8proc:=[-cjk]
		media-libs/fcft[harfbuzz]
	)
"
DEPEND="
	${COMMON_DEPEND}
	>=dev-libs/tllist-1.1.0
	>=dev-libs/wayland-protocols-1.41
"
RDEPEND="
	${COMMON_DEPEND}
	|| (
		~gui-apps/foot-terminfo-${PV}
		>=sys-libs/ncurses-6.3[-minimal]
	)
	utempter? ( sys-libs/libutempter )
"
BDEPEND="
	man? ( app-text/scdoc )
	dev-util/wayland-scanner
	verify-sig? ( sec-keys/openpgp-keys-dnkl )
"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/dnkl.asc

src_prepare() {
	default
	echo -e "Name[ru_RU]=Фут" >> "${PN}.desktop"
	echo -e "GenericName[ru_RU]=Терминал" >> "${PN}.desktop"
	echo -e "Name[ru_RU]=Фут Клиент" >> "${PN}client.desktop"
	echo -e "GenericName[ru_RU]=Терминал" >> "${PN}client.desktop"
	echo -e "Name[ru_RU]=Фут Сервер" >> "${PN}-server.desktop"
	echo -e "GenericName[ru_RU]=Терминал" >> "${PN}-server.desktop"
	# disable the systemd dep, we install the unit file manually
	sed -i "s/systemd', required: false)$/', required: false)/" meson.build || die

	# adjust install dir
	sed -i "s/'doc', 'foot'/'doc', '${PF}'/" meson.build || die

	# do not install LICENSE file
	sed -i "s/'LICENSE', //" meson.build || die
	use completions || ( sed -e "/subdir('completions')/d" -i meson.build || die "Sed failed..." )
	tc-is-cross-compiler && ( sed "/find_program(wayland_scanner/s@native\: true@native\: false@" -i meson.build || die "Sed failed..." )
}

src_configure() {
	local emesonargs=(
		-Dterminfo=disabled
		$(meson_feature man docs)
		$(meson_feature grapheme-clustering)
		$(meson_use test tests)
		$(meson_use themes)
		$(meson_use ime)
		-Dutmp-backend=$(usex utempter libutempter none)
		-Dutmp-default-helper-path="/usr/$(get_libdir)/misc/utempter/utempter"
	)
	meson_src_configure

	use systemd && ( sed 's|@bindir@|/usr/bin|g' "${S}"/foot-server.service.in > foot-server.service || die )
}

src_install() {
	meson_src_install

	if use systemd; then
		systemd_douserunit foot-server.service "${S}"/foot-server.socket
	else
		exeinto /etc/user/init.d
		newexe "${FILESDIR}"/footserver.user.initd footserver
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
}
