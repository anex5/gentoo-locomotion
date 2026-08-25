# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..14} )
DISTUTILS_USE_PEP517=setuptools
MY_PN="LnkParse"
inherit distutils-r1

if [[ -z ${PV%%*9999} ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/silascutler/LnkParse.git"
else
	COMMIT="9fd35a4e6224e8b3d771de8b876ba8f8e8b90df6"
	SRC_URI="https://github.com/silascutler/LnkParse/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.gh.tar.gz"
	RESTRICT="mirror"
	KEYWORDS="amd64 arm arm64 x86"
	S="${WORKDIR}/${MY_PN}-${COMMIT}"
fi

DESCRIPTION="A tool to parse Windows shortcut file (LNK)"
HOMEPAGE="https://github.com/silascutler/LnkParse"

LICENSE="Apache-2.0"
SLOT="0"

DEPEND="${PYTHON_REQUIRED_DEPS}"

RDEPEND="
	${DEPEND}
"

src_install () {
	python_setup
	distutils-r1_src_install
	local sitedir="$(python_get_sitedir)"
	python_optimize "${ED}${sitedir}/lnkfile"
	dodir usr/bin
	cat > "${D}/usr/bin/${PN}" <<-EOF || die
#!/bin/sh
exec ${EPYTHON} ${sitedir}/lnkfile/__init__.py -f "\${@}"
EOF
	fperms +x "usr/bin/${PN}"
}
