# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

ETYPE="headers"

inherit git-r3 toolchain-funcs

EGIT_REPO_URI="https://github.com/NVIDIA/eglexternalplatform.git"

if [[ ${PV} = *9999* ]]; then
	EGIT_COMMIT="refs/heads/master"
else
	EGIT_COMMIT="refs/tags/${PV/_*/}"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
fi

DESCRIPTION="EGL External Platform interface"
HOMEPAGE="https://github.com/NVIDIA/eglexternalplatform"

LICENSE="MIT"
SLOT="0"
IUSE="debug"

BDEPEND="
	virtual/pkgconfig
	dev-vcs/git
"

src_install() {
	insinto "${EPREFIX}/usr/include/EGL"
	doins "${S}/interface/"*.h
	insinto "${EPREFIX}/usr/$(get_libdir)/pkgconfig"
	doins  "${S}/${PN}.pc"
}
