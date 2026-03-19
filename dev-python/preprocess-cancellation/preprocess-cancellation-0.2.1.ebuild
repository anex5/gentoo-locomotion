# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1

DESCRIPTION="GCode processor to add klipper cancel-object markers"
HOMEPAGE="https://github.com/kageurufu/cancelobject-preprocessor"

SRC_URI="https://github.com/kageurufu/cancelobject-preprocessor/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"

S="${WORKDIR}/${P/-/_}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

DEPEND="
	>=dev-python/atomicwrites-1.4.0[${PYTHON_USEDEP}]
	>=dev-python/attrs-21.4.0[${PYTHON_USEDEP}]
	>=dev-python/black-22.1.0[${PYTHON_USEDEP}]
	>=dev-python/click-8.0.3[${PYTHON_USEDEP}]
	>=dev-python/colorama-0.4.4[${PYTHON_USEDEP}]
	>=dev-python/coverage-6.2[${PYTHON_USEDEP}]
	>=dev-python/cycler-0.10.0[${PYTHON_USEDEP}]
	>=dev-python/importlib-metadata-4.8.3[${PYTHON_USEDEP}]
	>=dev-python/iniconfig-1.1.1[${PYTHON_USEDEP}]
	>=dev-python/isort-4.3.21[${PYTHON_USEDEP}]
	>=dev-python/kiwisolver-1.3.1[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.3.4[${PYTHON_USEDEP}]
	>=dev-python/mypy-extensions-0.4.3[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.19.5[${PYTHON_USEDEP}]
	>=dev-python/packaging-21.3[${PYTHON_USEDEP}]
	>=dev-python/pathspec-0.10.3[${PYTHON_USEDEP}]
	>=dev-python/pefile-2021.9.3[${PYTHON_USEDEP}]
	>=dev-python/pillow-8.4.0[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-4.1.0[${PYTHON_USEDEP}]
	>=dev-python/pluggy-1.1[${PYTHON_USEDEP}]
	>=dev-python/shapely-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/tomli-1.2.3[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.0.1[${PYTHON_USEDEP}]
	>=dev-python/zipp-3.6.0[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		>=dev-python/pytest-7.1.2[${PYTHON_USEDEP}]
	)
"

RESTRICT="mirror"

: ${EPYTEST_TIMEOUT:=5}
distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare

	# upstream doesn't provide build system in pyproject.toml
	cat >> pyproject.toml <<-EOF || die
		[build-system]
		requires = ["poetry-core>=1.0.0"]
		build-backend = "poetry.core.masonry.api"
	EOF
}
