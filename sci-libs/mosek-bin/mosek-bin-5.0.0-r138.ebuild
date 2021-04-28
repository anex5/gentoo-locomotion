# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{7..9} )

MY_PN=${PN/-bin/}
MY_PV=$(ver_rs 1-2 '_' $(ver_cut 1-2))

inherit distutils-r1

DESCRIPTION="A commercial solver for mathematical optimization problems."
HOMEPAGE="http://mosek.com/"
SRC_URI="https://download.mosek.com/stable/${PV}/mosektoolslinux64x86.tar.bz2"

LICENSE="MOSEK"
SLOT="$(ver-cut 1-1)"
KEYWORDS="amd64"
IUSE="python doc"

RESTRICT="mirror"

S="${WORKDIR}"

DISTUTILS_USE_SETUPTOOLS=no

RDEPEND="
	>=dev-python/numpy-1.11.0[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

QA_PREBUILT="opt/${MY_PN}/usr/lib/{libcilkrts.so.5,libmosek64.so,libmosekxx$MY_PV.so} opt/${MY_PN}/usr/bin/mosek"

src_compile(){
	if use python ; then
		cd "${S}/mosek/$(ver_cut 1-2)/tools/platform/linux64x86/python/3/" || die
		distutils-r1_src_compile
	fi
}

src_install (){
	dodir "/opt/${MY_PN}"

	# Install shared libraries.
	dodir "/opt/${MY_PN}/usr/lib"
	insinto "/opt/${MY_PN}/usr/lib"
	cd "${S}/mosek/$(ver_cut 1-2)/tools/platform/linux64x86/bin"

	doins "libmosek64.so.$(ver_cut 1-2)"
	doins "libmosekxx${MY_PV}.so"
	dosym "libmosek64.so.$(ver_cut 1-2)" "/opt/${MY_PN}/usr/lib/libmosek64.so"

	# Install command line utilities.
	cd "${S}/mosek/$(ver_cut 1-2)/tools/platform/linux64x86/bin"
	dodir "/opt/${MY_PN}/usr/bin"
	insinto "/opt/${MY_PN}/usr/bin"
	doins "mosek"

	# Install C bindings.
	cd "${S}/mosek/$(ver_cut 1-2)/tools/platform/linux64x86/h"
	dodir "/opt/${MY_PN}/usr/include"
	insinto "/opt/${MY_PN}/usr/include"
	doins "mosek.h"

	# Install Python bindings.
	if use python; then
		cd "${S}/mosek/$(ver_cut 1-2)/tools/platform/linux64x86/python/3/" || die
		distutils-r1_src_install
	fi

	cd "${S}"
	echo "PATH=\"/opt/${MY_PN}/usr/bin\"" > "99mosek"
	echo "LDPATH=\"/opt/${MY_PN}/usr/lib\"" > "99mosek"
	insinto "/etc/env.d"
	doins "99mosek"

	# Install documentation.
	if use doc; then
		cd "${S}/mosek/$(ver_cut 1-2)"
		dodoc mosek-eula.pdf
		dodoc doc/xml/*.xml
		dodoc doc/*.pdf
		#dodoc ${S}/mosek/$(ver_cut 1-2)/tools/examples/*
	fi
}
