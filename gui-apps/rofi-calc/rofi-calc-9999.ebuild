# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="Do live calculations in rofi!"
HOMEPAGE="https://github.com/svenstaro/rofi-calc"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/svenstaro/rofi-calc.git"
	EGIT_SUBMODULES=()
	KEYWORDS=""
else
	SRC_URI="https://github.com/svenstaro/rofi-calc/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

DEPEND="
	x11-misc/rofi
	>=sci-libs/libqalculate-2.0
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-add-to-history-hint.patch"
)

src_prepare() {
	default
	eautoreconf -i
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
