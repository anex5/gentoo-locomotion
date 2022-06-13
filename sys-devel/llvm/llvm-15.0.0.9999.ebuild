# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
inherit git-r3 cmake flag-o-matic multilib-minimal pax-utils python-any-r1 toolchain-funcs

DESCRIPTION="Low Level Virtual Machine. Includes clang and many other tools"
HOMEPAGE="https://llvm.org/"

EGIT_REPO_URI="https://github.com/llvm/llvm-project"
EGIT_BRANCH="main"

LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA BSD MIT public-domain rc"
SLOT="$(ver_cut 1)"
#KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~sparc ~x86 ~amd64-linux ~ppc-macos ~x64-macos"
IUSE_PROJECTS="clang clang-tools-extra cross-project-tests flang libc libclc lld lldb mlir openmp polly pstl"
IUSE_RTLIBS="libcxx libcxxabi libunwind compiler-rt libc libomp"
IUSE="asserts benchmark +binutils-plugin bootstrap ccache cuda debug doc elibc_glibc elibc_musl \
	examples exegesis libedit +libffi +libfuzzer lto man +memprof +ompt offload ocaml hwloc \
	static-analyzer static-libs -system-lld +thinlto ncurses +orc pgo pic +profile test +xray xar xml z3"

SANITIZER_FLAGS=(
	asan dfsan lsan msan hwasan tsan ubsan safestack cfi scudo shadowcallstack gwp-asan
)
ALL_LLVM_EXPERIMENTAL_TARGETS=( ARC CSKY LoongArch M68k )
ALL_LLVM_PRODUCTION_TARGETS=(
	AArch64 AMDGPU ARM AVR BPF Hexagon Lanai Mips MSP430 NVPTX
	PowerPC RISCV Sparc SystemZ VE WebAssembly X86 XCore
)
ALL_LLVM_TARGET_FLAGS=(
	"${ALL_LLVM_PRODUCTION_TARGETS[@]/#/llvm_targets_}"
	"${ALL_LLVM_EXPERIMENTAL_TARGETS[@]/#/llvm_targets_}"
)

IUSE+=" ${ALL_LLVM_TARGET_FLAGS[@]/#/+} ${IUSE_RTLIBS/#/+} ${IUSE_PROJECTS/#/+} ${SANITIZER_FLAGS[@]/#/+}"
RESTRICT="!test? ( test )"
REQUIRED_USE="
	thinlto? ( lto )
	pgo? ( lto )
	libcxx? ( clang )
	libunwind? ( libcxx )
	compiler-rt? ( libcxx )
	cuda? ( openmp llvm_targets_NVPTX )
	offload? ( openmp cuda? ( abi_x86_64 ) )
	ompt? ( openmp )
	bootstrap? ( clang )
"
CDEPEND="
	sys-libs/zlib:0=[${MULTILIB_USEDEP}]
	binutils-plugin? ( >=sys-devel/binutils-2.31.1-r4:*[plugins] )
	exegesis? ( dev-libs/libpfm:= )
	libedit? ( dev-libs/libedit:0=[${MULTILIB_USEDEP}] )
	libffi? ( >=dev-libs/libffi-3.0.13-r1:0=[${MULTILIB_USEDEP}] )
	ncurses? ( >=sys-libs/ncurses-5.9-r3:0=[${MULTILIB_USEDEP}] )
	ocaml? (
		>=dev-lang/ocaml-4.00.0:0=
		dev-ml/findlib
		dev-ml/ocaml-ctypes
	)
	xar? ( app-arch/xar )
	xml? ( dev-libs/libxml2:2=[${MULTILIB_USEDEP}] )
	z3? ( >=sci-mathematics/z3-4.7.1:0=[${MULTILIB_USEDEP}] )"
DEPEND="${CDEPEND}
	binutils-plugin? ( sys-libs/binutils-libs )
	sys-devel/binutils
	ocaml? ( test? ( dev-ml/ounit ) )
"
BDEPEND="
	dev-lang/perl
	libffi? ( virtual/pkgconfig )
	sys-devel/gnuconfig
	ccache? ( dev-util/ccache )
	doc? ( $(python_gen_any_dep '
		dev-python/recommonmark[${PYTHON_USEDEP}]
		dev-python/sphinx[${PYTHON_USEDEP}]
	') )
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
	!sys-devel/clang
	!sys-libs/compiler-rt
	!sys-libs/libcxx
	!sys-libs/libcxxabi
	!sys-libs/libunwind
	!sys-libs/llvm-libunwind
	!sys-devel/lld
	!sys-libs/openmp
	!sys-libs/polly
"

PATCHES=(
	"${FILESDIR}"/13.0.0/disable-bswap-for-spir.patch
)

check_space() {
	if use test; then
		local CHECKREQS_DISK_BUILD=11G
		check-reqs_pkg_pretend
	fi
}

get_llvm_projects() {
	for PROJ in ${IUSE_PROJECTS}; do
		use ${PROJ} && LLVM_PROJ+="${PROJ};"
	done
	echo ${LLVM_PROJ::-1}
}

pkg_setup() {
	check_space
	python-any-r1_pkg_setup
}

src_unpack() {
	export CMAKE_USE_DIR="${S}/llvm"

	git-r3_src_unpack

	#if apply_pgo_profile; then
	#	cd "${WORKDIR}" || die
	#	local profile_hash
	#	if use llvm-next; then
	#		profile_hash="${LLVM_NEXT_HASH}"
	#	else
	#		profile_hash="${LLVM_HASH}"
	#	fi
	#	unpack "llvm-profdata-${profile_hash}.tar.xz"
	#fi
}


src_prepare() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	use compiler-rt && ( sed -i -e 's:-Werror::' ../compiler-rt/lib/tsan/go/buildgo.sh || die )

	use cuda && addpredict /dev/nvidiactl

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

	# Update config.guess to support more systems
	cp "${BROOT}/usr/share/gnuconfig/config.guess" cmake/ || die

	cmake_src_prepare
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
		use "${flag}" && want_sanitizer=ON; break
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
		-DLLVM_ENABLE_PROJECTS=$(get_llvm_projects)
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
		-DLLVM_USE_LINKER=$(usex system-lld lld "")
		-DLLVM_ENABLE_LLD=$(usex lld ON OFF)
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

	use compiler-rt && mycmakeargs+=(
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

	use libcxx && mycmakeargs+=(
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
	)

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
}

multilib_src_compile() {
	use bootstrap && (
		use pgo && cmake_build stage2-instrumented stage2-instrumented-generate-profdata stage2
	) || (
		cmake_src_compile
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
		/usr/include/llvm/Config/config.h
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
	cmake_src_install

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
	if has_version ">=dev-util/ccache-3.1.9-r2" ; then
		#add ccache links as clang might get installed after ccache
		"${EROOT}"/usr/bin/ccache-config --install-links
	fi
}

pkg_postrm() {
	if has_version ">=dev-util/ccache-3.1.9-r2" && [[ -z ${REPLACED_BY_VERSION} ]]; then
		# --remove-links would remove all links, --install-links updates them
		"${EROOT}"/usr/bin/ccache-config --install-links
	fi
}
