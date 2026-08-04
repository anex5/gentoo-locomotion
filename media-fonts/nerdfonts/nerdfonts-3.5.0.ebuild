# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font check-reqs

DESCRIPTION="Nerd Fonts is a project that patches developer targeted fonts with glyphs"
HOMEPAGE="https://github.com/ryanoasis/nerd-fonts"
COMMON_URI="https://github.com/ryanoasis/nerd-fonts/releases/download/v${PV/_rc/-RC}"

FONTS=(
	0xProto
	3270
	AdwaitaMono
	Agave
	AnnotationMono
	AnonymousPro
	Arimo
	AtkinsonHyperlegibleMono
	AurulentSansMono
	BigBlueTerminal
	BitstreamVeraSansMono
	CascadiaCode
	CascadiaMono
	CodeNewRoman
	ComicShannsMono
	CommitMono
	Cousine
	D2Coding
	DaddyTimeMono
	DejaVuSansMono
	DepartureMono
	DroidSansMono
	EnvyCodeR
	FantasqueSansMono
	FiraCode
	FiraMono
	GeistMono
	Go-Mono
	Gohu
	GoogleSansCode
	Hack
	Hasklig
	HeavyData
	Hermit
	iA-Writer
	IBMPlexMono
	Inconsolata
	InconsolataGo
	InconsolataLGC
	IntelOneMono
	Iosevka
	IosevkaTerm
	IosevkaTermSlab
	JetBrainsMono
	Lekton
	LiberationMono
	Lilex
	MartianMono
	Meslo
	Monaspace
	Monofur
	Monoid
	Mononoki
	MPlus
	NerdFontsSymbolsOnly
	Noto
	OpenDyslexic
	Overpass
	ProFont
	ProggyClean
	Recursive
	RobotoMono
	ShareTechMono
	SourceCodePro
	SpaceMono
	Terminus
	Tinos
	Ubuntu
	UbuntuMono
	UbuntuSans
	VictorMono
	ZedMono
)

gen_src_uri() {
	local f flag
	for f in ${FONTS[*]}; do
		flag="${f,,}"
		echo "${flag//-}? ( ${COMMON_URI}/${f}.tar.xz -> ${f}-nf-${PV}.gh.tar.xz )"
	done
}

SRC_URI="
	https://github.com/ryanoasis/nerd-fonts/raw/v${PV}/10-nerd-font-symbols.conf -> ${P}-10-nerd-font-symbols.conf
	$(gen_src_uri)
"
S="${WORKDIR}"
LICENSE="MIT
	OFL-1.1
	Apache-2.0
	CC-BY-SA-4.0
	BitstreamVera
	BSD
	WTFPL-2
	Vic-Fieger-License
	UbuntuFontLicense-1.0"
SLOT="0"
KEYWORDS="*"

RDEPEND="media-libs/fontconfig"

CHECKREQS_DISK_BUILD="3G"
CHECKREQS_DISK_USR="4G"

declare -l IUSE_FLAGS
IUSE_FLAGS=(${FONTS[*]//-})
IUSE="${IUSE_FLAGS[*]} +otf +ttf"
REQUIRED_USE="|| ( ${IUSE_FLAGS[*]} )"

RESTRICT="mirror"

FONT_CONF=(
	"${S}/10-nerd-font-symbols.conf"
)
FONT_S=${S}

pkg_pretend() {
	check-reqs_pkg_setup
}

src_unpack() {
	default
	cp "${DISTDIR}/${P}-10-nerd-font-symbols.conf" "${S}/10-nerd-font-symbols.conf" || die
}

src_install() {
	declare -A font_filetypes
	local otf_file_number=0 ttf_file_number=0

	use otf && otf_file_number=$(ls "${S}" | grep -i otf | wc -l)
	use ttf && ttf_file_number=$(ls "${S}" | grep -i ttf | wc -l)

	if [[ ${otf_file_number} != 0 ]]; then
		font_filetypes[otf]=
	fi

	if [[ ${ttf_file_number} != 0 ]]; then
		font_filetypes[ttf]=
	fi

	FONT_SUFFIX="${!font_filetypes[@]}"

	font_src_install
}

pkg_postinst() {
	einfo "Installing font-patcher via an ebuild is hard, because paths are hardcoded differently"
	einfo "in .sh files. You can still get it and use it by git cloning the nerd-font project and"
	einfo "running it from the cloned directory."
	einfo "https://github.com/ryanoasis/nerd-fonts"

	elog "You might have to enable 50-user.conf and 10-nerd-font-symbols.conf by using"
	elog "eselect fontconfig"
}
