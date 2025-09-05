# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit font

DESCRIPTION="Google's font family that aims to support all the world's languages"
HOMEPAGE="https://fonts.google.com/noto https://github.com/notofonts/notofonts.github.io"

FONT_FACES=(Black BlackItalic Bold BoldItalic Condensed CondensedBlack CondensedBlackItalic CondensedBold CondensedBoldItalic CondensedExtraBold CondensedExtraBoldItalic CondensedExtraLight CondensedExtraLightItalic CondensedItalic CondensedLight CondensedLightItalic CondensedMedium CondensedMediumItalic CondensedSemiBold CondensedSemiBoldItalic CondensedThin CondensedThinItalic Italic Light LightItalic Medium MediumItalic Regular Thin ThinItalic)
FONT_FACES_EXTRA=(ExtraBold ExtraBoldItalic ExtraCondensed ExtraCondensedBlack ExtraCondensedBlackItalic ExtraCondensedBold ExtraCondensedBoldItalic ExtraCondensedExtraBold ExtraCondensedExtraBoldItalic ExtraCondensedExtraLight ExtraCondensedExtraLightItalic ExtraCondensedItalic ExtraCondensedLight ExtraCondensedLightItalic ExtraCondensedMedium ExtraCondensedMediumItalic ExtraCondensedSemiBold ExtraCondensedSemiBoldItalic ExtraCondensedThin ExtraCondensedThinItalic ExtraLight ExtraLightItalic)
FONT_FACES_SEMI=(SemiBold SemiBoldItalic SemiCondensed SemiCondensedBlack SemiCondensedBlackItalic SemiCondensedBold SemiCondensedBoldItalic SemiCondensedExtraBold SemiCondensedExtraBoldItalic SemiCondensedExtraLight SemiCondensedExtraLightItalic SemiCondensedItalic SemiCondensedLight SemiCondensedLightItalic SemiCondensedMedium SemiCondensedMediumItalic SemiCondensedSemiBold SemiCondensedSemiBoldItalic SemiCondensedThin SemiCondensedThinItalic)
FONT_FACES_MONO=(Black Bold Condensed CondensedBlack CondensedBold CondensedExtraBold CondensedExtraLight CondensedLight CondensedMedium CondensedSemiBold CondensedThin ExtraBold ExtraCondensed ExtraCondensedBlack ExtraCondensedBold ExtraCondensedExtraBold ExtraCondensedExtraLight ExtraCondensedLight ExtraCondensedMedium ExtraCondensedSemiBold ExtraCondensedThin ExtraLight Light Medium Regular SemiBold SemiCondensed SemiCondensedBlack SemiCondensedBold SemiCondensedExtraBold SemiCondensedExtraLight SemiCondensedLight SemiCondensedMedium SemiCondensedSemiBold SemiCondensedThin Thin)
FONT_FAMILIES=(NotoSans NotoSerif NotoSerifDisplay)
COMMON_URI="https://github.com/notofonts/notofonts.github.io/raw/refs/heads/main/fonts"

gen_src_uri() {
	for fam in ${FONT_FAMILIES[*]}; do
		for face in ${FONT_FACES[*]}; do
			echo "otf? ( ${COMMON_URI}/${fam}/unhinted/otf/${fam}-${face}.otf )"
			echo "ttf? ( ${COMMON_URI}/${fam}/unhinted/ttf/${fam}-${face}.ttf )"
		done
	done
	echo "extra? ("
	for fam in ${FONT_FAMILIES[*]}; do
		for face in ${FONT_FACES_EXTRA[*]}; do
			echo "otf? ( ${COMMON_URI}/${fam}/unhinted/otf/${fam}-${face}.otf )"
			echo "ttf? ( ${COMMON_URI}/${fam}/unhinted/ttf/${fam}-${face}.ttf )"
		done
	done
	echo ")"
	echo "semi? ( "
	for fam in ${FONT_FAMILIES[*]}; do
		for face in ${FONT_FACES_SEMI[*]}; do
			echo "otf? ( ${COMMON_URI}/${fam}/unhinted/otf/${fam}-${face}.otf )"
			echo "ttf? ( ${COMMON_URI}/${fam}/unhinted/ttf/${fam}-${face}.ttf )"
		done
	done
	echo ")"
	echo "mono? ( "
	for face in ${FONT_FACES_MONO[*]}; do
		echo "otf? ( ${COMMON_URI}/NotoSansMono/unhinted/otf/NotoSansMono-${face}.otf )"
		echo "ttf? ( ${COMMON_URI}/NotoSansMono/unhinted/ttf/NotoSansMono-${face}.ttf )"
	done
	echo ")"
	echo "glagolitic? ("
	echo "    otf? ( ${COMMON_URI}/NotoSansGlagolitic/full/otf/NotoSansGlagolitic-Regular.otf )"
	echo "    ttf? ( ${COMMON_URI}/NotoSansGlagolitic/full/ttf/NotoSansGlagolitic-Regular.ttf )"
	echo ")"
	echo "linear? ("
	echo "    otf? ( ${COMMON_URI}/NotoSansLinearA/full/otf/NotoSansLinearA-Regular.otf )"
	echo "    ttf? ( ${COMMON_URI}/NotoSansLinearA/full/ttf/NotoSansLinearA-Regular.ttf )"
	echo "    otf? ( ${COMMON_URI}/NotoSansLinearB/full/otf/NotoSansLinearB-Regular.otf )"
	echo "    ttf? ( ${COMMON_URI}/NotoSansLinearB/full/ttf/NotoSansLinearB-Regular.ttf )"
	echo ")"
	echo "music? ("
	echo "    otf? ( ${COMMON_URI}/NotoMusic/full/otf/NotoMusic-Regular.otf )"
	echo "    ttf? ( ${COMMON_URI}/NotoMusic/full/ttf/NotoMusic-Regular.ttf )"
	echo ")"
	echo "math? ("
	echo "    otf? ( ${COMMON_URI}/NotoSansMath/full/otf/NotoSansMath-Regular.otf )"
	echo "    ttf? ( ${COMMON_URI}/NotoSansMath/full/ttf/NotoSansMath-Regular.ttf )"
	echo ")"
	echo "symbols? ("
	echo "    otf? ( ${COMMON_URI}/NotoSansSymbols/full/otf/NotoSansSymbols-Regular.otf )"
	echo "    ttf? ( ${COMMON_URI}/NotoSansSymbols/full/ttf/NotoSansSymbols-Regular.ttf )"
	echo "    otf? ( ${COMMON_URI}/NotoSansSymbols2/full/otf/NotoSansSymbols2-Regular.otf )"
	echo "    ttf? ( ${COMMON_URI}/NotoSansSymbols2/full/ttf/NotoSansSymbols2-Regular.ttf )"
	echo ")"
	echo "runic? ("
	echo "    otf? ( ${COMMON_URI}/NotoSansRunic/full/otf/NotoSansRunic-Regular.otf )"
	echo "    ttf? ( ${COMMON_URI}/NotoSansRunic/full/ttf/NotoSansRunic-Regular.ttf )"
	echo ")"
	echo "gothic? ("
	echo "    otf? ( ${COMMON_URI}/NotoSansGothic/full/otf/NotoSansGothic-Regular.otf )"
	echo "    ttf? ( ${COMMON_URI}/NotoSansGothic/full/ttf/NotoSansGothic-Regular.ttf )"
	echo ")"
}

SRC_URI="$(gen_src_uri)"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="*"
# Extra allows to optionally reduce disk usage even returning to tofu
# issue as described in https://fonts.google.com/noto
IUSE="glagolitic extra math +mono music runic gothic linear +symbols semi +otf ttf"

RESTRICT="binchecks strip mirror"

FONT_CONF=(
	# From ArchLinux
	"${FILESDIR}/66-noto-serif.conf"
	"${FILESDIR}/66-noto-mono.conf"
	"${FILESDIR}/66-noto-sans.conf"
)

src_unpack(){
	local f
	mkdir "${S}" || die
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${S}/${f}"
	done
}

src_install() {
	use otf && FONT_SUFFIX="otf "
	use ttf && FONT_SUFFIX+="ttf"
	font_src_install
}
