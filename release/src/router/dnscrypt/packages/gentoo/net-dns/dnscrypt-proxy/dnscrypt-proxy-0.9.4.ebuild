EAPI="3"

inherit eutils flag-o-matic

DESCRIPTION="A tool for securing communications between a client and a DNS resolver"
HOMEPAGE="http://www.opendns.com/technology/dnscrypt/"
SRC_URI="http://download.dnscrypt.org/dnscrypt-proxy/dnscrypt-proxy-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 i386"

pkg_setup() {
	enewgroup dnscrypt
	enewuser dnscrypt -1 -1 /var/empty dnscrypt
}

src_configure() {
	append-ldflags -Wl,-z,noexecstack || die
	econf --enable-nonblocking-random || die
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	newinitd "${FILESDIR}/dnscrypt-proxy.initd" dnscrypt-proxy || die "newinitd failed"
	newconfd "${FILESDIR}/dnscrypt-proxy.confd" dnscrypt-proxy || die "newconfd failed"

	dodoc {AUTHORS,COPYING,INSTALL,NEWS,README,README.markdown,TECHNOTES,THANKS} || die "dodoc failed"
}
