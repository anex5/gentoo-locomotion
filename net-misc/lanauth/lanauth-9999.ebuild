# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils git-r3 toolchain-funcs

DESCRIPTION="KABiNET ISP authorizer"
HOMEPAGE="visir@telenet.ru"

EGIT_REPO_URI="https://github.com/TideSofDarK/lanauth"
#EGIT_COMMIT=""

LICENSE="BEER-WARE"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~arm ~x86 ~mips"

DEPEND=""

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	dosbin lanauth
}

pkg_postinst() {
	elog "lanauth client \n\
(c) visir \n\
THE BEER-WARE LICENSE (Revision 42): \n\
<visir@telenet.ru> wrote this file.  As long as you retain this notice you \n\
can do whatever you want with this stuff. If we meet some day, and you think \n\
this stuff is worth it, you can buy me a beer in return. \n\
compile: gcc -O2 -Wall -s -lcrypto -o lanauth lanauth.c \n\
run: ./lanauth -p yourpassword"
}