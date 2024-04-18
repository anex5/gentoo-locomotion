# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs flag-o-matic prefix

DESCRIPTION="Tiniest x86-64-linux emulator"
HOMEPAGE="https://github.com/jart/blink"
if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/jart/blink"
	KEYWORDS=""
else
	SRC_URI="https://github.com/jart/blink/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64 ~arm ~x86 ~mips ~ppc ~ppc64 ~s390"
fi

LICENSE="ISC"
SLOT="0"

BUILD_MODES=( tiny opt rel dbg cosmo prof cov asan ubsan tsan msan llvm llvm++ rel-llvm tiny-llvm )

IUSE="cpu_flags_x86_mmxext +ancillary backtrace +bcd +bmi2 debug +disassembler +fork jit man +metal overlays +rom +sockets static strace test +threads +vfs +x87 ${BUILD_MODES[@]}"

BDEPEND="
	test? ( app-emulation/qemu )
	>=sys-libs/zlib-1.2.13
"

REQUIRED_USE="
	^^ ( ${BUILD_MODES[@]} )
	^^ ( overlays vfs )
	jit? ( ^^ ( amd64 arm64 ) )
	debug? ( ^^ ( dbg asan msan ubsan tsan llvm llvm++ ) )
"

RESTRICT="
	!test? ( test )
	mirror
"

src_prepare() {
	# Unbundle zlib
	sed -e "/include third_party\/libz\/zlib\.mk.*$/d" -i Makefile || die "Sed failed."

	default
}

src_configure() {
	export HOSTCC=${BUILD_CC} CFLAGS_HOST="${BUILD_CFLAGS}" LDFLAGS_HOST="${BUILD_LDFLAGS}"
	if use llvm || use rel-llvm || use llvm++; then
		CC="${CHOST}-clang"
		append-cflags -stdlib=libc++ -lc++abi -I/usr/include/c++/v1
	fi

	filter-lto
	strip-unsupported-flags
	for bm in "${BUILD_MODES[@]}"; do
		if use ${bm}; then export m="${bm}"; break; fi
	done

	local myargs=(
		$(use_enable ancillary)
		$(use_enable backtrace)
		$(use_enable bcd)
		$(use_enable bmi2)
		$(use_enable disassembler)
		$(use_enable fork)
		$(use_enable jit)
		$(use_enable metal)
		$(use_enable overlays)
		$(use_enable rom)
		$(use_enable sockets)
		$(use_enable strace)
		$(usev static)
		$(use_enable threads)
		$(use_enable vfs)
		$(use_enable x87)
		$(use_enable cpu_flags_x86_mmxext mmx)
		--prefix="${EPREFIX}${sysroot}/usr"
		--posix
		--disable-nonposix
	)

	./configure "${myargs[@]}"
}

src_test() {
	emake check check2 emulates
}

src_install() {
	insinto ${EPREFIX}/usr/bin
	dobin ./o/${m}/blink/blink ./o/${m}/blink/blinkenlights
	if use man; then
		doman ./blink/blink.1 ./blink/blinkenlights.1
	fi
	dodoc LICENSE* README*
}
