# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit fcaps flag-o-matic meson optfeature systemd

DESCRIPTION="SwayFX: Sway, but with eye candy!"
HOMEPAGE="https://github.com/WillPower3309/swayfx"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/WillPower3309/swayfx"
	SCENEFX_PV=9999
else
	MY_PV=${PV/_*/}
	COMMIT="a131cfb71665de7bad26030c2c02ef6279300551"
	SRC_URI="https://github.com/WillPower3309/swayfx/archive/${COMMIT}.tar.gz -> ${P}.gh.tar.gz"
	#	https://github.com/WillPower3309/swayfx/archive/${MY_PV}.tar.gz.sig -> ${P}.gh.tar.gz.sig"
	KEYWORDS="amd64 arm64 ~arm ~loong ~ppc64 ~riscv ~x86"
	S="${WORKDIR}/${PN}-${COMMIT}"
	SCENEFX_PV=0.4.1
fi

LICENSE="MIT"
SLOT="0"
IUSE="bash-completion fish-completion grimshot +man +swaybar +swaynag systemd tray wallpapers x11-backend zsh-completion"
REQUIRED_USE="tray? ( swaybar )"

DEPEND="
	>=dev-libs/json-c-0.13:0=
	>=dev-libs/libinput-1.26.0:0=
	virtual/libudev
	sys-auth/seatd:=
	dev-libs/libpcre2
	>=dev-libs/wayland-1.21.0
	>=gui-libs/scenefx-${SCENEFX_PV}
	x11-libs/cairo
	>=x11-libs/libxkbcommon-1.5.0:0=
	x11-libs/pango
	x11-libs/pixman
	media-libs/mesa[libglvnd(+)]
	swaybar? ( x11-libs/gdk-pixbuf:2 )
	tray? ( || (
		sys-apps/systemd
		sys-auth/elogind
		sys-libs/basu
	) )
	wallpapers? ( gui-apps/swaybg[gdk-pixbuf(+)] )
	x11-backend? (
		x11-libs/libxcb:0=
		x11-libs/xcb-util-wm
	)
"
RDEPEND="
	${DEPEND}
	x11-misc/xkeyboard-config
	grimshot? (
		app-misc/jq
		gui-apps/grim
		gui-apps/slurp
		gui-apps/wl-clipboard
		x11-libs/libnotify
	)
	!!gui-wm/sway
"
BDEPEND="
	man? ( >=app-text/scdoc-1.9.3 )
	>=dev-libs/wayland-protocols-1.41
	>=dev-build/meson-1.3
	virtual/pkgconfig
"

FILECAPS=(
	cap_sys_nice usr/bin/sway # bug 919298
)

RESTRICT="mirror"

src_prepare() {
	default
	#use x11-backend || ( eapply "${FILESDIR}/swayfx-9999-disable-xwayland.patch" || die )
}

src_configure() {
	! use elibc_glibc && append-cppflags "-D__always_inline=__attribute__((always_inline))"
	local emesonargs=(
		$(meson_feature man man-pages)
		$(meson_feature tray)
		#$(meson_feature x11-backend xwayland)
		$(meson_feature swaybar gdk-pixbuf)
		$(meson_use swaynag)
		$(meson_use swaybar)
		$(meson_use wallpapers default-wallpaper)
		$(meson_use zsh-completion zsh-completions)
		$(meson_use bash-completion bash-completions)
		$(meson_use fish-completion fish-completions)
	)

	meson_src_configure
}

src_install() {
	meson_src_install
	insinto /usr/share/xdg-desktop-portal
	doins "${FILESDIR}/sway-portals.conf"

	if use grimshot; then
		use man && doman contrib/grimshot.1
		dobin contrib/grimshot
	fi

	if use systemd; then
		systemd_douserunit "${FILESDIR}/sway-session."{target,service}
	fi
}

pkg_postinst() {
	fcaps_pkg_postinst

	optfeature_header "There are several packages that may be useful with swayfx:"
	optfeature "wallpaper utility" gui-apps/swaybg
	optfeature "idle management utility" gui-apps/swayidle
	optfeature "simple screen locker" gui-apps/swaylock
	optfeature "lightweight notification daemon" gui-apps/mako
	echo
	einfo "For a list of additional addons and tools usable with sway please"
	einfo "visit the official wiki at:"
	einfo "https://github.com/swaywm/sway/wiki/Useful-add-ons-for-sway"
	einfo "Please note that some of them might not (yet) available on gentoo"
}
