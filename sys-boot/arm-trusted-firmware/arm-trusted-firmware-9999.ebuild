# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Reference secure world boot and runtime firmware complying with the relevant Arm specifications"
HOMEPAGE="https://www.trustedfirmware.org"

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ARM-software/${PN}"
	EGIT_BRANCH="master"
	KEYWORDS=""
else
	SRC_URI="https://github.com/ARM-software/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz "
	KEYWORDS="~amd64 ~arm ~arm64 ~mips ~ppc64 ~riscv ~sparc ~x86"
fi

LICENSE="BSD"
SLOT="0"
RESTRICT="mirror"

src_compile() {
	:;
}

src_install() {
	dodir /usr/src/
	cp -R "${S}/" "${D}/usr/src/" || die "Install failed!"
}
