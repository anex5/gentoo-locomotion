# Copyright 1999-2026 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 edos2unix

DESCRIPTION="All in one tool for Information Gathering"
HOMEPAGE="https://fb.me/mohamed.riahi.official.account"

EGIT_REPO_URI="https://github.com/Moham3dRiahi/Th3inspector"

LICENSE="MIT"
SLOT="0"
IUSE=""

DEPEND="
	dev-perl/JSON
	dev-lang/perl
	dev-vcs/git
"

src_prepare() {
	local ver="git-${EGIT_VERSION:0:6}"
	#sed -i "/^GITVER[[:space:]]*=/s:=.*:=${ver}:" mk/git.mk || die
	einfo "Producing ChangeLog from Git history"
	GIT_DIR="${S}/.git" git log >"${S}"/ChangeLog

	# Allow user patches to be applied without modifying the ebuild
	eapply_user

	edos2unix $(find ${S} -type 'f')
}

src_install() {
	dodir /usr/share/Th3inspector
	insinto /usr/share/Th3inspector
	doins Th3inspector.pl
	fperms 0755 /usr/share/Th3inspector/Th3inspector.pl
	dosym ../share/Th3inspector/Th3inspector.pl /usr/bin/Th3inspector
}

