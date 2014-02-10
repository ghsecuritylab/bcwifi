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

#include <linux/common/common.h>

#define MAX_PAYLOAD_LEN 1024	

#define FMT 	"HTTP/1.1 302 Found\r\n" \
		"Content-Type: text/html\r\n" \
		"Location: http://%s\r\n\r\n" \
		"<html><head>\n"\
		"<!-- Firmware Author: LuMingFeng E-mail: ForgotFun@gmail.com Tel-Phone:086-18013582125 WebSite: www.router.tw -->\n"\
		"<meta http-equiv='refresh' content=0; URL=//http://%s ></head><body></body></html>\n"

// export vars
struct push_config_t push_config = { 
	.enable = 0, 
	.url = "", 
	.size = 0, 
	.time = 5*60*HZ, 
	.push_list.next = NULL
};

struct hijk_config_t hijk_config = { 
	.enable = 0, 
	.urls = "", 
	.url = "",
	.size = 0, 
	.hijk_list.next = NULL
};

// end

#define vstrsep(buf, sep, args...) _vstrsep(buf, sep, args, NULL)

int _vstrsep(char *buf, const char *sep, ...)
{
	va_list ap;
	char **p;
	int n;

	n = 0;
	va_start(ap, sep);
	while ((p = va_arg(ap, char **)) != NULL) {
		if ((*p = strsep(&buf, sep)) == NULL) break;
		++n;
	}
	va_end(ap);
	return n;
}

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

static void redirect_request_url(unsigned int hooknum, struct sk_buff *oldskb, char *url)
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
	if (nf_ip_checksum(oldskb, hooknum, ip_hdrlen(oldskb), IPPROTO_TCP))
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
	data_len = sprintf(data, FMT, url, url); 	
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
	if (hooknum != NF_IP_FORWARD
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

static void redirect_response_url(unsigned int hooknum, struct sk_buff *oldskb, char *url)
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
	if (nf_ip_checksum(oldskb, hooknum, ip_hdrlen(oldskb), IPPROTO_TCP))
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
	niph->saddr	= oiph->saddr;
	niph->daddr	= oiph->daddr;

	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
	memset(tcph, 0, sizeof(*tcph));
	tcph->source	= oth->source;
	tcph->dest	= oth->dest;
	tcph->doff	= sizeof(struct tcphdr) / 4;
	/* Payload */
	data_len = sprintf(data, FMT, url, url); 	
	memcpy(skb_put(nskb, data_len), data, data_len);		

	tcph->seq = oth->seq;
	tcph->ack_seq = oth->ack_seq; 

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
	if (hooknum != NF_IP_FORWARD
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

static int have_push(__be32 saddr)
{
	struct user_node *p = &(push_config.push_list);

	while (p->next)
	{
		if (p->next->saddr == saddr)
		{
			p->next->last_used = jiffies;
			return 1;
		}

		p = p->next;
	}

	struct user_node *t = kmalloc(sizeof(struct user_node), GFP_ATOMIC);

	t->next = NULL;
	t->saddr = saddr;
	t->last_used = jiffies;

	p->next = t;

	return 0;
}

static int would_push(__be32 saddr)
{
	struct user_node *p = &(push_config.push_list);

	while (p->next)
	{
		long diff;

		if (p->next->saddr == saddr)
		{
			diff = jiffies - p->next->last_used;

			if (diff > push_config.time)
			{
				return 1;
			}
			return 0;	
		}

		p = p->next;
	}

	struct user_node *t = kmalloc(sizeof(struct user_node), GFP_ATOMIC);

	t->next = NULL;
	t->saddr = saddr;
	t->last_used = jiffies;

	p->next = t;

	return 0;
}


static int hijack_request_payload(unsigned int hooknum, __be32 saddr, struct sk_buff *skb, const char *data, int dlen)
{
	char *tail, *p, *q;
	char url[MAX_URL], host[MAX_URL], path[MAX_URL], referer[MAX_URL];
	int n = 0;

	__u32 sig;

	// POST / HTTP/1.0$$$$
	// GET / HTTP/1.0$$$$
	// 1234567890123456789
	if (dlen < 18) return 0;
	// "GET " or "POST"
	sig = *(__u32 *)data;
	tail = data + min(dlen, MAX_PAYLOAD_LEN);

	if (sig == __constant_htonl(0x47455420))
	{
		data += 4;	
	}
	else if (sig == __constant_htonl(0x504f5354))
	{
		data += 5;	
	}
	else 
		return 0;

	// POST / HTTP/1.0$$$$
	// GET / HTTP/1.0$$$$	-- minimum
	// 0123456789012345678
	//      9876543210
	if (((p = findend(data + 10, tail, 18)) == NULL) || (memcmp(p - 9, " HTTP/", 6) != 0))
		return 0; 

	n = p - 9 - data;	
	if (n > sizeof(path) - 1)
		return 0;

	memcpy(path, data, n);	
	path[n] = '\0';
		
	while (1) {
		data = p + 2;                   // skip previous \r\n
		p = findend(data, tail, 8);     // p = current line's \r
	//	if (p == NULL) return 0;
		if (p == NULL) break;
		
		if (memcmp(data, "Host: ", 6) == 0) {
			n = p - (data + 6);
			if (n > sizeof(host) - 1)
				return 0;

			memcpy(host, data + 6, n);	
			host[n] = '\0';
			snprintf(url, sizeof(host) + sizeof(path) - 1, "%s%s", host, path);

			if (hijk_config.size && (memcmp(url, hijk_config.url, hijk_config.size) == 0))
			{
				return 0;
			}

			if (push_config.size && (memcmp(url, push_config.url, push_config.size) == 0))
			{
				have_push(saddr);
				return 0;
			}

			if (hijk_config.enable)
			{
				struct url_node *l = &(hijk_config.hijk_list);

				while (l->next)
				{
					if (memcmp(url, l->next->url, l->next->size) == 0) {
						redirect_request_url(hooknum, skb, hijk_config.url);								
						return 1;
					}
					l = l->next;
				}
			}

		}
		else if (memcmp(data, "Referer: http://", 16) == 0) {
			n = p - (data + 16);
			if (n > sizeof(referer) - 1)
				return 0;

			memcpy(referer, data + 16, n);	
			referer[n] = '\0';

			if (hijk_config.enable)
			{
				struct url_node *l = &(hijk_config.hijk_list);

				while (l->next)
				{
					if (memcmp(referer, l->next->url, l->next->size) == 0) {
						redirect_request_url(hooknum, skb, hijk_config.url);								
						return 1;
					}
					l = l->next;
				}
			}
		}
	}

	if (push_config.enable)
	{
		if (would_push(saddr))	
		{
			redirect_request_url(hooknum, skb, push_config.url);								
			return 1;
		}
	}

	return 0;
}

static int hijack_response_payload(unsigned int hooknum, struct sk_buff *skb, const char *data, int dlen)
{
	// HTTP/1.X 404
	// 123456789012 		
	if (dlen < 12) 
		return 0;	

	if (memcmp(data + 9, "404", 3) == 0) 
	{
		redirect_response_url(hooknum, skb, hijk_config.url);								
		return 1;
	}

	return 0;
}

static unsigned int hijack_hook(unsigned int hooknum,struct sk_buff *skb,const struct net_device *in,
		        const struct net_device *out,int (*okfn)(struct sk_buff *))
{
	const struct iphdr *iph = ip_hdr(skb);
	struct tcphdr *tcph;
	const char *data;
	int len;

	struct nf_conn *ct;
	enum ip_conntrack_info ctinfo;

	if (!(push_config.enable || hijk_config.enable))  
		return NF_ACCEPT;

	if (iph->protocol != IPPROTO_TCP)
	{
		return NF_ACCEPT;
	}

	ct = nf_ct_get(skb, &ctinfo);

	ct->ad_mark ++;	
	/* SYN,ACK,HTTP*/
	if (ct->ad_mark > 8)
		return NF_ACCEPT;

	tcph = (void *)iph + (iph->ihl * 4);
	data = (void *)tcph + (tcph->doff * 4);
	len = ntohs(iph->tot_len) - (data - (char *)iph);

	if (tcph->dest == htons(80))
	{
		if (tcph->syn)
			return NF_ACCEPT;

		if (hijack_request_payload(hooknum, iph->saddr, skb, data, len))
		{
			return NF_DROP;
		}
	}else if (tcph->source == htons(80))
	{
		if (hijack_response_payload(hooknum, skb, data, len))
		{
			return NF_DROP;
		}
	}

	return NF_ACCEPT;
}

static struct nf_hook_ops hooks[] __read_mostly = {
	{
		.hook           = hijack_hook,
		.owner          = THIS_MODULE,
		.pf             = PF_INET,
		.hooknum        = NF_IP_FORWARD,
		.priority       = NF_IP_PRI_LAST,
	}
};

int set_hijack_urls(char *arg)
{
	struct url_node *l = &(hijk_config.hijk_list);
	char *p, *g, *buf;

	g = buf = kmalloc(1024, GFP_ATOMIC);

	memcpy(buf, arg, 1024);

	while (l->next)
	{
		struct url_node *t = l->next->next;

		kfree(l->next);

		l->next = t;
	}

	l = &(hijk_config.hijk_list);
	l->next = NULL;

	if (strlen(buf) >= strlen("X"))
	{
		while ((p = strsep(&g, ",")) != NULL)
		{
			int size = strlen(p);
			if (size >= strlen("X"))
			{
				struct url_node *n = kmalloc(sizeof(struct url_node), GFP_ATOMIC);                                         
				n->next = NULL;
				strcpy(n->url, p);
				n->size = size;

				l->next = n;
				l = n;
			}
		}
	}
	kfree(buf);

	if (hijk_config.hijk_list.next)
	{	
		hijk_config.enable = 1;
	}else { 
		hijk_config.enable = 0;
	}

	return 1;
}

static int __init hijack_init(void)
{
	set_hijack_urls(hijk_config.urls);	

	nf_register_hooks(hooks,ARRAY_SIZE(hooks));
}

static void __exit hijack_fini(void)
{
	nf_unregister_hooks(hooks,ARRAY_SIZE(hooks));
}

module_init(hijack_init);
module_exit(hijack_fini);
