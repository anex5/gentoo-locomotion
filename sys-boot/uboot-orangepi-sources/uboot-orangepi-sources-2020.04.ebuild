# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="U-Boot for xunlong orangepi devices"
HOMEPAGE="https://github.com/orangepi-xunlong/u-boot-orangepi"

EGIT_REPO_URI="https://github.com/orangepi-xunlong/u-boot-orangepi"
EGIT_BRANCH="v${PV}"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="arm arm64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="
	sys-devel/bc
"

src_compile() {
	:;
}

src_install() {
	dodir /usr/src/
	cp -R "${S}/" "${D}/usr/src/" || die "Install failed!"
}

