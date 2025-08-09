# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic toolchain-funcs

DESCRIPTION="Header-only C++11 serialization library"
HOMEPAGE="https://uscilab.github.io/cereal/"
SRC_URI="https://github.com/USCiLab/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~loong ~ppc64 ~riscv x86"
IUSE="doc examples libcxx test"
RESTRICT="!test? ( test )"

BDEPEND="doc? ( app-text/doxygen )"
DEPEND="dev-libs/rapidjson"

src_prepare() {
	# remove bundled rapidjson
	rm -r include/cereal/external/rapidjson || die 'could not remove bundled rapidjson'
	sed -e '/rapidjson/s|cereal/external/||' \
		-e 's/CEREAL_RAPIDJSON_NAMESPACE/rapidjson/g' \
		-i include/cereal/archives/json.hpp || die

	if use elibc_musl; then
		eapply "${FILESDIR}"/0001-sandbox-Do-not-use-int8_t-in-std-uniform_int_distrib.patch
		eapply "${FILESDIR}"/0001-cmake-Use-idirafter-instead-of-isystem.patch
		eapply "${FILESDIR}"/0001-doctest-Do-not-use-unnamed-class.patch
		eapply "${FILESDIR}"/0001-Fix-instances-of-Wmissing-template-arg-list-after-te.patch
	fi

	cmake_src_prepare
}

src_configure() {
	# TODO: drop bundled doctest, rapidxml (bug #792444)

	tc-is-clang && append-cflags "-Wno-error=c++11-narrowing-const-reference"

	local mycmakeargs=(
		#-DCMAKE_CXX_STANDARD=11
		-DBUILD_TESTS=$(usex test)
		-DBUILD_DOC=$(usex doc)
		-DBUILD_SANDBOX=$(usex examples)

		# Avoid Boost dependency
		-DSKIP_PERFORMANCE_COMPARISON=ON
		-DWITH_WERROR=OFF
	)

	tc-is-clang && mycmakeargs+=( -DCLANG_USE_LIBCPP=$(usex libcxx) )

	# TODO: Enable if multilib?
	use test && mycmakeargs+=( -DSKIP_PORTABILITY_TEST=ON )

	CMAKE_BUILD_TYPE='Release'
	cmake_src_configure
}
