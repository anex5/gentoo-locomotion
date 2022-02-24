# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1 git-r3

DESCRIPTION="A utility for batch-normalizing audio using ffmpeg"
HOMEPAGE="https://github.com/slhck/ffmpeg-normalize"
EGIT_REPO_URI="https://github.com/slhck/ffmpeg-normalize"
EGIT_COMMIT="5c68c551a2fc1fa5aaeaecb41ff2202b7eed23aa"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-python/tqdm[${PYTHON_USEDEP}]
	>=media-video/ffmpeg-3.1:=
"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

