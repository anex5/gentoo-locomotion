# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit vim-plugin

REF="a0cdbae1e6acbbe67d8501070a99be8fdf12fd71"
DESCRIPTION="vim plugin: CPP syntax highlighting"
HOMEPAGE="https://github.com/bfrg/vim-cpp-modern"

SRC_URI="https://github.com/bfrg/${PN}/tarball/${REF} -> ${P}.tar.gz"

LICENSE="vim"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv s390 sparc x86 ~ppc-aix ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""
RESTRICT="mirror"

VIM_PLUGIN_HELPFILES="cpp-syntax"
VIM_PLUGIN_MESSAGES="filetype"

S="${WORKDIR}/bfrg-${PN}-${REF:0:7}"
