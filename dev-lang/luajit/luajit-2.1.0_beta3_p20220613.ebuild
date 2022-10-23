# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GIT_COMMIT=6c4826f12c4d33b8b978004bc681eb1eef2be977

LUA_COMPAT=( lua5-{1..4} luajit)

inherit pax-utils lua-single toolchain-funcs

MY_PV="$(ver_cut 1-5)"
MY_PV="${MY_PV/_beta/-beta}"
MY_P="LuaJIT-${MY_PV}"

DESCRIPTION="Just-In-Time Compiler for the Lua programming language"
HOMEPAGE="https://luajit.org/"
#SRC_URI="https://luajit.org/download/${MY_P}.tar.gz"
SRC_URI="https://github.com/LuaJIT/LuaJIT/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
# this should probably be pkgmoved to 2.0 for sake of consistency.
SLOT="2/${PV}"
KEYWORDS="~amd64 ~arm ~arm64 -hppa ~ppc -riscv -sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="lua52compat static-libs"

RESTRICT="mirror"

S="${WORKDIR}/LuaJIT-${GIT_COMMIT}"

get-abi-cflags() {
	# Convert the ABI name we use in Gentoo to what gcc uses
	local map=()
	case ${CBUILD} in
		mips*)
			map=("o32 32" "n32 n32" "n64 64")
			;;
		riscv*)
			map=("lp64d lp64d" "lp64 lp64" "ilp32d ilp32d" "ilp32 ilp32")
			;;
		x86_64*)
			map=("amd64 m64" "x86 m32" "x32 mx32")
			;;
	esac

	local m
	for m in "${map[@]}" ; do
		l=( ${m} )
		[[ $1 == ${l[0]} ]] && echo ${l[1]} && break
	done
}

_emake() {
	local abi_cflags=-$(get-abi-cflags ${ABI})
	emake \
		Q= \
		PREFIX="${EPREFIX}/usr" \
		MULTILIB="$(get_libdir)" \
		DESTDIR="${D}" \
		CFLAGS="" \
		LDFLAGS="" \
		CCOPT="" \
		CCOPT_x86="" \
		HOST_LUA="${LUA}" \
		HOST_CC="$(tc-getBUILD_CC) ${abi_cflags}" \
		HOST_CFLAGS="${BUILD_CPPFLAGS} ${BUILD_CFLAGS}" \
		HOST_LDFLAGS="${BUILD_LDFLAGS}" \
		STATIC_CC="$(tc-getCC)" \
		DYNAMIC_CC="$(tc-getCC) -fPIC" \
		TARGET_LD="$(tc-getCC)" \
		TARGET_CFLAGS="${CPPFLAGS} ${CFLAGS}" \
		TARGET_LDFLAGS="${LDFLAGS}" \
		TARGET_AR="$(tc-getAR) rcus" \
		BUILDMODE="$(usex static-libs mixed dynamic)" \
		TARGET_STRIP="true" \
		INSTALL_LIB="${ED}/usr/$(get_libdir)" \
		"$@"
}
# -L${ESYSROOT}/usr/$(get_libdir) -L${ESYSROOT}/$(get_libdir) -L${ESYSROOT}${LDPATH}
src_compile() {
	tc-export_build_env
	_emake \
		$(tc-is-cross-compiler && echo CROSS="${CHOST}-" ) \
		$(usex lua52compat "XCFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT" '')
}

src_install() {
	_emake install
	dosym luajit-2.1.0-beta3 /usr/bin/luajit
	pax-mark m "${ED}/usr/bin/luajit-${MY_PV}"

	HTML_DOCS="doc/." einstalldocs
}
