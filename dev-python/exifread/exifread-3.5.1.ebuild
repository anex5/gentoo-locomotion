# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )

DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="Read Exif metadata from tiff and jpeg files"
HOMEPAGE="
	https://github.com/ianare/exif-py/
	https://pypi.org/project/exif-py/
"
SRC_URI="https://github.com/ianare/exif-py/archive/refs/tags/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~riscv x86"
RESTRICT="mirror"
S="${WORKDIR}/exif-py-${PV}"

RDEPEND+="${PYTHON_DEPS}"
BDEPEND+="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
	test? (
		>=dev-python/isort-5.9.2[${PYTHON_USEDEP}]
		>=dev-python/pytest-7.0.1[${PYTHON_USEDEP}]
		dev-python/mypy[${PYTHON_USEDEP}]
	)
"
distutils_enable_tests pytest

src_install() {
	distutils-r1_src_install
	docinto "licenses"
	dodoc "LICENSE"
}
