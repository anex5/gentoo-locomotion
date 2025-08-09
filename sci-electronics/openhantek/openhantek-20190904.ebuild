# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 cmake desktop

DESCRIPTION="Digital Storage Osziloscope"
HOMEPAGE="http://www.openhantek.org/"

EGIT_REPO_URI="https://github.com/OpenHantek/openhantek"
EGIT_BRANCH="master"
EGIT_COMMIT="e7e0c7b8b12884b85d7e14f997fdf4013558e6a4"

LICENSE="GPL-3"

SLOT="0"

IUSE="udev"

DEPEND="
	sci-libs/fftw
	dev-libs/libusb
	dev-qt/qtopengl
	dev-qt/qtgui
	dev-qt/qtcore
	dev-qt/qtprintsupport
"
RDEPEND="${DEPEND} sci-electronics/electronics-menu"

KEYWORDS="~amd64"

S="${WORKDIR}"/${PN}-${PV}

src_configure() {
	export PREFIX=/usr
	export CXX="/usr/bin/$(tc-getCXX)"
	export CC="/usr/bin/$(tc-getCC)"
	#ewarn "${CXX}"
	cmake_src_configure
}

src_install() {
	newicon ${PN}/res/images/openhantek.png openhantek.png
	#make_desktop_entry openhantek OpenHantek openhantek Electronics
	dodoc ${PN}/readme.md
	cmake_src_install
}

pkg_postinst() {
	echo
	elog "You will need the firmware for your DSO installed."
	elog "Visit http://www.openhantek.org/ for futher configuration instructions."
	echo
}
