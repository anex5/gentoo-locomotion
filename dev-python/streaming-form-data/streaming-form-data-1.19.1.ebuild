# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1

DOCS_BUILDER="mkdocs"
DOCS_DEPEND="
	dev-python/mkdocs-material
"

inherit distutils-r1 docs

DESCRIPTION="Streaming multipart/form-data parser"
HOMEPAGE="https://github.com/siddhantgoel/streaming-form-data"
SRC_URI="https://github.com/siddhantgoel/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~mips ~x86 ~arm"

RDEPEND="${PYTHON_DEPS}
	>=dev-python/smart-open-7.5.0[${PYTHON_USEDEP}]
"

BDEPEND+="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/wheel[${PYTHON_USEDEP}]
	test? (
		=dev-python/cython-3*[${PYTHON_USEDEP}]
		>=dev-python/flask-3.0.3[${PYTHON_USEDEP}]
		>=dev-python/mkdocs-1.6.1[${PYTHON_USEDEP}]
		>=dev-python/moto-5.0.18[${PYTHON_USEDEP}]
		>=dev-python/mypy-1.13.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-8.3.3[${PYTHON_USEDEP}]
		>=dev-python/requests-toolbelt-1.0.0[${PYTHON_USEDEP}]
		>=dev-util/ruff-0.7.1
	)
"

RESTRICT="mirror"

distutils_enable_tests pytest

EPYTEST_DESELECT=(
	"utils/stress_test.py::DifferentChunksTestCase::test_special_chars_first_attach"
	"utils/stress_test.py::DifferentChunksTestCase::test_special_chars_last_attach"
	"utils/stress_test.py::DifferentFileSizesTestCase::test_special_chars"
)

src_install() {
	distutils-r1_src_install
	docinto "licenses"
	dodoc "LICENSE.txt"
}
