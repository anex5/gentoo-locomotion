# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib toolchain-funcs

DESCRIPTION="A suite of sparse matrix tools"
HOMEPAGE="https://github.com/DrTimothyAldenDavis/SuiteSparse"
HOMEPAGE="http://faculty.cse.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v${PV}.tar.gz -> SuiteSparse-${PV}.gh.tar.gz"

# No licensing restrictions apply to this file or to the SuiteSparse_config directory.
LICENSE="public-domain"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 sparc x86"
IUSE="+amd btf blas +camd +ccolamd +cholmod +colamd +cxsparse cuda doc debug fortran -graphblas \
	klu lagraph ldl mongoose paru openmp rbio +spex spqr supernodal partition static-libs test umfpack"
RESTRICT="mirror"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	paru? ( blas )
	spqr? ( blas )
	umfpack? ( blas )
	graphblas? ( blas )
"

BDEPEND="
	fortran? ( virtual/fortran )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	blas? ( virtual/blas )
"

S=${WORKDIR}/SuiteSparse-${PV}

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_prepare() {
	tc-export CC CXX AR RANLIB
	multilib_copy_sources
	cmake_src_prepare
}

multilib_src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)

	local projects=(
		"suitesparse_config;"
		$(usex mongoose "mongoose;" "")
		$(usex amd "amd;" "")
		$(usex btf "btf;" "")
		$(usex camd "camd;"  "")
		$(usex ccolamd "ccolamd;" "")
		$(usex colamd "colamd;" "")
		$(usex cholmod "cholmod;" "")
		$(usex cxsparse "cxsparse;" "")
		$(usex ldl "ldl;" "")
		$(usex klu "klu;" "")
		$(usex umfpack "umfpack;" "")
		$(usex paru "paru;" "")
		$(usex rbio "rbio;" "")
		$(usex spqr "spqr;" "")
		$(usex spex "spex;" "")
		$(usex graphblas "graphblas;" "")
		$(usex lagraph "lagraph;" "")
	)

	IFS_backup=$IFS
	IFS=
	projects="${projects[*]}"
	IFS=${IFS_backup}

	local mycmakeargs=(
		-DBLA_VENDOR=Blis
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_STATIC_LIBS=$(use static-libs ON OFF)
		-DSUITESPARSE_CONFIG_USE_OPENMP=$(usex openmp)
		-DSUITESPARSE_USE_CUDA=$(usex cuda)
		-DSUITESPARSE_USE_FORTRAN=$(usex fortran)
		-DSUITESPARSE_USE_SYSTEM_BTF=OFF
		-DSUITESPARSE_USE_SYSTEM_CHOLMOD=OFF
		-DSUITESPARSE_USE_SYSTEM_AMD=OFF
		-DSUITESPARSE_USE_SYSTEM_COLAMD=OFF
		-DSUITESPARSE_USE_SYSTEM_CAMD=OFF
		-DSUITESPARSE_USE_SYSTEM_CCOLAMD=OFF
		-DSUITESPARSE_USE_SYSTEM_GRAPHBLAS=OFF
		-DSUITESPARSE_USE_SYSTEM_UMFPACK=OFF
		-DSUITESPARSE_USE_SYSTEM_SUITESPARSE_CONFIG=OFF
		-DSUITESPARSE_ENABLE_PROJECTS="${projects%%;}"
		-DSUITESPARSE_REQUIRE_BLAS=$(usex blas ON OFF)
		-DSUITESPARSE_DEMOS=$(usex test)
		#-DCMAKE_FIND_DEBUG_MODE=yes
		-DCMAKE_POLICY_VERSION_MINIMUM=3.5
	)
	if use cholmod; then
		mycmakeargs+=(
			-DCHOLMOD_SUPERNODAL=$(usex supernodal)
			-DCHOLMOD_CAMD=$(usex camd)
			-DKLU_USE_CHOLMOD=$(usex klu)
			-DUMFPACK_USE_CHOLMOD=$(usex umfpack)
		)
	fi
	cmake_src_configure
}

src_configure() {
	cmake-multilib_src_configure
}

multilib_src_compile() {
	cmake_src_compile
}

src_compile() {
	cmake-multilib_src_compile
}

multilib_src_test() {
	# Run demo files
	if use amd; then
		pushd AMD
		local demofiles=(
			amd_demo
			amd_l_demo
			amd_demo2
			amd_simple
		)
		if use fortran; then
			demofiles+=(
				amd_f77simple
				amd_f77demo
			)
		fi
		for i in ${demofiles[@]}; do
			./"${i}" > "${i}.out" || die "failed to run test ${i}"
			diff "${S}/AMD/Demo/${i}.out" "${i}.out" || die "failed testing ${i}"
		done
		popd
	fi

	if use camd; then
		pushd CAMD
		local demofiles=(
			camd_demo
			camd_l_demo
			camd_demo2
			camd_simple
		)
		for i in ${demofiles[@]}; do
			./"${i}" > "${i}.out" || die "failed to run test ${i}"
			diff "${S}/CAMD/Demo/${i}.out" "${i}.out" || die "failed testing ${i}"
		done
		popd
	fi

	if use colamd; then
		pushd COLAMD
		./colamd_example > colamd_example.out || die "failed to run test colamd_example"
		diff "${S}"/COLAMD/Demo/colamd_example.out colamd_example.out || die "failed testing colamd_example"
		./colamd_l_example > colamd_l_example.out || die "failed to run test colamd_l_example"
		diff "${S}"/COLAMD/Demo/colamd_l_example.out colamd_l_example.out || die "failed testing colamd_l_example"
		popd
	fi

	if use ccolamd; then
		pushd CCOLAMD
		./ccolamd_example > ccolamd_example.out || die "failed to run test ccolamd_example"
		diff "${S}"/CCOLAMD/Demo/ccolamd_example.out ccolamd_example.out || die "failed testing ccolamd_example"
		./ccolamd_l_example > ccolamd_l_example.out || die "failed to run test ccolamd_l_example"
		diff "${S}"/CCOLAMD/Demo/ccolamd_l_example.out ccolamd_l_example.out || die "failed testing ccolamd_l_example"
		popd
	fi

	if use cxsparse; then
		pushd CXSparse
		# Programs assume that they can access the Matrix folder in ${S}
		ln -s "${S}/CXSparse/Matrix" || die "cannot link to the Matrix folder"
		# Run demo files
		./cs_idemo < Matrix/t2 || die "failed testing"
		./cs_ldemo < Matrix/t2 || die "failed testing"
		./cs_demo1 < Matrix/t1 || die "failed testing"
		./cs_demo2 < Matrix/t1 || die "failed testing"
		./cs_demo2 < Matrix/fs_183_1 || die "failed testing"
		./cs_demo2 < Matrix/west0067 || die "failed testing"
		./cs_demo2 < Matrix/lp_afiro || die "failed testing"
		./cs_demo2 < Matrix/ash219 || die "failed testing"
		./cs_demo2 < Matrix/mbeacxc || die "failed testing"
		./cs_demo2 < Matrix/bcsstk01 || die "failed testing"
		./cs_demo3 < Matrix/bcsstk01 || die "failed testing"
		./cs_demo2 < Matrix/bcsstk16 || die "failed testing"
		./cs_demo3 < Matrix/bcsstk16 || die "failed testing"
		./cs_di_demo1 < Matrix/t1 || die "failed testing"
		./cs_di_demo2 < Matrix/t1 || die "failed testing"
		./cs_di_demo2 < Matrix/fs_183_1 || die "failed testing"
		./cs_di_demo2 < Matrix/west0067 || die "failed testing"
		./cs_di_demo2 < Matrix/lp_afiro || die "failed testing"
		./cs_di_demo2 < Matrix/ash219 || die "failed testing"
		./cs_di_demo2 < Matrix/mbeacxc || die "failed testing"
		./cs_di_demo2 < Matrix/bcsstk01 || die "failed testing"
		./cs_di_demo3 < Matrix/bcsstk01 || die "failed testing"
		./cs_di_demo2 < Matrix/bcsstk16 || die "failed testing"
		./cs_di_demo3 < Matrix/bcsstk16 || die "failed testing"
		./cs_dl_demo1 < Matrix/t1 || die "failed testing"
		./cs_dl_demo2 < Matrix/t1 || die "failed testing"
		./cs_dl_demo2 < Matrix/fs_183_1 || die "failed testing"
		./cs_dl_demo2 < Matrix/west0067 || die "failed testing"
		./cs_dl_demo2 < Matrix/lp_afiro || die "failed testing"
		./cs_dl_demo2 < Matrix/ash219 || die "failed testing"
		./cs_dl_demo2 < Matrix/mbeacxc || die "failed testing"
		./cs_dl_demo2 < Matrix/bcsstk01 || die "failed testing"
		./cs_dl_demo3 < Matrix/bcsstk01 || die "failed testing"
		./cs_dl_demo2 < Matrix/bcsstk16 || die "failed testing"
		./cs_dl_demo3 < Matrix/bcsstk16 || die "failed testing"
		./cs_ci_demo1 < Matrix/t2 || die "failed testing"
		./cs_ci_demo2 < Matrix/t2 || die "failed testing"
		./cs_ci_demo2 < Matrix/t3 || die "failed testing"
		./cs_ci_demo2 < Matrix/t4 || die "failed testing"
		./cs_ci_demo2 < Matrix/c_west0067 || die "failed testing"
		./cs_ci_demo2 < Matrix/c_mbeacxc || die "failed testing"
		./cs_ci_demo2 < Matrix/young1c || die "failed testing"
		./cs_ci_demo2 < Matrix/qc324 || die "failed testing"
		./cs_ci_demo2 < Matrix/neumann || die "failed testing"
		./cs_ci_demo2 < Matrix/c4 || die "failed testing"
		./cs_ci_demo3 < Matrix/c4 || die "failed testing"
		./cs_ci_demo2 < Matrix/mhd1280b || die "failed testing"
		./cs_ci_demo3 < Matrix/mhd1280b || die "failed testing"
		./cs_cl_demo1 < Matrix/t2 || die "failed testing"
		./cs_cl_demo2 < Matrix/t2 || die "failed testing"
		./cs_cl_demo2 < Matrix/t3 || die "failed testing"
		./cs_cl_demo2 < Matrix/t4 || die "failed testing"
		./cs_cl_demo2 < Matrix/c_west0067 || die "failed testing"
		./cs_cl_demo2 < Matrix/c_mbeacxc || die "failed testing"
		./cs_cl_demo2 < Matrix/young1c || die "failed testing"
		./cs_cl_demo2 < Matrix/qc324 || die "failed testing"
		./cs_cl_demo2 < Matrix/neumann || die "failed testing"
		./cs_cl_demo2 < Matrix/c4 || die "failed testing"
		./cs_cl_demo3 < Matrix/c4 || die "failed testing"
		./cs_cl_demo2 < Matrix/mhd1280b || die "failed testing"
		./cs_cl_demo3 < Matrix/mhd1280b || die "failed testing"
		popd
	fi

	if use ldl; then
		pushd LDL
		# Some programs assume that they can access the Matrix folder in ${S}
		ln -s "${S}/Matrix" || die "cannot link to the Matrix folder"
		# Run demo files
		local demofiles=(
			ldlsimple
			ldllsimple
			ldlmain
			ldllmain
			ldlamd
			ldllamd
		)
		for i in ${demofiles[@]}; do
			./"${i}" > "${i}.out" || die "failed to run test ${i}"
			diff "${S}/LDL/Demo/${i}.out" "${i}.out" || die "failed testing ${i}"
		done
		popd
	fi

	if use klu; then
		pushd KLU
		# Programs assume that they can access the Matrix folder in ${S}
		ln -s "${S}/KLU/Matrix" || die "cannot link to the Matrix folder"
		# Run demo files
		./klu_simple || die "failed testing"
		./kludemo  < Matrix/1c.mtx || die "failed testing"
		./kludemo  < Matrix/arrowc.mtx || die "failed testing"
		./kludemo  < Matrix/arrow.mtx || die "failed testing"
		./kludemo  < Matrix/impcol_a.mtx || die "failed testing"
		./kludemo  < Matrix/w156.mtx || die "failed testing"
		./kludemo  < Matrix/ctina.mtx || die "failed testing"
		./kluldemo < Matrix/1c.mtx || die "failed testing"
		./kluldemo < Matrix/arrowc.mtx || die "failed testing"
		./kluldemo < Matrix/arrow.mtx || die "failed testing"
		./kluldemo < Matrix/impcol_a.mtx || die "failed testing"
		./kluldemo < Matrix/w156.mtx || die "failed testing"
		./kluldemo < Matrix/ctina.mtx || die "failed testing"
		popd
	fi

	if use spqr; then
		pushd SPQR
		# Programs assume that they can access the Matrix folder in ${S}
		ln -s "${S}/SPQR/Matrix" || die "cannot link to the Matrix folder"
		# Run demo files
		./qrsimple  < Matrix/ash219.mtx || die "failed testing"
		./qrsimplec < Matrix/ash219.mtx || die "failed testing"
		./qrsimple  < Matrix/west0067.mtx || die "failed testing"
		./qrsimplec < Matrix/west0067.mtx || die "failed testing"
		./qrdemo < Matrix/a2.mtx || die "failed testing"
		./qrdemo < Matrix/r2.mtx || die "failed testing"
		./qrdemo < Matrix/a04.mtx || die "failed testing"
		./qrdemo < Matrix/a2.mtx || die "failed testing"
		./qrdemo < Matrix/west0067.mtx || die "failed testing"
		./qrdemo < Matrix/c2.mtx || die "failed testing"
		./qrdemo < Matrix/a0.mtx || die "failed testing"
		./qrdemo < Matrix/lfat5b.mtx || die "failed testing"
		./qrdemo < Matrix/bfwa62.mtx || die "failed testing"
		./qrdemo < Matrix/LFAT5.mtx || die "failed testing"
		./qrdemo < Matrix/b1_ss.mtx || die "failed testing"
		./qrdemo < Matrix/bcspwr01.mtx || die "failed testing"
		./qrdemo < Matrix/lpi_galenet.mtx || die "failed testing"
		./qrdemo < Matrix/lpi_itest6.mtx || die "failed testing"
		./qrdemo < Matrix/ash219.mtx || die "failed testing"
		./qrdemo < Matrix/a4.mtx || die "failed testing"
		./qrdemo < Matrix/s32.mtx || die "failed testing"
		./qrdemo < Matrix/c32.mtx || die "failed testing"
		./qrdemo < Matrix/lp_share1b.mtx || die "failed testing"
		./qrdemo < Matrix/a1.mtx || die "failed testing"
		./qrdemo < Matrix/GD06_theory.mtx || die "failed testing"
		./qrdemo < Matrix/GD01_b.mtx || die "failed testing"
		./qrdemo < Matrix/Tina_AskCal_perm.mtx || die "failed testing"
		./qrdemo < Matrix/Tina_AskCal.mtx || die "failed testing"
		./qrdemo < Matrix/GD98_a.mtx || die "failed testing"
		./qrdemo < Matrix/Ragusa16.mtx || die "failed testing"
		./qrdemo < Matrix/young1c.mtx || die "failed testing"
		./qrdemo < Matrix/lp_e226_transposed.mtx || die "failed testing"
		./qrdemoc < Matrix/a2.mtx || die "failed testing"
		./qrdemoc < Matrix/r2.mtx || die "failed testing"
		./qrdemoc < Matrix/a04.mtx || die "failed testing"
		./qrdemoc < Matrix/a2.mtx || die "failed testing"
		./qrdemoc < Matrix/west0067.mtx || die "failed testing"
		./qrdemoc < Matrix/c2.mtx || die "failed testing"
		./qrdemoc < Matrix/a0.mtx || die "failed testing"
		./qrdemoc < Matrix/lfat5b.mtx || die "failed testing"
		./qrdemoc < Matrix/bfwa62.mtx || die "failed testing"
		./qrdemoc < Matrix/LFAT5.mtx || die "failed testing"
		./qrdemoc < Matrix/b1_ss.mtx || die "failed testing"
		./qrdemoc < Matrix/bcspwr01.mtx || die "failed testing"
		./qrdemoc < Matrix/lpi_galenet.mtx || die "failed testing"
		./qrdemoc < Matrix/lpi_itest6.mtx || die "failed testing"
		./qrdemoc < Matrix/ash219.mtx || die "failed testing"
		./qrdemoc < Matrix/a4.mtx || die "failed testing"
		./qrdemoc < Matrix/s32.mtx || die "failed testing"
		./qrdemoc < Matrix/c32.mtx || die "failed testing"
		./qrdemoc < Matrix/lp_share1b.mtx || die "failed testing"
		./qrdemoc < Matrix/a1.mtx || die "failed testing"
		./qrdemoc < Matrix/GD06_theory.mtx || die "failed testing"
		./qrdemoc < Matrix/GD01_b.mtx || die "failed testing"
		./qrdemoc < Matrix/Tina_AskCal_perm.mtx || die "failed testing"
		./qrdemoc < Matrix/Tina_AskCal.mtx || die "failed testing"
		./qrdemoc < Matrix/GD98_a.mtx || die "failed testing"
		./qrdemoc < Matrix/Ragusa16.mtx || die "failed testing"
		./qrdemoc < Matrix/young1c.mtx || die "failed testing"
		./qrdemoc < Matrix/lp_e226_transposed.mtx || die "failed testing"
		popd
	fi

	if use umfpack; then
		pushd UMFPACK
		./umfpack_simple || die "failed testing umfpack_simple"
		popd
	fi

	einfo "All tests passed"
}


multilib_src_install() {
	cmake_src_install

	if multilib_is_native_abi; then
		use static-libs && ( dolib.a libsuitesparseconfig.a || die )
	fi
}

multilib_src_install_all() {
	use doc && einstalldocs

	use !static-libs && ( find "${ED}" -name "*.a" -delete || die )

	# strip .la files
	find "${ED}" -name '*.la' -delete || die
}
