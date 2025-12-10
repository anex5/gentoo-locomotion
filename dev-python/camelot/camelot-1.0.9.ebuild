# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )

DISTUTILS_USE_PEP517=setuptools

DOCS_BUILDER="sphinx"
DOCS_DEPEND="
	dev-python/sphinxcontrib-bibtex
	dev-python/sphinx-book-theme
"

inherit distutils-r1 optfeature docs

DESCRIPTION="A Python library to extract tabular data from PDFs"
HOMEPAGE="https://camelot-py.readthedocs.io/"
SRC_URI="https://github.com/camelot-dev/camelot/archive/refs/tags/v${PV}/${P}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~riscv x86"
RESTRICT="mirror"

RDEPEND+="${PYTHON_DEPS}
	>=app-text/pdfminer-20220506[${PYTHON_USEDEP}]
	>=dev-python/openpyxl-3.1.0[${PYTHON_USEDEP}]
	>=dev-python/tabulate-0.8.0[${PYTHON_USEDEP}]
	>=dev-python/pypdf-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/pandas-2.2.2[${PYTHON_USEDEP}]
	>=dev-python/click-8.0.1[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
"
DEPEND="
	>=dev-python/numpy-1.23.2:=[${PYTHON_USEDEP}]
"
BDEPEND+="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
	test? (
		>=dev-python/isort-5.9.2[${PYTHON_USEDEP}]
		>=dev-python/pytest-7.0.1[${PYTHON_USEDEP}]
		dev-python/mypy[${PYTHON_USEDEP}]
		dev-python/pytest-mpl[${PYTHON_USEDEP}]
		dev-python/pytest-xdist[${PYTHON_USEDEP}]
	)
"
distutils_enable_tests pytest

distutils_enable_sphinx docs dev-python/sphinx-book-theme \
	dev-python/sphinx-prompt \
	dev-python/sphinx-tabs \
	dev-python/sphinx-copybutton \
	dev-python/sphinxcontrib-autoprogram

pkg_postinst() {
	optfeature "Plotting support" dev-python/matplotlib
}
