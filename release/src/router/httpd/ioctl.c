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


void wo_webauth(char *url)
{	
	unsigned char mac[6];	
	char ifname[128];
	char *jsonpcallback = webcgi_get("jsonpcallback");	

	if (get_client_info2(mac, ifname))	
	{
		ioctl_wrapper(CMD_ADDUSER, mac);	
		if (jsonpcallback)
		{
			web_printf("%s ({ \"msg\":\"Login OK!\", \"ret\": \"1\" })\n", jsonpcallback);	
		}else  
			web_printf("{ \"msg\":\"Login OK!\", \"ret\": \"1\" }\n");	
	}else { 
		if (jsonpcallback)
		{
			web_printf("%s ({ \"msg\":\"Login Failed!\", \"ret\": \"0\" })\n", jsonpcallback);	
		}else 
			web_printf("{ \"msg\":\"Login Failed!\", \"ret\": \"0\" }\n");	
	}	
}


static int verify_token(char *token)
{
        MD5_CTX ctx;
        unsigned char digest[128], md5[128];
        char buf[128];
        char slat[] = "rainkide@gmail.com";
        int ttl = 180;
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

void wo_login(char *url)
{	
	unsigned char mac[6];	
	char ifname[128];
	const char *jsonpcallback = webcgi_get("jsonpcallback");	
	const char *token = webcgi_get("token");

	if (strlen(token) >= 32)	
	{
		if (verify_token(token) != 1)
		{
			if (jsonpcallback)
			{
				web_printf("%s ({ \"msg\":\"Invaild Token!\", \"ret\": \"0\" })\n", jsonpcallback);	
			}else  
				web_printf("{ \"msg\":\"Invaild Token!\", \"ret\": \"0\" }\n");	
			return;
		}
	}else {  
		if (jsonpcallback)
		{
			web_printf("%s ({ \"msg\":\"Invaild Token!\", \"ret\": \"0\" })\n", jsonpcallback);	
		}else  
			web_printf("{ \"msg\":\"Invaild Token!\", \"ret\": \"0\" }\n");	
		return;
	}

	if (get_client_info2(mac, ifname))	
	{
		ioctl_wrapper(CMD_ADDUSER, mac);	
		if (jsonpcallback)
		{
			web_printf("%s ({ \"msg\":\"Login OK!\", \"ret\": \"1\" })\n", jsonpcallback);	
		}else  
			web_printf("{ \"msg\":\"Login OK!\", \"ret\": \"1\" }\n");	
	}else { 
		if (jsonpcallback)
		{
			web_printf("%s ({ \"msg\":\"Login Failed!\", \"ret\": \"0\" })\n", jsonpcallback);	
		}else 
			web_printf("{ \"msg\":\"Login Failed!\", \"ret\": \"0\" }\n");	
	}	
}

void wo_deluser(char *url)
{       
	unsigned char mac[6];   
	char ifname[128];
	char *jsonpcallback = webcgi_get("jsonpcallback");      

	if (get_client_info2(mac, ifname))       
	{
		ioctl_wrapper(CMD_DELUSER, mac);        
		if (jsonpcallback)
		{
			web_printf("%s ({ \"msg\":\"Logout OK!\", \"ret\": \"1\" })\n", jsonpcallback);      
		}else  
			web_printf("{ \"msg\":\"Logout OK!\", \"ret\": \"1\" }\n");  
	}else { 
		if (jsonpcallback)
		{
			web_printf("%s ({ \"msg\":\"Logout Failed!\", \"ret\": \"0\" })\n", jsonpcallback);  
		}else 
			web_printf("{ \"msg\":\"Logout Failed!\", \"ret\": \"0\" }\n");      
	}       

}

void wo_logout(char *url)
{       
	unsigned char mac[6];   
	char ifname[128];
	char *jsonpcallback = webcgi_get("jsonpcallback");      

	if (get_client_info2(mac, ifname))       
	{
		ioctl_wrapper(CMD_DELUSER, mac);        
		if (jsonpcallback)
		{
			web_printf("%s ({ \"msg\":\"Logout OK!\", \"ret\": \"1\" })\n", jsonpcallback);      
		}else  
			web_printf("{ \"msg\":\"Logout OK!\", \"ret\": \"1\" }\n");  
	}else { 
		if (jsonpcallback)
		{
			web_printf("%s ({ \"msg\":\"Logout Failed!\", \"ret\": \"0\" })\n", jsonpcallback);  
		}else 
			web_printf("{ \"msg\":\"Logout Failed!\", \"ret\": \"0\" }\n");      
	}       
}

int ioctl_wrapper(int cmd_type, void *cmd_arg)
{
	int ret;
	int fd;

	if (fd = open("/dev/rainkide@gmail.com", O_RDWR))
	{
		ret = ioctl(fd, cmd_type, cmd_arg);
		close(fd);
	}

	return ret;
}
