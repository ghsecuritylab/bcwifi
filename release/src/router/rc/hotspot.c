#include "rc.h"
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

void start_hotspot(int argc, char argv[])
{
	int hotspot_enable = 0;
	int inject_enable = 0;
	int hijack_enable = 0;
	int pushing_enable = 0;

	unsigned long hotspot_timeout = 0;
	unsigned long hotspot_kickout = 0;
	unsigned long pushing_interval = 0;
	char auth_url[256], white_url[1024], white_ip[1024],hijack_hijackurl[2048],hijack_targeturl[256],pushing_url[256];

	hotspot_enable = nvram_match("hotspot_enable", "1");
	inject_enable = nvram_match("inject_enable", "0");
	hijack_enable = nvram_match("hijack_enable", "0");
	pushing_enable = nvram_match("pushing_enable", "0");
	hotspot_timeout = atol(nvram_safe_get("hotspot_timeout"));
	hotspot_kickout = atol(nvram_safe_get("hotspot_kickout"));
	pushing_interval = atol(nvram_safe_get("pushing_interval")); 
	strcpy(auth_url, nvram_safe_get("hotspot_authurl"));	
	strcpy(white_url, nvram_safe_get("hotspot_whiteurl"));	
	strcpy(white_ip, nvram_safe_get("hotspot_whiteip"));	
	strcpy(hijack_hijackurl, nvram_safe_get("hijack_hijackurl"));	
	strcpy(hijack_targeturl, nvram_safe_get("hijack_targeturl"));	
	strcpy(pushing_url, nvram_safe_get("pushing_url"));	

	ioctl_wrapper(CMD_SETWHIP, white_ip);
	ioctl_wrapper(CMD_SETWHURL, white_url);
	ioctl_wrapper(CMD_SETAUTHURL, auth_url);
	ioctl_wrapper(CMD_SETTIMEOUT, &hotspot_timeout);
	ioctl_wrapper(CMD_SETKICKOUT, &hotspot_kickout);
	ioctl_wrapper(CMD_SETENABLE, &hotspot_enable);

	ioctl_wrapper(CMD_SETINJECT, &inject_enable);

	ioctl_wrapper(CMD_SETHIJKURLS, hijack_hijackurl); 
	ioctl_wrapper(CMD_SETHIJKURL, hijack_targeturl);
	ioctl_wrapper(CMD_SETHIJACK, &hijack_enable);

	ioctl_wrapper(CMD_SETPUSHTME, &pushing_interval);
	ioctl_wrapper(CMD_SETPUSHURL, pushing_url);
	ioctl_wrapper(CMD_SETPUSHING, &pushing_enable);

}

void stop_hotspot(int argc, char argv[])
{
	int hotspot_enable = 0;

	ioctl_wrapper(CMD_SETENABLE, &hotspot_enable);
}
