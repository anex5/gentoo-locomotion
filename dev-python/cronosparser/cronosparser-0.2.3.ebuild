# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10,11} )

inherit distutils-r1 git-r3

DESCRIPTION="Parser for CronosPro / CronosPlus database files."
HOMEPAGE="https://github.com/occrp/cronosparser tech@occrp.org"
EGIT_REPO_URI="https://github.com/occrp/cronosparser"
EGIT_COMMIT="e7748a1a98992b2cc2191f4ce3b1621db1365c3f"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND="
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/unicodecsv[${PYTHON_USEDEP}]
	dev-python/normality[${PYTHON_USEDEP}]
	test? (
		dev-python/nose[${PYTHON_USEDEP}]
		dev-python/coverage[${PYTHON_USEDEP}]
	)
"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"
