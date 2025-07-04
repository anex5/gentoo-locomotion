# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit python-any-r1

DESCRIPTION="Script for creating GNU Icecat tarball"
HOMEPAGE="https://www.gnu.org/software/gnuzilla/"

COMMIT="7286181cbff5c4b98ed9246366a85ae1fbc8f54d"

PP="1"
GV="1"
COMPARE_LOCALES_PV="9.0.4"
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
LANG_COMMIT[ach]="4c5fea93f2624411412afc90cda054f7d645e71e" # 2024-07-09 12:14
LANG_COMMIT[af]="b4e3c95d5b2bb8694ffa72d607ae418ee19b67e8" # 2024-07-09 12:14
LANG_COMMIT[ak]="f82cfa823d7ed911c5519c50e5881beb24def5fa" # 2024-07-09 12:14
LANG_COMMIT[an]="50a12624cd5cde9f018efa51b8433f84213e06f6" # 2024-07-09 12:14
LANG_COMMIT[ar]="2a6b9746463b26b41b8f9d36ee6b4a0b8be9d47a" # 2024-07-09 12:14
LANG_COMMIT[as]="08c274ff79475cae458e1ed35770f5c416ac34e2" # 2024-07-09 12:14
LANG_COMMIT[ast]="f515769d5719f8d673fd17fed6f5194de60d8c77" # 2024-07-09 12:14
LANG_COMMIT[az]="ef9e6a1e591411c9f8d13a6974a96d26b175e06e" # 2024-07-09 12:14
LANG_COMMIT[be]="cc17926ff5d45d8af339d44b457f0c4054d3037e" # 2024-07-09 12:14
LANG_COMMIT[bg]="139421848b25353e6deb4a2306ba7cf7e2434a58" # 2024-07-09 12:14
LANG_COMMIT[bn]="0fe5fe3663f0872781a811734c03f49bc4980e9f" # 2024-07-09 12:14
LANG_COMMIT[bn-BD]="97b9c13ea376d937d0211274a6ca9ec713015853" # 2024-07-09 12:14
LANG_COMMIT[bn-IN]="914a6bf0496b39ca2d05b70255fe88a1b49cd1f2" # 2024-07-09 12:14
LANG_COMMIT[bo]="84df3a5a7327aa2261436d043baba4d44109525b" # 2024-07-09 12:14
LANG_COMMIT[br]="b84bfc5072700b961775046a285cac685252b6e7" # 2024-07-09 12:14
LANG_COMMIT[brx]="a2f84d3d57cf765458aef85b548a79916b04c5a9" # 2024-07-09 12:14
LANG_COMMIT[bs]="b2c4f5a406d97c20a73e3715ae45b43138d7e906" # 2024-07-09 12:14
LANG_COMMIT[ca]="dae0084381471f8ccfa429791410b0a7fba64c56" # 2024-07-09 12:14
LANG_COMMIT[ca-valencia]="cbb59aed8a7baebaafe6bb38f456eb720f678f84" # 2024-07-09 12:14
LANG_COMMIT[cak]="a5ee9fc6b23aed9363802d0f8f7d6b23b09135bc" # 2024-07-09 12:14
LANG_COMMIT[ckb]="6656a93b69127ff4237221d57c3bea828d5397c7" # 2024-07-09 12:14
LANG_COMMIT[crh]="bf90ea2238bad0e2d1d66d06e19e8d6f0441cd83" # 2024-07-09 12:14
LANG_COMMIT[cs]="6ba70977cd61f28839645c9f4ec634a5466ca7e4" # 2024-07-09 12:14
LANG_COMMIT[csb]="86f0804df27a725987987f4211600d375b4ace78" # 2024-07-09 12:14
LANG_COMMIT[cy]="6c1e5fb7988fb3681140aed65b387d706de3d26a" # 2024-07-09 12:14
LANG_COMMIT[da]="803579fd1a4d3c7833dc4afaf97a82b6867bb59f" # 2024-07-09 12:21
LANG_COMMIT[de]="a24e44cd9012506fc45a04754e49212473474c8a" # 2024-07-09 12:14
LANG_COMMIT[dsb]="a9bc76f6383ee9ecc1708c6d203b895a9ce54973" # 2024-07-09 12:02
LANG_COMMIT[el]="bab0b0affe256e98c405cc07c802d6c37c1d9a17" # 2024-07-09 12:14
LANG_COMMIT[en-CA]="b8d5641eb6eb73587f78127813cf56803c7e3df5" # 2024-07-09 20:02
LANG_COMMIT[en-GB]="c9aa642b3c714f5cf3f2f6759179b4fb353f10e3" # 2024-07-09 21:11
LANG_COMMIT[en-ZA]="49e9391b1814f8e046484bfb4c4e3170480fca14" # 2024-07-09 12:14
LANG_COMMIT[eo]="1ce3bae8f941d0713e9984de5adbb360c54a7daf" # 2024-07-09 12:14
LANG_COMMIT[es-AR]="5864a7f25a6a7a2361a6f8e3cc21147044b85669" # 2024-07-09 12:14
LANG_COMMIT[es-CL]="63e0ced6ce18d4c69a7ea2a3abe5470822eea144" # 2024-07-09 12:14
LANG_COMMIT[es-ES]="967230a30cb768202ad164dfb252c618327f455b" # 2024-07-09 12:14
LANG_COMMIT[es-MX]="a12332f48724583c720da0d8ff6b8e32654e9200" # 2024-07-09 12:14
LANG_COMMIT[et]="6e2f66da09d35cf79bfe121b771c8abc36e0dc7d" # 2024-07-09 12:14
LANG_COMMIT[eu]="51c25788c594027d41898a01666db0054ea24f69" # 2024-07-09 12:14
LANG_COMMIT[fa]="98130adb7867760f17ba58177b6766ca47b7b1e6" # 2024-07-09 12:14
LANG_COMMIT[ff]="4afa4b4e4a33566c0166a349ac3eadcbb3f2770d" # 2024-07-09 12:14
LANG_COMMIT[fi]="aaa683848a4f1548361558cc03f2a33a89c9d34f" # 2024-07-09 17:51
LANG_COMMIT[fr]="f77487a0a53df4cb1074c0831a501fa6f4d5d080" # 2024-07-09 11:51
LANG_COMMIT[frp]="98f43af4d21725f0534d21b70fca8b9ab8caf63a" # 2024-07-09 12:15
LANG_COMMIT[fur]="f5298046ff89bac2fd92d567bec9371f648ccb6b" # 2024-07-09 12:15
LANG_COMMIT[fy-NL]="b00b914387999d744057652bc5a745a2d0b8a438" # 2024-07-09 12:15
LANG_COMMIT[ace]="415dee13b9cb64b188aa3e861483cbf8be26f2fe" # 2024-07-09 12:14
LANG_COMMIT[ach]="4c5fea93f2624411412afc90cda054f7d645e71e" # 2024-07-09 12:14
LANG_COMMIT[af]="b4e3c95d5b2bb8694ffa72d607ae418ee19b67e8" # 2024-07-09 12:14
LANG_COMMIT[ak]="f82cfa823d7ed911c5519c50e5881beb24def5fa" # 2024-07-09 12:14
LANG_COMMIT[an]="50a12624cd5cde9f018efa51b8433f84213e06f6" # 2024-07-09 12:14
LANG_COMMIT[ar]="2a6b9746463b26b41b8f9d36ee6b4a0b8be9d47a" # 2024-07-09 12:14
LANG_COMMIT[as]="08c274ff79475cae458e1ed35770f5c416ac34e2" # 2024-07-09 12:14
LANG_COMMIT[ast]="f515769d5719f8d673fd17fed6f5194de60d8c77" # 2024-07-09 12:14
LANG_COMMIT[az]="ef9e6a1e591411c9f8d13a6974a96d26b175e06e" # 2024-07-09 12:14
LANG_COMMIT[be]="cc17926ff5d45d8af339d44b457f0c4054d3037e" # 2024-07-09 12:14
LANG_COMMIT[bg]="139421848b25353e6deb4a2306ba7cf7e2434a58" # 2024-07-09 12:14
LANG_COMMIT[bn]="0fe5fe3663f0872781a811734c03f49bc4980e9f" # 2024-07-09 12:14
LANG_COMMIT[bn-BD]="97b9c13ea376d937d0211274a6ca9ec713015853" # 2024-07-09 12:14
LANG_COMMIT[bn-IN]="914a6bf0496b39ca2d05b70255fe88a1b49cd1f2" # 2024-07-09 12:14
LANG_COMMIT[bo]="84df3a5a7327aa2261436d043baba4d44109525b" # 2024-07-09 12:14
LANG_COMMIT[br]="b84bfc5072700b961775046a285cac685252b6e7" # 2024-07-09 12:14
LANG_COMMIT[brx]="a2f84d3d57cf765458aef85b548a79916b04c5a9" # 2024-07-09 12:14
LANG_COMMIT[bs]="b2c4f5a406d97c20a73e3715ae45b43138d7e906" # 2024-07-09 12:14
LANG_COMMIT[ca]="dae0084381471f8ccfa429791410b0a7fba64c56" # 2024-07-09 12:14
LANG_COMMIT[ca-valencia]="cbb59aed8a7baebaafe6bb38f456eb720f678f84" # 2024-07-09 12:14
LANG_COMMIT[cak]="a5ee9fc6b23aed9363802d0f8f7d6b23b09135bc" # 2024-07-09 12:14
LANG_COMMIT[ckb]="6656a93b69127ff4237221d57c3bea828d5397c7" # 2024-07-09 12:14
LANG_COMMIT[crh]="bf90ea2238bad0e2d1d66d06e19e8d6f0441cd83" # 2024-07-09 12:14
LANG_COMMIT[cs]="6ba70977cd61f28839645c9f4ec634a5466ca7e4" # 2024-07-09 12:14
LANG_COMMIT[csb]="86f0804df27a725987987f4211600d375b4ace78" # 2024-07-09 12:14
LANG_COMMIT[cy]="6c1e5fb7988fb3681140aed65b387d706de3d26a" # 2024-07-09 12:14
LANG_COMMIT[da]="803579fd1a4d3c7833dc4afaf97a82b6867bb59f" # 2024-07-09 12:21
LANG_COMMIT[de]="a24e44cd9012506fc45a04754e49212473474c8a" # 2024-07-09 12:14
LANG_COMMIT[dsb]="a9bc76f6383ee9ecc1708c6d203b895a9ce54973" # 2024-07-09 12:02
LANG_COMMIT[el]="bab0b0affe256e98c405cc07c802d6c37c1d9a17" # 2024-07-09 12:14
LANG_COMMIT[en-CA]="b8d5641eb6eb73587f78127813cf56803c7e3df5" # 2024-07-09 20:02
LANG_COMMIT[en-GB]="c9aa642b3c714f5cf3f2f6759179b4fb353f10e3" # 2024-07-09 21:11
LANG_COMMIT[en-ZA]="49e9391b1814f8e046484bfb4c4e3170480fca14" # 2024-07-09 12:14
LANG_COMMIT[eo]="1ce3bae8f941d0713e9984de5adbb360c54a7daf" # 2024-07-09 12:14
LANG_COMMIT[es-AR]="5864a7f25a6a7a2361a6f8e3cc21147044b85669" # 2024-07-09 12:14
LANG_COMMIT[es-CL]="63e0ced6ce18d4c69a7ea2a3abe5470822eea144" # 2024-07-09 12:14
LANG_COMMIT[es-ES]="967230a30cb768202ad164dfb252c618327f455b" # 2024-07-09 12:14
LANG_COMMIT[es-MX]="a12332f48724583c720da0d8ff6b8e32654e9200" # 2024-07-09 12:14
LANG_COMMIT[et]="6e2f66da09d35cf79bfe121b771c8abc36e0dc7d" # 2024-07-09 12:14
LANG_COMMIT[eu]="51c25788c594027d41898a01666db0054ea24f69" # 2024-07-09 12:14
LANG_COMMIT[fa]="98130adb7867760f17ba58177b6766ca47b7b1e6" # 2024-07-09 12:14
LANG_COMMIT[ff]="4afa4b4e4a33566c0166a349ac3eadcbb3f2770d" # 2024-07-09 12:14
LANG_COMMIT[fi]="aaa683848a4f1548361558cc03f2a33a89c9d34f" # 2024-07-09 17:51
LANG_COMMIT[fr]="f77487a0a53df4cb1074c0831a501fa6f4d5d080" # 2024-07-09 11:51
LANG_COMMIT[frp]="98f43af4d21725f0534d21b70fca8b9ab8caf63a" # 2024-07-09 12:15
LANG_COMMIT[fur]="f5298046ff89bac2fd92d567bec9371f648ccb6b" # 2024-07-09 12:15
LANG_COMMIT[fy-NL]="b00b914387999d744057652bc5a745a2d0b8a438" # 2024-07-09 12:15
LANG_COMMIT[ga-IE]="81fa22e91f77fb560a006d9e2b117fd44908c88e" # 2024-07-09 12:15
LANG_COMMIT[gd]="2abaadf5435eb16a848542dba66e960153ff21fb" # 2024-07-09 12:15
LANG_COMMIT[gl]="3815e938a79092509de9d6dc8ad68dfa687c2e08" # 2024-07-09 12:15
LANG_COMMIT[gn]="345d0564b53225cea036d558da6c9cc9631d0600" # 2024-07-09 12:15
LANG_COMMIT[gu-IN]="4c417d85c6adeb13363f8e721048a3376e60ff19" # 2024-07-09 12:15
LANG_COMMIT[gv]="6f7b1db9564812c5a31934bc4aaee8fec20574ad" # 2024-01-18 12:23
LANG_COMMIT[he]="1d0192e0b3db316c28c66a44b205d470f6d2db99" # 2024-07-09 18:31
LANG_COMMIT[hi-IN]="1dc8fbead967016c1db99c15fb830517ab8ff47f" # 2024-07-09 12:15
LANG_COMMIT[hr]="6e1f58afa0921fc32acceb53138e961a8ac98d25" # 2024-07-09 12:15
LANG_COMMIT[hsb]="bef42efe6cc5d978fb325e3c218c3575b5760b8f" # 2024-07-09 11:51
LANG_COMMIT[hto]="9a50e09f33a659dece65b66cfaec4062b7a2b5f4" # 2024-07-09 12:15
LANG_COMMIT[hu]="1af2c152e93eca93e536bbd4ab8e928e03037ac1" # 2024-07-09 12:15
LANG_COMMIT[hy-AM]="6d458eddae9425e3af5ce84b6f58b177a627889d" # 2024-07-09 12:15
LANG_COMMIT[hye]="e2769a41b66cc10f5a6c5124780eef514a2d6a21" # 2024-07-09 12:15
LANG_COMMIT[ia]="781c6aaf7c76abc11afb72966e351238beafe155" # 2024-07-09 12:15
LANG_COMMIT[id]="75345734324251821e1ab2063408341bfee7e389" # 2024-07-09 12:15
LANG_COMMIT[ilo]="eb7ce2f410caa5469e85c5543c2657e284c7b092" # 2024-07-09 12:15
LANG_COMMIT[is]="bd46be8d7a85aa0d5bc3b0764b24ae58c8705691" # 2024-07-09 16:21
LANG_COMMIT[it]="e87f39bed5fd0de323cee1fa3846ccfa75f36c18" # 2024-07-09 12:15
LANG_COMMIT[ixl]="05658410323015ad5747c2bc3b025ff33fef8bad" # 2024-07-09 12:15
LANG_COMMIT[ja]="edefe7232113f9a1245746e6a3d0d67e6b51518f" # 2024-07-09 12:15
LANG_COMMIT[ja-JP-mac]="9e525c9e74ce02969b89803924b616101e3ddb68" # 2024-07-09 12:15
LANG_COMMIT[ka]="83b0879c0b445a5eeed33aef9ae4e48e1f7499f1" # 2024-07-09 12:15
LANG_COMMIT[kab]="61cbc03243cba011800da857427d67b5bf1aa0c9" # 2024-07-09 12:15
LANG_COMMIT[kk]="0989c9d3fe2239a5246610d42e90e765d31e76b7" # 2024-07-09 12:15
LANG_COMMIT[km]="744f1af2e244845bc84d95749d2134d265bec6a1" # 2024-07-09 12:15
LANG_COMMIT[kn]="a25b877af1d8566badc43e8617f4ebeadb58eb63" # 2024-07-09 12:15
LANG_COMMIT[ko]="2f97fa6ac0e3e26ba509198d39e3853b72ad0f41" # 2024-07-09 18:21
LANG_COMMIT[kok]="da1205a9e7f595eb7d3998db782a1c3e5d6f7bdf" # 2024-07-09 12:15
LANG_COMMIT[ks]="dc2062030b7d9ceeaea69dbd630eee4511804e2e" # 2024-07-09 12:15
LANG_COMMIT[ku]="b3948fcb9315e51ce433cc33a59e5097d7ff869c" # 2024-07-09 12:15
LANG_COMMIT[lb]="8ec62ed0fd642072a10324045660e4d49e79014b" # 2024-07-09 12:15
LANG_COMMIT[lg]="683c632d814d8ab223e7fb3dfd483acd1d91eef2" # 2024-07-09 12:15
LANG_COMMIT[lij]="1799b25bb22202175c58258bbb9b2ae74629e261" # 2024-07-09 12:15
LANG_COMMIT[lo]="d280823b3d61ec11844d856291317c58e5261fdd" # 2024-07-09 12:15
LANG_COMMIT[lt]="59f18048eb0a08c7c46ef12e0abaf53af07853cb" # 2024-07-09 12:15
LANG_COMMIT[ltg]="97f7fd4bdcd56f0ac049c6f31f174a5190fd5d2d" # 2024-07-09 12:15
LANG_COMMIT[lv]="8740d268cb1df82af4a36c4be30aa30b00d7f758" # 2024-07-09 12:15
LANG_COMMIT[mai]="1989de4c4879f9bfb03c899ccd9b6db8a143932a" # 2024-07-09 12:15
LANG_COMMIT[meh]="13e9cc368d418e7e1b3d4a0ecd19521a4a78bfe0" # 2024-07-09 12:15
LANG_COMMIT[mix]="d22cf291018ea4462f0f6b570db479b3db23b2aa" # 2024-07-09 12:15
LANG_COMMIT[mk]="29709a90ff3fac3f711686227c21b80e7db94b3a" # 2024-07-09 12:15
LANG_COMMIT[ml]="75a1c0743f8a1bc5d3242267685114aa0363022e" # 2024-07-09 12:15
LANG_COMMIT[mn]="d50f05c9002ec2e5f350e8e2222cfeebcadaa547" # 2024-07-09 12:15
LANG_COMMIT[mr]="f2a8b306074fcea6248c4ea7b88142293416974e" # 2024-07-09 12:15
LANG_COMMIT[ms]="6634a4dda3cef1f6011d297d2d69bdb03ff85210" # 2024-07-09 12:15
LANG_COMMIT[my]="33eae9474f1c9f1f129f73f8728aa8010465af06" # 2024-07-09 12:15
LANG_COMMIT[nb-NO]="b90f9e50c4813a6efebd2fa806823d707699459d" # 2024-07-09 12:02
LANG_COMMIT[ne-NP]="8a1862e1fd6f2f4ba699e71499bc82b124e4df14" # 2024-07-09 12:15
LANG_COMMIT[nl]="c7741ce77100fdc71c89a51c71aec3ce5119c6a8" # 2024-07-09 12:15
LANG_COMMIT[nn-NO]="6b612d304b3242920e2f43e247bc63c7beb9efed" # 2024-07-09 12:15
LANG_COMMIT[nr]="0ae57f779b95c3a856df2717f6cf89381b0cb0a4" # 2024-07-09 12:15
LANG_COMMIT[nso]="168c334e5f44cd0b47deb1fdf4c6e19d13c3f343" # 2024-07-09 12:15
LANG_COMMIT[ny]="0279f25d9e71c3a42a463f8148168cb4ae7a53cc" # 2024-07-09 12:15
LANG_COMMIT[oc]="db4aaf9a41e0376ea2e735ea60df192a4f732229" # 2024-07-09 12:15
LANG_COMMIT[or]="2939fbbaaac7d654b6a18677522efec662de3245" # 2024-07-09 12:15
LANG_COMMIT[pa-IN]="66d8a510328c3ed8bba1f99e83dddf6bdf379a5e" # 2024-07-09 12:15
LANG_COMMIT[pai]="29047ceb5cb5f90e25fb23ddbb9a3e5173232942" # 2024-07-09 12:15
LANG_COMMIT[pbb]="fe6b5eb1d44e0c97581e751ea313f8d4578786e8" # 2024-07-09 12:15
LANG_COMMIT[pl]="ffd050236a85c7a9f6989bc3ec459257e2f394fd" # 2024-07-09 12:15
#LANG_COMMIT[ppl]="65b3ab6d50725e7c1e626abe7846b78557d28588" # 2024-01-18 12:34
LANG_COMMIT[pt-BR]="604739b89fb234808a2060e60dc9903abe7df9aa" # 2024-07-09 11:51
LANG_COMMIT[pt-PT]="1000c5704572002a58ea2b2d27a39334a420ed94" # 2024-07-09 12:15
#LANG_COMMIT[quy]="d6b514dd7fa7004290657c4698aef0ccbb9138da" # 2024-04-29 15:17
#LANG_COMMIT[qvi]="41079c0a8ce980779df96e20b264401d4fa1a620" # 2024-04-29 15:17
LANG_COMMIT[rm]="bcb807ee0623dd2d638733d4426c2a807df720da" # 2024-07-09 18:02
LANG_COMMIT[ro]="a6c782e754f21fe9911218b581966d6dc875ff05" # 2024-07-09 12:15
LANG_COMMIT[ru]="7134bcfc193e5b5a5ebbbb6b0b31a3f49125e3c8" # 2024-07-09 11:31
LANG_COMMIT[rw]="cc676e7b7f41a14060a3a04f50254baa79129bc7" # 2024-07-09 12:15
LANG_COMMIT[sah]="87710753a74a8fb25e00376e189a35b3c35cbc54" # 2024-07-09 12:15
LANG_COMMIT[sat]="c16bb7f954dece92e73decbce2bacffd6251cb94" # 2024-07-09 12:15
LANG_COMMIT[sc]="07ca01783f9333f9633a4764d103bbcc5949a69a" # 2024-07-09 12:15
LANG_COMMIT[scn]="c0eda44a0a434b9d9a84158a32682dcfe94da610" # 2024-07-09 12:15
LANG_COMMIT[sco]="812bd0b4471a845d2bc15ced303e98075a70b601" # 2024-07-09 12:15
LANG_COMMIT[si]="a05ce2a92874ead3344c0a1b218753ce6718111f" # 2024-07-09 12:15
LANG_COMMIT[sk]="b9738bf183b1b4f16eba67cbe30eb36a7571631a" # 2024-07-09 12:15
LANG_COMMIT[skr]="00eaf8d9e83b662814a5d1f30cd55cc1efa2b2e3" # 2024-07-09 12:15
LANG_COMMIT[sl]="886f8abe76b5c60707ade082de28b16035469e5b" # 2024-07-09 12:15
LANG_COMMIT[son]="e50833bbce27b9412e9c51edc08f6adaeaab354b" # 2024-07-09 12:15
LANG_COMMIT[sq]="5dbfb24210875e28996cf10e47734f17491424d5" # 2024-07-09 11:21
LANG_COMMIT[sr]="4c55ff582357dc725929967b5824179c2d528ea2" # 2024-07-09 12:15
LANG_COMMIT[ss]="03b42afe2f3107fdd70f1b271dff47267977addd" # 2024-07-09 12:16
LANG_COMMIT[st]="b1447a0d5dec6abfef19210eb7fb820d0a5bd814" # 2024-07-09 12:16
LANG_COMMIT[sv-SE]="16e09411019a19db559083238ada701ff5476b22" # 2024-07-09 10:31
LANG_COMMIT[sw]="353f49adbb972d7e2b0dbaf039541cf779176484" # 2024-07-09 12:16
LANG_COMMIT[szl]="fbc305bf93e75cd341aada117021c222251bad2f" # 2024-07-09 12:16
LANG_COMMIT[ta]="f96f81a9c02262e404e4f98bc18efc91426d79a5" # 2024-07-09 12:16
LANG_COMMIT[ta-LK]="45f39c201b2b78857c80af71faa9f6262253298e" # 2024-07-09 12:16
LANG_COMMIT[te]="5d2837843d741b4ec19195823474711cde097bf4" # 2024-07-09 12:16
LANG_COMMIT[tg]="e4dd5093dfe6b9c23313b946861daff2cd20e369" # 2024-07-09 12:16
LANG_COMMIT[th]="dcd298cc2947fb1de9f852324525f4218381cf34" # 2024-07-09 12:16
LANG_COMMIT[tl]="b5249deac845dc2fbdb8c90431d41c3c0d440d20" # 2024-07-09 12:16
LANG_COMMIT[tn]="854f6bdb28c0200bd779dd05b410bc70fd583e71" # 2024-07-09 12:16
LANG_COMMIT[tr]="e7f0335e15cee835c95b7ea376697efe46069517" # 2024-07-09 12:16
LANG_COMMIT[trs]="23f725b65aa5b34f74979c337a081539bb23b523" # 2024-07-09 12:16
LANG_COMMIT[ts]="f54b95a227f23a923e2b1982497ac9576960114d" # 2024-07-09 12:16
LANG_COMMIT[tsz]="f4f23123fd7ff4143d0debc90dcd848de157d4b6" # 2024-07-09 12:16
LANG_COMMIT[uk]="0042931571cd741f26adff40427a5c9339980632" # 2024-07-09 12:16
LANG_COMMIT[ur]="43fb6ead27551512c0c1cf12fceb9b74392c670d" # 2024-07-09 12:16
LANG_COMMIT[uz]="95853f4be89e03315239e5285c251a5edcbcda0c" # 2024-07-09 12:16
LANG_COMMIT[ve]="095586949a749497c2d3d8410f649f83fd719a10" # 2024-07-09 12:16
LANG_COMMIT[vi]="b1c3aff4c1098d6467520431471ea75bf6acb55e" # 2024-07-09 12:16
LANG_COMMIT[wo]="cc4c1bf9164f7d673d82087496649b0835553138" # 2024-07-09 12:16
LANG_COMMIT[xcl]="51e97d471c8c865cbebd584a0a250e86df0de5a3" # 2024-07-09 12:16
LANG_COMMIT[xh]="e8621ee49ae483944667c36c99bb23052551204c" # 2024-07-09 12:16
LANG_COMMIT[zam]="d3435879a40f812b026f821beb21331c1c9048bc" # 2024-07-09 12:16
LANG_COMMIT[zh-CN]="9232e1cf3644980c5b45e74cb0bec8e161271b44" # 2024-07-09 12:16
LANG_COMMIT[zh-TW]="bdede5e586d2288b0a3d4bf0c27744cd682ee1ba" # 2024-07-09 11:12
LANG_COMMIT[zu]="2f8eb432efd5660f5e1ab85164858a949f27b4b9" # 2024-07-09 12:16

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
	unpack "firefox-${PV}esr.source.tar.xz"
}

src_prepare() {
	default_src_prepare

	# Remove the minimum necessary for script to work offline
	sed -i '/^verify_sources$/d' makeicecat || die
	sed -i '/^fetch_l10n$/d' makeicecat || die
	sed -i '/^fetch_source$/d' makeicecat || die
	sed -i '/^extract_sources$/d' makeicecat || die
	sed -i '/^prepare_env$/d' makeicecat || die

	#mkdir "${S}/output" || die
	#cp "${DISTDIR}/firefox-${PV}esr.source.tar.xz" "${S}/output" || die
	mv "${WORKDIR}/firefox-${PV}" "${S}/icecat-${PV}" || die

	L10N_DIR="${S}/icecat-${PV}/l10n"
	mkdir -p "${L10N_DIR}" || die
	for lang in "${!LANG_COMMIT[@]}"; do
		#en_US is handled internally
		[[ "${lang}" == "en-US" ]] && continue
		mv "${WORKDIR}/${lang}-${LANG_COMMIT[${lang}]}" "${L10N_DIR}/${lang}" || die
		mkdir -p "${L10N_DIR}/${lang}/browser/chrome/browser/preferences" || die
		touch "${L10N_DIR}/${lang}/browser/chrome/browser/preferences/advanced-scripts.dtd" || die
		rm -rf "${L10N_DIR}/${lang}/.hg*" || die
	done
	mv "${WORKDIR}/compare-locales-RELEASE_${COMPARE_LOCALES_PV//./_}" "${L10N_DIR}/compare-locales" || die
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
		#insinto /usr/src/makeicecat-"${PV}"
		insinto "${PORTAGE_ACTUAL_DISTDIR}"
		doins "${S}/icecat-${PV}-${PP}gnu${GV}.tar.bz2"
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
