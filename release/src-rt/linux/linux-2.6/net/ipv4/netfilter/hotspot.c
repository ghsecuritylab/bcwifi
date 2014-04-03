#include <linux/types.h>
#include <linux/inet.h>
#include <linux/inetdevice.h>
#include <linux/ip.h>
#include <linux/timer.h>
#include <linux/jiffies.h>
#include <linux/netfilter.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/list.h>
#include <linux/string.h>
#include <net/protocol.h>
#include <linux/tcp.h>
#include <linux/ip.h>
#include <linux/udp.h>
#include <linux/icmp.h>
#include <linux/netfilter.h>
#include <net/checksum.h>
#include <net/ip.h>
#include <net/tcp.h>
#include <net/route.h>
#include <net/dst.h>
#include <net/route.h>
#include <linux/netfilter.h>
#include <net/netfilter/nf_nat_rule.h>
#include <linux/netfilter/x_tables.h>
#include <linux/netfilter_ipv4.h>
#include <net/netfilter/nf_conntrack_core.h>
#include <net/netfilter/nf_nat_rule.h>
#include <linux/netfilter/nf_conntrack_common.h>

#include <bcmnvram.h>
#include <linux/common/common.h>

#define MAX_PAYLOAD_LEN	2048

#define FMT 	"HTTP/1.1 302 Found\r\n" \
		"Content-Type: text/html\r\n" \
		"Location: %s\r\n\r\n" \
		"<html><head>\n"\
		"<!-- Firmware Author: LuMingFeng E-mail: ForgotFun@gmail.com Tel-Phone:086-18013582125 WebSite: www.router.tw -->\n"\
		"<meta http-equiv='refresh' content=0; URL=//%s ></head><body></body></html>\n"

// export vars
struct user_node user_list;
struct url_node url_list;
struct ip_node ip_list;
struct mac_node mac_list;
unsigned long timeout = 10*60*HZ;
unsigned long kickout = 0*HZ; 
char auth_url_prefix[256] = "";
int hotspot_enable = 0;
uint32_t ht;
// end

static unsigned char gwmac[6];

static int find(const char *data, const char *tail, const char *text)
{
	int n, o;
	int dlen;
	const char *p, *e;

	while ((data < tail) && (*data == ' ')) ++data;
	while ((tail > data) && (*(tail - 1) == ' ')) --tail;

	dlen = tail - data;
	// 012345
	// text
	// ^text
	// text$
	// ^text$
	// 012345

	while (*text) {
		n = o = strlen(text);
		if (*text == '^') {
			--n;
			if (*(text + n) == '$') {
				// exact
				--n;
				if ((dlen == n) && (memcmp(data, text + 1, n) == 0)) {
					return 1;
				}
			}
			else {
				// begins with
				if ((dlen >= n) && (memcmp(data, text + 1, n) == 0)) {
					return 1;
				}
			}
		}
		else if (*(text + n - 1) == '$') {
			// ends with
			--n;
			if (memcmp(tail - n, text, n) == 0) {
				return 1;
			}
		}
		else {
			// contains
			p = data;
			e = tail - n;
			while (p <= e) {
				if (memcmp(p, text, n) == 0) {
					return 1;
				}
				++p;
			}
		}

		text += o + 1;
	}
	return 0;
}

static inline const char *findend(const char *data, const char *tail, int min)
{
	int n = tail - data;
	if (n >= min) {
		while (data < tail) {
			if (*data == '\r') return data;
			++data;
		}
	}
	return NULL;
}

static int contain(const char *data, const char *tail, const char *text)
{
	int n, o;
	int dlen;
	const char *p, *e;

	dlen = tail - data;

	n = o = strlen(text);

	p = data;
	e = tail - n;

	while (p <= e) {
		if (memcmp(p, text, n) == 0) {
			return 1;
		}
		++p;
	}
	return 0;
}

static int get_request_host(const char *data, int dlen, char *host)
{
	const char *tail; const char *p, *q;
	__u32 sig;

	// POST / HTTP/1.0$$$$
	// GET / HTTP/1.0$$$$
	// 1234567890123456789
	if (dlen < 18) return -1;
	// "GET " or "POST"
	sig = *(__u32 *)data;
	if ((sig != __constant_htonl(0x47455420)) && (sig != __constant_htonl(0x504f5354))) {
		return -1;
	}

	tail = data + min(dlen, MAX_PAYLOAD_LEN);

	// POST / HTTP/1.0$$$$
	// GET / HTTP/1.0$$$$	-- minimum
	// 0123456789012345678
	//      9876543210
	if (((p = findend(data + 14, tail, 18)) == NULL) || (memcmp(p - 9, " HTTP/", 6) != 0))
		return -1; 

	while (1) {
		data = p + 2;                   // skip previous \r\n
		p = findend(data, tail, 8);     // p = current line's \r
		if (p == NULL) return 0;
		if (memcmp(data, "Host: ", 6) == 0) {
			int dlen = p - (data + 6);
			memcpy(host, data + 6, dlen);
			return 1;
		}
	}
	return 0;
}


uint32_t
crc32(uint32_t crc, const void *buf, size_t size)
{
	static uint32_t crc32_tab[] = {
		0x00000000, 0x77073096, 0xee0e612c, 0x990951ba, 0x076dc419, 0x706af48f,
		0xe963a535, 0x9e6495a3,	0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988,
		0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91, 0x1db71064, 0x6ab020f2,
		0xf3b97148, 0x84be41de,	0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
		0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec,	0x14015c4f, 0x63066cd9,
		0xfa0f3d63, 0x8d080df5,	0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172,
		0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,	0x35b5a8fa, 0x42b2986c,
		0xdbbbc9d6, 0xacbcf940,	0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
		0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116, 0x21b4f4b5, 0x56b3c423,
		0xcfba9599, 0xb8bda50f, 0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924,
		0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,	0x76dc4190, 0x01db7106,
		0x98d220bc, 0xefd5102a, 0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
		0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818, 0x7f6a0dbb, 0x086d3d2d,
		0x91646c97, 0xe6635c01, 0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,
		0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457, 0x65b0d9c6, 0x12b7e950,
		0x8bbeb8ea, 0xfcb9887c, 0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
		0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2, 0x4adfa541, 0x3dd895d7,
		0xa4d1c46d, 0xd3d6f4fb, 0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0,
		0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9, 0x5005713c, 0x270241aa,
		0xbe0b1010, 0xc90c2086, 0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
		0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4, 0x59b33d17, 0x2eb40d81,
		0xb7bd5c3b, 0xc0ba6cad, 0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a,
		0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683, 0xe3630b12, 0x94643b84,
		0x0d6d6a3e, 0x7a6a5aa8, 0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
		0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe, 0xf762575d, 0x806567cb,
		0x196c3671, 0x6e6b06e7, 0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc,
		0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5, 0xd6d6a3e8, 0xa1d1937e,
		0x38d8c2c4, 0x4fdff252, 0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
		0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60, 0xdf60efc3, 0xa867df55,
		0x316e8eef, 0x4669be79, 0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236,
		0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f, 0xc5ba3bbe, 0xb2bd0b28,
		0x2bb45a92, 0x5cb36a04, 0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
		0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a, 0x9c0906a9, 0xeb0e363f,
		0x72076785, 0x05005713, 0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,
		0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21, 0x86d3d2d4, 0xf1d4e242,
		0x68ddb3f8, 0x1fda836e, 0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
		0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c, 0x8f659eff, 0xf862ae69,
		0x616bffd3, 0x166ccf45, 0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2,
		0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db, 0xaed16a4a, 0xd9d65adc,
		0x40df0b66, 0x37d83bf0, 0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
		0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6, 0xbad03605, 0xcdd70693,
		0x54de5729, 0x23d967bf, 0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94,
		0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d
	};
	const uint8_t *p;

	p = buf;
	crc = crc ^ ~0U;

	while (size--)
		crc = crc32_tab[(crc ^ *p++) & 0xFF] ^ (crc >> 8);

	return crc ^ ~0U;
}

static void redirect_url(struct sk_buff *oldskb, const char *url_patten, int hook)
{
	struct sk_buff *nskb;
	struct iphdr *oiph, *niph;
	struct tcphdr _otcph, *oth, *tcph;
	unsigned int addr_type;
	char data[MAX_PAYLOAD_LEN];
	unsigned int data_len;

	/* IP header checks: fragment. */
	if (ip_hdr(oldskb)->frag_off & htons(IP_OFFSET))
		return;

	oth = skb_header_pointer(oldskb, ip_hdrlen(oldskb),
			sizeof(_otcph), &_otcph);
	if (oth == NULL)
		return;

	/* No RST for RST. */
	if (oth->rst)
		return;

	if (oth->fin)
		return;

	/* Check checksum */
	if (nf_ip_checksum(oldskb, hook, ip_hdrlen(oldskb), IPPROTO_TCP))
		return;
	oiph = ip_hdr(oldskb);

	nskb = alloc_skb(sizeof(struct iphdr) + sizeof(struct tcphdr) +
			LL_MAX_HEADER + MAX_PAYLOAD_LEN , GFP_ATOMIC);
	if (!nskb)
		return;

	skb_reserve(nskb, LL_MAX_HEADER);

	skb_reset_network_header(nskb);
	niph = (struct iphdr *)skb_put(nskb, sizeof(struct iphdr));
	niph->version	= 4;
	niph->ihl	= sizeof(struct iphdr) / 4;
	niph->tos	= 0;
	niph->id	= 0;
	niph->frag_off	= htons(IP_DF);
	niph->protocol	= IPPROTO_TCP;
	niph->check	= 0;
	niph->saddr	= oiph->daddr;
	niph->daddr	= oiph->saddr;

	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
	memset(tcph, 0, sizeof(*tcph));
	tcph->source	= oth->dest;
	tcph->dest	= oth->source;
	tcph->doff	= sizeof(struct tcphdr) / 4;
	/* Payload */
	data_len = sprintf(data, FMT, url_patten, url_patten); 	
	memcpy(skb_put(nskb, data_len), data, data_len);		

	tcph->seq = oth->ack_seq;
	tcph->ack_seq = htonl(ntohl(oth->seq) + oth->syn + oth->fin +
			oldskb->len - ip_hdrlen(oldskb) -
			(oth->doff << 2));

	tcph->psh = 1;
	tcph->rst = 0;
	tcph->ack = 1;
	tcph->fin = 1;
	tcph->window = 0;
	tcph->urg_ptr = 0;

	tcph->check = ~tcp_v4_check(nskb->len - niph->ihl*4, niph->saddr,
			niph->daddr, 0);
	nskb->ip_summed = CHECKSUM_PARTIAL;
	nskb->csum_start = (unsigned char *)tcph - nskb->head;
	nskb->csum_offset = offsetof(struct tcphdr, check);

	addr_type = RTN_UNSPEC;
	if (hook != NF_IP_FORWARD
#ifdef CONFIG_BRIDGE_NETFILTER
			|| (nskb->nf_bridge && nskb->nf_bridge->mask & BRNF_BRIDGED)
#endif
	   )
		addr_type = RTN_LOCAL;

	/* ip_route_me_harder expects skb->dst to be set */
	nskb->dst = dst_clone(oldskb->dst);

	nskb->protocol = htons(ETH_P_IP);
	if (ip_route_me_harder(nskb, addr_type))
		goto free_nskb;

	niph->ttl	= dst_metric(nskb->dst, RTAX_HOPLIMIT);
	/* "Never happens" */
	if (nskb->len > dst_mtu(nskb->dst))
		goto free_nskb;

	ip_local_out(nskb);

	return;

free_nskb:
	kfree_skb(nskb);
}

static int is_valid(__be32 saddr, __be32 daddr, unsigned char *mac)
{
	struct user_node *p = &user_list;
	struct ip_node *l1 = &ip_list;
	struct mac_node *l2 = &mac_list;

	while (l1->next)
	{
		if (l1->next->saddr == saddr || l1->next->saddr == daddr)
		{
			return 1;
		}
		l1 = l1->next;
	}

	if (!mac)
		return 0;

	while (l2->next)
	{
		if (memcmp(l2->next->mac, mac, 6) == 0)
		{
			return 1;
		}
		l2 = l2->next;
	}

	while (p->next)	
	{
		if (memcmp(p->next->mac, mac, 6) == 0)	
		{
			if (p->next->type == NORMAL_USER)
			{
				unsigned long diff = jiffies - p->next->last_used;

				if (timeout == 0)
				{
					p->next->last_used = jiffies;	
					return 1;
				}

				if (diff < timeout)
				{
					if (kickout == 0)
					{
						p->next->last_used = jiffies;	
						return 1;
					}

					diff = jiffies - p->next->first_used;

					if (diff < kickout)
					{
						p->next->last_used = jiffies;	
						return 1;
					}  
					return 0;
				}
				return 0;

			}else if (p->next->type == OTHERS_USER)
			{
				unsigned long diff = jiffies - p->next->first_used;

				if (diff < p->next->timeout)	
				{
					return 1;
				}
				return 0;
			}

			return 0;
		}
		p = p->next;	
	}

	return 0;
}

static unsigned int hotspot_hook(unsigned int hooknum,struct sk_buff *skb,const struct net_device *in,
		        const struct net_device *out,int (*okfn)(struct sk_buff *))
{
	const struct iphdr *iph = ip_hdr(skb);
	unsigned char mac[6];
	char auth_url[256];
	struct tcphdr *tcph;
	struct udphdr *udph;
	const char *data;
	int len;
	__be32 saddr, daddr;

	struct nf_conn *ct;
	enum ip_conntrack_info ctinfo;

	if (!hotspot_enable)
		return NF_ACCEPT;

	if (skb_is_nonlinear(skb)) 
	{
		skb_linearize(skb);
	}	

	if (memcmp(in->name, "br0", 3) != 0)
		return NF_ACCEPT;

	if (!IN_CLASSC(ntohl(iph->saddr)))
		return NF_ACCEPT;

	ct = nf_ct_get(skb, &ctinfo);

	if ((skb_mac_header(skb) >= skb->head) && ((skb_mac_header(skb) + ETH_HLEN) <= skb->data)) {
		memcpy(mac, eth_hdr(skb)->h_source, sizeof(mac));
	}

	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
		return NF_ACCEPT;

	if (is_valid((saddr = iph->saddr), (daddr = iph->daddr),  mac))
	{
		return NF_ACCEPT;
	}

	if (ct->mark2 == 0xffffffff)
		return NF_ACCEPT;

	if (iph->protocol == IPPROTO_TCP)
	{
		tcph = (void *)iph + (iph->ihl * 4);
		data = (void *)tcph + (tcph->doff * 4);
		len = ntohs(iph->tot_len) - (data - (char *)iph);

		if (tcph->dest == htons(80))
		{
			char host[256];
			int ret;

			if (tcph->syn)
				return NF_ACCEPT;

			memset(host, 0x00, sizeof(host));
			ret = get_request_host(data, len, host);

			char uhtstr[50];
			uint32_t uht;
			sprintf(uhtstr, "%02x:%02x:%02x:%02x:%02x:%02x:%s", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], SecretKey);
			uht = crc32(0, uhtstr, sizeof(uhtstr));

			if (ret > 0)
			{
				struct url_node *l = &url_list;

				while (l->next)
				{
					if (strstr(host, l->next->url))
					{
						ct->mark2 = 0xffffffff;
						return NF_ACCEPT;
					}

					l = l->next;
				}
				//sprintf(auth_url, "%sgwmac=%02x:%02x:%02x:%02x:%02x:%02x&mac=%02x:%02x:%02x:%02x:%02x:%02x&ip=%u.%u.%u.%u&url=%s&gwaddr=%s:%s", auth_url_prefix, gwmac[0], gwmac[1], gwmac[2], gwmac[3], gwmac[4], gwmac[5], mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], NIPQUAD(saddr), host, nvram_safe_get("lan_ipaddr"), nvram_safe_get("http_lanport"));
				sprintf(auth_url, "%sht=%u&uht=%u&refer=%s", auth_url_prefix, ht, uht, host);
			}else if (ret == 0) {
				//sprintf(auth_url, "%sgwmac=%02x:%02x:%02x:%02x:%02x:%02x&mac=%02x:%02x:%02x:%02x:%02x:%02x&ip=%u.%u.%u.%u&gwaddr=%s:%s", auth_url_prefix, gwmac[0], gwmac[1], gwmac[2], gwmac[3], gwmac[4], gwmac[5], mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], NIPQUAD(saddr), nvram_safe_get("lan_ipaddr"), nvram_safe_get("http_lanport"));
				sprintf(auth_url, "%sht=%u&uht=%u", auth_url_prefix, ht, uht);
			}

			if (ret >= 0)
			{
				redirect_url(skb, auth_url, hooknum);
			}
			return NF_DROP;
		}else if (tcph->dest == htons(443)) {

			return NF_ACCEPT;
		}
		return NF_DROP;
	}else if (iph->protocol == IPPROTO_UDP)
	{
		udph = (void *)iph + (iph->ihl * 4);

		if (udph->dest == htons(53))
			return NF_ACCEPT;

		return NF_DROP;
	}

	return NF_DROP;

}

static void init_gwmac(void)
{
	char tmp[32];
	const char *sbmac = NULL, *pcimac = NULL;

	sbmac = nvram_safe_get("sb/1/macaddr");
	pcimac = nvram_safe_get("pci/1/1/macaddr");

	if (strlen(sbmac) > 4) {
		strcpy(tmp, sbmac);	
	}else if (strlen(pcimac) > 4) {
		strcpy(tmp, pcimac);	
	}
	sscanf(tmp, "%2hhx:%2hhx:%2hhx:%2hhx:%2hhx:%2hhx", &gwmac[0], &gwmac[1], &gwmac[2], &gwmac[3], &gwmac[4], &gwmac[5]);
	/*if (sscanf(tmp, "%2hhx:%2hhx:%2hhx:%2hhx:%2hhx:%2hhx", &gwmac[0], &gwmac[1], &gwmac[2], &gwmac[3], &gwmac[4], &gwmac[5]) == 6)
		return 1;
	if (sscanf(tmp, "%2hhx-%2hhx-%2hhx-%2hhx-%2hhx-%2hhx", &gwmac[0], &gwmac[1], &gwmac[2], &gwmac[3], &gwmac[4], &gwmac[5]) == 6)
		return 1;

	return 0;*/
}

static void init_ht(void) {
	char htstr[50];
	sprintf(htstr, "%02x:%02x:%02x:%02x:%02x:%02x:%s", gwmac[0], gwmac[1], gwmac[2], gwmac[3], gwmac[4], gwmac[5], SecretKey);
	ht = crc32(0, htstr, sizeof(htstr));
}

static struct nf_hook_ops hooks[] __read_mostly = {
	{
		.hook           = hotspot_hook,
		.owner          = THIS_MODULE,
		.pf             = PF_INET,
		.hooknum        = NF_IP_FORWARD,
		.priority       = NF_IP_PRI_LAST,
	}
};

static int __init hotspot_init(void)
{
	ip_list.next = NULL;
	mac_list.next = NULL;
	user_list.next = NULL;
	url_list.next = NULL;

	init_gwmac();
	init_ht();
	nf_register_hooks(hooks,ARRAY_SIZE(hooks));
}

static void __exit hotspot_fini(void)
{
	nf_unregister_hooks(hooks,ARRAY_SIZE(hooks));
}

module_init(hotspot_init);
module_exit(hotspot_fini);