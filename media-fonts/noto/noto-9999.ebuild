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
L10N=( ar ban bax ber bku blt bn bo bsq bug bya ccp chr cja cmr dv
	eo ff gu he hi hoc hy ii ja jv ka khb km kn ko kv lo mai men mjl ml mn mni
	mww my new nod nqo or osa pa rej sa sat saz sd si so sq srb su syc syl ta
	tbw te th tl tmh ur vai zh-CN zh-TW iu hnn bho eky lep lif lis tbw skr mr
	pa tmh )

declare -A LANG_FAMILIES=(
	[ar]="SansArabic SansArabicUI"
	[ban]="SansBalinese"
	[bax]="SansBamum"
	[ber]="SansTifinagh"
	[bho]="SansKaithi"
	[bku]="SansBuhid"
	[blt]="SansTaiViet"
	[bn]="SansBengali"
	[bo]="SerifTibetan"
	[bsq]="SansBassaVah"
	[bug]="SansBuginese"
	[bya]="SansBatak"
	[ccp]="SansChakma"
	[chr]="SansCherokee"
	[cja]="SansCham"
	[cmr]="SansMro"
	[dv]="SansThaana"
	[eky]="SansKayahLi"
	[eo]="SansShavian"
	[ff]="SansAdlam"
	[gu]="SansGujarati"
	[he]="SansHebrew"
	[hi]="SansDevanagari"
	[hnn]="SansHanunoo"
	[hoc]="SansWarangCiti"
	[hy]="SansArmenian"
	[ii]="SansYi"
	[iu]="SansCanadianAboriginal"
	[jv]="SansJavanese"
	[ka]="SansGeorgian"
	[khb]="SansTaiLe"
	[km]="SansKhmer"
	[kn]="SansKannada"
	[kv]="SansOldPermic"
	[lep]="SansLepcha"
	[lif]="SansLimbu"
	[lis]="SansLisu"
	[lo]="SansLao"
	[mai]="SansTirhuta"
	[men]="SansMendeKikakui"
	[mjl]="SansTakri"
	[ml]="SansMalayalam"
	[mn]="SansMongolian"
	[mni]="SansMeeteiMayek"
	[mr]="SansModi"
	[mww]="SansPahawhHmong SansMiao"
	[my]="SansMyanmar"
	[new]="SansNewa"
	[nod]="SansTaiTham"
	[nqo]="SansNKo"
	[or]="SansOriya"
	[osa]="SansOsage"
	[pa]="SansGurmukhi"
	[pa]="SansMahajani"
	[rej]="SansRejang"
	[sa]="SansSharada SansBhaiksuki SansKharoshthi SansNandinagari SansGrantha"
	[sat]="SansOlChiki"
	[saz]="SansSaurashtra"
	[sd]="SansKhudawadi"
	[si]="SansSinhala"
	[skr]="SansMultani"
	[so]="SansOsmanya"
	[sq]="SansCaucasianAlbanian SansElbasan"
	[srb]="SansSoraSompeng"
	[su]="SansSundanese"
	[syc]="SansSyriac"
	[syl]="SansSylotiNagri"
	[ta]="SansTamil"
	[tbw]="SansTagbanwa"
	[te]="SansTelugu"
	[th]="SansThai"
	[tl]="SansTagalog"
	[tmh]="SansTifinagh"
	[ur]="NastaliqUrdu"
	[vai]="SansVai"
)

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
	echo "ancient? ("
	echo "    otf? ( ${COMMON_URI}/NotoSerifAhom/full/otf/NotoSerifAhom-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansImperialAramaic/full/otf/NotoSansImperialAramaic-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansAvestan/full/otf/NotoSansAvestan-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansCarian/full/otf/NotoSansCarian-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansEthiopic/full/otf/NotoSansEthiopic-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansGlagolitic/full/otf/NotoSansGlagolitic-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansGothic/full/otf/NotoSansGothic-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansHatran/full/otf/NotoSansHatran-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansInscriptionalPahlavi/full/otf/NotoSansInscriptionalPahlavi-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansLycian/full/otf/NotoSansLycian-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansLydian/full/otf/NotoSansLydian-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansMandaic/full/otf/NotoSansMandaic-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansManichaean/full/otf/NotoSansManichaean-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansMarchen/full/otf/NotoSansMarchen-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansMeroitic/full/otf/NotoSansMeroitic-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansNabataean/full/otf/NotoSansNabataean-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansOgham/full/otf/NotoSansOgham-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansOldHungarian/full/otf/NotoSansOldHungarian-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansOldItalic/full/otf/NotoSansOldItalic-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansOldPersian/full/otf/NotoSansOldPersian-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansOldTurkic/full/otf/NotoSansOldTurkic-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansPalmyrene/full/otf/NotoSansPalmyrene-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansPhoenician/full/otf/NotoSansPhoenician-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansPsalterPahlavi/full/otf/NotoSansPsalterPahlavi-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansSamaritan/full/otf/NotoSansSamaritan-Regular.otf"
	echo "        ${COMMON_URI}/NotoSansUgaritic/full/otf/NotoSansUgaritic-Regular.otf )"
	echo "    ttf? ( ${COMMON_URI}/NotoSerifAhom/full/ttf/NotoSerifAhom-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansImperialAramaic/full/ttf/NotoSansImperialAramaic-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansAvestan/full/ttf/NotoSansAvestan-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansCarian/full/ttf/NotoSansCarian-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansEthiopic/full/ttf/NotoSansEthiopic-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansGlagolitic/full/ttf/NotoSansGlagolitic-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansGothic/full/ttf/NotoSansGothic-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansHatran/full/ttf/NotoSansHatran-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansInscriptionalPahlavi/full/ttf/NotoSansInscriptionalPahlavi-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansLycian/full/ttf/NotoSansLycian-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansLydian/full/ttf/NotoSansLydian-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansMandaic/full/ttf/NotoSansMandaic-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansManichaean/full/ttf/NotoSansManichaean-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansMarchen/full/ttf/NotoSansMarchen-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansMeroitic/full/ttf/NotoSansMeroitic-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansNabataean/full/ttf/NotoSansNabataean-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansOgham/full/ttf/NotoSansOgham-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansOldHungarian/full/ttf/NotoSansOldHungarian-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansOldItalic/full/ttf/NotoSansOldItalic-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansOldPersian/full/ttf/NotoSansOldPersian-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansOldTurkic/full/ttf/NotoSansOldTurkic-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansPalmyrene/full/ttf/NotoSansPalmyrene-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansPhoenician/full/ttf/NotoSansPhoenician-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansPsalterPahlavi/full/ttf/NotoSansPsalterPahlavi-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansSamaritan/full/ttf/NotoSansSamaritan-Regular.ttf"
	echo "        ${COMMON_URI}/NotoSansUgaritic/full/ttf/NotoSansUgaritic-Regular.ttf )"
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
	# Langs
	for l in ${L10N[*]}; do
		if [[ ${LANG_FAMILIES[$l]} == "" ]]; then continue; fi
		echo "l10n_${l}? ("
		for fam in ${LANG_FAMILIES[$l]}; do
			echo "otf? ( ${COMMON_URI}/Noto${fam}/full/otf/Noto${fam}-Regular.otf )"
			echo "ttf? ( ${COMMON_URI}/Noto${fam}/full/ttf/Noto${fam}-Regular.ttf )"
		done
		echo ")"
	done
}

SRC_URI="$(gen_src_uri)"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="*"
# Extra allows to optionally reduce disk usage even returning to tofu
# issue as described in https://fonts.google.com/noto
IUSE="ancient extra math +mono music runic gothic linear +symbols semi +otf ttf ${L10N[@]/#/l10n_}"

RDEPEND="l10n_zh-CN? ( media-fonts/noto-cjk )
	l10n_zh-TW? ( media-fonts/noto-cjk )
	l10n_ja? ( media-fonts/noto-cjk )
	l10n_ko? ( media-fonts/noto-cjk )"

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
