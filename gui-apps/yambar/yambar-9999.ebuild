# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://codeberg.org/dnkl/${PN}.git"
	EGIT_SUBMODULES=()
else
	COMMIT="abeffbd9a9fd0b2133343e1149e65d4a795a43d0"
	SRC_URI="https://codeberg.org/dnkl/${PN}/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT}.tar.gz"
	S="${WORKDIR}/${PN}"
	KEYWORDS="~amd64 ~arm64 ~arm ~x86"
fi

DESCRIPTION="Simplistic and highly configurable status panel for X and Wayland"
HOMEPAGE="https://codeberg.org/dnkl/yambar"
LICENSE="MIT"
SLOT="0"
IUSE="alsa backlight battery +clock +cpu debug +disk-io dwl +foreign-toplevel man +memory mpd mpris niri i3 +label +network pipewire pulseaudio removables river +script +shared-plugins sway-xkb wayland X xkb xwindow"
REQUIRED_USE="
	|| ( wayland X )
	sway-xkb? ( wayland )
	xkb? ( X )
	xwindow? ( X )
"

RDEPEND="
	>=media-libs/fcft-2.4.0
	dev-libs/libyaml
	alsa? ( media-libs/alsa-lib )
	backlight? ( virtual/libudev:= )
	battery? ( virtual/libudev:= )
	dwl? ( gui-wm/dwl )
	mpris? (
		sys-apps/dbus
		media-sound/mpd
	)
	mpd? (
		media-libs/libmpdclient
		media-sound/mpd
	)
	niri? ( gui-wm/niri )
	pipewire? (
		dev-libs/json-c
		media-video/pipewire
	)
	pulseaudio? ( media-libs/libpulse )
	removables? ( virtual/libudev:= )
	sway-xkb? (
		|| ( gui-wm/sway gui-wm/swayfx )
		dev-libs/json-c
	)
	x11-libs/pixman
	X? (
		x11-libs/libxcb:0=[xkb]
		x11-libs/xcb-util
		x11-libs/xcb-util-cursor
		x11-libs/xcb-util-wm
	)
	wayland? ( dev-libs/wayland )
"
DEPEND="${RDEPEND}"
BDEPEND="
	man? ( app-text/scdoc )
	>=dev-libs/tllist-1.0.1
	>=dev-build/meson-1.1.0
	virtual/pkgconfig
	wayland? (
		dev-libs/wayland-protocols
		dev-util/wayland-scanner
	)
"

RESTRICT="mirror test"

PATCHES=(
	"${FILESDIR}/yambar-9999-module-mem-float.patch"
	"${FILESDIR}/yambar-9999-autohide-wayland.patch"
)

src_prepare() {
	default
	#sed -e "s/^\(Icon=\).*$/\1preferences-system-notifications-symbolic/" -i "${PN}.desktop"
	echo -e "Name[ru_RU]=Ямбар" >> "${PN}.desktop"
	echo -e "GenericName[ru_RU]=Панель" >> "${PN}.desktop"
	tc-is-cross-compiler && ( sed "/find_program(wayland_scanner/s@native\: true@native\: false@" -i meson.build || die "Sed failed..." )
	use man || $( sed -i "/subdir('doc')/d" meson.build || die "Sed failed..." )
	if [[ ${PV} == *9999* ]]; then
		"${FILESDIR}/yambar-9999-mpris-build-fix.patch"
	fi
}

src_configure() {
	use debug && EMESON_BUILDTYPE=debug || EMESON_BUILDTYPE=release
	local emesonargs=(
		$(meson_feature wayland backend-wayland)
		$(meson_feature X backend-x11)
		$(meson_use shared-plugins core-plugins-as-shared-libraries)
		$(meson_feature alsa plugin-alsa)
		$(meson_feature backlight plugin-backlight)
		$(meson_feature battery plugin-battery)
		$(meson_feature clock plugin-clock)
		$(meson_feature cpu plugin-cpu)
		$(meson_feature disk-io plugin-disk-io)
		$(meson_feature dwl plugin-dwl)
		$(meson_feature foreign-toplevel plugin-foreign-toplevel)
		$(meson_feature memory plugin-mem)
		$(meson_feature mpd plugin-mpd)
		$(meson_feature mpris plugin-mpris)
		$(meson_feature niri plugin-niri-workspaces)
		$(meson_feature niri plugin-niri-language)
		$(meson_feature i3 plugin-i3)
		$(meson_feature label plugin-label)
		$(meson_feature network plugin-network)
		$(meson_feature pipewire plugin-pipewire)
		$(meson_feature pulseaudio plugin-pulse)
		$(meson_feature removables plugin-removables)
		$(meson_feature river plugin-river)
		$(meson_feature script plugin-script)
		$(meson_feature sway-xkb plugin-sway-xkb)
		$(meson_feature xkb plugin-xkb)
		$(meson_feature xwindow plugin-xwindow)
		-Dwerror=false
		-Db_ndebug=$(usex debug false true)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	if use shared-plugins; then
		echo "LDPATH=${EPREFIX}/usr/$(get_libdir)/${PN}/" > 99yambar || die
		doenvd 99yambar
	fi
	rm -rf "${D}/usr/share/doc/${PN}" || die
}

pkg_postinst() {
	ewarn "Warning: if you are upgrading from 1.8.0, please note that there are breaking changes that might affect your config.yml file."
	ewarn "See the changelog for more information"
	ewarn "https://codeberg.org/dnkl/yambar/releases/tag/1.9.0"
}
