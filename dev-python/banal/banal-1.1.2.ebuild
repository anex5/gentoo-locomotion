# Copyright 1999-2026 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..15} )

DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1

DESCRIPTION="Commons of banal micro-functions for Python."
HOMEPAGE="
	https://pypi.org/project/banal/
	https://github.com/pudo/banal/
"
COMMIT="d682c22187b498c2f67d78453e84ddc29663c198"
SRC_URI="https://github.com/pudo/banal/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.tar.gz"


LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE+="test"
RESTRICT="
	mirror
	!test? ( test )
"

RDEPEND+="
	>=dev-python/six-1.11.0[${PYTHON_USEDEP}]
"

BDEPEND+="
	>=dev-python/hatchling-1.24.2[${PYTHON_USEDEP}]
	>=dev-python/hatch-vcs-0.3.0[${PYTHON_USEDEP}]
	>=dev-python/hatch-fancy-pypi-readme-23.2.0[${PYTHON_USEDEP}]
	test? (
		dev-python/mypy[${PYTHON_USEDEP}]
		dev-python/build[${PYTHON_USEDEP}]
	)
"

S="${WORKDIR}/${PN}-${COMMIT}"
