# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Standard BSD utilities"
HOMEPAGE="https://github.com/dcantrell/bsdutils"
SRC_URI="https://github.com/matijaskala/${PN}/archive/52ecd743ee01a094f9d533a2745b4882a2363a52.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm64 arm mips mipsel"
IUSE=""
RESTRICT="mirror"

DEPEND="
	dev-libs/libbsd
	sys-libs/fts-standalone
"
RDEPEND="${DEPEND}
	!sys-apps/coreutils
	!sys-apps/net-tools[hostname]
	!sys-apps/util-linux[kill]
	!sys-apps/which
	!sys-process/procps[kill]"

src_prepare() {
	default

	tc-export CC CXX
	tc-export_build_env BUILD_CC
	#use elibc_musl && export LDLIBS+=" -lfts"
	#sed -i s@md5@@ Makefile || die
	use elibc_musl && append-ldflags -Wl,--whole-archive -Wl,-lcompat_time32 -Wl,--no-whole-archive
}

src_install() {
	default

	rm -f "${D}"/usr/bin/groups || die
	rm -f "${D}"/usr/share/man/man1/groups.1 || die
}
