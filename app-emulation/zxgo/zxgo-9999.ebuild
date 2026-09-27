# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module toolchain-funcs xdg-utils desktop

MY_PN="${PN}-v3"
DESCRIPTION="Very simple Sinclair ZX Spectrum emulator"
HOMEPAGE="https://github.com/kiltum/zxgo-v3"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/kiltum/zxgo-v3.git"
	KEYWORDS=""
else
	COMMIT="a592e3cadefaded45f7ac6002ab879765f7c7251"
	SRC_URI="https://github.com/kiltum/zxgo-v3/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.gh.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86"
	S="${WORKDIR}/${MY_PN}-${COMMIT}"
fi

LICENSE="GPL-2+"
SLOT="0"

DEPEND="
	dev-libs/libzip
	media-libs/imgui:0=[sdl3]
"
BDEPEND="
	>=dev-lang/go-1.26.5
	virtual/pkgconfig
"
RESTRICT="mirror"

src_compile() {
	ego build -o "bin/${PN}" "./cmd/${PN}"
}

#src_test() {
#	ego test ./...
#}

src_install() {
	#mv emulator zxgo
	doicon -s scalable "${FILESDIR}"/zx.svg
	domenu "${FILESDIR}/${PN}.desktop"
	dobin bin/zxgo
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
