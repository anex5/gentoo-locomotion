# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8


inherit pax-utils toolchain-funcs

# Split release channel (such as "2.1") from relver (such as "1727870382")
VER_CHANNEL=${PV%.*}
VER_RELVER=${PV##*.}

DESCRIPTION="Just-In-Time Compiler for the Lua programming language"
HOMEPAGE="https://luajit.org/"

if [[ ${VER_RELVER} == 9999999999 ]]; then
	# Upstream recommends pulling rolling releases from versioned branches.
	# > The old git master branch is phased out and stays pinned to the v2.0
	# > branch. Please follow the versioned branches instead.
	#
	# See http://luajit.org/status.html for additional information.
	EGIT_BRANCH="v${VER_CHANNEL}"
	EGIT_REPO_URI="https://luajit.org/git/luajit.git"
	inherit git-r3
else
	# Update this commit hash to bump a pinned-commit ebuild.
	GIT_COMMIT=fe71d0fb54ceadfb5b5f3b6baf29e486d97f6059
	SRC_URI="https://github.com/LuaJIT/LuaJIT/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/LuaJIT-${GIT_COMMIT}"

	KEYWORDS="~amd64 ~arm ~arm64 -hppa ~mips ~ppc -riscv -sparc ~x86 ~amd64-linux ~x86-linux"
fi

LICENSE="MIT"
# this should probably be pkgmoved to 2.1 for sake of consistency.
SLOT="2/${PV}"
IUSE="lua52compat static-libs"

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
		TARGET_SHLDFLAGS="${LDFLAGS}" \
		TARGET_AR="$(tc-getAR) rcus" \
		BUILDMODE="$(usex static-libs mixed dynamic)" \
		TARGET_STRIP="true" \
		INSTALL_LIB="${ED}/usr/$(get_libdir)" \
		"$@"
}

src_compile() {
# 	_emake \
#		$(tc-is-cross-compiler && echo CROSS="${CHOST}-" ) \
#		$(tc-is-cross-compiler && echo HOST_LUA="${LUA}" ) \
#		$(usex lua52compat "XCFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT" '')
	tc-export_build_env
	_emake XCFLAGS="$(usex lua52compat "-DLUAJIT_ENABLE_LUA52COMPAT" "")"
}

src_install() {
	_emake install
	local relver="$(cat "${S}/src/luajit_relver.txt" || die 'error retrieving relver')"
	dosym luajit-"${VER_CHANNEL}.${relver}" /usr/bin/luajit
	pax-mark m "${ED}/usr/bin/luajit-${MY_PV}"

	HTML_DOCS="doc/." einstalldocs
}
