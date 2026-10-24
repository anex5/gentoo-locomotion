# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Material Design Icons from Google"
HOMEPAGE="https://materialdesignicons.com"
MY_PN="MaterialDesign-Webfont"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/Templarian/MaterialDesign-Webfont.git"
	inherit git-r3
else
	SRC_URI="https://github.com/Templarian/MaterialDesign-Webfont/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
	S="${WORKDIR}/${MY_PN}-${PV}"
	KEYWORDS="*"
fi

LICENSE="Apache-2.0"
SLOT="0"
FONT_SUFFIX="ttf"
FONT_S="${S}/fonts"

# No binaries, only fonts
RESTRICT="strip binchecks mirror"
