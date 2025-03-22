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

IUSE="man zsh-completion systemd test"
RESTRICT="
	!test? ( test )
	mirror
"
LICENSE="MIT ZLIB"
SLOT="0"

DEPEND="
	x11-libs/pixman
	media-libs/libpng
	dev-libs/wayland
	sys-apps/dbus
	media-libs/fcft
	media-libs/freetype
	media-libs/fontconfig
"
RDEPEND="${DEPEND}
"
BDEPEND="
	dev-util/wayland-scanner
	dev-libs/wayland-protocols
	man? ( app-text/scdoc )
	dev-libs/tllist
"

src_prepare() {
	default
	sed -e "s/^\(Icon=\).*$/\1preferences-system-notifications-symbolic/" -i "${PN}.desktop"
	echo -e "Name[ru_RU]=Уведомления" >> "${PN}.desktop"
	echo -e "GenericName[ru_RU]=Служба уведомлений" >> "${PN}.desktop"
	tc-is-cross-compiler && ( sed -e "/wscanner\./s@native\: true@native\: false@" -i meson.build || die "Sed failed..." )
	use systemd || ( sed -e "/subdir('systemd')/d" -i meson.build || die "Sed failed..." )
	use man || ( sed -e "/subdir('doc')/d" -i meson.build || die "Sed failed..." )
	use zsh-completion || ( sed -e "/subdir('completions')/d" -i meson.build || die "Sed failed..." )
}

src_configure() {
	local emesonargs=(
		$(meson_feature man docs)
		-Dsystem-nanosvg=disabled
	)
	meson_src_configure

	use systemd && ( sed 's|@bindir@|/usr/bin|g' "${S}"/dbus/${PN}.service.in > ${PN}.service || die )
}


src_install() {
	local DOCS=( CHANGELOG.md README.md LICENSE )
	meson_src_install

	use systemd && systemd_douserunit ${PN}.service
}
