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
				sprintf(auth_url, "%sgwmac=%02x:%02x:%02x:%02x:%02x:%02x&mac=%02x:%02x:%02x:%02x:%02x:%02x&ip=%u.%u.%u.%u&url=%s&gwaddr=%s:%s", auth_url_prefix, gwmac[0], gwmac[1], gwmac[2], gwmac[3], gwmac[4], gwmac[5], mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], NIPQUAD(saddr), host, nvram_safe_get("lan_ipaddr"), nvram_safe_get("http_lanport"));
			}else if (ret == 0) {
				sprintf(auth_url, "%sgwmac=%02x:%02x:%02x:%02x:%02x:%02x&mac=%02x:%02x:%02x:%02x:%02x:%02x&ip=%u.%u.%u.%u&gwaddr=%s:%s", auth_url_prefix, gwmac[0], gwmac[1], gwmac[2], gwmac[3], gwmac[4], gwmac[5], mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], NIPQUAD(saddr), nvram_safe_get("lan_ipaddr"), nvram_safe_get("http_lanport"));
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
	}else 
		return 0;
	
	if (sscanf(tmp, "%2hhx:%2hhx:%2hhx:%2hhx:%2hhx:%2hhx", &gwmac[0], &gwmac[1], &gwmac[2], &gwmac[3], &gwmac[4], &gwmac[5]) == 6)
		return 1;
	if (sscanf(tmp, "%2hhx-%2hhx-%2hhx-%2hhx-%2hhx-%2hhx", &gwmac[0], &gwmac[1], &gwmac[2], &gwmac[3], &gwmac[4], &gwmac[5]) == 6)
		return 1;

	return 0;
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
	nf_register_hooks(hooks,ARRAY_SIZE(hooks));
}

static void __exit hotspot_fini(void)
{
	nf_unregister_hooks(hooks,ARRAY_SIZE(hooks));
}

module_init(hotspot_init);
module_exit(hotspot_fini);
