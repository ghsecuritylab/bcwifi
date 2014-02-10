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

// export var
unsigned long upload_speed = 0, download_speed = 0;
// end

static struct timer_list rttim;
static unsigned long upload_stream = 0, download_stream = 0;

static void rate_timer(unsigned long arg)
{
	static unsigned long upload_stream_tmp = 0, download_stream_tmp = 0;
	rttim.expires = jiffies + HZ;
	add_timer(&rttim);

	upload_speed = upload_stream - upload_stream_tmp;			
	download_speed = download_stream - download_stream_tmp;

	upload_stream_tmp = upload_stream;
	download_stream_tmp = download_stream;
}


static unsigned int stats_hook(unsigned int hooknum,struct sk_buff *skb,const struct net_device *in,
		const struct net_device *out,int (*okfn)(struct sk_buff *))
{
	const struct iphdr *iph = ip_hdr(skb);

	if (IN_CLASSC(ntohl(iph->saddr))) {
		if (skb->len)
			upload_stream += skb->len;		
	}else if (IN_CLASSC(ntohl(iph->daddr))) {
		if (skb->len)
			download_stream += skb->len;		
	}

	return NF_ACCEPT;
}

static struct nf_hook_ops hooks[] __read_mostly = {
	{
		.hook           = stats_hook,
		.owner          = THIS_MODULE,
		.pf             = PF_INET,
		.hooknum        = NF_IP_FORWARD,
		.priority       = NF_IP_PRI_LAST,
	}
};

static int __init stats_init(void)
{

	init_timer(&rttim);
	rttim.function = rate_timer;
	rttim.expires = jiffies + HZ;
	add_timer(&rttim);

	nf_register_hooks(hooks,ARRAY_SIZE(hooks));
}

static void __exit stats_fini(void)
{
	nf_unregister_hooks(hooks,ARRAY_SIZE(hooks));
}

module_init(stats_init);
module_exit(stats_fini);

