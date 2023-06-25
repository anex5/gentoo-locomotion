# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1

COMMIT_HASH="496e8eb09b46c32a873cbefbcaf799f498308c1c"

DISTUTILS_USE_PEP517=setuptools

DESCRIPTION="Python client for Neovim"
HOMEPAGE="https://github.com/neovim/pynvim"
SRC_URI="https://github.com/neovim/${PN}/archive/${COMMIT_HASH}.tar.gz -> ${P}-${COMMIT_HASH}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 ~arm ~x86"

RDEPEND="dev-python/msgpack[${PYTHON_USEDEP}]
	virtual/python-greenlet[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	test? ( app-editors/neovim )"

S=${WORKDIR}/${PN}-${COMMIT_HASH}

distutils_enable_tests pytest

python_prepare_all() {
	sed -r -i "s:[\"']pytest-runner[\"'](,|)::" setup.py || die
	distutils-r1_python_prepare_all
}
