#include <linux/config.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/inet.h>
#include <linux/string.h>
#include <linux/notifier.h>
#include <linux/interrupt.h>
#include <linux/spinlock.h>
#include <linux/slab.h>
#include <linux/bootmem.h>
#include <linux/fs.h>
#include <linux/miscdevice.h>
#include <linux/mtd/mtd.h>
#include <asm/addrspace.h>
#include <asm/io.h>
#include <asm/uaccess.h>
#include <asm/cacheflush.h>

#include <linux/common/common.h>

static int magic_major = -1;
static struct class *magic_class = NULL;

// import vars
extern struct user_node user_list;
extern struct url_node url_list;
extern struct ip_node ip_list;
extern struct mac_node mac_list;
extern unsigned long timeout;
extern unsigned long kickout;

extern char auth_url_prefix[256];
extern int hotspot_enable;
extern int inject_enable;

extern struct push_config_t push_config;
extern struct hijk_config_t hijk_config;
extern int set_hijack_urls(char *arg);

extern unsigned long upload_speed, download_speed;

// end

static int macstr2dig(char *macstr, unsigned char *mac)
{
        if (sscanf(macstr, "%2hhx:%2hhx:%2hhx:%2hhx:%2hhx:%2hhx", &mac[0], &mac[1], &mac[2], &mac[3], &mac[4], &mac[5]) == 6)
                return 1;
        if (sscanf(macstr, "%2hhx-%2hhx-%2hhx-%2hhx-%2hhx-%2hhx", &mac[0], &mac[1], &mac[2], &mac[3], &mac[4], &mac[5]) == 6)
                return 1;
        return 0;
}

static int dev_magic_ioctl(struct inode *inode, struct file *file, unsigned int cmd, unsigned long arg)
{
	switch (cmd)
	{
		case CMD_ADDUSER:
			{
				struct user_node *p = &user_list;
				unsigned char mac[6];

				copy_from_user(&mac, arg, sizeof(mac));	

				//printk("%02x:%02x:%02x:%02x:%02x:%02x\n", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
				while (p->next)
				{
					if (memcmp(p->next->mac, mac, 6) == 0)
					{
						p->next->type = NORMAL_USER;
						p->next->first_used = jiffies;
						p->next->last_used = jiffies;

						return 1;
					}
					p = p->next;
				}
		
				struct user_node *n = kmalloc(sizeof(struct user_node), GFP_ATOMIC);						

				n->next = NULL;

				memcpy(n->mac, mac, 6);
				n->type = NORMAL_USER;
				n->first_used = jiffies;
				n->last_used = jiffies;

				p->next = n;	

				return 1;
			}
			break;
		case CMD_DELUSER:
			{
				struct user_node *p = &user_list;
				unsigned char mac[6];

				copy_from_user(&mac, arg, sizeof(mac));	

				while (p->next)
				{
					if (memcmp(p->next->mac, mac, 6) == 0)
					{
						memset(p->next->mac, 0x00, 6);
						return 1;
					}
					p = p->next;
				}
				return 0;
			}
			break;
		case CMD_SETWHURL:
			{
				struct url_node *l = &url_list;
				char *p, *g, *buf;

				g = buf = kmalloc(1024, GFP_ATOMIC); 

				copy_from_user(buf, arg, 1024);	
		
				while (l->next)	
				{
					struct url_node *t = l->next->next;	

					kfree(l->next);

					l->next = t;
				}

				l = &url_list;
				l->next = NULL;

				if (strlen(buf) >= strlen("X"))
				{
					while ((p = strsep(&g, ",")) != NULL)
					{
						if (strlen(p) >= strlen("X"))
						{
							struct url_node *n = kmalloc(sizeof(struct url_node), GFP_ATOMIC);						
							n->next = NULL;	
							strcpy(n->url, p);	

							l->next = n;		
							l = n;
						}
					}
				}
				kfree(buf);
				return 1;
			}
			break;
		case CMD_SETWHIP:
			{
				struct ip_node *l = &ip_list;
				char *p, *g, *buf;

				g = buf = kmalloc(1024, GFP_ATOMIC); 

				copy_from_user(buf, arg, 1024);	

				while (l->next)	
				{
					struct ip_node *t = l->next->next;

					kfree(l->next);

					l->next = t;
				}

				l = &ip_list;
				l->next = NULL;

				if (strlen(buf) >= strlen("1.1.1.1"))
				{
					while ((p = strsep(&g, ",")) != NULL)
					{
						if (strlen(p) >= strlen("1.1.1.1"))
						{
							struct ip_node *n = kmalloc(sizeof(struct ip_node), GFP_ATOMIC);						
							n->next = NULL;	
							n->saddr = in_aton(p);		

							l->next = n;		
							l = n;
						}
					}
				}
				kfree(buf);
				return 1;
			}
			break;
			case CMD_SETWHMAC:
			{
				struct mac_node *l = &mac_list;
				char *p, *g, *buf;

				g = buf = kmalloc(1024, GFP_ATOMIC); 

				copy_from_user(buf, arg, 1024);	

				while (l->next)	
				{
					struct mac_node *t = l->next->next;

					kfree(l->next);

					l->next = t;
				}

				l = &mac_list;
				l->next = NULL;

				if (strlen(buf) >= strlen("0:0:0:0:0:0"))
				{
					while ((p = strsep(&g, ",")) != NULL)
					{
						if (strlen(p) >= strlen("0:0:0:0:0:0"))
						{
							struct mac_node *n = kmalloc(sizeof(struct mac_node), GFP_ATOMIC);						
							n->next = NULL;	
							if (macstr2dig(p, l->next->mac)) 
							{
								l->next = n;		
								l = n;
							}else {
								kfree(n);
							}
						}
					}
				}
				kfree(buf);
				return 1;
			}
			break;

		case CMD_SETAUTHURL:
			{
				char *buf;

				if (auth_url_prefix == NULL)
					return 0;

				buf = kmalloc(256, GFP_ATOMIC); 

				copy_from_user(buf, arg, 256);	

				if (strlen(buf) > strlen("http://X.X"))	
				{
					strcpy(auth_url_prefix, buf);
					kfree(buf);

					char *p = strstr(auth_url_prefix, "?");

					if (p)
					{
						sprintf(auth_url_prefix, "%s&", auth_url_prefix);
					}else {
						sprintf(auth_url_prefix, "%s?", auth_url_prefix);
					}
					return 1;
				}

				kfree(buf);
				return 0;
			}	
			break;
		case CMD_SETENABLE:
			{
				int buf;		

				copy_from_user(&buf, arg, sizeof(int));	

				if (buf > 0)		
				{				
					hotspot_enable = 1;	
				}else {
					hotspot_enable = 0;	
				}

				return 1;
			}
			break;
		case CMD_SETTIMEOUT:
			{
				unsigned long t = 600;	

				copy_from_user(&t, arg, sizeof(unsigned long));	

				timeout = t*HZ;

				return 1;
			}
			break;
		case CMD_SETKICKOUT:
			{
				unsigned long t = 0;	

				copy_from_user(&t, arg, sizeof(unsigned long));	

				kickout = t*HZ;

				return 1;
			}
			break;
		case CMD_GETHOSTNUM:
			{	
				struct user_node *p = &user_list;
				int t = 0;	

				while (p->next)
				{
					if (p->next->saddr)
					{
						if (p->next->type == NORMAL_USER)
						{
							unsigned long diff = jiffies - p->next->last_used;

							if (timeout == 0)
							{
								t++;
							}

							if (diff < timeout)
							{
								if (kickout == 0)
								{
									t++;
								}

								diff = jiffies - p->next->first_used;

								if (diff < kickout)
								{
									t++;
								}  
							}
						}else if (p->next->type == OTHERS_USER)
						{
							unsigned long diff = jiffies - p->next->first_used;

							if (diff < p->next->timeout)	
							{
								t++;
							}
						}
					}
					p = p->next;
				}

				copy_to_user(arg, &t, sizeof(int));	

				return 1;
			}
			break;
		case CMD_GETACCTIME:
			{
				struct user_node *p = &user_list;
				struct user_node node;

				long time_poss, time_used, time_left;

				copy_from_user(&node, arg, sizeof(struct user_node));	

				while (p->next)
				{
					if (memcmp(p->next->mac, node.mac, 6) == 0)
					{
						time_poss = p->next->timeout;
						time_used = jiffies - p->next->first_used;   
							
						if (time_used > time_poss)
						{
							node.timeout = 0;
						}else {
							time_left = time_poss - time_used; 
							node.timeout = time_left/HZ;
						}	
						
						copy_to_user(arg, &node, sizeof(struct user_node));	
						return 1;
					}
					p = p->next;
				}

				node.timeout = 0; 
				copy_to_user(arg, &node, sizeof(struct user_node));	
				return 0;
			}
			break;
		case CMD_SETACCTIME:
			{
				struct user_node *p = &user_list;
				struct user_node node;

				copy_from_user(&node, arg, sizeof(struct user_node));	

				while (p->next)
				{
					if (memcmp(p->next->mac, node.mac, 6) == 0)
					{
						p->next->type = OTHERS_USER;
						p->next->first_used = jiffies;
						p->next->last_used = jiffies;

						p->next->timeout = node.timeout * HZ;

						copy_to_user(arg, &node, sizeof(struct user_node));	
						return 1;
					}
					p = p->next;
				}
		
				struct user_node *n = kmalloc(sizeof(struct user_node), GFP_ATOMIC);						

				n->next = NULL;

				memcpy(n->mac, node.mac, 6);		
				n->type = OTHERS_USER;
				n->first_used = jiffies;
				n->last_used = jiffies;
				n->timeout = node.timeout * HZ;
				p->next = n;	

				copy_to_user(arg, &node, sizeof(struct user_node));	
				return 1;
			}
			break;
		case CMD_SETINJECT:
			{
				int buf;		

				copy_from_user(&buf, arg, sizeof(int));	

				if (buf > 0)		
				{				
					inject_enable = 1;	
				}else {
					inject_enable = 0;	
				}

				return 1;
			}
			break;
		case CMD_SETPUSHING:
			{
				int buf;		

				copy_from_user(&buf, arg, sizeof(int));	

				if (buf > 0)		
				{				
					push_config.enable = 1;
				}else {
					push_config.enable = 0;
				}

				return 1;
			}
			break;
		case CMD_SETPUSHTME:	
			{
				unsigned long t = 5*60;

				copy_from_user(&t, arg, sizeof(unsigned long));

				if (t)
				{
					push_config.enable = 1;
					push_config.time = t*HZ;
				}else { 
					push_config.enable = 0;
					push_config.time = 0;
				}
				return 1;
			}
			break;
		case CMD_SETPUSHURL:
			{
				char buf[256];
				int size; 	

				copy_from_user(buf, arg, 256);
				size = strlen(buf); 	

				if (size > strlen("X.X"))
				{
					strcpy(push_config.url, buf);
					push_config.size = size;
					push_config.enable = 1;
					return 1;
				}else { 
					push_config.enable = 0;
				}
		
				return 0;
			}
			break;
		case CMD_SETHIJACK:
			{
				int buf;		

				copy_from_user(&buf, arg, sizeof(int));	

				if (buf > 0)		
				{				
					hijk_config.enable = 1;
				}else {
					hijk_config.enable = 0;
				}

				return 1;
			}
			break;
		case CMD_SETHIJKURL:
			{
				char buf[256];
				int size; 	

				copy_from_user(buf, arg, 256);
				size = strlen(buf); 	

				if (size > strlen("X.X"))
				{
					strcpy(hijk_config.url, buf);
					hijk_config.size = size;
					hijk_config.enable = 1;
					return 1;
				}else { 
					hijk_config.enable = 0;
				}

				return 0;
			}
			break;
		case CMD_SETHIJKURLS:
			{
				char buf[1024];
				int size; 	

				copy_from_user(buf, arg, 1024);
				size = strlen(buf); 	

				if (size > strlen("X.X"))
				{
					strcpy(hijk_config.urls, buf);
					set_hijack_urls(hijk_config.urls);		
					return 1;
				}else { 

				}

				return 0;
			}
			break;
		case CMD_GETBWSPEED:
			{
				unsigned long buf[2];

				buf[0] = upload_speed;	
				buf[1] = download_speed;	

				copy_to_user(arg, &buf, sizeof(buf));	

				return 1;
			}
			break;
		case CMD_GETHOSTDATA:
			{	
				struct user_node *p = &user_list;
				unsigned char buf[256][6];
				int t = 0;	

				while (p->next)
				{
					if (p->next->saddr)
					{
						if (p->next->type == NORMAL_USER)
						{
							unsigned long diff = jiffies - p->next->last_used;

							if (timeout == 0)
							{
								t++;
								memcpy(buf[t], p->next->mac, 6);	
							}

							if (diff < timeout)
							{
								if (kickout == 0)
								{
									t++;
									memcpy(buf[t], p->next->mac, 6);	
								}

								diff = jiffies - p->next->first_used;

								if (diff < kickout)
								{
									t++;
									memcpy(buf[t], p->next->mac, 6);	
								}  
							}
						}else if (p->next->type == OTHERS_USER)
						{
							unsigned long diff = jiffies - p->next->first_used;

							if (diff < p->next->timeout)	
							{
								t++;
								memcpy(buf[t], p->next->mac, 6);	
							}
						}
					}
					p = p->next;
				}

				buf[0][0] = t;
				copy_to_user(arg, &buf, sizeof(buf));	

				return 1;
			}
			break;

		default:
			printk("out of cmd\n");
			return 0;
	}
}

static struct file_operations dev_magic_fops = {
        owner:          THIS_MODULE,
        ioctl:          dev_magic_ioctl
};

static int dev_magic_init (void)
{
	int ret = 0;

	if ((magic_major = register_chrdev(0, "rainkide@gmail.com", &dev_magic_fops)) < 0) {
		ret = magic_major;
		goto err;
	}

	magic_class = class_create(THIS_MODULE, "rainkide@gmail.com");

	if (IS_ERR(magic_class)) {
		goto err;
	}

	class_device_create(magic_class, NULL, MKDEV(magic_major, 0), NULL, "rainkide@gmail.com");
err:
	return 0;
}

static void dev_magic_exit(void)
{

}

module_init(dev_magic_init);
module_exit(dev_magic_exit);

