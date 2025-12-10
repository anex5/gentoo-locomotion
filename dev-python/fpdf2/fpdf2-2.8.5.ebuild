# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

DISTUTILS_USE_PEP517=setuptools

DOCS_BUILDER="mkdocs"
DOCS_DEPEND="
	dev-python/mkdocs-material
"

inherit distutils-r1 docs

DESCRIPTION="Simple PDF generation for Python"
HOMEPAGE="
	https://pypi.org/project/pypdf/
	https://py-pdf.github.io/fpdf2
"
SRC_URI="https://github.com/py-pdf/fpdf2/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE+=" doc"
DEPEND+="
	app-text/endesive
	dev-python/pypdf[${PYTHON_USEDEP}]
	dev-python/defusedxml[${PYTHON_USEDEP}]
	dev-python/fonttools[${PYTHON_USEDEP}]
	virtual/pillow[${PYTHON_USEDEP}]
"
BDEPEND+="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/wheel[${PYTHON_USEDEP}]
	doc? (
		>=dev-python/mkdocs-1.6.1[${PYTHON_USEDEP}]
	)
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/pytest-cov[${PYTHON_USEDEP}]
		dev-python/qrcode[${PYTHON_USEDEP}]
		dev-python/uharfbuzz[${PYTHON_USEDEP}]
		dev-python/camelot[${PYTHON_USEDEP}]
	)
"

RESTRICT="mirror"

EPYTEST_PLUGINS=( pytest-cov )
EPYTEST_XDIST=1
export PYTHONHASHSEED=0
distutils_enable_tests pytest

EPYTEST_DESELECT=(
	"test/table/test_table_extraction.py::test_camelot_extract_two_pages_table[lattice]"
	"test/table/test_table_extraction.py::test_camelot_extract_two_pages_table[stream]"
	"test/test_linearization.py::test_linearization"
	"test/table/test_table_extraction.py::test_tabula_extract_two_pages_table"
	"test/table/test_table_extraction.py::test_camelot_extract_simple_table[table_with_headings_styled.pdf-lattice]"
	"test/text/test_line_break.py::test_line_break_no_initial_newline"
	"test/signing/test_sign.py::test_sign_pkcs12"
	"test/signing/test_sign.py::test_sign_pkcs12_with_link"
	"test/table/test_table_extraction.py::test_camelot_extract_simple_table[table_with_internal_layout.pdf-lattice]"
	"test/table/test_table_extraction.py::test_camelot_extract_two_tables[table_align.pdf]"
	"test/table/test_table_extraction.py::test_tabula_extract_simple_table[table_simple.pdf]"
	"test/table/test_table_extraction.py::test_tabula_extract_simple_table[table_with_headings_styled.pdf]"
	"test/table/test_table_extraction.py::test_tabula_extract_simple_table[table_with_minimal_layout.pdf]"
	"test/table/test_table_extraction.py::test_tabula_extract_simple_table[table_with_single_top_line_layout.pdf]"
	"test/table/test_table_extraction.py::test_tabula_extract_two_tables[table_align.pdf]"
	"test/table/test_table_extraction.py::test_tabula_extract_two_tables[table_with_cell_fill.pdf]"
	"test/table/test_table_extraction.py::test_camelot_extract_simple_table[table_simple.pdf-lattice]"
	"test/table/test_table_extraction.py::test_camelot_extract_simple_table[table_with_images.pdf-lattice]"
	"test/text/test_line_break.py::test_two_words_two_lines_break_by_space_justify"
	"test/table/test_table_extraction.py::test_camelot_extract_simple_table[table_with_images_and_img_fill_width.pdf-lattice]"
	"test/text/test_line_break.py::test_four_words_two_lines_break_by_space"
	"test/text/test_line_break.py::test_four_words_two_lines_break_by_space_justify"
)

src_install() {
	distutils-r1_src_install
	docinto "licenses"
	dodoc "LICENSE"
	insinto "/usr/share/${PN}"
	doins -r "contributors"
	if use doc ; then
		insinto "/usr/share/${PN}"
		dodoc -r "docs"
	fi
}
