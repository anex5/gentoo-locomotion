# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GIT_COMMIT=d06beb0480c5d1eb53b3343e78063950275aa281

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
KEYWORDS="~amd64 ~arm ~arm64 -hppa ~mips ~ppc -riscv -sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="lua52compat static-libs"

BDEPEND="${LUA_DEPS}"

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
		[[ $1 == ${l[0]} ]] && echo -${l[1]} && break
	done
}

src_configure() {
	tc-export_build_env

	# You need to use a 32-bit toolchain to build for a 32-bit architecture.
	# Some 64-bit toolchains (like amd64 and ppc64) usually have multilib
	# enabled, allowing you to build in 32-bit with -m32. This won't work in all
	# cases, but it will otherwise just break, so it's worth trying anyway. If
	# you're trying to build for 64-bit from 32-bit, then you're screwed, sorry.
	# See https://github.com/LuaJIT/LuaJIT/issues/664 for the upstream issue.
	if tc-is-cross-compiler; then
		BUILD_CFLAGS+="$(get-abi-cflags ${ABI})"
		BUILD_LDFLAGS+="$(get-abi-cflags ${ABI})"
	fi
}

_emake() {
	emake \
		Q= \
		PREFIX="${EPREFIX}/usr" \
		MULTILIB="$(get_libdir)" \
		DESTDIR="${D}" \
		CFLAGS="" \
		LDFLAGS="" \
		HOST_CC="$(tc-getBUILD_CC)" \
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

src_compile() {
	_emake \
		$(tc-is-cross-compiler && echo CROSS="${CHOST}-" ) \
		$(tc-is-cross-compiler && echo HOST_LUA="${LUA}" ) \
		$(usex lua52compat "XCFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT" '')
}

src_install() {
	_emake install
	dosym luajit-2.1.1710088188 /usr/bin/luajit
	pax-mark m "${ED}/usr/bin/luajit-${MY_PV}"

	HTML_DOCS="doc/." einstalldocs
}
