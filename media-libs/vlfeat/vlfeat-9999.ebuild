# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs flag-o-matic

DESCRIPTION="VisionLab Features Library for SFM applications"
HOMEPAGE="https://www.vlfeat.org"
if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vlfeat/vlfeat"
	EGIT_BRANCH="master"
	KEYWORDS=""
	SLOT="0/0.9"
else
	SRC_URI="https://www.vlfeat.org/download/${P}.tar.gz https://github.com/vlfeat/vlfeat/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
	#S="${WORKDIR}/${P}"
	SLOT="0/$(ver_cut 1-2 ${PV})"
fi

LICENSE="BSD"

IUSE="debug man mpi octave utils"
RESTRICT="
	!test (test)
	mirror
"

DEPEND="
	octave? ( >=sci-mathematics/octave-3.4.0 )
"
BDEPEND="
	octave? ( dev-lang/swig )
"

PATCHES+=(
	"${FILESDIR}/vlfeat-fix-omp-build.patch"
)

pkg_setup() {
	use amd64 && ARCH=glnxa64
	use x86 && ARCH=glnx86
}

src_configure() {
	CC="$(tc-getBUILD_CC)" LD="$(tc-getLD)" \
	MEX=""
	use debug && DEBUG=true
	use octave && MKOCTFILE=${EPREFIX}/usr/bin/mkoctfile || MKOCTFILE=""
	use mpi && CC=mpicc
}

src_compile() {
	tc-export CC LD
	default
}

src_install() {
	use utils && dobin bin/${ARCH}/{sift,mser}
	use man && doman src/{vlfeat.7,mser.1,sift.1}
	dolib.so bin/${ARCH}/libvl.so
	insinto /usr/include
	doins -r vl
	dodoc README.md
}
