# Copyright 2021-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

inherit python-any-r1

DESCRIPTION="Script for creating GNU Icecat tarball"
HOMEPAGE="https://www.gnu.org/software/gnuzilla/"

COMMIT="a59b8a2c2e4c8b8de47b3ae4d10032154a47a01e"
PP="1"
COMPARE_LOCALES_PV="9.0.1"
SRC_URI="
	https://git.savannah.gnu.org/cgit/gnuzilla.git/snapshot/gnuzilla-${COMMIT}.tar.gz
	https://archive.mozilla.org/pub/firefox/releases/${PV}esr/source/firefox-${PV}esr.source.tar.xz
	https://github.com/mozilla/compare-locales/archive/refs/tags/RELEASE_${COMPARE_LOCALES_PV//./_}.tar.gz
		-> compare-locales-${COMPARE_LOCALES_PV}.tar.gz
"

LICENSE="GPL-3"
SLOT="${PV}"
KEYWORDS="~amd64"

RESTRICT="test mirror"

IUSE="+buildtarball"

RDEPEND="${BDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	app-arch/unzip
	app-crypt/gnupg
	dev-vcs/mercurial
	$(python_gen_any_dep '
		dev-python/jsonschema[${PYTHON_USEDEP}]
	')
"

S="${WORKDIR}/gnuzilla-${COMMIT}"

declare -A LANG_COMMIT
LANG_COMMIT[ace]="ef9c06f0d0259dacf11e4c515ce37bb7a694b9b1" # 2024-01-18 12:13
LANG_COMMIT[ach]="e91bb5281c62d042d6ac7420fed6210baba21fe9" # 2024-02-26 11:51
LANG_COMMIT[af]="334bb18824909819f950d62906cb69d01149c0a1" # 2024-01-31 07:37
LANG_COMMIT[ak]="4f43af6834f1f172e2a0eecc61c73751c77243f2" # 2024-01-18 12:13
LANG_COMMIT[an]="fbfa8d9bc6662369009bda463483a032e466934c" # 2024-02-26 11:51
LANG_COMMIT[ar]="d56d7c7d8d152dba0ad37bd64409de8b10cf047e" # 2024-03-08 13:21
LANG_COMMIT[as]="7e8c549988564e3d0a3fcb6a88e0d89c36a3aa43" # 2024-02-26 11:51
LANG_COMMIT[ast]="c9a1711eb6f85327545d3547189851cc578a8bcb" # 2024-03-20 15:34
LANG_COMMIT[az]="31f3a61ec07d9c50ae757395abd7d442cb05cd5f" # 2024-02-26 11:52
LANG_COMMIT[be]="c67b2f6a03d89082c7a47750e78429038050522f" # 2024-03-20 15:34
LANG_COMMIT[bg]="51b6e21f0f61592bd86d661baf343ef8587c88f4" # 2024-03-05 09:29
LANG_COMMIT[bn]="bc6b9cc545ff26f7673518f1546e32c202b4a823" # 2024-02-26 11:52
LANG_COMMIT[bn-BD]="ad772238016a37f1b2f0a553b9e430751d345004" # 2024-02-26 11:52
LANG_COMMIT[bn-IN]="bb73000e07fadf3be54361f566b55f1683e6bb96" # 2024-02-26 11:52
LANG_COMMIT[bo]="b8ee1b7924418727c22432f23bb5e9b203dc6fbc" # 2024-01-18 12:16
LANG_COMMIT[br]="34af5228df4bbeb53ad7ff9035293caf4480f8fa" # 2024-03-21 17:43
LANG_COMMIT[brx]="1c65955e254a664a11e03ea2d3928e7fd16650b5" # 2024-02-26 11:52
LANG_COMMIT[bs]="065cd8697832ee0579c0e735b587eed960a03c28" # 2024-03-22 19:05
LANG_COMMIT[ca]="e1cb447e28cc16dae2146029eab57cecd8230011" # 2024-03-20 15:35
LANG_COMMIT[ca-valencia]="17e74ca85bd06858f86277f8c9de3ef115df6095" # 2024-03-20 15:35
LANG_COMMIT[cak]="a2d5c0ad5d7390250b0c9ffe903b18e59ca203b4" # 2024-03-20 15:35
LANG_COMMIT[ckb]="5caf1728df7d7bc1f0be970d6b79459b6f9de960" # 2024-02-26 11:53
LANG_COMMIT[crh]="24a4927fd178a15cc3ec534860c94220ef76eb03" # 2024-02-26 11:53
LANG_COMMIT[cs]="6ed97078556fc2ec3bff9890ea157c2aba716bc7" # 2024-03-23 07:43
LANG_COMMIT[csb]="dd59841595cae91eaace78f8e668d6d09cb3251a" # 2024-01-18 12:17
LANG_COMMIT[cy]="355823e7f5d1c8188cfb0893eac26b5a27d1e67f" # 2024-03-20 15:35
LANG_COMMIT[da]="9b2dd555f2c87519a6b77767b84383207fdbbcd8" # 2024-03-20 15:35
LANG_COMMIT[de]="3c46b32f824a1401414482abaf1fc42f07f66c70" # 2024-03-22 11:09
LANG_COMMIT[dsb]="7c9202aff6dc20259c40d3a9d65e5f1ecda09872" # 2024-03-20 15:35
LANG_COMMIT[el]="d8aeb32babefd3f728945cbbf42d8ab122cdf7d6" # 2024-03-20 15:36
LANG_COMMIT[en-CA]="e916f7fbf514d9dc942fbff336264f9b0a590292" # 2024-03-20 15:36
LANG_COMMIT[en-GB]="be72178980e1388dd3f0c31ad01c31317416a0c5" # 2024-03-23 07:04
LANG_COMMIT[en-ZA]="4f35c5e1a9b328eebb1d4ffcc4776bd28360168f" # 2024-01-18 12:19
LANG_COMMIT[eo]="be2d96bc035e8debfab89769d51da105de9dfd34" # 2024-03-20 15:36
LANG_COMMIT[es-AR]="a7a50d3770969455c330f57c841d76d05ae05a39" # 2024-03-21 02:34
LANG_COMMIT[es-CL]="3469c35c56c763452aef702244d8b1fcde42291b" # 2024-03-21 13:53
LANG_COMMIT[es-ES]="dfd907374a269dda0db9e25a82b571d0f63e2aa7" # 2024-03-20 15:36
LANG_COMMIT[es-MX]="ea977981fb26e99974c8b18bc73bcfb1a874601b" # 2024-03-20 15:36
LANG_COMMIT[et]="d8d81aca4fa5fff97916fddcdd465d79200b9d87" # 2024-03-20 15:36
LANG_COMMIT[eu]="7dc9ec4036cc6678eccc3ff3828e9c275ec042b4" # 2024-03-20 15:36
LANG_COMMIT[fa]="71df6acd8ae7e6899297e21feac1506aca030657" # 2024-03-20 15:36
LANG_COMMIT[ff]="7091a9a4d60b1d0941c411d165c676687183f4c7" # 2024-02-26 11:54
LANG_COMMIT[fi]="d60e530d98c8b7ca842316ea332a13e0bb5f7230" # 2024-03-24 13:03
LANG_COMMIT[fr]="eae6a34702d9e87e079889fd05eb479b7c6b03f8" # 2024-03-20 15:37
LANG_COMMIT[frp]="fe1ea5ded92a685acf9b55d9604d31049c78ed95" # 2024-01-18 12:21
LANG_COMMIT[fur]="eb21947e7b85df869d0c6e8dbdc580d4aff4e1c8" # 2024-03-21 07:10
LANG_COMMIT[fy-NL]="87dff387455c8f23dcd7e81cbac00e467282f721" # 2024-03-22 17:05
LANG_COMMIT[ga-IE]="559b3bd148a477fbb95fef1bcb2f2ef49be06dc3" # 2024-01-31 07:45
LANG_COMMIT[gd]="8d5b6f49ece7c9b8f100087f782272ad512bde5d" # 2024-03-20 15:37
LANG_COMMIT[gl]="59f020aa7d7bce53c85cdcce21cbaeede864e040" # 2024-03-20 15:37
LANG_COMMIT[gn]="f3dddeef672ee6b6de4e80f4411793d91814e237" # 2024-03-20 15:37
LANG_COMMIT[gu-IN]="6065a5c2c8de8cf3f06d5e0a7c1ec537c0da29db" # 2024-02-26 11:55
LANG_COMMIT[gv]="6f7b1db9564812c5a31934bc4aaee8fec20574ad" # 2024-01-18 12:23
LANG_COMMIT[he]="bef1510a38ca8f22bfd59ec439d846acf128cdcf" # 2024-03-21 06:37
LANG_COMMIT[hi-IN]="44ff1ad18d448a14dc2e5c9bbe0b31ebc8d1a470" # 2024-02-26 11:55
LANG_COMMIT[hr]="898f3c50dbd6732d98d140229184c1e4985d4627" # 2024-02-26 11:55
LANG_COMMIT[hsb]="7be544b21b76023c62a7e1ac054b654c7be719d6" # 2024-03-21 19:33
LANG_COMMIT[hto]="ee95e68c8f4a27ee9038e20e2c8a9f52dac6eeef" # 2024-01-18 12:24
LANG_COMMIT[hu]="0b0541b90c59f34f2bd39354c607eb9ad6cd9d2d" # 2024-03-20 15:38
LANG_COMMIT[hy-AM]="9fc355a0f1613b8f4c4bbc86d66cc298b6f7c70d" # 2024-03-20 15:38
LANG_COMMIT[hye]="8d1f2122537faeecdceaa196d4c93491aea59f01" # 2024-03-20 15:38
LANG_COMMIT[ia]="8007b9e54b539b2b7c5ca95032907fec229a2e57" # 2024-03-22 13:53
LANG_COMMIT[id]="e7a8c852ef4d63a854835168b4d9365e517a3775" # 2024-03-20 15:38
LANG_COMMIT[ilo]="41707a7c00d31d020e18110293ccf0706e77fd86" # 2024-01-18 12:25
LANG_COMMIT[is]="41e2499fee367e6723db7a6145bfbe49397d7351" # 2024-03-20 15:38
LANG_COMMIT[it]="c6c7eb8ce07d26639858d3ec495112ad20bc64fb" # 2024-03-21 14:16
LANG_COMMIT[ixl]="02a247c82cc92b3dd55fe4049a6d0c3a00321da4" # 2024-02-26 11:56
LANG_COMMIT[ja]="3503de5b47747eaf61164e1e90dbd3a5938e3d2e" # 2024-03-20 15:38
LANG_COMMIT[ja-JP-mac]="4c9e23e20cbc16123d6142e3c2ea3111d544ddf0" # 2024-03-20 15:38
LANG_COMMIT[ka]="f3a1cad438c5e86032c887aff53d7af542370988" # 2024-03-20 15:39
LANG_COMMIT[kab]="af985ee5430012d27329de6bfd679791a5bd96a4" # 2024-03-20 15:39
LANG_COMMIT[kk]="5c84c53b3993a530d47c4ae230c181c050286201" # 2024-03-20 15:39
LANG_COMMIT[km]="bdee7f2c48262ea1731b4755293c8b204184c788" # 2024-01-31 07:49
LANG_COMMIT[kn]="d9c8fcba3970098b0a419814d55fa53da7ffcf19" # 2024-02-26 11:56
LANG_COMMIT[ko]="1330d82c2f349d0fb65ddfad902d42b096432b68" # 2024-03-21 00:23
LANG_COMMIT[kok]="e0a06109095cb77d0197cfcdc1680c6e8a9c98c5" # 2024-01-18 12:27
LANG_COMMIT[ks]="f51cf6563192d4cbd63c065c131a0e0224e69621" # 2024-01-18 12:28
LANG_COMMIT[ku]="8b68718619fa626485bbb8ba3d59bbe6f987e3a1" # 2024-01-18 12:28
LANG_COMMIT[lb]="1aff6ce35ae7aafa7f28e0ee37a77771c46fbd35" # 2024-01-18 12:28
LANG_COMMIT[lg]="2c3be1444f393ab6980193c617269350c4259d03" # 2024-01-18 12:28
LANG_COMMIT[lij]="636cfd254e26a284c6a0cf80f883dc1a9173e08d" # 2024-02-26 11:57
LANG_COMMIT[lo]="8dfaec0e0128fd7ffa033fe88f991fc41177e7a8" # 2024-03-08 13:28
LANG_COMMIT[lt]="c3f12ebb8c79e1c352be2ea0b784a9d48932b9c4" # 2024-03-20 15:39
LANG_COMMIT[ltg]="f762baa50e837bed9fc0e677645351c42cd2707e" # 2024-01-31 07:50
LANG_COMMIT[lv]="91ee4b01c8b456865ee14e607130dc50ca02328c" # 2024-03-24 09:33
LANG_COMMIT[mai]="e1645eb3ef2e5e5fa54b1e19802b852a65406b59" # 2024-01-31 07:50
LANG_COMMIT[meh]="bbecbd9a6f21b8c1104c15a0bc50db627df6401a" # 2024-02-26 11:57
LANG_COMMIT[mix]="0c43b59dbf57a08af80648b43de6301a3c4dfd33" # 2024-01-18 12:30
LANG_COMMIT[mk]="6b923a0cbbfb1b10331cc11abeffc56758b915a7" # 2024-01-31 07:51
LANG_COMMIT[ml]="a38929c997c92b1de007ffe0ef3f899d9006d41f" # 2024-01-31 07:51
LANG_COMMIT[mn]="11e057cb8d573170f2fd6911f2047624e1d27b23" # 2024-01-18 12:30
LANG_COMMIT[mr]="21ed265d30c375ab53250b0d8c23e334f6a5f320" # 2024-02-26 11:58
LANG_COMMIT[ms]="4c5825a103ab17b608d474fbe3d849996d5285d8" # 2024-02-26 11:58
LANG_COMMIT[my]="36789d479c814ecb612ee914e35d81f9af41e1a4" # 2024-03-24 06:04
LANG_COMMIT[nb-NO]="450f1172b261c10767e522a7be814f0d2eb55e68" # 2024-03-20 23:44
LANG_COMMIT[ne-NP]="6e9a8e45e4b5b80e5be0e7ee0790f2e2a3ba11d7" # 2024-02-18 06:33
LANG_COMMIT[nl]="8f3779a0c3ee5c0c15cc48d1d95a20572ca4df1e" # 2024-03-22 16:53
LANG_COMMIT[nn-NO]="1837d226473d2120782f2fad5196ed8aa97dd3d1" # 2024-03-20 15:41
LANG_COMMIT[nr]="2dff51031859d7a2df46261cedacbbce583d961d" # 2024-01-18 12:32
LANG_COMMIT[nso]="5525ed1116827ada72e3eb95b9b1e05adf22ea5e" # 2024-01-18 12:32
LANG_COMMIT[ny]="28a42329b34c64a2f821d21b4bd58f0a57d70468" # 2024-01-18 12:32
LANG_COMMIT[oc]="9c393420d2312fb36157e2a55b32313b8313f13d" # 2024-03-20 15:41
LANG_COMMIT[or]="b3d8069c8d751531c49299c218605d64875de57a" # 2024-01-31 07:52
LANG_COMMIT[pa-IN]="2513114fbf289bf56e495571d5c17707d33fba63" # 2024-03-20 15:41
LANG_COMMIT[pai]="795cddda95afcef548462a2f667aaf024e03c1df" # 2024-01-18 12:33
LANG_COMMIT[pbb]="4c98b1097b105729b55098578bcee0381362a3d8" # 2024-01-18 12:33
LANG_COMMIT[pl]="5b7210f8c9ab4b607a5329129df9d3efb1838342" # 2024-03-20 15:41
LANG_COMMIT[pt-BR]="5fbf9c4b3abdadfffee53edbd0ec254986fe59d3" # 2024-03-21 18:53
LANG_COMMIT[pt-PT]="5ca9ef14acdbd1192d9fee3fc4b314405e06770b" # 2024-03-21 10:33
LANG_COMMIT[rm]="e4b9d46661465f5cf8e1c8917614b8e3610f0dda" # 2024-03-20 15:42
LANG_COMMIT[ro]="6476ae1d66c5a085a6d8ac667576badf80603e62" # 2024-03-20 15:42
LANG_COMMIT[ru]="e51c4cf57bfa6d2596f41530bbd923aa1deb712f" # 2024-03-21 08:40
LANG_COMMIT[rw]="6eff5f0971ff6c84e67610a4130a48e01cc00cee" # 2024-01-18 12:35
LANG_COMMIT[sah]="2231fd9780ffe2fa0195e36d8402882c97848ff8" # 2024-01-18 12:35
LANG_COMMIT[sat]="cd501b70ad3dae902500f6a64e26141707c3810b" # 2024-03-20 15:43
LANG_COMMIT[sc]="84b9feea7d84bcfe4b7153e28c0b8cb0971a23a7" # 2024-03-20 15:43
LANG_COMMIT[scn]="0f7ac5ac63ccf9719a5321c02b60be4265fb21db" # 2024-01-18 12:36
LANG_COMMIT[sco]="ca67bbd939c70d9cde5ed0ace904c98e30964e8f" # 2024-03-20 15:43
LANG_COMMIT[si]="92528652d1ebf2aacd1e3cf5dd81bc152cf7cf78" # 2024-03-20 15:43
LANG_COMMIT[sk]="84770a640af927fcbeb544a09071b04035f1e15e" # 2024-03-24 13:03
LANG_COMMIT[sl]="077b23859a2f46a04e127db2fe8c1231cc8eccc3" # 2024-03-20 15:44
LANG_COMMIT[son]="9b2b39b1d87865b0db0f67a966968eea84a39af0" # 2024-01-31 07:55
LANG_COMMIT[sq]="37b30cfbb16f5b8d31169baed8823c37b50807be" # 2024-03-20 15:44
LANG_COMMIT[sr]="a5caf259904267d850886cc7a3fec1444e0fcedc" # 2024-03-20 15:44
LANG_COMMIT[ss]="f18834f63e8120877988d9490df03f273749b032" # 2024-01-18 12:38
LANG_COMMIT[st]="84c69b6ca84c4b5a3c065771c17752b82ae43f51" # 2024-01-18 12:38
LANG_COMMIT[sv-SE]="f3914c518eff1a8ad99b5a153647ae396dfc162f" # 2024-03-21 00:05
LANG_COMMIT[sw]="a11d6d289c99f2704944a9bffb1816f73b09872a" # 2024-01-18 12:38
LANG_COMMIT[szl]="cd60661eb4caa7f759d496cbb2a52a8489e3e587" # 2024-03-20 15:44
LANG_COMMIT[ta]="b23fe1bb7faaeec322c12ddad28dd2c8568f82c2" # 2024-01-31 07:56
LANG_COMMIT[ta-LK]="32bedfcd303c2c89c71f43bc452f6d775afbe17c" # 2024-01-18 12:39
LANG_COMMIT[te]="8e86d4e3639524a1288b8460c18f600341fd6205" # 2024-02-26 12:01
LANG_COMMIT[tg]="1ef2e595be24616f1962bce85d11ac27e2ac7e4a" # 2024-03-20 15:44
LANG_COMMIT[th]="12f795d3d2112bbf17dfa30c59aed6c51981b2be" # 2024-03-20 15:45
LANG_COMMIT[tl]="53333797dfbf17d715c0c26070c6fcea80fe9729" # 2024-02-26 12:01
LANG_COMMIT[tn]="3c5fdce437c6ce84791a30949971490403414613" # 2024-01-18 12:40
LANG_COMMIT[tr]="6085a9952676b18b041c086e00ba3eb0066e67f1" # 2024-03-22 12:53
LANG_COMMIT[trs]="27df8bbe05561942756947bb418c644f0dcb3d52" # 2024-03-21 20:43
LANG_COMMIT[ts]="5813e786c7b8f9c626d6bbbc188ab60fc30d1d38" # 2024-01-18 12:41
LANG_COMMIT[tsz]="ef5c7535524d956c2a25427bb58f7871acf4c0f6" # 2024-01-18 12:41
LANG_COMMIT[uk]="6aa0516470b9b05d57bdc87907a08cb42f888569" # 2024-03-21 14:04
LANG_COMMIT[ur]="7566f7c8147815d51f1d17d847bc8c1d60256860" # 2024-02-26 12:01
LANG_COMMIT[uz]="8c5d179b742ed4a78889de781942f14480815b0c" # 2024-01-31 07:58
LANG_COMMIT[ve]="fa24d13094d1db0b3190c0f41e3f3716cf6f447d" # 2024-01-18 12:41
LANG_COMMIT[vi]="99afa839735f427184bc447c79778c1a80fd1373" # 2024-03-24 08:10
LANG_COMMIT[wo]="b3ecc71f87d05cd3654d327fd9ce42a149b9ca6a" # 2024-01-18 12:42
LANG_COMMIT[xcl]="49b80541e741bca5902a9524ff15e8613da517f8" # 2024-01-18 12:42
LANG_COMMIT[xh]="ca50ac09f6b7ca50859ef54cfa294269838e8d39" # 2024-01-31 07:59
LANG_COMMIT[zam]="3dbacaaa62f17deeaa3c922b22f0da0f67de9143" # 2024-01-18 12:42
LANG_COMMIT[zh-CN]="728919d2b486fbd2c9885a07555979e104b3a581" # 2024-03-23 02:53
LANG_COMMIT[zh-TW]="8e65e290e271f0f16efa7f021c7277dbbd3840a6" # 2024-03-21 04:17
LANG_COMMIT[zu]="ed927aab1514dc08c89b5d5a94c145ef402214c1" # 2024-01-18 12:43

fetch_l10n() {
	local lang
	for lang in "${!LANG_COMMIT[@]}" ; do
		#en_US is handled internally
		if [[ ${lang} == en-US ]] ; then
			continue
		fi
		SRC_URI+=" https://hg.mozilla.org/l10n-central/${lang}/archive/${LANG_COMMIT[${lang}]}.zip -> icecat-lang-${lang}-${LANG_COMMIT[${lang}]}.zip"
	done
}
fetch_l10n

python_check_deps() {
	python_has_version "dev-python/jsonschema[${PYTHON_USEDEP}]"
}

src_unpack() {
	unpack "gnuzilla-${COMMIT}.tar.gz"
	for langpack in $(cd "${DISTDIR}"; ls icecat-lang-*.zip); do
		unpack ${langpack}
	done
	unpack "compare-locales-${COMPARE_LOCALES_PV}.tar.gz"
}

src_prepare() {
	default_src_prepare

	# Remove the minimum necessary for script to work offline
	sed -i '/^verify_sources$/d' makeicecat || die
	sed -i '/hg checkout ${L10N_CMP_REV}$/d' makeicecat || die

	# brand.dtd's removed in l10n's
	sed -i -e '/find l10n.*brand.dtd/d' makeicecat || die

	mkdir "${S}/output" || die
	cp "${DISTDIR}/firefox-${PV}esr.source.tar.xz" "${S}/output" || die

	mkdir "${S}/output/l10n" || die
	for lang in "${!LANG_COMMIT[@]}"; do
		#en_US is handled internally
		if [[ ${lang} == en-US ]] ; then
			continue
		fi
		mv "${WORKDIR}/${lang}-${LANG_COMMIT[${lang}]}" "${S}/output/l10n/${lang}" || die
		mkdir -p "${S}/output/l10n/${lang}/browser/chrome/browser/preferences" || die
		touch "${S}/output/l10n/${lang}/browser/chrome/browser/preferences//advanced-scripts.dtd" || die
		rm -rf "${S}/output/l10n/${lang}/.hg*" || die
	done
	mv "${WORKDIR}/compare-locales-RELEASE_${COMPARE_LOCALES_PV//./_}" "${S}/output/compare-locales" || die
}

src_compile() {
	if use buildtarball; then
		./makeicecat || die
	fi
}

src_install() {
	insinto "/usr/src/makeicecat-${PV}"
	doins -r "${S}/"{artwork,CHANGELOG,COPYING,data,makeicecat,README,tools}
	fperms +x "/usr/src/makeicecat-${PV}"/{makeicecat,tools/{AddonsScraper.py,buildbinaries,createdebsrcrepo,gnupload}}
	if use buildtarball; then
		insinto /usr/src/makeicecat-"${PV}"/output
		doins "${S}/output/icecat-${PV}-${PP}gnu1.tar.bz2"
	fi
}

pkg_postinst() {
	if ! use buildtarball; then
		einfo "You haven't enabled buildtarball, therefore you have to create the tarball yourself."
		einfo "You can create the tarball in /usr/share/makeicecat-${PV} by starting the script manually."
		einfo "   ./makeicecat"
		einfo "It will take a while so be prepared."
	fi
}
