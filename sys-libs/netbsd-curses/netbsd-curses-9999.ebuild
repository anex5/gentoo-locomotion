# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic toolchain-funcs multilib-minimal

DESCRIPTION="Netbsd-libcurses portable edition"
HOMEPAGE="https://github.com/sabotage-linux/netbsd-curses"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/sabotage-linux/${PN}"
	EGIT_BRANCH="master"
	KEYWORDS=""
else
	SRC_URI="https://github.com/sabotage-linux/${PN}/archive/refs/tags/v${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm64 ~arm ~mips ~mipsel"
fi

LICENSE="BSD"
SLOT="0"
IUSE="doc static-libs"
RESTRICT="mirror"

BDEPEND="
	app-alternatives/awk
	sys-apps/sed
	sys-apps/coreutils
"
RDEPEND="sys-libs/ncurses:0/1"

PATCHES=(
	"${FILESDIR}/netbsd-curses-0.3.2-fix-crossbuild.patch"
)

src_prepare() {
	default

	multilib_copy_sources

	tc-export CC CXX
	tc-export_build_env BUILD_CC
	export HOSTCC=${BUILD_CC} CFLAGS_HOST="${BUILD_CFLAGS}" LDFLAGS_HOST="${BUILD_LDFLAGS}"
}

multilib_src_compile() {
	#use elibc_musl && append-ldflags -Wl,--whole-archive -Wl,-lcompat_time32 -Wl,--no-whole-archive

	emake PREFIX="${EPREFIX}/usr"

	./tic/host_tic -ax -o terminfo.cdb terminfo/terminfo || die "Tic failed"
}

multilib_src_install() {
	emake PREFIX="${EPREFIX}/usr" LIBDIR="${EPREFIX}/usr/$(get_libdir)" DESTDIR="${D}" \
		$(usex static-libs install-libs install-dynlibs) \
		$(usex doc install-manpages "") \
		install-headers install-progs install-pcs

	insinto /usr/share
	doins terminfo.cdb

	dodoc README.md

	# fix file collisions with attr
	if use doc; then
		rm "${ED%/}/usr/share/man/man3/attr_get.3" || die
		rm "${ED%/}/usr/share/man/man3/attr_set.3" || die
	fi
}
