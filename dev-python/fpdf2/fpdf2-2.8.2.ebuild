# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Simple PDF generation for Python"
HOMEPAGE="
	https://pypi.org/project/pypdf/
	https://github.com/reingart/pyfpdf
"
#SRC_URI="
#https://github.com/PyFPDF/fpdf2/archive/${P}.tar.gz
#mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz
#"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/defusedxml[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/svg-path[${PYTHON_USEDEP}]
"

RESTRICT="mirror"
