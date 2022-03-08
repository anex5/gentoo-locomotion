# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

inherit cmake multilib

DESCRIPTION="Switch your X keyboard layouts from the command line"
HOMEPAGE="https://github.com/ierton/xkb-switch"
if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/ierton/xkb-switch"
	KEYWORDS=""
else
	SRC_URI="https://github.com/grwlf/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE=""
RESTRICT="mirror"

DEPEND="x11-libs/libxkbfile"
RDEPEND="${DEPEND}"

src_prepare() {
	# multilib-strict
	sed -i -e "s/DESTINATION lib/DESTINATION $(get_libdir)/" CMakeLists.txt
	cmake_src_prepare
}
