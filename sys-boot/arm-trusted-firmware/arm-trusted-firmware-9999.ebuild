# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Reference boot and runtime firmware complying with the Arm specifications"
HOMEPAGE="https://www.trustedfirmware.org"

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ARM-software/${PN}"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/ARM-software/${PN}/archive/refs/tags/lts-v${PV}.tar.gz -> ${P}.gh.tar.gz "
	KEYWORDS="amd64 arm arm64 mips ppc64 riscv sparc x86"
	S="${WORKDIR}/${PN}-lts-v${PV}"
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
