# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
LLVM_MAX_SLOT=16
inherit cmake toolchain-funcs python-any-r1 llvm

DESCRIPTION="Intel SPMD Program Compiler"
HOMEPAGE="https://ispc.github.io/"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ispc/ispc.git"
	EGIT_SUBMODULES=()
	EGIT_BRANCH="main"
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm ~arm64 ~ppc64 ~x86"
fi

LICENSE="BSD BSD-2 UoI-NCSA"
SLOT="0"
IUSE="examples doc sanitize test"
RESTRICT="mirror"

RDEPEND="
	<sys-devel/clang-$((${LLVM_MAX_SLOT} + 1)):=
	sys-libs/ncurses:0=
"

DEPEND="
	${RDEPEND}
	doc? (
		app-doc/doxygen[dot(+)]
		media-fonts/freefont
	)
"

BDEPEND="
	sys-devel/bison
	sys-devel/flex
	${PYTHON_DEPS}
"

PATCHES=(
	#"${FILESDIR}"/${PN}-1.14.0-cmake-gentoo-release.patch
	"${FILESDIR}"/0001-Fix-QA-Issues.patch
	"${FILESDIR}"/0002-cmake-don-t-build-for-32-bit-targets.patch
	"${FILESDIR}"/0001-CMakeLists.txt-link-with-libclang-cpp-library-instea.patch
	"${FILESDIR}"/${PN}-1.19.0-curses-cmake.patch
)

DOCS=( README.md "${S}"/docs/{ReleaseNotes.txt,faq.rst,ispc.rst,perf.rst,perfguide.rst} )

pkg_setup() {
	llvm_pkg_setup
	python-any-r1_pkg_setup
}

src_prepare() {
	# drop -Werror
	sed -e 's/-Werror//' -i CMakeLists.txt || die

	# fix path for dot binary
	if use doc; then
		sed -e 's|/usr/local/bin/dot|/usr/bin/dot|' -i "${S}"/doxygen.cfg || die
	fi

	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE="Release"
	local mycmakeargs=(
		-DARM_ENABLED=$(usex arm)
		-DCMAKE_SKIP_RPATH=ON
		#-DNVPTX_ENABLED=OFF
		-DISPC_INCLUDE_EXAMPLES=$(usex examples)
		-DISPC_INCLUDE_DPCPP_EXAMPLES=$(usex examples)
		-DISPC_INCLUDE_TESTS=$(usex test)
		-DISPC_INCLUDE_UTILS=ON
		-DISPC_PREPARE_PACKAGE=OFF
		-DISPC_STATIC_STDCXX_LINK=OFF
		-DISPC_STATIC_LINK=OFF
		-DISPC_USE_ASAN=$(usex sanitize)
		-DPython3_EXECUTABLE="${PYTHON}"
	)
	cmake_src_configure
}

src_test() {
	# Inject path to prevent using system ispc
	PATH="${BUILD_DIR}/bin:${PATH}" ${EPYTHON} run_tests.py || die "Testing failed under ${EPYTHON}"
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
