# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

COMMIT_HASH="6eb62e1515072827db992c2befd80b71b2d04329"

DESCRIPTION="Easy to integrate Vulkan memory allocation library"
HOMEPAGE="https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator"
SRC_URI="https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/${COMMIT_HASH}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="doc"

BDEPEND="doc? ( dev-python/sphinx )"
RDEPEND="media-libs/vulkan-loader"

RESTRICT="mirror"

S="${WORKDIR}/VulkanMemoryAllocator-${COMMIT_HASH}"

CMAKE_BUILD_TYPE=Release

src_configure() {
	local mycmakeargs=(
		-DVMA_BUILD_DOCUMENTATION="$(usex doc)"
		-DVMA_BUILD_SAMPLES=OFF
	)
	cmake_src_configure
}
