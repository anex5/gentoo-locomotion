# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7..9} )

inherit cmake toolchain-funcs python-any-r1

DESCRIPTION="Intel SPMD Program Compiler"
HOMEPAGE="https://ispc.github.com/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ispc/ispc.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD BSD-2 UoI-NCSA"
SLOT="0"
IUSE="examples doc sanitize test"

RDEPEND="
	sys-devel/clang:=
	sys-devel/llvm:=
	sys-libs/ncurses:0=
	sys-libs/zlib:=
"

DEPEND="
	${RDEPEND}
	${PYTHON_DEPS}
	doc? (
		app-doc/doxygen[dot(+)]
		media-fonts/freefont
	)
"

BDEPEND="
	sys-devel/bison
	sys-devel/flex
"

PATCHES=(
	"${FILESDIR}/${PN}-1.14.0-cmake-gentoo-release.patch"
	"${FILESDIR}/${PN}-1.15.0-llvm-12.patch"
)

DOCS=( README.md "${S}"/docs/{ReleaseNotes.txt,faq.rst,ispc.rst,perf.rst,perfguide.rst} )

src_prepare() {
	# drop -Werror
	sed -e 's/-Werror//' -i CMakeLists.txt || die

	# fix path for dot binary
	if use doc; then
		sed -e 's|/usr/local/bin/dot|/usr/bin/dot|' -i "${S}"/doxygen.cfg || die
	fi

	if use amd64; then
		# On amd64 systems, build system enables x86/i686 build too.
		# This ebuild doesn't even have multilib support, nor need it.
		# https://bugs.gentoo.org/730062
		elog "Removing auto-x86 build on amd64"
		sed -i -e 's:set(target_arch "i686"):return():' cmake/GenerateBuiltins.cmake || die
	fi

	cmake_src_prepare
}

src_configure() {
	#CMAKE_BUILD_TYPE="Release"
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DARM_ENABLED=$(usex arm)
		-DGENX_ENABLED=OFF
		#-DNVPTX_ENABLED=OFF
		-DISPC_INCLUDE_EXAMPLES=$(usex examples)
		-DISPC_INCLUDE_TESTS=$(usex test)
		-DISPC_INCLUDE_UTILS=ON
		-DISPC_NO_DUMPS=ON
		-DISPC_PREPARE_PACKAGE=OFF
		-DISPC_STATIC_STDCXX_LINK=OFF
		-DISPC_STATIC_LINK=OFF
		-DISPC_USE_ASAN=$(usex sanitize)
		-DPython3_EXECUTABLE="${PYTHON}"
	)
	cmake_src_configure
}

src_compile(){
	cmake_src_compile

	if use doc; then
		pushd "${S}" >/dev/null || die
		doxygen -u doxygen.cfg || die "failed to update doxygen.cfg"
		doxygen doxygen.cfg || die "failed to build documentation"
		popd >/dev/null || die
	fi
}

src_install() {
	cmake_src_install

	if use doc; then
		local HTML_DOCS=( docs/doxygen/html/. )
	fi
	einstalldocs

	if use examples; then
		insinto "/usr/share/doc/${PF}/examples"
		docompress -x "/usr/share/doc/${PF}/examples"
		doins -r "${BUILD_DIR}"/examples/*
	fi
}

src_test() {
	# Inject path to prevent using system ispc
	PATH="${BUILD_DIR}/bin:${PATH}" ${EPYTHON} run_tests.py || die "Testing failed under ${EPYTHON}"
}

