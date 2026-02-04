# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit prefix

DESCRIPTION="A POSIX *nix fetch script using Nerdfonts"
HOMEPAGE="https://github.com/ThatOneCalculator/NerdFetch"
SRC_URI="https://github.com/ThatOneCalculator/NerdFetch/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/NerdFetch-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86 ~arm"

RDEPEND="
app-portage/portage-utils
media-fonts/nerd-fonts
"

RESTRICT="mirror"

src_prepare() {
	default
	hprefixify nerdfetch
}

src_install() {
	dobin "nerdfetch"
	dodoc "README.md"
}
