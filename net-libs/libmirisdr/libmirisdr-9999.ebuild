# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 udev

EGIT_REPO_URI="https://github.com/f4exb/libmirisdr-4/"

DESCRIPTION="Software for the Mirics MSi2500 + MSi001 SDR platform"
HOMEPAGE="https://github.com/f4exb/libmirisdr-4/"

LICENSE="GPL-2"
SLOT="0/${PV}"
IUSE="static-libs driver"
KEYWORDS="~amd64 ~x86"

DEPEND="virtual/libusb:1"
BDEPEND="
	acct-group/plugdev
	virtual/pkgconfig
"
RESTRICT="mirror test"

src_prepare() {
	# Fix CMake-4 compatibility
	sed -e '/cmake_minimum_required/s/3\.7\.2/3.10/' -i CMakeLists.txt || die

	# Set proper so file version name
	sed -e '/VERSION_INFO_PATCH_VERSION/ s/git/0/g' -i CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		-DDETACH_KERNEL_DRIVER=ON
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	udev_dorules mirisdr.rules
	use static-libs || rm -f "${ED}"/usr/$(get_libdir)/libmirisdr.a
}

pkg_postinst() {
	udev_reload
	elog "Only users in the usb group can capture."
	elog "Just run 'gpasswd -a <USER> plugdev', then have <USER> re-login."
}

pkg_postrm() {
	udev_reload
}
