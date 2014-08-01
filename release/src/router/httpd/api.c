#include "tomato.h"
#include "md5.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/sysinfo.h>
#include <sys/socket.h>
#include <errno.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <linux/common/common.h>

static int get_client_info2(unsigned char *mac, char *ifname)
{
        FILE *f;
        char s[256];
#ifdef TCONFIG_IPV6
        char ip[INET6_ADDRSTRLEN];
#else
        char ip[INET_ADDRSTRLEN];
#endif

/*
# ip neigh show fe80:0:0::201:02ff:fe03:0405
fe80::201:2ff:fe3:405 dev br0 lladdr 00:01:02:03:04:05 REACHABLE
*/
        if (clientsai.ss_family == AF_INET) {
                inet_ntop(clientsai.ss_family, &(((struct sockaddr_in*)&clientsai)->sin_addr), ip, sizeof(ip));
                sprintf(s, "ip neigh show %s", ip);
        }
#ifdef TCONFIG_IPV6
        else if (clientsai.ss_family == AF_INET6) {
                inet_ntop(clientsai.ss_family, &(((struct sockaddr_in6*)&clientsai)->sin6_addr), ip, sizeof(ip));
                if (IN6_IS_ADDR_V4MAPPED( &(((struct sockaddr_in6*)&clientsai)->sin6_addr) ))
                        sprintf(s, "ip neigh show %s", ip + 7); // chop off the ::ffff: to get the ipv4 bit
                else
                        sprintf(s, "ip neigh show %s", ip);
        }
#endif

        if ((f = popen(s, "r")) != NULL) {
                while (fgets(s, sizeof(s), f)) {
                        if (sscanf(s, "%*s dev %16s lladdr %2hhx:%2hhx:%2hhx:%2hhx:%2hhx:%2hhx %*s", ifname, &mac[0], &mac[1], &mac[2], &mac[3], &mac[4], &mac[5]) == 7) {
                                pclose(f);
                                return 1;
                        }
                }
                pclose(f);
        }
        return 0;
}

static int verify_token(char *token)
{
	MD5_CTX ctx;	
	unsigned char digest[128], md5[128]; 
	char buf[128];
	char slat[] = "test";
	int ttl = 60;	
	int n;

	n = sprintf(buf, "%d%s", time(NULL) / ttl, slat);

	printf("%s\n", buf);
	MD5_Init(&ctx);
	MD5_Update(&ctx, buf, n);
	MD5_Final(digest, &ctx);

	for (n = 0; n < 16; ++n) {
		snprintf(&(md5[n*2]), 16*2, "%02x", (unsigned int)digest[n]);
	}

	if (memcmp(token, md5, 32) == 0)
	{
		return 1;
	}
	else
		return 0;
}

static char *current_ipaddr(void)
{
	uint32_t saddr = 0;

#ifdef TCONFIG_IPV6
	static char a[INET6_ADDRSTRLEN];
#else
	static char a[INET_ADDRSTRLEN];
#endif
	void *addr = NULL;

	if (clientsai.ss_family == AF_INET)
		addr = &( ((struct sockaddr_in*) &clientsai)->sin_addr );
#ifdef TCONFIG_IPV6
	else if (clientsai.ss_family == AF_INET6)
		addr = &( ((struct sockaddr_in6*) &clientsai)->sin6_addr );
#endif
	inet_ntop(clientsai.ss_family, addr, a, sizeof(a));

	return a; 
}

void get_hostmac(char *url) 
{
	char *ip = webcgi_get("ip");
	char *jsonpcallback = webcgi_get("jsonpcallback");

	if (ip == NULL)
	{
		ip = current_ipaddr();
	}

	{ 
		FILE *f;
		char s[512];
		char ipaddr[16];
		char macaddr[18];
		char dev[17];
		int flags;

		if ((f = fopen("/proc/net/arp", "r")) != NULL) {
			while (fgets(s, sizeof(s), f)) {
				if (sscanf(s, "%15s %*s 0x%X %17s %*s %16s", ipaddr, &flags, macaddr, dev) != 4) continue;
				if ((strlen(macaddr) != 17) || (strcmp(macaddr, "00:00:00:00:00:00") == 0)) continue;
				if (flags == 0) continue;
				
				if (strcmp(ip, ipaddr) == 0) 
				{
					if (jsonpcallback)
					{
						web_printf("%s({\"ret\":\"1\",\"mac\":\"%s\",\"msg\":\"\"})", jsonpcallback, macaddr);	
					}else {
						web_printf("{\"ret\":\"1\",\"mac\":\"%s\",\"msg\":\"\"}", macaddr);	
					}
					fclose(f);
					return;
				}

			}	
			fclose(f);
		}
		if (jsonpcallback)
		{
			web_printf("%s({\"ret\":\"-1\",\"mac\":\"\",\"msg\":\"can't find any entry!\"})", jsonpcallback);	
		}else {
			web_printf("{\"ret\":\"-1\",\"mac\":\"\",\"msg\":\"can't find any entry!\"}");	
		}
	}
}

void get_routmac(char *url)
{
	char *jsonpcallback = webcgi_get("jsonpcallback");
	
	if (jsonpcallback)
	{
		web_printf("%s({\"ret\":\"1\",\"mac\":\"%s\",\"msg\":\"\"})", jsonpcallback, nvram_get("wan_hwaddr"));	
	}else {
		web_printf("{\"ret\":\"1\",\"mac\":\"%s\",\"msg\":\"\"}", nvram_get("wan_hwaddr"));	
	}
}

void get_hostnum(char *url)
{
	char *jsonpcallback = webcgi_get("jsonpcallback");

	int hostnum = 0;
	ioctl_wrapper(CMD_GETHOSTNUM, &hostnum);

	if (jsonpcallback)
	{
		web_printf("%s({\"ret\":\"1\",\"hostnum\":\"%d\",\"msg\":\"\"})", jsonpcallback, hostnum);	
	}else {
		web_printf("{\"ret\":\"1\",\"hostnum\":\"%d\",\"msg\":\"\"}", hostnum);	
	}
}

void get_acctime(char *url)
{
	struct user_node node;

	char *ip = webcgi_get("ip");
	char *jsonpcallback = webcgi_get("jsonpcallback");


	if (ip == NULL)
	{
		ip = current_ipaddr();
	}

	node.saddr = inet_addr(ip); 

	if (ioctl_wrapper(CMD_GETACCTIME, &node))
	{
		if (jsonpcallback)
		{
			web_printf("%s({\"ret\":\"1\",\"ip\":\"%s\",\"time\":\"%lu\",\"msg\":\"\"})", jsonpcallback, ip, node.timeout);	
		}else {
			web_printf("{\"ret\":\"1\",\"ip\":\"%s\",\"time\":\"%lu\",\"msg\":\"\"}", ip, node.timeout);	
		}
	}else {
		if (jsonpcallback)
		{
			web_printf("%s({\"ret\":\"1\",\"ip\":\"%s\",\"time\":\"%ld\",\"msg\":\"\"})", jsonpcallback, ip, -1);	
		}else {
			web_printf("{\"ret\":\"1\",\"ip\":\"%s\",\"time\":\"%ld\",\"msg\":\"\"}", ip, -1);	
		}
	}
}

void set_acctime(char *url)
{
	struct user_node node;
	unsigned char mac[6];
	char ifname[128];
	char *time = webcgi_get("time");
	char *token = webcgi_get("token");
	char *jsonpcallback = webcgi_get("jsonpcallback");

	if (!(get_client_info2(mac, ifname) && time && token))
	{
		if (jsonpcallback)
		{
			web_printf("%s({\"ret\":\"-1\",\"ip\":\"\",\"time\":\"\",\"msg\":\"missing mac or time or token!\"})", jsonpcallback);	
		}else {
			web_printf("{\"ret\":\"-1\",\"ip\":\"\",\"time\":\"\",\"msg\":\"missing mac or time or token!\"}");	
		}
		return;
	}

	if (!verify_token(token))
	{
		if (jsonpcallback)
		{
			web_printf("%s({\"ret\":\"-1\",\"ip\":\"\",\"time\":\"\",\"msg\":\"invalid token!\"})", jsonpcallback);	
		}else {
			web_printf("{\"ret\":\"-1\",\"ip\":\"\",\"time\":\"\",\"msg\":\"invalid token!\"}");	
		}
		return;
	}

	memcpy(node.mac, mac, 6);
	node.timeout = atol(time); 
	
	if (ioctl_wrapper(CMD_SETACCTIME, &node))
	{
		if (jsonpcallback)
		{
			web_printf("%s({\"ret\":\"1\",\"time\":\"%lu\",\"msg\":\"\"})", jsonpcallback, node.timeout);	
		}else {
			web_printf("{\"ret\":\"1\",\"time\":\"%lu\",\"msg\":\"\"}", node.timeout);	
		}
	}else {
		if (jsonpcallback)
		{
			web_printf("%s({\"ret\":\"-1\",\"ip\":\"\",\"time\":\"\",\"msg\":\"set acc time failed!\"})", jsonpcallback);	
		}else {
			web_printf("{\"ret\":\"-1\",\"ip\":\"\",\"time\":\"\",\"msg\":\"set acc time failed!\"}");	
		}
	}
}

void get_wl0ssid(char *url)
{
	char *jsonpcallback = webcgi_get("jsonpcallback");

	if (jsonpcallback) 
	{
		web_printf("%s({\"ret\":\"1\",\"ssid\":\"", jsonpcallback);
	}else {
		web_printf("{\"ret\":\"1\",\"ssid\":\"");
	}

	web_putj_utf8(nvram_get("wl0_ssid"));

	if (jsonpcallback)
	{
		web_printf("\",\"msg\":\"\"})");	
	}else {
		web_printf("\",\"msg\":\"\"}");	
	}
}

