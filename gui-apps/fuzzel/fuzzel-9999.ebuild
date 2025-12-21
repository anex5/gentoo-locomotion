# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson optfeature toolchain-funcs

DESCRIPTION="Application launcher for wlroots based Wayland compositors."
HOMEPAGE="https://codeberg.org/dnkl/fuzzel"

if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://codeberg.org/dnkl/fuzzel.git"
else
	SRC_URI="https://codeberg.org/dnkl/fuzzel/archive/${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
fi

IUSE="man completions png svg test"
RESTRICT="
	!test? ( test )
	mirror
"
LICENSE="MIT"
SLOT="0"

DEPEND="
	dev-libs/wayland
	<media-libs/fcft-4.0.0
	>=media-libs/fcft-3.0.0
	media-libs/fontconfig
	x11-libs/libxkbcommon
	x11-libs/pixman
	png? ( media-libs/libpng )
	svg? ( >=media-libs/nanosvg-20241219 )
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
	echo -e "Name[ru_RU]=Пузырек" >> "${PN}.desktop"
	echo -e "GenericName=Menu" >> "${PN}.desktop"
	echo -e "GenericName[ru_RU]=Меню" >> "${PN}.desktop"
	use man || ( sed -e "/subdir('doc')/d" -i meson.build || die "Sed failed..." )
	use completions || ( sed -e "/subdir('completions')/d" -i meson.build || die "Sed failed..." )

	tc-is-cross-compiler && ( sed "/find_program(wayland_scanner/s@native\: true@native\: false@" -i meson.build || die "Sed failed..." )
}

src_configure() {
	local emesonargs=(
		-Dpng-backend=$(usex png libpng none)
		-Dsvg-backend=$(usex svg nanosvg none)
		$(meson_feature svg system-nanosvg)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	rm -rf "${ED}/usr/share/doc/fuzzel" || die
}

pkg_postinst() {
	optfeature "For rounded corner support" x11-libs/cairo
}
