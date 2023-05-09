# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10,11} )

inherit distutils-r1 git-r3

DESCRIPTION="A tiny library for Python text normalisation. Useful for ad-hoc text processing."
HOMEPAGE="https://pypi.org/project/normality http://pudo.org friedrich@pudo.org "
EGIT_REPO_URI="https://github.com/pudo/normality"
EGIT_COMMIT="e23d4bd4b66254813adbc3b472919ab16a87e10b"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="icu test"

RDEPEND="
	>=dev-python/six-1.11.0[${PYTHON_USEDEP}]
	>=dev-python/banal-0.4.1[${PYTHON_USEDEP}]
	dev-python/text-unidecode[${PYTHON_USEDEP}]
	dev-python/chardet[${PYTHON_USEDEP}]
	icu? ( >=dev-python/pyicu-1.9.3[${PYTHON_USEDEP}] )
"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

python_prepare_all() {
	rm -r "tests" || die
	distutils-r1_python_prepare_all
}
