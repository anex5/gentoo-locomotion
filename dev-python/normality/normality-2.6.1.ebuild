# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1

DESCRIPTION="A tiny library for Python text normalisation. Useful for ad-hoc text processing."
HOMEPAGE="
	https://github.com/pudo/normality/
"
SRC_URI="https://github.com/pudo/normality/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"


LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE+="icu test"

RDEPEND+="
	>=dev-python/six-1.11.0[${PYTHON_USEDEP}]
	>=dev-python/banal-0.4.1[${PYTHON_USEDEP}]
	dev-python/text-unidecode[${PYTHON_USEDEP}]
	dev-python/chardet[${PYTHON_USEDEP}]
	icu? ( >=dev-python/pyicu-1.9.3[${PYTHON_USEDEP}] )
"

DEPEND+="${RDEPEND}
	>=dev-python/hatchling-1.24.2[${PYTHON_USEDEP}]
	>=dev-python/hatch-vcs-0.3.0[${PYTHON_USEDEP}]
	>=dev-python/hatch-fancy-pypi-readme-23.2.0[${PYTHON_USEDEP}]
	test? (
		dev-python/mypy[${PYTHON_USEDEP}]
		dev-python/build[${PYTHON_USEDEP}]
	)
"

RESTRICT="mirror test"

python_prepare_all() {
	rm -r "tests" || die
	distutils-r1_python_prepare_all
}
