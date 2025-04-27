# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )

DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Read Exif metadata from tiff and jpeg files"
HOMEPAGE="
	https://github.com/ianare/exif-py/
	https://pypi.org/project/exif-py/
"

LICENSE="BSD-3-clause"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~mips ~x86"
IUSE+="test"
RESTRICT="
	mirror
	!test? ( test )
"

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
S="${WORKDIR}/exif-py-${PV}"

python_install() {
	distutils-r1_python_install
	rm -rf "${ED}/usr/lib/${EPYTHON}/site-packages/tests"
}

src_install() {
	distutils-r1_src_install
	docinto "licenses"
	dodoc "LICENSE"
}
