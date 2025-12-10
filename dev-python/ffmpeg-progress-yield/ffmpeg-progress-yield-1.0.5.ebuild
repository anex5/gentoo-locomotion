# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=uv-build

PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

DESCRIPTION="Run an ffmpeg command with its progress yielded"
HOMEPAGE="
	https://pypi.org/project/ffmpeg-progress-yield/
	https://github.com/slhck/ffmpeg-progress-yield/
"
SRC_URI="https://github.com/slhck/ffmpeg-progress-yield/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"

RDEPEND+="
	>=dev-python/tqdm-4.38.0[${PYTHON_USEDEP}]
	>=dev-python/colorama-0.4.3[${PYTHON_USEDEP}]
	>=media-video/ffmpeg-4.4:=
"

BDEPEND+="
	dev-python/uv-build[${PYTHON_USEDEP}]
	test? (
		dev-python/mypy[${PYTHON_USEDEP}]
		>=dev-python/pytest-9.0.2[${PYTHON_USEDEP}]
		>=dev-python/pytest-asyncio-1.3.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-xdist-3.8.0[${PYTHON_USEDEP}]
	)
"

RESTRICT="mirror"

S="${WORKDIR}/${PN//_/-}-${PV}"

EPYTEST_PLUGINS=( pytest-asyncio )
EPYTEST_XDIST=1
distutils_enable_tests pytest

python_test() {
	local -x PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
	epytest -m "not slow" tests
}

