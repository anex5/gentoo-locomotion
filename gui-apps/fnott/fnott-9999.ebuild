# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson xdg systemd toolchain-funcs

DESCRIPTION="Keyboard driven and lightweight Wayland notification daemon."
HOMEPAGE="https://codeberg.org/dnkl/fnott"

if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://codeberg.org/dnkl/fnott.git"
else
	SRC_URI="https://codeberg.org/dnkl/fnott/archive/${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
fi

IUSE="man +completions systemd test"
LICENSE="MIT ZLIB"
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
	x11-libs/pixman
	media-libs/libpng
	sys-apps/dbus
	media-libs/freetype
	>=media-libs/nanosvg-20241219
"
RDEPEND="${DEPEND}"
BDEPEND="
	man? ( app-text/scdoc )
	>=dev-libs/tllist-1.1.0
	>=dev-libs/wayland-protocols-1.32
	dev-util/wayland-scanner
"

src_prepare() {
	default
	sed -e "s/^\(Icon=\).*$/\1preferences-system-notifications-symbolic/" -i "${PN}.desktop"
	echo -e "Name[ru_RU]=Уведомления" >> "${PN}.desktop"
	echo -e "GenericName[ru_RU]=Служба уведомлений" >> "${PN}.desktop"
	tc-is-cross-compiler && ( sed -e "/wscanner\./s@native\: true@native\: false@" -i meson.build || die "Sed failed..." )
	use systemd || ( sed -e "/subdir('systemd')/d" -i meson.build || die "Sed failed..." )
	use man || ( sed -e "/subdir('doc')/d" -i meson.build || die "Sed failed..." )
	use completions || ( sed -e "/subdir('completions')/d" -i meson.build || die "Sed failed..." )
}

src_configure() {
	local emesonargs=(
		$(meson_feature man docs)
		-Dsystem-nanosvg=enabled
	)
	meson_src_configure

	use systemd && ( sed 's|@bindir@|/usr/bin|g' "${S}"/dbus/${PN}.service.in > ${PN}.service || die )
}

src_install() {
	local DOCS=( CHANGELOG.md README.md LICENSE )
	meson_src_install

	if use systemd; then
		systemd_douserunit ${PN}.service
	else
		exeinto /etc/user/init.d
		newexe "${FILESDIR}"/${PN}.user.initd ${PN}
	fi
}
