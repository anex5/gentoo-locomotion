# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1

COMMIT_HASH="5f989dfc47d98bba9f98e5ea17bfbe4c995cb0b0"

DISTUTILS_USE_PEP517=setuptools

DESCRIPTION="Python client for Neovim"
HOMEPAGE="https://github.com/neovim/pynvim"
SRC_URI="https://github.com/neovim/${PN}/archive/${COMMIT_HASH}.tar.gz -> ${P}-${COMMIT_HASH}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 ~arm ~x86"

RDEPEND="
	>=dev-python/msgpack-0.5.0[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/wheel[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	test? ( app-editors/neovim )"

S=${WORKDIR}/${PN}-${COMMIT_HASH}

RESTRICT="mirror"

distutils_enable_tests pytest

python_prepare_all() {
	sed -e "s/msgpack-python/msgpack/g" -i setup.py || die
	sed -re "s:[\"']pytest-runner[\"'](,|)::" -i setup.py || die
	distutils-r1_python_prepare_all
}
