# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=7

inherit autotools eutils

DESCRIPTION="C for Media Runtime"
HOMEPAGE="https://github.com/01org/cmrt"
SRC_URI="https://github.com/01org/cmrt/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"

SLOT="0"

KEYWORDS="amd64 x86"

RDEPEND="x11-libs/libdrm"

RESTRICT="mirror"

DEPEND="${RDEPEND}
	x11-libs/libva
	virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${P}-use-right-cpp.patch"
)

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
