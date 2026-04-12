# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

if [[ -z ${PV%%*9999} ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/eosrei/${PN}"
else
	COMMIT="b85cc979dfcb4b70e90d56c684ab3eba00e5dce6"
	SRC_URI="https://github.com/eosrei/${PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
	RESTRICT="mirror"
	KEYWORDS="~amd64 ~arm64 ~x86 ~arm"
fi

inherit font

DESCRIPTION="A color emoji SVGinOT font using Twitter emoji"
HOMEPAGE="https://github.com/eosrei/${PN}"

LICENSE="CC-BY-4.0 MIT"
SLOT="0"
IUSE="+otf ttf"
REQUIRED_USE="|| ( otf ttf )"

BDEPEND="
	dev-util/svgo
	dev-python/scfbuild
"

pkg_setup() {
	local _fc="fontconfig/46-${PN%-*}.conf"
	S="${WORKDIR}/${PN}-${COMMIT}"

	FONT_CONF="${S}/linux/${_fc}"
	use otf && { FONT_SUFFIX="otf "; }
	use ttf && { FONT_SUFFIX+="ttf"; }

	font_pkg_setup
}

src_prepare() {
	default
	# Set build directory
	sed -e 's/\(REGULAR_FONT \:\= \)build\/\(\$(FONT_PREFIX)\)\.ttf/\1\2\.ttf/' \
		-i Makefile || die
	# Replace MacOS font name with opentype font name
	sed -e 's/\(MACOS_FONT \:\= \)build\/\(\$(FONT_PREFIX)\)-MacOS\.ttf/\1\2\.otf/' \
		-i Makefile || die
	sed -e 's/\(output_file\: \)build\/\(TwitterEmojiColor-SVGinOT\)\.ttf/\1\2\.ttf/' \
		-i scfbuild.yml || die
	sed -e 's/\(output_file\: \)build\/\(TwitterEmojiColor-SVGinOT\)-MacOS\.ttf/\1\2\.otf/' \
		-i scfbuild-macos.yml || die
	# Replace inkskape & imagemagick BW conversion to simple sed
	sed -e '/ifeq/,/endif/d' -i Makefile || die
	sed -e '/inkscape -w/,/\.pgm$/d' \
		-e 's/rm \$(TMP)\/\$(\*F)\.pgm/cp \"\$\<\" \"\$\@\"/' \
		-i Makefile || die
	# -e 's/rm \$(TMP)\/\$(\*F)\.pgm/sed -e \"s\/ fill\\=\\"[\#0-9A-Za-z]\\+\\"\/ fill\\=\\"none\\" stroke\\=\\"black\\" stroke-width\\=\\"2\\"\\nsed -e \\"s\/style\\=\\"fill\\:[\#0-9A-Za-z]\\;\\"\/s\/style\\=\\"fill\\:none\/\"\/g\" \"\$\<\" \> \"\$\@\"/' \
	# Not Build BW files
	#sed -e 's/\$(SVG_BW_FILES) //g' -i Makefile || die
}

src_compile() {
	local myemakeargs=(
		$(usex otf "TwitterColorEmoji-SVGinOT.otf" "")
		$(usex ttf "TwitterColorEmoji-SVGinOT.ttf" "")
		SCFBUILD=/usr/bin/scfbuild
	)
	emake "${myemakeargs[@]}"
}
