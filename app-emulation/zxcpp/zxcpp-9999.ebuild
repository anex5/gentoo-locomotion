# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs xdg-utils desktop

DESCRIPTION="Very simple Sinclair ZX Spectrum emulator"
HOMEPAGE="https://github.com/kiltum/zxcpp"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/kiltum/zxcpp.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/kiltum/zxcpp/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86"
fi
#S="${WORKDIR}/iotop-${PV}"

LICENSE="GPL-2+"
SLOT="0"

DEPEND="
	dev-libs/libzip
	media-libs/imgui:0=[sdl3]
"
BDEPEND="
	virtual/pkgconfig
"
RESTRICT="mirror"

src_prepare() {
	# Remove hardcoded cflags
	sed -e '/CXX = g++/d' \
		-e 's/ -O3//g' -e 's/ -march=native//g' -e 's/ -mtune=native//g' -e 's/ -g//g' \
		-e 's/ -fprofile-instr-generate//g' -e 's/ -fcoverage-mapping//g' -e 's/ -fsanitize=address//g' \
		-i Makefile || die
	sed -e '/\#include <vector>/a typedef unsigned int uint;' -i include/tape.hpp
	default
}

src_compile() {
	emake V=1 CXX="$(tc-getCXX)"
}

src_install() {
	mv emulator zxcpp
	doicon -s scalable "${FILESDIR}"/zx.svg
	domenu "${FILESDIR}/zxcpp.desktop"
	dobin zxcpp
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
