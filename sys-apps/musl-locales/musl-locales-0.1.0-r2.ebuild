# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Locale program for musl libc"
HOMEPAGE="https://git.adelielinux.org/adelie/musl-locales"
SRC_URI="https://git.adelielinux.org/adelie/musl-locales/uploads/2936dfdde3ee6f7e3492ec8a7287107ac41f792c/${P}.tar.xz"

LICENSE="LGPL-3 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~x86"

RDEPEND="!sys-libs/glibc"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_POLICY_DEFAULT_CMP0175="OLD" # add_custom_command
		-DCMAKE_POLICY_DEFAULT_CMP0115="NEW"
		-DLOCALE_PROFILE=OFF
	)
	CMAKE_BUILD_TYPE="Release"
	cmake_src_configure
}

src_install() {
	echo "MUSL_LOCPATH=\"/usr/share/i18n/locales/musl\"" | newenvd - 00locale
	cmake_src_install
}

pkg_postinst() {
	elog "Run . /etc/profile and then eselect locale list"
	elog "to see available locales to use with musl. "
}
