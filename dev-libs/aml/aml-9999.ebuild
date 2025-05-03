# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Event timer executor loop"
HOMEPAGE="https://github.com/any1/aml/"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/any1/aml.git"
	KEYWORDS=""
else
	COMMIT=f6086bca136ddad96d67121ecfece59899b91f6a
	SRC_URI="https://github.com/any1/aml/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc ~riscv ~x86"
	S=${WORKDIR}/${PN}-${COMMIT}
fi

LICENSE="ISC"
SLOT="0"
IUSE="debug examples"

DEPEND="elibc_musl? ( sys-libs/queue-standalone )"

RESTRICT="
	mirror
"
PATCHES=(
	"${FILESDIR}"/${PN}-0.3.0-queue.patch
)

src_prepare() {
	default

	# The bundled copy includes cdefs which breaks on musl and this header is
	# already available on glibc. See bug #828806 and
	# https://github.com/any1/aml/issues/11.
	rm include/sys/queue.h || die
}

src_configure() {
	local emesonargs=(
		-Dbuildtype="$(usex debug debug plain)"
		-Db_ndebug="$(usex debug false true)"
		$(meson_use examples)
	)

	meson_src_configure
}
