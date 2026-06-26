# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION="6.0.2"

PYTHON_COMPAT=( python3_{12..15} )

inherit cargo edo git-r3 rocm python-any-r1

#MY_PV="${PV//_pre/-preview.}"

DESCRIPTION="Open nVidia CUDA replacement"
HOMEPAGE="https://github.com/vosen/ZLUDA"

EGIT_REPO_URI="https://github.com/vosen/ZLUDA.git"
EGIT_SUBMODULES=( '*' )
EGIT_LFS="yes"

SLOT="0"

# cargo fetches the entire workspace's dependency tree on first build; the
# kokoros / lemonade live ebuilds in this overlay use the same exception.
PROPERTIES="live"
RESTRICT="network-sandbox test"

LICENSE="BSD"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 ISC MIT MPL-2.0 Unicode-3.0
	Unicode-DFS-2016 ZLIB
"
#KEYWORDS="~amd64"
IUSE="blas blaslt bindgen zoc dark-api detours dnn fft ld ml ptx ptxas rocm sparse test trace"

RDEPEND="
	dev-util/hip
	dev-util/hipify-clang
	dev-util/rocm-smi:${SLOT}
"
DEPEND="${RDEPEND}"
BDEPEND="
	|| ( >=dev-lang/rust-1.85 >=dev-lang/rust-bin-1.85 )
	${PYTHON_DEPS}
	>=dev-build/cmake-3.22
	>=dev-build/rocm-cmake-5.0.2-r1
	test? ( dev-cpp/gtest )
	virtual/pkgconfig
"

RESTRICT="!test? ( test ) mirror"
#S="${WORKDIR}/rccl-rocm-${PV}"
#S="${WORKDIR}/${PN^^}-${MY_PV}"

PATCHES=(
#	"${FILESDIR}"/zluda-6.0.2-rocm-version.patch
)

pkg_setup() {
	#export CC="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/clang" CXX="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/clang++"
	tc-is-clang || die "Clang required"
	strip-unsupported-flags

	addpredict /dev/kfd
	addpredict /dev/dri/

	rust_pkg_setup
}

src_configure() {
	local myfeatures=(
		$(usev test)
	)

	AMDGPU_TARGETS="$(get_amdgpu_flags)"
	ROCM_VERSION=${ROCM_VERSION} CXX=hipcc
	cargo_src_configure --no-default-features --frozen
}

src_compile() {
    # Build only specific crate(s) instead of all default members
    local build_type=$(usex debug --debug --release)

	cargo xtask ${build_type} || die "cargo xtask --release failed"

    use detours && cargo build -p detours-sys ${build_type}
    use dark-api && cargo build -p dark_api ${build_type}
    if use rocm; then
    	cargo build -p cuda_types ${build_type}
    	cargo build ext/highs-sys ${build_type}
    	cargo build ext/hip_runtime-sys ${build_type}
    	cargo build ext/miopen-sys ${build_type}
    	use blaslt && cargo build ext/hipblaslt-sys ${build_type}
    	use blas && cargo build ext/rocblas-sys ${build_type}
    fi
    if use ptx ; then
    	cargo build -p ptx_parser ${build_type}
    	cargo build -p ptx ${build_type}
    	cargo build -p ptxas ${build_type}
    	cargo build -p ptx_parser_macros_impl ${build_type}
    	cargo build -p ptx_parser_macros ${build_type}
    fi
    use fft && cargo build -p zluda_fft ${build_type}
    use ml && cargo build -p zluda_ml ${build_type}
    use ld && cargo build -p zluda_ld ${build_type}
    use blas && cargo build -p zluda_blas ${build_type}
	use blaslt && cargo build -p zluda_blaslt ${build_type}
	if use dnn ; then
		cargo build -p zluda_dnn ${build_type}
    	cargo build -p zluda_dnn8 ${build_type}
    	cargo build -p zluda_dnn9 ${build_type}
	fi
    use zoc && cargo build -p compiler ${build_type}
    use sparce && cargo build -p zluda_sparse ${build_type}
    if use trace; then
    	cargo build -p zluda_trace ${build_type}
		cargo build -p zluda_trace_common ${build_type}
    	use sparse && cargo build -p zluda_trace_sparse ${build_type}
    	use ml && cargo build -p zluda_trace_nvml ${build_type}
		use dnn && cargo build -p zluda_trace_dnn8 ${build_type}
		use dnn && cargo build -p zluda_trace_dnn9 ${build_type}
		use fft && cargo build -p zluda_trace_fft ${build_type}
		use blas && cargo build -p zluda_trace_blas ${build_type}
		use blaslt && cargo build -p zluda_trace_blaslt ${build_type}
    fi
}

src_install() {
    cargo_src_install
    rm -rf "${ED}"/usr/${PN} || die
}

src_test() {
	check_amdgpu
	LD_LIBRARY_PATH="${BUILD_DIR}" edob test/UnitTests
}

pkg_postinst() {
	elog ""
	elog "ZLUDA installed under /opt/zluda/."
	elog ""
	elog "Run a CUDA application against ZLUDA:"
	elog "  LD_LIBRARY_PATH=/opt/zluda:\${LD_LIBRARY_PATH} <APP>"
	elog ""
	elog "or via the LD_AUDIT entry point:"
	elog "  LD_AUDIT=/opt/zluda/zluda_ld <APP>"
	elog ""
	elog "ZLUDA targets AMD GPUs only — requires a working ROCm/HIP runtime"
	elog "(dev-util/hip) and a supported AMD GPU. Upstream warns the project"
	elog "is under heavy development and may not yet work for your CUDA app."
	elog ""
	elog "Live ebuild — rebuild via: emerge --oneshot =dev-util/zluda-9999"
}
