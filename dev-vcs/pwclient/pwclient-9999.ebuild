# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
DISTUTILS_USE_SETUPTOOLS=manual

inherit distutils-r1

DESCRIPTION="The command-line client for the patchwork patch tracking tool"
HOMEPAGE="https://github.com/getpatchwork/pwclient"

if [[ ${PV} == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/getpatchwork/${PN}"
else
	SRC_URI="https://github.com/getpatchwork/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	RESTRICT="mirror "
fi

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT+="test"

RDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/pbr[${PYTHON_USEDEP}]
	dev-python/pip[${PYTHON_USEDEP}]
"
BDEPEND="
"

src_configure() {
	export PBR_VERSION=${PV}
}
