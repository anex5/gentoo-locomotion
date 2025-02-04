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

IUSE="doc zsh-completion systemd test"
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
	doc? ( app-text/scdoc )
	dev-libs/tllist
"

src_prepare() {
	default
	tc-is-cross-compiler && ( sed "/wscanner\./s@native\: true@native\: false@" -i meson.build || die "Sed failed..." )
	use systemd || ( sed "/subdir('systemd')/d" -i meson.build || die "Sed failed..." )
	use doc || ( sed "/subdir('doc')/d" -i meson.build || die "Sed failed..." )
	use zsh-completion || ( sed "/subdir('completions')/d" -i meson.build || die "Sed failed..." )
}

src_configure() {
	local emesonargs=(
		$(meson_feature doc docs)
		-Dsystem-nanosvg=disabled
	)
	meson_src_configure

	sed 's|@bindir@|/usr/bin|g' "${S}"/dbus/${PN}.service.in > ${PN}.service || die
}


src_install() {
	local DOCS=( CHANGELOG.md README.md LICENSE )
	meson_src_install

	use systemd && systemd_douserunit ${PN}.service
}
