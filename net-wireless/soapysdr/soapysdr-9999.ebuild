# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..15} )

inherit cmake python-single-r1

DESCRIPTION="vendor and platform neutral SDR support library"
HOMEPAGE="https://github.com/pothosware/SoapySDR"

if [ "${PV}" = "9999" ]; then
	EGIT_REPO_URI="https://github.com/pothosware/SoapySDR.git"
	EGIT_CLONE_TYPE="shallow"
	inherit git-r3
else
	KEYWORDS="amd64 ~arm ~riscv ~x86"
	COMMIT="1551ea0d39ce546b32a15808b9b1241018a89fc8"
	SRC_URI="https://github.com/pothosware/SoapySDR/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.tar.gz"
	S="${WORKDIR}/SoapySDR-${COMMIT}"
	RESTRICT="mirror"
fi

LICENSE="Boost-1.0"
SLOT="0/${PV}"
IUSE="bladerf hackrf python rtlsdr plutosdr uhd"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="python? ( ${PYTHON_DEPS} )"
DEPEND="${RDEPEND}"
BDEPEND="
	python? ( dev-lang/swig:0 )
"
PDEPEND="
	bladerf? ( net-wireless/soapybladerf )
	hackrf? ( net-wireless/soapyhackrf )
	rtlsdr? ( net-wireless/soapyrtlsdr )
	plutosdr? ( net-wireless/soapyplutosdr )
	uhd? ( net-wireless/soapyuhd )
"

src_configure() {
	local mycmakeargs=(
		-DENABLE_PYTHON=$(usex python)
		-DENABLE_PYTHON3=$(usex python)
		-DBUILD_PYTHON3=$(usex python)
		-DUSE_PYTHON_CONFIG=ON
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install
	use python && python_optimize
}
