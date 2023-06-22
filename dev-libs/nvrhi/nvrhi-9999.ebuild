# Copyright 2019-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A Library that implements a common abstraction layer over multiple graphics APIs"
HOMEPAGE="https://github.com/NVIDIAGameWorks/nvrhi"

inherit git-r3
EGIT_REPO_URI="https://github.com/NVIDIAGameWorks/nvrhi"
EGIT_BRANCH="main"
EGIT_SUBMODULES=( )
KEYWORDS="amd64"

IUSE="dxc nvapi rtxmu video_cards_d3d11 video_cards_d3d12 vulkan"

LICENSE="MIT"
SLOT="0"

BDEPEND="
	dev-util/glslang
	dev-libs/cxxopts
	rtxmu? ( dev-libs/rtxmu )
	dxc? ( dev-util/DirectXShaderCompiler )
	sys-devel/llvm[llvm_targets_DirectX]
	vulkan? ( dev-util/vulkan-headers )
"

RDEPEND="
	media-libs/vulkan-loader
"

RESTRICT="mirror"

PATCHES=(
	${FILESDIR}/nvrhi-unbundle-libs.patch
)

src_prepare() {
	cmake_src_prepare
	sed -i "s|LIBRARY DESTINATION lib|LIBRARY DESTINATION $(get_libdir)|" CMakeLists.txt || die
}

src_configure() {
	CMAKE_BUILD_TYPE=Release
	CMAKE_CXX_STANDARD=17

	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DNVRHI_BUILD_SHARED=ON
		-DNVRHI_WITH_SHADER_COMPILER=$(usex dxc ON OFF)
		-DNVRHI_WITH_NVAPI=$(usex nvapi ON OFF)
		-DNVRHI_WITH_VULKAN=$(usex vulkan ON OFF)
		-DNVRHI_WITH_RTXMU=$(usex rtxmu ON OFF)
		-DNVRHI_WITH_DX12=$(usex video_cards_d3d12 ON OFF)
		-DNVRHI_WITH_DX11=$(usex video_cards_d3d11 ON OFF)
	)
	cmake_src_configure
}
