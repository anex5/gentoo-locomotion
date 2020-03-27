# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-multilib

DESCRIPTION="Small C++ library to interface with the FreeSRP"
HOMEPAGE="https://github.com/FreeSRP"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/FreeSRP/libfreesrp.git"
	inherit git-r3
	KEYWORDS=""
	EGIT_CHECKOUT_DIR="${WORKDIR}/libfreesrp"
	S="${WORKDIR}/libfreesrp"
else
	S="${WORKDIR}/libfreesrp-${PV}/"
	SRC_URI="https://github.com/myriadrf/libfreesrp/archive/0.3.0.tar.gz"
	KEYWORDS="~amd64 ~arm ~ppc ~x86"
fi

LICENSE="GPL-3"
SLOT="0/${PV}"
IUSE="doc static-libs"

BDEPEND="dev-libs/boost:="
DEPEND="virtual/libusb:1"
RDEPEND="${BDEPEND} ${DEPEND}"

multilib_src_configure(){
	mycmakeargs=(
		-DCMAKE_BUILD_TYPE="Release"
		-DCMAKE_INSTALL_PREFIX=/usr/$(get_libdir)
		-DCMAKE_VERBOSE_MAKEFILE=ON
	)
	cmake-utils_src_configure
}

pkg_postinst() {
	einfo "Users in the usb group can use libfreesrp."
}
