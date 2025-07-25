# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic toolchain-funcs

DESCRIPTION="libopenaptx library without the additional license restriction"
HOMEPAGE="https://github.com/iamthehorker/libfreeaptx"

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/iamthehorker/${PN}"
else
	SRC_URI="https://github.com/iamthehorker/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	RESTRICT="mirror"
fi

LICENSE="LGPL-2.1+"
SLOT="0"

IUSE="cpu_flags_x86_avx2"

src_compile() {
	tc-export CC AR

	use cpu_flags_x86_avx2 && append-cflags "-mavx2"

	emake \
		PREFIX="${EPREFIX}"/usr \
		LIBDIR=$(get_libdir) \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		ARFLAGS="${ARFLAGS} -rcs" \
		all
}

src_install() {
	emake \
		PREFIX="${EPREFIX}"/usr \
		DESTDIR="${D}" \
		LIBDIR="$(get_libdir)" \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		ARFLAGS="${ARFLAGS} -rcs" \
		install

	rm -f "${ED}/usr/$(get_libdir)"/libfreeaptx.a || die "Failed to remove static lib"
}
