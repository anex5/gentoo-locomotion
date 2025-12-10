# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )

DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="A python library to extract table from PDF into pandas DataFrame"
HOMEPAGE="https://github.com/chezou/tabula-py"
SRC_URI="https://github.com/chezou/tabula-py/archive/refs/tags/v${PV}/${P}.tar.gz -> ${P}.gh.tar.gz"
export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~riscv x86"
RESTRICT="mirror"
S="${WORKDIR}/tabula-py-${PV}"

RDEPEND+="${PYTHON_DEPS}"
BDEPEND+="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
	test? (
		>=dev-python/pytest-7.0.1[${PYTHON_USEDEP}]
		dev-python/mypy[${PYTHON_USEDEP}]
		>=dev-python/jpype-1.5.2[${PYTHON_USEDEP}]
	)
"
distutils_enable_tests pytest

src_install() {
	distutils-r1_src_install
	docinto "licenses"
	dodoc "LICENSE"
}
