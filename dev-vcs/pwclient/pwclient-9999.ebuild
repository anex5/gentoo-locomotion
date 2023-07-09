# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="The command-line client for the patchwork patch tracking tool"
HOMEPAGE="https://github.com/getpatchwork/pwclient"

if [[ ${PV} == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/getpatchwork/${PN}"
else
	SRC_URI="https://github.com/getpatchwork/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
	RESTRICT="mirror "
fi

LICENSE="LGPL-2"
SLOT="0"
IUSE=""
RESTRICT+="!test ( test )"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	dev-python/importlib-metadata[${PYTHON_USEDEP}]
	>=dev-python/pbr-5.7.0[${PYTHON_USEDEP}]
"
