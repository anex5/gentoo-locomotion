# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson systemd verify-sig xdg toolchain-funcs

DESCRIPTION="Keyboard driven and lightweight Wayland notification daemon"
HOMEPAGE="https://codeberg.org/dnkl/fnott"

if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://codeberg.org/dnkl/fnott.git"
else
	COMMIT="cd31aa61ac9080b00bd42b9afaf9d1741cfe4431"
	SRC_URI="
		https://codeberg.org/dnkl/fnott/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.cb.tar.gz
		verify-sig? ( https://codeberg.org/dnkl/fnott/releases/download/${PV//_p*/}/${PN}-${PV//_p*/}.tar.gz.sig )
	"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
	S="${WORKDIR}/${PN}"
fi

IUSE="man +completions systemd test"
LICENSE="MIT ZLIB"
SLOT="0"
RESTRICT="
	!test? ( test )
	mirror
"

RDEPEND="
	dev-libs/wayland
	<media-libs/fcft-4.0.0
	>=media-libs/fcft-3.0.0
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libpng:=
	>=media-libs/nanosvg-20241219
	sys-apps/dbus
	x11-libs/pixman
"
DEPEND="
	${RDEPEND}
	>=dev-libs/tllist-1.1.0
	>=dev-libs/wayland-protocols-1.32
"
BDEPEND="
	dev-util/wayland-scanner
	man? ( app-text/scdoc )
	verify-sig? ( sec-keys/openpgp-keys-dnkl )
"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/dnkl.asc

src_prepare() {
	default
	sed -e "s/^\(Icon=\).*$/\1preferences-system-notifications-symbolic/" -i "${PN}.desktop"
	echo -e "Name[ru_RU]=Уведомления" >> "${PN}.desktop"
	echo -e "GenericName=Notification service" >> "${PN}.desktop"
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
		# always install unit
		-Dsystemd-units-dir="$(systemd_get_userunitdir)"
	)
	meson_src_configure

	#sed 's|@bindir@|/usr/bin|g' "${S}"/dbus/${PN}.service.in > dbus/${PN}.service || die
	if use systemd; then
		sed 's|@bindir@|/usr/bin|g' "${S}"/systemd/${PN}.service.in > systemd/${PN}.service || die
	fi
}

src_install() {
	local DOCS=( CHANGELOG.md README.md )
	meson_src_install

	#rm -r "${ED}"/usr/share/doc/"${PN}" || die

	if use systemd; then
		systemd_douserunit systemd/${PN}.service
	else
		exeinto /etc/user/init.d
		newexe "${FILESDIR}"/${PN}.user.initd ${PN}
	fi
}
