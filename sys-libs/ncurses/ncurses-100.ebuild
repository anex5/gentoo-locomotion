# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit multilib-minimal

DESCRIPTION="dummy package for sys-libs/netbsd-curses"
LICENSE="metapackage"

SLOT="0/1"
KEYWORDS=""
#KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 ~s390 sparc x86 ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs"

RDEPEND="sys-libs/netbsd-curses[static-libs=,${MULTILIB_USEDEP}]"

S="${WORKDIR}"
