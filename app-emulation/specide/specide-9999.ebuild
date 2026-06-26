# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic toolchain-funcs xdg-utils desktop

DESCRIPTION="Very simple Sinclair ZX Spectrum emulator"
HOMEPAGE="https://github.com/MartianGirl/SpecIde"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://codeberg.org/MartianGirl/SpecIde"
	KEYWORDS=""
else
	SRC_URI="https://codeberg.org/MartianGirl/SpecIde/archive/${PV}.tar.gz -> ${P}.cb.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86"
	S="${WORKDIR}/${PN}"
fi

IUSE="test +sfml"
LICENSE="GPL-2+"
SLOT="0"

DEPEND="
	sys-libs/zlib
	media-libs/libglvnd
	sfml? (
		<media-libs/libsfml-3
		>=media-libs/libsfml-2.6.2
	)
	!sfml? (
		media-libs/libsdl2
	)
"
BDEPEND="
	virtual/pkgconfig
"
RESTRICT="mirror"

PATCHES=(
#	"${FILESDIR}/specide-fix-sdl2-includes.patch"
)

CMAKE_USE_DIR="${S}/source"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DSPECIDE_MEDIA_LIB=$(usex sfml SFML SDL2)
		-DSPECIDE_BUILD_TESTS=$(usex test)
	)
	CMAKE_BUILD_TYPE=Release cmake_src_configure
}

src_install() {
	cmake_src_install
	doicon -s scalable "${FILESDIR}"/zx.svg
	domenu "${FILESDIR}/specide.desktop"
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
