# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..10} )
inherit cmake llvm.org multilib-minimal pax-utils python-any-r1 toolchain-funcs

DESCRIPTION="Low Level Virtual Machine. Includes clang and many other tools"
HOMEPAGE="https://llvm.org/"

# Additional licenses:
# 1. OpenBSD regex: Henry Spencer's license ('rc' in Gentoo) + BSD.
# 2. xxhash: BSD.
# 3. MD5 code: public-domain.
# 4. ConvertUTF.h: TODO.

LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA BSD MIT public-domain rc"
SLOT="$(ver_cut 1)"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~sparc ~x86 ~amd64-linux ~ppc-macos ~x64-macos"
IUSE="asserts benchmark +binutils-plugin bootstrap ccache +clang +compiler-rt cuda debug doc \
	elibc_glibc elibc_musl examples exegesis libedit +libcxx +libunwind +libffi \
	+libfuzzer lldb lto man +memprof +ompt +openmp offload hwloc static-analyzer static-libs \
	-system-libunwind -system-libcxx -system-lld -system-lldb -system-clang -system-compiler-rt \
	-system-polly -system-openmp thinlto ncurses +orc pgo pic +polly +profile test +xray xar xml z3 \
	kernel_Darwin"
SANITIZER_FLAGS=(
	asan dfsan lsan msan hwasan tsan ubsan safestack cfi scudo shadowcallstack gwp-asan
)
IUSE+=" ${SANITIZER_FLAGS[@]/#/+}"
RESTRICT="!test? ( test )"
REQUIRED_USE="
	thinlto? ( clang )
	pgo? ( clang )
	libcxx? ( clang )
	system-openmp? ( openmp )
	system-clang? ( clang )
	system-libcxx? ( libcxx )
	system-compiler-rt? ( clang )
	system-polly? ( polly )
	libunwind? ( libcxx )
	compiler-rt? ( libcxx )
	cuda? ( openmp llvm_targets_NVPTX )
	offload? ( openmp cuda? ( abi_x86_64 ) )
	ompt? ( openmp )
	bootstrap? ( clang !system-libcxx !system-clang !system-lld !system-lldb !system-compiler-rt !system-libunwind !system-openmp )
"
RDEPEND="
	sys-libs/zlib:0=[${MULTILIB_USEDEP}]
	binutils-plugin? ( >=sys-devel/binutils-2.31.1-r4:*[plugins] )
	exegesis? ( dev-libs/libpfm:= )
	libedit? ( dev-libs/libedit:0=[${MULTILIB_USEDEP}] )
	libffi? ( >=dev-libs/libffi-3.0.13-r1:0=[${MULTILIB_USEDEP}] )
	ncurses? ( >=sys-libs/ncurses-5.9-r3:0=[${MULTILIB_USEDEP}] )
	xar? ( app-arch/xar )
	xml? ( dev-libs/libxml2:2=[${MULTILIB_USEDEP}] )
	z3? ( >=sci-mathematics/z3-4.7.1:0=[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}
	binutils-plugin? ( sys-libs/binutils-libs )"
BDEPEND="
	dev-lang/perl
	>=dev-util/cmake-3.16
	sys-devel/gnuconfig
	kernel_Darwin? (
		<sys-libs/libcxx-$(ver_cut 1-3).9999
		>=sys-devel/binutils-apple-5.1
	)
	ccache? ( dev-util/ccache )
	system-clang? ( =sys-devel/clang-${PV}:=[${MULTILIB_USEDEP}] )
	system-compiler-rt? ( =sys-libs/compiler-rt-${PV}:=[${MULTILIB_USEDEP}] )
	system-libcxx? ( =sys-libs/libcxx-${PV}:=[${MULTILIB_USEDEP}] )
	system-libunwind? ( =sys-libs/llvm-libunwind-${PV}:=[static-libs?,${MULTILIB_USEDEP}] )
	system-lld? ( =sys-devel/lld-${PV}:=[${MULTILIB_USEDEP}] )
	system-lldb? ( =dev-util/lldb-${PV}:=[${MULTILIB_USEDEP}] )
	system-openmp? ( =sys-libs/openmp-${PV}:=[${MULTILIB_USEDEP}] )
	system-polly? ( =sys-libs/polly-${PV}:=[${MULTILIB_USEDEP}] )
	doc? ( $(python_gen_any_dep '
		dev-python/recommonmark[${PYTHON_USEDEP}]
		dev-python/sphinx[${PYTHON_USEDEP}]
	') )
	libffi? ( virtual/pkgconfig )
	${PYTHON_DEPS}"
# There are no file collisions between these versions but having :0
# installed means llvm-config there will take precedence.
RDEPEND="${RDEPEND}
	!sys-devel/llvm:0
	openmp? (
		hwloc? ( >=sys-apps/hwloc-2.5:0=[${MULTILIB_USEDEP}] )
		offload? (
			virtual/libelf:=[${MULTILIB_USEDEP}]
			cuda? ( dev-util/nvidia-cuda-toolkit:= )
		)
	)
"
PDEPEND="
	sys-devel/llvm-common
	binutils-plugin? ( >=sys-devel/llvmgold-${SLOT} )
	!system-clang? ( !sys-devel/clang )
	!system-compiler-rt? ( !sys-libs/compiler-rt )
	!system-libcxx? (
		!sys-libs/libcxx
		!sys-libs/libcxxabi
	)
	!system-libunwind? (
		!sys-libs/libunwind
		!sys-libs/llvm-libunwind
	)
	!system-lld? ( !sys-devel/lld )
	!system-openmp? ( !sys-libs/openmp )
	!system-polly? ( !sys-libs/polly )
"

LLVM_COMPONENTS=()
LLVM_TEST_COMPONENTS=( llvm/lib/Testing/Support llvm/utils/unittest )
LLVM_MANPAGES=
#LLVM_PATCHSET=${PV/_/-}
LLVM_PATCHSET=9999-1
LLVM_USE_TARGETS=provide
llvm.org_set_globals

PATCHES=(
	"${FILESDIR}"/13.0.0/0001-llvm-fix-typos-found-by-PVS.patch
	"${FILESDIR}"/13.0.0/disable-bswap-for-spir.patch
)

check_space() {
	if use test; then
		local CHECKREQS_DISK_BUILD=11G
		check-reqs_pkg_pretend
	fi
}

pkg_setup() {
	check_space
	python-any-r1_pkg_setup
    LLVM_COMPONENTS+=( llvm third-party )
	use clang && LLVM_COMPONENTS+=( clang clang-tools-extra )
	(use compiler-rt && use !system-compiler-rt) && LLVM_COMPONENTS+=( compiler-rt )
	(use libcxx && use !system-libcxx) && LLVM_COMPONENTS+=( libcxx{,abi} )
	(use libunwind && use !system-libunwind) && LLVM_COMPONENTS+=( libunwind )
	(use openmp && use !system-openmp) && LLVM_COMPONENTS+=( openmp )
	(use lldb && use !system-lldb) && LLVM_COMPONENTS+=( lldb )
	use system-lld || LLVM_COMPONENTS+=( lld )

}

check_live_ebuild() {
	local prod_targets=(
		$(sed -n -e '/set(LLVM_ALL_TARGETS/,/)/p' CMakeLists.txt \
			| tail -n +2 | head -n -1)
	)
	local all_targets=(
		lib/Target/*/
	)
	all_targets=( "${all_targets[@]#lib/Target/}" )
	all_targets=( "${all_targets[@]%/}" )

	local exp_targets=() i
	for i in "${all_targets[@]}"; do
		has "${i}" "${prod_targets[@]}" || exp_targets+=( "${i}" )
	done

	if [[ ${exp_targets[*]} != ${ALL_LLVM_EXPERIMENTAL_TARGETS[*]} ]]; then
		eqawarn "ALL_LLVM_EXPERIMENTAL_TARGETS is outdated!"
		eqawarn "    Have: ${ALL_LLVM_EXPERIMENTAL_TARGETS[*]}"
		eqawarn "Expected: ${exp_targets[*]}"
		eqawarn
	fi

	if [[ ${prod_targets[*]} != ${ALL_LLVM_PRODUCTION_TARGETS[*]} ]]; then
		eqawarn "ALL_LLVM_PRODUCTION_TARGETS is outdated!"
		eqawarn "    Have: ${ALL_LLVM_PRODUCTION_TARGETS[*]}"
		eqawarn "Expected: ${prod_targets[*]}"
	fi
}

check_distribution_components() {
	if [[ ${CMAKE_MAKEFILE_GENERATOR} == ninja ]]; then
		local all_targets=() my_targets=() l
		cd "${BUILD_DIR}" || die

		while read -r l; do
			if [[ ${l} == install-*-stripped:* ]]; then
				l=${l#install-}
				l=${l%%-stripped*}

				case ${l} in
					# shared libs
					LLVM|LLVMgold)
						;;
					# TableGen lib + deps
					LLVMDemangle|LLVMSupport|LLVMTableGen)
						;;
					# static libs
					LLVM*)
						continue
						;;
					# meta-targets
					distribution|llvm-libraries)
						continue
						;;
					# used only w/ USE=doc
					docs-llvm-html)
						use doc || continue
						;;
				esac

				all_targets+=( "${l}" )
			fi
		done < <(ninja -t targets all)

		while read -r l; do
			my_targets+=( "${l}" )
		done < <(get_distribution_components $"\n")

		local add=() remove=()
		for l in "${all_targets[@]}"; do
			if ! has "${l}" "${my_targets[@]}"; then
				add+=( "${l}" )
			fi
		done
		for l in "${my_targets[@]}"; do
			if ! has "${l}" "${all_targets[@]}"; then
				remove+=( "${l}" )
			fi
		done

		if [[ ${#add[@]} -gt 0 || ${#remove[@]} -gt 0 ]]; then
			eqawarn "get_distribution_components() is outdated!"
			eqawarn "   Add: ${add[*]}"
			eqawarn "Remove: ${remove[*]}"
		fi
		cd - >/dev/null || die
	fi
}

src_prepare() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	(use compiler-rt && use !system-compiler-rt) && sed -i -e 's:-Werror::' ../compiler-rt/lib/tsan/go/buildgo.sh || die

	local flag
	for flag in "${SANITIZER_FLAGS[@]}"; do
		if ! use "${flag}"; then
			local cmake_flag=${flag/-/_}
			sed -i -e "/COMPILER_RT_HAS_${cmake_flag^^}/s:TRUE:FALSE:" \
				cmake/config-ix.cmake || die
		fi
	done

	# TODO: fix these tests to be skipped upstream
	if use asan && ! use profile; then
		rm test/asan/TestCases/asan_and_llvm_coverage_test.cpp || die
	fi
	if use ubsan && ! use cfi; then
		> test/cfi/CMakeLists.txt || die
	fi

	# disable use of SDK on OSX, bug #568758
	sed -i -e 's/xcrun/false/' utils/lit/lit/util.py || die

	# Update config.guess to support more systems
	cp "${BROOT}/usr/share/gnuconfig/config.guess" cmake/ || die

	# Verify that the live ebuild is up-to-date
	check_live_ebuild

	llvm.org_src_prepare
}

# Is LLVM being linked against libc++?
is_libcxx_linked() {
	local code='#include <ciso646>
#if defined(_LIBCPP_VERSION)
	HAVE_LIBCXX
#endif
'
	local out=$($(tc-getCXX) ${CXXFLAGS} ${CPPFLAGS} -x c++ -E -P - <<<"${code}") || return 1

	[[ ${out} == *HAVE_LIBCXX* ]]
}

get_distribution_components() {
	local sep=${1-;}

	local out=(
		# shared libs
		LLVM
		LTO
		Remarks

		# tools
		llvm-config

		# common stuff
		cmake-exports
		llvm-headers

		# libraries needed for clang-tblgen
		LLVMDemangle
		LLVMSupport
		LLVMTableGen
	)

	use clang && out+=(
		# common stuff
		clang-cmake-exports
		clang-headers
		clang-resource-headers
		libclang-headers

		# libs
		clang-cpp
		libclang
	)

	if multilib_is_native_abi; then
		out+=(
			# utilities
			llvm-tblgen
			FileCheck
			llvm-PerfectShuffle
			count
			not
			yaml-bench

			# tools
			bugpoint
			dsymutil
			llc
			lli
			lli-child-target
			llvm-addr2line
			llvm-ar
			llvm-as
			llvm-bcanalyzer
			llvm-bitcode-strip
			llvm-c-test
			llvm-cat
			llvm-cfi-verify
			llvm-config
			llvm-cov
			llvm-cvtres
			llvm-cxxdump
			llvm-cxxfilt
			llvm-cxxmap
			llvm-diff
			llvm-dis
			llvm-dlltool
			llvm-dwarfdump
			llvm-dwp
			llvm-exegesis
			llvm-extract
			llvm-gsymutil
			llvm-ifs
			llvm-install-name-tool
			llvm-jitlink
			llvm-jitlink-executor
			llvm-lib
			llvm-libtool-darwin
			llvm-link
			llvm-lipo
			llvm-lto
			llvm-lto2
			llvm-mc
			llvm-mca
			llvm-ml
			llvm-modextract
			llvm-mt
			llvm-nm
			llvm-objcopy
			llvm-objdump
			llvm-opt-report
			llvm-otool
			llvm-pdbutil
			llvm-profdata
			llvm-profgen
			llvm-ranlib
			llvm-rc
			llvm-readelf
			llvm-readobj
			llvm-reduce
			llvm-rtdyld
			llvm-sim
			llvm-size
			llvm-split
			llvm-stress
			llvm-strings
			llvm-strip
			llvm-symbolizer
			llvm-tapi-diff
			llvm-undname
			llvm-windres
			llvm-xray
			obj2yaml
			opt
			sancov
			sanstats
			split-file
			verify-uselistorder
			yaml2obj

			# python modules
			opt-viewer
		)

		use man && out+=(
			# manpages
			docs-dsymutil-man
			docs-llvm-dwarfdump-man
			docs-llvm-man
		)

		use doc && out+=(
			docs-llvm-html
		)

		use binutils-plugin && out+=(
			LLVMgold
		)

		use clang && out+=(
			# common stuff
			bash-autocomplete
			libclang-python-bindings

			# tools
			c-index-test
			clang
			clang-format
			clang-offload-bundler
			clang-offload-wrapper
			clang-refactor
			clang-rename
			clang-scan-deps
			diagtool
			hmaptool

			# extra tools
			clang-apply-replacements
			clang-change-namespace
			clang-doc
			clang-include-fixer
			clang-move
			clang-query
			clang-reorder-fields
			clang-tidy
			clangd
			find-all-symbols
			modularize
			pp-trace
		)

		use clang && use man &&	out+=(
			# manpages
			docs-clang-man
			docs-clang-tools-man
		)

		use clang && use doc && out+=(
			docs-clang-html
			docs-clang-tools-html
		)

		use static-analyzer && out+=(
			clang-check
			clang-extdef-mapping
			scan-build
			scan-build-py
			scan-view
		)

	fi

	printf "%s${sep}" "${out[@]}"
}

multilib_src_configure() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup
	CMAKE_BUILD_TYPE=$(usex debug Debug Release)

	local nolib_flags=( -nodefaultlibs -lc )
	if use clang; then
		local -x CC=${CHOST}-clang
		local -x CXX=${CHOST}-clang++
		strip-unsupported-flags
		# ensure we can use clang before installing compiler-rt
		local -x LDFLAGS="${LDFLAGS} ${nolib_flags[*]}"
	elif ! test_compiler; then
		if test_compiler "${nolib_flags[@]}"; then
			local -x LDFLAGS="${LDFLAGS} ${nolib_flags[*]}"
			ewarn "${CC} seems to lack runtime, trying with ${nolib_flags[*]}"
		fi
	fi

	local flag want_sanitizer=OFF
	for flag in "${SANITIZER_FLAGS[@]}"; do
		use "${flag}" && ( want_sanitizer=ON; break	)
	done

	local ffi_cflags ffi_ldflags
	use libffi && (
		ffi_cflags="$($(tc-getPKG_CONFIG) --cflags-only-I libffi)";
		ffi_ldflags="$($(tc-getPKG_CONFIG) --libs-only-L --keep-system-libs libffi)"
	)

	local libdir=$(get_libdir)

	local mycmakeargs=(
		# disable appending VCS revision to the version to improve
		# direct cache hit ratio
		-DLLVM_APPEND_VC_REV=OFF
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/lib/llvm/${SLOT}"
		-DLLVM_LIBDIR_SUFFIX=${libdir#lib}

		-DBUILD_SHARED_LIBS=OFF
		-DLLVM_BUILD_LLVM_DYLIB=ON
		-DLLVM_LINK_LLVM_DYLIB=$(usex !static-libs)
		-DLLVM_DISTRIBUTION_COMPONENTS=$(get_distribution_components)
		-DLLVM_USE_RELATIVE_PATHS_IN_FILES=ON
		-DLLVM_ABI_BREAKING_CHECKS=FORCE_ON
		-DLLVM_PARALLEL_LINK_JOBS=1
		-DLLVM_USE_NEWPM=$(usex clang) # Turn on new pass manager for LLVM
		-DLLVM_ENABLE_EXPENSIVE_CHECKS=OFF
		-DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON # Bypass warning about old gcc
		-DLLVM_USE_SPLIT_DWARF=ON

		# cheap hack: LLVM combines both anyway, and the only difference
		# is that the former list is explicitly verified at cmake time
		-DLLVM_TARGETS_TO_BUILD=""
		-DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="${LLVM_TARGETS// /;}"
		-DLLVM_BUILD_TESTS=$(usex test)
		-DLLVM_INCLUDE_TESTS=$(usex test)
		-DLLVM_BUILD_EXAMPLES=$(usex examples)
		-DLLVM_INCLUDE_EXAMPLES=$(usex examples)
		-DLLVM_BUILD_BENCHMARKS=$(usex benchmark)
		-DLLVM_INCLUDE_BENCHMARKS=$(usex benchmark)

		-DLLVM_ENABLE_FFI=$(usex libffi)
		-DLLVM_ENABLE_LIBEDIT=$(usex libedit)
		-DLLVM_ENABLE_TERMINFO=$(usex ncurses)
		-DLLVM_ENABLE_LIBXML2=$(usex xml)
		-DLLVM_ENABLE_ASSERTIONS=$(usex asserts)
		-DLLVM_ENABLE_LIBPFM=$(usex exegesis)
		-DLLVM_ENABLE_EH=ON
		-DLLVM_ENABLE_RTTI=ON
		-DLLVM_ENABLE_Z3_SOLVER=$(usex z3)

		-DLLVM_HOST_TRIPLE="${CHOST}"

		-DFFI_INCLUDE_DIR="${ffi_cflags#-I}"
		-DFFI_LIBRARY_DIR="${ffi_ldflags#-L}"
		# used only for llvm-objdump tool
		-DLLVM_HAVE_LIBXAR=$(multilib_native_usex xar 1 0)

		-DPython3_EXECUTABLE="${PYTHON}"

		# disable OCaml bindings (now in dev-ml/llvm-ocaml)
		-DLLVM_ENABLE_BINDINGS=OFF
		-DOCAMLFIND=NO

		-DLLVM_ENABLE_LIBCXX=$(usex libcxx ON OFF)
		-DLLVM_USE_LINKER=lld
		-DLLVM_ENABLE_LLD=ON
		-DLLVM_ENABLE_LTO=$(usex lto $(usex clang $(usex thinlto "Thin" "Full") OFF) "")
		#-DLLVM_BUILD_INSTRUMENTED=$(usex pgo IR NO)
		#-DLLVM_PROFDATA_FILE="${WORKDIR}/llvm.profdata"
		-DLLVM_OPTIMIZED_TABLEGEN=$(usex debug ON OFF)
		-DLLVM_ENABLE_PIC=$(usex pic ON OFF)
		-DLLVM_CCACHE_BUILD=$(usex ccache ON OFF)
		-DCLANG_ENABLE_BOOTSTRAP=$(usex bootstrap ON OFF)
		-DCLANG_BOOTSTRAP_PASSTHROUGH=$(usex bootstrap ON OFF)
		#-DBOOTSTRAP_CMAKE_CXX_FLAGS
		#-DBOOTSTRAP_CMAKE_C_FLAGS
	)

	use system-compiler-rt || mycmakeargs+=(
		-DCOMPILER_RT_INSTALL_PATH="${EPREFIX}/usr/lib/clang/${SLOT}"
		# use a build dir structure consistent with install
		# this makes it possible to easily deploy test-friendly clang
		-DCOMPILER_RT_OUTPUT_DIR="${BUILD_DIR}/lib/clang/${SLOT}"
		-DCOMPILER_RT_INCLUDE_TESTS=$(usex test)
		-DCOMPILER_RT_BUILD_BUILTINS=ON
		-DCOMPILER_RT_BUILD_CRT=ON
		-DCOMPILER_RT_BUILD_LIBFUZZER=$(usex libfuzzer)
		-DCOMPILER_RT_BUILD_MEMPROF=$(usex memprof)
		-DCOMPILER_RT_BUILD_ORC=$(usex orc)
		-DCOMPILER_RT_BUILD_PROFILE=$(usex profile)
		-DCOMPILER_RT_BUILD_SANITIZERS="${want_sanitizer}"
		-DCOMPILER_RT_BUILD_XRAY=$(usex xray)
		# By default do not enable PGO for compiler-rt
		-DCOMPILER_RT_ENABLE_PGO=OFF
		-DCOMPILER_RT_BUILTINS_HIDE_SYMBOLS=OFF
	)

	use system-libcxx && mycmakeargs+=(
		-DCOMPILER_RT_LIBCXXABI_PATH=${S}/libcxxabi
		-DCOMPILER_RT_LIBCXX_PATH=${S}/libcxx
	) || ( use libcxx && mycmakeargs+=(
		-DCOMPILER_RT_LIBCXXABI_PATH=${S}/libcxxabi
		-DCOMPILER_RT_LIBCXX_PATH=${S}/libcxx
		-DLIBCXX_LIBDIR_SUFFIX=${libdir#lib}
		-DLIBCXX_ENABLE_SHARED=ON
		-DLIBCXX_ENABLE_STATIC=$(usex static-libs)
		-DLIBCXX_CXX_ABI=libcxxabi
		-DLIBCXX_CXX_ABI_INCLUDE_PATHS=${cxxabi_incs}
		# we're using our own mechanism for generating linker scripts
		-DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=OFF
		-DLIBCXX_HAS_MUSL_LIBC=$(usex elibc_musl)
		-DLIBCXX_HAS_GCC_S_LIB=OFF
		-DLIBCXX_USE_COMPILER_RT=ON
		-DLIBCXX_INCLUDE_TESTS=$(usex test)
		-DLIBCXX_HAS_ATOMIC_LIB=OFF
		-DLIBCXX_TARGET_TRIPLE="${CHOST}"
		-DLIBCXXABI_USE_LLVM_UNWINDER=$(usex libunwind)
		-DLIBCXXABI_LIBDIR_SUFFIX=${libdir#lib}
		-DLIBCXXABI_ENABLE_SHARED=ON
		-DLIBCXXABI_ENABLE_STATIC=$(usex static-libs)
		-DLIBCXXABI_INCLUDE_TESTS=$(usex test)
		-DLIBCXXABI_USE_COMPILER_RT=ON
		-DLIBCXXABI_LIBCXX_INCLUDES="${BUILD_DIR}"/libcxx/include/c++/v1
		# upstream is omitting standard search path for this
		# probably because gcc & clang are bundling their own unwind.h
		-DLIBCXXABI_LIBUNWIND_INCLUDES="${EPREFIX}"/usr/include
		-DLIBCXXABI_TARGET_TRIPLE="${CHOST}"
	))

	use libunwind && mycmakeargs+=(
		-DLIBUNWIND_ENABLE_ASSERTIONS=$(usex debug)
		-DLIBUNWIND_ENABLE_STATIC=$(usex static-libs)
		-DLIBUNWIND_TARGET_TRIPLE="${CHOST}"

		# support non-native unwinding; given it's small enough,
		# enable it unconditionally
		-DLIBUNWIND_ENABLE_CROSS_UNWINDING=ON

		# avoid dependency on libgcc_s if compiler-rt is used
		-DLIBUNWIND_USE_COMPILER_RT=$(usex clang)
	)

	use openmp && mycmakeargs+=(
		-DOPENMP_LIBDIR_SUFFIX="${libdir#lib}"
		-DLIBOMP_USE_HWLOC=$(usex hwloc)
		-DLIBOMP_OMPT_SUPPORT=$(usex ompt)
		-DOPENMP_ENABLE_LIBOMPTARGET=$(usex offload)

		# do not install libgomp.so & libiomp5.so aliases
		-DLIBOMP_INSTALL_ALIASES=OFF
		# disable unnecessary hack copying stuff back to srcdir
		-DLIBOMP_COPY_EXPORTS=OFF
	)

	use polly && mycmakeargs+=(
		-DPOLLY_ENABLE_GPGPU_CODEGEN=$(usex cuda)
	)

#	Note: go bindings have no CMake rules at the moment
#	but let's kill the check in case they are introduced
#	if ! multilib_is_native_abi || ! use go; then
		mycmakeargs+=(
			-DGO_EXECUTABLE=GO_EXECUTABLE-NOTFOUND
		)
#	fi

	use test && mycmakeargs+=(
		-DLLVM_EXTERNAL_LIT="${EPREFIX}/usr/bin/lit"
		-DLLVM_LIT_ARGS="$(get_lit_flags)"

		-DCOMPILER_RT_TEST_COMPILER="${EPREFIX}/usr/lib/llvm/${CLANG_SLOT}/bin/clang"
		-DCOMPILER_RT_TEST_CXX_COMPILER="${EPREFIX}/usr/lib/llvm/${CLANG_SLOT}/bin/clang++"
	)

	if multilib_is_native_abi; then
		use man || mycmakeargs+=(
			-DCMAKE_INSTALL_MANDIR="${EPREFIX}/usr/lib/llvm/${SLOT}/share/man"
		)

		mycmakeargs+=(
			-DSPHINX_WARNINGS_AS_ERRORS=OFF
			-DLLVM_INSTALL_SPHINX_HTML_DIR="${EPREFIX}/usr/share/doc/${PF}/html"
			-DLLVM_BUILD_DOCS=$(usex doc ON OFF)
			-DLLVM_ENABLE_OCAMLDOC=OFF
			-DLLVM_ENABLE_SPHINX=$(usex doc ON OFF)
			-DLLVM_ENABLE_DOXYGEN=OFF
			-DLLVM_INSTALL_UTILS=ON
		)

		use binutils-plugin && mycmakeargs+=(
			-DLLVM_BINUTILS_INCDIR="${EPREFIX}"/usr/include
		)
	fi

	if tc-is-cross-compiler; then
		local tblgen="${EPREFIX}/usr/lib/llvm/${SLOT}/bin/llvm-tblgen"
		[[ -x "${tblgen}" ]] \
			|| die "${tblgen} not found or usable"
		mycmakeargs+=(
			-DCMAKE_CROSSCOMPILING=ON
			-DLLVM_TABLEGEN="${tblgen}"
		)
	fi

	# workaround BMI bug in gcc-7 (fixed in 7.4)
	# https://bugs.gentoo.org/649880
	# apply only to x86, https://bugs.gentoo.org/650506
	if tc-is-gcc && [[ ${MULTILIB_ABI_FLAG} == abi_x86* ]] &&
			[[ $(gcc-major-version) -eq 7 && $(gcc-minor-version) -lt 4 ]]
	then
		local CFLAGS="${CFLAGS} -mno-bmi"
		local CXXFLAGS="${CXXFLAGS} -mno-bmi"
	fi

	# LLVM can have very high memory consumption while linking,
	# exhausting the limit on 32-bit linker executable
	use x86 && local -x LDFLAGS="${LDFLAGS} -Wl,--no-keep-memory"

	# LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us, #614844
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"
	cmake_src_configure

	multilib_is_native_abi && check_distribution_components
}

multilib_src_compile() {
	use bootstrap && (
		use pgo && cmake_build stage2-instrumented stage2-instrumented-generate-profdata stage2
	) || (
		cmake_build distribution
	)

	pax-mark m "${BUILD_DIR}"/bin/llvm-rtdyld
	pax-mark m "${BUILD_DIR}"/bin/lli
	pax-mark m "${BUILD_DIR}"/bin/lli-child-target

	use test && (
		pax-mark m "${BUILD_DIR}"/unittests/ExecutionEngine/Orc/OrcJITTests
		pax-mark m "${BUILD_DIR}"/unittests/ExecutionEngine/MCJIT/MCJITTests
		pax-mark m "${BUILD_DIR}"/unittests/Support/SupportTests
	)
}

multilib_src_test() {
	# respect TMPDIR!
	local -x LIT_PRESERVES_TMP=1
	# disable sandbox to have it stop clobbering LD_PRELOAD
	local -x SANDBOX_ON=0
	# wipe LD_PRELOAD to make ASAN happy
	local -x LD_PRELOAD=

	cmake_build check
	use libcxx && (
		use !system-compiler-rt && cmake_build check-builtins
		use !system-libcxx && cmake_build check-cxx check-cxxabi
	)
	use libunwind && (
		use !system-libunwind cmake_build check-unwind
	)

}

src_install() {
	local MULTILIB_CHOST_TOOLS=(
		/usr/lib/llvm/${SLOT}/bin/llvm-config
	)

	local MULTILIB_WRAPPED_HEADERS=(
		/usr/include/llvm/Config/llvm-config.h
	)

	local LLVM_LDPATHS=()
	multilib-minimal_src_install

	# move wrapped headers back
	mv "${ED}"/usr/include "${ED}"/usr/lib/llvm/${SLOT}/include || die

	# install headers like sys-libs/libunwind
	use libunwind && doheader "${S}"/libunwind/include/*.h

}

multilib_src_install() {
	DESTDIR=${D} cmake_build install-distribution

	# move headers to /usr/include for wrapping
	rm -rf "${ED}"/usr/include || die
	mv "${ED}"/usr/lib/llvm/${SLOT}/include "${ED}"/usr/include || die

	LLVM_LDPATHS+=( "${EPREFIX}/usr/lib/llvm/${SLOT}/$(get_libdir)" )
}

multilib_src_install_all() {
	local revord=$(( 9999 - ${SLOT} ))
	newenvd - "60llvm-${revord}" <<-_EOF_
		PATH="${EPREFIX}/usr/lib/llvm/${SLOT}/bin"
		# we need to duplicate it in ROOTPATH for Portage to respect...
		ROOTPATH="${EPREFIX}/usr/lib/llvm/${SLOT}/bin"
		MANPATH="${EPREFIX}/usr/lib/llvm/${SLOT}/share/man"
		LDPATH="$( IFS=:; echo "${LLVM_LDPATHS[*]}" )"
	_EOF_

	use man && (
		docompress "/usr/lib/llvm/${SLOT}/share/man"
		insinto "/usr/lib/llvm/${SLOT}/share/man/man1"
		doins "${WORKDIR}/llvm-${PV}-manpages/${LLVM_COMPONENTS[0]}"/*.1
	)
}

pkg_postinst() {
	elog "You can find additional opt-viewer utility scripts in:"
	elog "  ${EROOT}/usr/lib/llvm/${SLOT}/share/opt-viewer"
	elog "To use these scripts, you will need Python along with the following"
	elog "packages:"
	elog "  dev-python/pygments (for opt-viewer)"
	elog "  dev-python/pyyaml (for all of them)"
}
