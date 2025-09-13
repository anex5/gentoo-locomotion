# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

DISTUTILS_USE_PEP517=standalone

inherit distutils-r1 pypi

DESCRIPTION="A utility for batch-normalizing audio using ffmpeg"
HOMEPAGE="
	https://pypi.org/project/ffmpeg-normalize/
	https://github.com/slhck/ffmpeg-normalize/
"
#SRC_URI="https://github.com/slhck/ffmpeg-normalize/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
IUSE+="test"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND+="
	>=media-video/ffmpeg-4.4:=
	dev-python/colorama[${PYTHON_USEDEP}]
	dev-python/colorlog[${PYTHON_USEDEP}]
	dev-python/ffmpeg-progress-yield[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	media-libs/mutagen[${PYTHON_USEDEP}]
"

BDEPEND+="
	dev-python/uv-build[${PYTHON_USEDEP}]
	test? ( dev-python/mypy[${PYTHON_USEDEP}] )
"

RESTRICT="
	mirror
	!test? ( test )
"
