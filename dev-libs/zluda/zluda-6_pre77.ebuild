# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION="6.0.2"

CRATES="
	adler2@2.0.0
	ahash@0.8.12
	aho-corasick@1.1.3
	alloca@0.4.0
	allocator-api2@0.2.21
	anyhow@1.0.98
	arbitrary@1.4.1
	arc-swap@1.7.1
	argh@0.1.12
	argh_derive@0.1.12
	argh_shared@0.1.12
	arrayref@0.3.9
	arrayvec@0.7.6
	autocfg@1.4.0
	beef@0.5.2
	bindgen@0.70.1
	bindgen@0.71.1
	bit-vec@0.8.0
	bitflags@1.3.2
	bitflags@2.9.1
	blake3@1.8.2
	block-buffer@0.10.4
	bpaf@0.9.19
	bpaf_derive@0.5.17
	bstr@1.12.0
	bumpalo@3.17.0
	bytecheck@0.8.2
	bytecheck_derive@0.8.2
	bytemuck@1.25.0
	bytemuck_derive@1.10.2
	byteorder@1.5.0
	bytes@1.11.1
	camino@1.1.9
	candle-core@0.9.2
	cargo-platform@0.1.9
	cargo_metadata@0.19.1
	cc@1.2.55
	cexpr@0.6.0
	cfg-if@1.0.0
	cglue-gen@0.3.2
	cglue-macro@0.3.1
	cglue@0.3.5
	clang-sys@1.8.1
	clru@0.6.2
	cmake@0.1.54
	console@0.16.1
	constant_time_eq@0.3.1
	convert_case@0.6.0
	cpufeatures@0.2.17
	crc32fast@1.5.0
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.21
	crunchy@0.2.4
	crypto-common@0.1.6
	darling@0.20.11
	darling_core@0.20.11
	darling_macro@0.20.11
	dashmap@6.1.0
	deranged@0.4.0
	derivative@2.2.0
	derive_arbitrary@1.4.1
	derive_builder@0.20.2
	derive_builder_core@0.20.2
	derive_builder_macro@0.20.2
	derive_more-impl@1.0.0
	derive_more@1.0.0
	diesel@2.2.12
	diesel_derives@2.2.7
	diesel_migrations@2.2.0
	diesel_table_macro_syntax@0.2.0
	diff@0.1.13
	digest@0.10.7
	dirs-sys@0.5.0
	dirs@6.0.0
	displaydoc@0.2.5
	dsl_auto_type@0.1.3
	dtor-proc-macro@0.0.6
	dtor@0.0.7
	dunce@1.0.5
	dyn-stack-macros@0.1.3
	dyn-stack@0.13.2
	dynasm@1.2.3
	dynasmrt@1.2.3
	either@1.13.0
	embed-resource@3.0.6
	encode_unicode@1.0.0
	encoding_rs@0.8.35
	enum-as-inner@0.6.1
	equivalent@1.0.1
	errno@0.3.11
	faster-hex@0.10.0
	faster-hex@0.9.0
	fastrand@2.1.1
	filetime@0.2.25
	find-msvc-tools@0.1.9
	fixedbitset@0.5.7
	flate2@1.1.1
	float8@0.6.1
	fnv@1.0.7
	foldhash@0.1.5
	foldhash@0.2.0
	form_urlencoded@1.2.1
	gemm-c32@0.19.0
	gemm-c64@0.19.0
	gemm-common@0.19.0
	gemm-f16@0.19.0
	gemm-f32@0.19.0
	gemm-f64@0.19.0
	gemm@0.19.0
	generic-array@0.14.7
	getrandom@0.2.16
	getrandom@0.3.3
	gix-actor@0.34.0
	gix-attributes@0.25.0
	gix-bitmap@0.2.14
	gix-chunk@0.4.11
	gix-command@0.5.0
	gix-commitgraph@0.27.0
	gix-config-value@0.14.12
	gix-config@0.44.0
	gix-date@0.9.4
	gix-diff@0.51.0
	gix-dir@0.13.0
	gix-discover@0.39.0
	gix-features@0.41.1
	gix-features@0.42.1
	gix-filter@0.18.0
	gix-fs@0.14.0
	gix-fs@0.15.0
	gix-glob@0.19.0
	gix-hash@0.17.0
	gix-hash@0.18.0
	gix-hashtable@0.8.1
	gix-ignore@0.14.0
	gix-index@0.39.0
	gix-lock@17.1.0
	gix-object@0.48.0
	gix-odb@0.68.0
	gix-pack@0.58.0
	gix-packetline-blocking@0.18.3
	gix-packetline@0.18.4
	gix-path@0.10.20
	gix-pathspec@0.10.0
	gix-protocol@0.49.0
	gix-quote@0.5.0
	gix-ref@0.51.0
	gix-refspec@0.29.0
	gix-revision@0.33.0
	gix-revwalk@0.19.0
	gix-sec@0.10.12
	gix-shallow@0.3.0
	gix-status@0.18.0
	gix-submodule@0.18.0
	gix-tempfile@17.1.0
	gix-trace@0.1.13
	gix-transport@0.46.0
	gix-traverse@0.45.0
	gix-url@0.30.0
	gix-utils@0.2.0
	gix-utils@0.3.0
	gix-validate@0.10.0
	gix-validate@0.9.4
	gix-worktree@0.40.0
	gix@0.71.0
	glob@0.3.1
	goblin@0.9.3
	half@2.7.1
	hash32@0.3.1
	hashbrown@0.14.5
	hashbrown@0.15.2
	hashbrown@0.16.1
	heapless@0.8.0
	heck@0.5.0
	hermit-abi@0.5.2
	highs@1.12.0
	home@0.5.11
	icu_collections@2.0.0
	icu_locale_core@2.0.0
	icu_normalizer@2.0.0
	icu_normalizer_data@2.0.0
	icu_properties@2.0.1
	icu_properties_data@2.0.1
	icu_provider@2.0.0
	ident_case@1.0.1
	idna@1.0.3
	idna_adapter@1.2.1
	imara-diff@0.1.8
	indexmap@2.7.1
	indicatif@0.18.3
	int-enum@1.1.2
	is-terminal@0.4.17
	is_ci@1.2.0
	itertools@0.10.5
	itertools@0.13.0
	itoa@1.0.14
	jiff-tzdb-platform@0.1.3
	jiff-tzdb@0.1.4
	jiff@0.2.1
	jobserver@0.1.33
	js-sys@0.3.81
	kstring@2.0.2
	lazy_static@1.5.0
	libc@0.2.174
	libloading@0.8.6
	libm@0.2.16
	libredox@0.1.3
	libsqlite3-sys@0.35.0
	libz-rs-sys@0.5.0
	linux-raw-sys@0.4.14
	linux-raw-sys@0.9.3
	litemap@0.8.0
	llvm-sys@191.0.0
	lock_api@0.4.12
	lockfree-object-pool@0.1.6
	log@0.4.28
	logos-codegen@0.14.2
	logos-derive@0.14.2
	logos@0.14.2
	lz4-sys@1.11.1+lz4-1.10.0
	maybe-async@0.2.10
	memchr@2.7.4
	memmap2@0.5.10
	memmap2@0.9.7
	migrations_internals@2.2.1
	migrations_macros@2.2.0
	minimal-lexical@0.2.1
	miniz_oxide@0.8.7
	munge@0.4.7
	munge_macro@0.4.7
	no-std-compat@0.4.1
	nom@7.1.3
	num-complex@0.4.6
	num-conv@0.1.0
	num-integer@0.1.46
	num-iter@0.1.45
	num-rational@0.4.2
	num-traits@0.2.19
	num@0.4.3
	num_cpus@1.17.0
	num_enum@0.4.3
	num_enum_derive@0.4.3
	num_threads@0.1.7
	object@0.38.1
	once_cell@1.21.3
	option-ext@0.2.0
	owo-colors@4.2.3
	parking_lot@0.12.3
	parking_lot_core@0.9.10
	paste@1.0.15
	pathdiff@0.2.3
	percent-encoding@2.3.1
	petgraph@0.7.1
	pkg-config@0.3.32
	plain@0.2.3
	portable-atomic-util@0.2.4
	portable-atomic@1.11.1
	potential_utf@0.1.2
	powerfmt@0.2.0
	ppv-lite86@0.2.21
	pretty_assertions@1.4.1
	prettyplease@0.2.25
	proc-macro-crate@0.1.5
	proc-macro-crate@3.3.0
	proc-macro-error-attr@1.0.4
	proc-macro-error@1.0.4
	proc-macro2-diagnostics@0.10.1
	proc-macro2@1.0.92
	prodash@29.0.2
	ptr_meta@0.3.1
	ptr_meta_derive@0.3.1
	pulp-wasm-simd-flag@0.1.0
	pulp@0.22.2
	quick-error@1.2.3
	quote@1.0.37
	r-efi@5.3.0
	rancor@0.1.1
	rand@0.9.2
	rand_chacha@0.9.0
	rand_core@0.9.5
	rand_distr@0.5.1
	raw-cpuid@11.6.0
	rayon-core@1.13.0
	rayon@1.11.0
	reborrow@0.5.5
	redox_syscall@0.5.11
	redox_users@0.5.2
	regex-automata@0.4.8
	regex-lite@0.1.6
	regex-syntax@0.8.5
	regex@1.11.0
	rend@0.5.3
	rkyv@0.8.15
	rkyv_derive@0.8.15
	rustc-hash@1.1.0
	rustc-hash@2.1.1
	rustc_version@0.4.1
	rustix@0.38.37
	rustix@1.0.5
	rustversion@1.0.21
	ruzstd@0.8.2
	ryu@1.0.18
	safetensors@0.7.0
	same-file@1.0.6
	scopeguard@1.2.0
	scroll@0.12.0
	scroll_derive@0.12.1
	semver@1.0.23
	seq-macro@0.3.6
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.142
	serde_spanned@1.0.0
	sha1-checked@0.10.0
	sha1@0.10.6
	shell-words@1.1.0
	shlex@1.3.0
	signal-hook-registry@1.4.6
	signal-hook@0.3.18
	simd-adler32@0.3.7
	simdutf8@0.1.5
	smallvec@1.15.1
	stable_deref_trait@1.2.0
	static_assertions@1.1.0
	strsim@0.11.1
	strum@0.27.1
	strum@0.28.0
	strum_macros@0.27.1
	strum_macros@0.28.0
	supports-color@2.1.0
	supports-color@3.0.2
	syn@1.0.109
	syn@2.0.89
	synstructure@0.13.2
	sysctl@0.6.0
	tar@0.4.44
	tarc@0.1.6
	tempfile@3.20.0
	thiserror-impl@1.0.64
	thiserror-impl@2.0.12
	thiserror@1.0.64
	thiserror@2.0.12
	time-core@0.1.4
	time-macros@0.2.22
	time@0.3.41
	tinystr@0.8.1
	tinyvec@1.9.0
	tinyvec_macros@0.1.1
	toml@0.5.11
	toml@0.9.5
	toml_datetime@0.6.9
	toml_datetime@0.7.0
	toml_edit@0.22.26
	toml_parser@1.0.2
	toml_writer@1.0.2
	trie-hard@0.1.0
	twox-hash@2.1.2
	typed-path@0.12.3
	typenum@1.18.0
	unicode-bom@2.0.3
	unicode-ident@1.0.13
	unicode-normalization@0.1.24
	unicode-segmentation@1.12.0
	unicode-width@0.2.2
	unicode-xid@0.2.6
	unit-prefix@0.5.1
	unwrap_or@1.0.1
	url@2.5.4
	utf8_iter@1.0.4
	uuid@1.18.1
	vcpkg@0.2.15
	vergen-gix@1.0.9
	vergen-lib@0.1.6
	vergen@9.0.6
	version_check@0.9.5
	vswhom-sys@0.1.3
	vswhom@0.1.0
	walkdir@2.5.0
	wasi@0.11.1+wasi-snapshot-preview1
	wasi@0.14.2+wasi-0.2.4
	wasm-bindgen-backend@0.2.104
	wasm-bindgen-macro-support@0.2.104
	wasm-bindgen-macro@0.2.104
	wasm-bindgen-shared@0.2.104
	wasm-bindgen@0.2.104
	web-time@1.1.0
	widestring@1.2.1
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.9
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-collections@0.3.2
	windows-core@0.62.2
	windows-future@0.3.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-numerics@0.3.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-sys@0.61.2
	windows-targets@0.52.6
	windows-threading@0.2.1
	windows@0.62.2
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.52.6
	winnow@0.6.20
	winnow@0.7.10
	winreg@0.55.0
	wit-bindgen-rt@0.39.0
	writeable@0.6.1
	xattr@1.5.0
	yansi@1.0.1
	yoke-derive@0.8.0
	yoke@0.8.1
	zerocopy-derive@0.8.26
	zerocopy@0.8.26
	zerofrom-derive@0.1.6
	zerofrom@0.1.6
	zerotrie@0.2.2
	zerovec-derive@0.11.1
	zerovec@0.11.3
	zip@4.2.0
	zip@7.2.0
	zlib-rs@0.5.0
	zopfli@0.8.1
	zstd-safe@7.2.4
	zstd-sys@2.0.15+zstd.1.5.7
"

inherit cargo edo rocm

MY_PV="${PV//_pre/-preview.}"

DESCRIPTION="Open nVidia CUDA replacement"
HOMEPAGE="https://github.com/vosen/ZLUDA"
SRC_URI="
	${CARGO_CRATE_URIS}
	https://github.com/vosen/ZLUDA/archive/refs/tags/v${MY_PV}.tar.gz -> ${PN}-${PV}.tar.gz
"

LICENSE="BSD"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 ISC MIT MPL-2.0 Unicode-3.0
	Unicode-DFS-2016 ZLIB
"
#KEYWORDS="~amd64"
SLOT="0/$(ver_cut 1-2)"
IUSE="blas blaslt bindgen cache zoc dark-api detours-sys dnn fft inject ld ml ptx ptxas precompile rocm sparse test trace xtask"

RDEPEND="
	dev-util/hip
	dev-util/hipify-clang
	dev-util/rocm-smi:${SLOT}
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-build/cmake-3.22
	>=dev-build/rocm-cmake-5.0.2-r1
	test? ( dev-cpp/gtest )
"

RESTRICT="!test? ( test ) mirror"
#S="${WORKDIR}/rccl-rocm-${PV}"
S="${WORKDIR}/${PN^^}-${MY_PV}"

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
	cargo_src_configure --no-default-features
}

src_compile() {
    # Build only specific crate(s) instead of all default members
    local build_type=$(usex debug --debug --release)
	cargo build -p zluda ${build_type}
	cargo build -p zluda_redirect ${build_type}
    cargo build -p cuda_macros ${build_type}
    use detours && cargo build -p detours-sys ${build_type}
    cargo build -p format ${build_type}
    cargo build -p kernel_metadata ${build_type}
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
    use xtask && cargo build xtask ${build_type}
    use bindgen && cargo build zluda_bindgen ${build_type}
    use cache && cargo build zluda_cache ${build_type}
    use inject && cargo build zluda_inject ${build_type}
    use precompile && cargo build zluda_precompile ${build_type}
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
