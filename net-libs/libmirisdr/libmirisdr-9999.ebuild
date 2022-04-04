# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3
EGIT_REPO_URI="https://github.com/f4exb/libmirisdr-4/"

DESCRIPTION="Software for the Mirics MSi2500 + MSi001 SDR platform"
HOMEPAGE="https://github.com/f4exb/libmirisdr-4/"

LICENSE="GPL-2"
SLOT="0/${PV}"
IUSE="doc static-libs"
KEYWORDS="~x86 ~amd64"

RDEPEND="virtual/libusb:1"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	CMAKE_BUILD_TYPE=Release
	cmake_src_configure
}

src_install() {
	cmake_src_install
	use static-libs || rm -f "${ED}"/usr/$(get_libdir)/libmirisdr.a
}
