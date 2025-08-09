# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )

inherit cmake

MY_PN=${PN^}

DESCRIPTION="Polygon and line clipping and offsetting library (C++, C#, Delphi)"
HOMEPAGE="http://www.angusj.com/delphi/clipper.php"
SRC_URI="https://github.com/AngusJohnson/${MY_PN}/archive/refs/tags/${MY_PN}_${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~x86"

IUSE="utils examples test"

RDEPEND=""
BDEPEND="app-arch/unzip"

RESTRICT="mirror"

S="${WORKDIR}/${MY_PN}-${MY_PN}_${PV}/CPP"

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DCLIPPER2_UTILS=$(usex utils ON OFF)
		-DCLIPPER2_TESTS=$(usex test ON OFF)
		-DCLIPPER2_EXAMPLES=$(usex examples ON OFF)
	)
	cmake_src_configure
}
