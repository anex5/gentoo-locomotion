# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=standalone

PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1 pypi

DESCRIPTION="Run an ffmpeg command with its progress yielded"
HOMEPAGE="
	https://pypi.org/project/ffmpeg-progress-yield/
	https://github.com/slhck/ffmpeg-progress-yield/
"
SRC_URI="https://github.com/slhck/ffmpeg-progress-yield/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
IUSE+="test"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND+="
	>=dev-python/tqdm-4.38.0[${PYTHON_USEDEP}]
	>=dev-python/colorama-0.4.3[${PYTHON_USEDEP}]
	>=media-video/ffmpeg-4.4:=
"

BDEPEND+="
	dev-python/uv-build[${PYTHON_USEDEP}]
	test? (
		>=dev-python/pytest-7.0.1[${PYTHON_USEDEP}]
		dev-python/mypy[${PYTHON_USEDEP}]
	)
"

RESTRICT="
	mirror
	!test? ( test )
"

S="${WORKDIR}/${PN//_/-}-${PV}"
