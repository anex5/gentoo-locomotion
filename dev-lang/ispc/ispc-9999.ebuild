# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( {17..20} )
PYTHON_COMPAT=( python3_{11..14} )

inherit cmake dot-a llvm-r1 multiprocessing python-any-r1 toolchain-funcs

DESCRIPTION="Intel SPMD Program Compiler"
HOMEPAGE="
	https://ispc.github.io/
	https://github.com/ispc/ispc/
"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ispc/ispc.git"
	EGIT_SUBMODULES=()
	EGIT_BRANCH="main"
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV//_*/}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm ~arm64 ~ppc64 ~x86"
	S=${WORKDIR}/${PN}-${PV//_*/}
fi

LICENSE="BSD BSD-2 UoI-NCSA"
SLOT="0"
IUSE="doc examples javascript gpu openmp test utils xe"
RESTRICT="!test? ( test ) mirror"

DEPEND="
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
		llvm-core/llvm:${LLVM_SLOT}
	')
	javascript? ( dev-util/emscripten[llvm_targets_WebAssembly(+)] )
	sys-libs/ncurses:=
	gpu? ( dev-libs/level-zero:= )
	!openmp? ( dev-cpp/tbb:= )
	doc? (
		app-doc/doxygen[dot(+)]
		media-fonts/freefont
	)
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	app-alternatives/yacc
	app-alternatives/lex
	${PYTHON_DEPS}
"

DOCS=( README.md "${S}"/docs/{ReleaseNotes.txt,faq.rst,ispc.rst,perf.rst,perfguide.rst} )

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
	llvm-r1_pkg_setup
	python-any-r1_pkg_setup
}

src_prepare() {
	# drop -Werror
	sed -e 's/-Werror//' -i CMakeLists.txt || die

	# fix path for dot binary
	if use doc; then
		sed -e 's|/usr/local/bin/dot|/usr/bin/dot|' -i "${S}"/doxygen.cfg || die
	fi

	# do not require bundled gtest
	mkdir -p ispcrt/tests/vendor/google/googletest || die
	cat > ispcrt/tests/vendor/google/googletest/CMakeLists.txt <<-EOF || die
		find_package(GTest)
	EOF
	# remove hacks that break unbundling
	sed -i -e '/gmock/d' -e '/install/,$d' ispcrt/tests/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	lto-guarantee-fat
	local mycmakeargs=(
		-DX86_ENABLED=$(usex amd64 ON $(usex x86))
		-DARM_ENABLED=$(usex arm ON OFF)
		-DXE_ENABLED=$(usex xe ON OFF)
		-DWASM_ENABLED=$(usex javascript ON OFF)
		-DCMAKE_SKIP_RPATH=ON
		#-DNVPTX_ENABLED=OFF
		-DISPC_INCLUDE_EXAMPLES=$(usex examples)
		-DISPC_INCLUDE_DPCPP_EXAMPLES=$(usex examples)
		-DISPC_INCLUDE_TESTS=$(usex test)
		-DISPC_INCLUDE_UTILS=$(usex utils)
		-DISPC_PREPARE_PACKAGE=OFF
		-DISPC_STATIC_STDCXX_LINK=OFF
		-DISPC_STATIC_LINK=OFF
		-DISPCRT_BUILD_GPU=$(usex gpu)
		-DISPCRT_BUILD_TASK_MODEL=$(usex openmp OpenMP TBB)
		-DISPC_USE_ASAN=OFF
		# prevent it from trying to find the git repo
		-DGIT_BINARY=GIT_BINARY-NOTFOUND
	)
	CMAKE_BUILD_TYPE="Release"
	cmake_src_configure
}

src_test() {
	# Inject path to prevent using system ispc
	local -x PATH="${BUILD_DIR}/bin:${PATH}"
	"${EPYTHON}" ./scripts/run_tests.py "-j$(makeopts_jobs)" -v ||
		die "Testing failed under ${EPYTHON}"
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
	strip-lto-bytecode

	if use doc; then
		local HTML_DOCS=( docs/doxygen/html/. )
	fi
	einstalldocs

	if use examples; then
		docompress -x "/usr/share/doc/${PF}/examples"
		dodoc -r examples
	fi
}
