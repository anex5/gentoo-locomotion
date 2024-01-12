# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A POSIX *nix fetch script using Nerdfonts"
HOMEPAGE="https://codeberg.org/thatonecalculator/NerdFetch"
SRC_URI="https://codeberg.org/thatonecalculator/NerdFetch/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="media-fonts/nerdfonts"

RESTRICT="mirror"

src_install() {
	dobin "nerdfetch"
	dodoc "README.md"
}
