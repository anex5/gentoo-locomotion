# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10,11} )

inherit distutils-r1 #git-r3

DESCRIPTION="Commons of banal micro-functions for Python."
HOMEPAGE="https://pypi.org/project/banal http://pudo.org friedrich@pudo.org "
#EGIT_REPO_URI="https://github.com/pudo/banal"
#EGIT_COMMIT="528c339be5138458e387a058581cf7d261285447"
SRC_URI="https://github.com/pudo/banal/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="
	>=dev-python/six-1.11.0[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"
