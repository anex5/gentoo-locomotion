# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-multilib llvm

DESCRIPTION="LLVM-based OpenCL compiler targetting Intel Gen graphics hardware"
HOMEPAGE="https://github.com/intel/intel-graphics-compiler"
SRC_URI="https://github.com/intel/${PN}/archive/igc-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

COMMON="sys-devel/llvm:9=[${MULTILIB_USEDEP}]
	>=dev-libs/opencl-clang-9.0.0:9=[${MULTILIB_USEDEP}]"
DEPEND="${COMMON}"
RDEPEND="${COMMON}"

RESTRICT="mirror"

LLVM_MAX_SLOT=9

PATCHES=(
	"${FILESDIR}"/${PN}-1.0.9-no_Werror.patch
)

S="${WORKDIR}"/${PN}-igc-${PV}

multilib_src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=RELEASE
		-DCMAKE_LIBRARY_PATH=$(get_llvm_prefix)/$(get_libdir)
		-DIGC_OPTION__FORCE_SYSTEM_LLVM=ON
		-DIGC_PREFERRED_LLVM_VERSION=9
		-DIGC_ShaderDumpEnable=0
	)
	cmake-utils_src_configure
}
