# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib flag-o-matic

DESCRIPTION="OpenCL implementation for Intel Sandy Bridge, Ivy Bridge and Haswell GPUs"
HOMEPAGE="https://01.org/beignet https://gitlab.freedesktop.org/beignet/beignet"
#SRC_URI="https://01.org/sites/default/files/${P}-source.tar.gz"
EGIT_COMMIT="419c041736c5d19cd9c9e7f90717792a01826638"
SRC_URI="https://github.com/intel/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}-${EGIT_COMMIT}.tar.gz"
LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="amd64"
IUSE="ocl20"
LLVM_MAX_SLOT=10

BDEPEND="${PYTHON_DEPS}
	virtual/pkgconfig
	<=sys-devel/llvm-${LLVM_MAX_SLOT}*=[${MULTILIB_USEDEP}]"
COMMON="
	media-libs/mesa[${MULTILIB_USEDEP}]
	>=x11-libs/libdrm-2.4.70[video_cards_intel,${MULTILIB_USEDEP}]
	x11-libs/libXext[${MULTILIB_USEDEP}]
	x11-libs/libXfixes[${MULTILIB_USEDEP}]
"
RDEPEND="${COMMON}"
DEPEND="${COMMON}"
RESTRICT="mirror"

PATCHES=(
	"${FILESDIR}/${PN}-1.3.2-Debian-compliant-compiler-flags-handling.patch"
	"${FILESDIR}/${PN}-1.3.2-support-kfreebsd.patch"
	"${FILESDIR}/${PN}-1.3.2-reduce-notfound-output.patch"
	"${FILESDIR}/${PN}-1.3.2-ship-test-tool.patch"
	"${FILESDIR}/${PN}-1.3.2-find-python35.patch"
	"${FILESDIR}/${PN}-1.3.2-docs-broken-links.patch"
	"${FILESDIR}/${PN}-1.3.2-cl_accelerator_intel.patch"
	"${FILESDIR}/${PN}-1.3.2-reproducibility.patch"
	"${FILESDIR}/${PN}-1.2.0_no-hardcoded-cflags.patch"
	"${FILESDIR}/${PN}-9999-libOpenCL.patch"
	#"${FILESDIR}/${PN}-1.3.2-static-llvm.patch"
	"${FILESDIR}/llvm-terminfo.patch"
	"${FILESDIR}/llvm-libs-tr.patch"
	"${FILESDIR}/llvm-empty-system-libs.patch"
)

DOCS=(
	docs/.
)

S="${WORKDIR}"/${PN}-${EGIT_COMMIT}

src_prepare() {
	for SLOT in 4..${LLVM_MAX_SLOT}; do
		has_version "sys-devel/llvm:${SLOT}" && LLVM_SLOT=${SLOT}
	done

	[[ ${LLVM_SLOT} -ge 6 ]] && eapply "${FILESDIR}/${PN}-1.3.2-llvm6-support.patch"
	[[ ${LLVM_SLOT} -ge 7 ]] && eapply "${FILESDIR}/${PN}-1.3.2-llvm7-support.patch"
	[[ ${LLVM_SLOT} -ge 8 ]] && eapply "${FILESDIR}/${PN}-1.3.2-llvm8-support.patch"
	[[ ${LLVM_SLOT} -ge 9 ]] && (
		eapply "${FILESDIR}/${PN}-1.3.2-llvm9-support.patch"
		eapply "${FILESDIR}/${PN}-1.3.2-llvm9-support-2.patch"
	)
	[[ ${LLVM_SLOT} -ge 10 ]] && eapply "${FILESDIR}/${PN}-1.3.2-llvm10-support.patch"

	cmake_src_prepare
	# We cannot run tests because they require permissions to access
	# the hardware, and building them is very time-consuming.
	cmake_comment_add_subdirectory utests
}

multilib_src_configure() {
	VENDOR_DIR="/usr/$(get_libdir)/OpenCL/vendors/${PN}"
	CMAKE_BUILD_TYPE=Release

	if tc-is-clang; then
		filter-flags -f*graphite -f*loop-*
		filter-flags -mfpmath* -freorder-blocks-and-partition
		filter-flags -flto* -fuse-linker-plugin
		filter-flags -ftracer -fvect-cost-model -ftree*
	fi

	# Pre-compiled headers otherwise result in redefined symbols (gcc only)
	if tc-is-gcc; then
		append-flags -fpch-deps
	fi

	# See Bug #593968
	append-flags -fPIC -fno-strict-aliasing

	local mycmakeargs=(
		-DBEIGNET_INSTALL_DIR="${VENDOR_DIR}"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}${VENDOR_DIR}"
		-DOCLICD_COMPAT="$(has_version dev-libs/ocl-icd && echo 1 || echo 0)"
		$(usex ocl20 "" "-DENABLE_OPENCL_20=0")
	)

	multilib_is_native_abi || mycmakeargs+=(
		-DLLVM_CONFIG_EXECUTABLE="${EPREFIX}/usr/bin/$(get_abi_CHOST ${ABI})-llvm-config"
	)

	cmake_src_configure
}

multilib_src_install() {
	VENDOR_DIR="/usr/$(get_libdir)/OpenCL/vendors/${PN}"

	cmake_src_install

	# Headers should only be in VENDOR_DIR
	rm -rf "${ED}/usr/include"

	insinto "/etc/OpenCL/vendors/"
	echo "${EPREFIX}${VENDOR_DIR}/lib/${PN}/libcl.so" > "${PN}-${ABI}.icd" || die "Failed to generate ICD file"
	doins "${PN}-${ABI}.icd"

	dosym "libOpenCL.so.1.0.0" "${VENDOR_DIR}/libOpenCL.so.1"
	dosym "libOpenCL.so.1.0.0" "${VENDOR_DIR}/libOpenCL.so"

}

pkg_postinst() {
	elog ""
	elog "Please note that for Broadwell and newer architectures, Beignet has been deprecated upstream in favour of dev-libs/intel-neo."
	elog "It remains the recommended solution for Sandy Bridge, Ivy Bridge and Haswell."
	elog ""
}
