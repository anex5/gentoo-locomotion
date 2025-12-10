# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

DISTUTILS_USE_PEP517=uv-build

DOCS_BUILDER="mkdocs"
DOCS_DEPEND="
	dev-python/mkdocs-material
"

inherit distutils-r1 docs

DESCRIPTION="A utility for batch-normalizing audio using ffmpeg"
HOMEPAGE="
	https://pypi.org/project/ffmpeg-normalize/
	https://github.com/slhck/ffmpeg-normalize/
"
SRC_URI="https://github.com/slhck/ffmpeg-normalize/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"

RDEPEND+="
	>=media-video/ffmpeg-4.4:=
	>=dev-python/colorama-0.4.6[${PYTHON_USEDEP}]
	>=dev-python/colorlog-6.7.0[${PYTHON_USEDEP}]
	>=dev-python/ffmpeg-progress-yield-1.0.1[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.64.1[${PYTHON_USEDEP}]
	>=media-libs/mutagen-1.47.0[${PYTHON_USEDEP}]
"

BDEPEND+="
	dev-python/uv-build[${PYTHON_USEDEP}]
	>=dev-python/cython-3.0.8[${PYTHON_USEDEP}]
	test? (
		dev-python/mypy[${PYTHON_USEDEP}]
		>=dev-python/pytest-9.0.2[${PYTHON_USEDEP}]
		>=dev-python/pytest-asyncio-1.3.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-xdist-3.8.0[${PYTHON_USEDEP}]
	)
"

RESTRICT="mirror"

EPYTEST_PLUGINS=( pytest-asyncio )
EPYTEST_XDIST=1
distutils_enable_tests pytest

python_test() {
	local -x PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
	epytest -m "not slow" tests
}
