#ifndef __COMMON_H
#define __COMMON_H
#include <linux/types.h>

#define MAX_URL 256 
#define SecretKey "2d3636d347b965123a4b6fecc2cd04b3" 

enum 
{
	CMD_NONE,
	CMD_ADDUSER,
	CMD_DELUSER,
	CMD_SETWHURL,
	CMD_SETWHIP,
	CMD_SETWHMAC,
	CMD_SETAUTHURL,
	CMD_SETENABLE,
	CMD_SETTIMEOUT,
	CMD_SETKICKOUT,
	CMD_GETHOSTNUM,
	CMD_GETACCTIME,
	CMD_SETACCTIME,
	CMD_SETINJECT,
	CMD_SETPUSHING,
	CMD_SETPUSHTME,
	CMD_SETPUSHURL,
	CMD_SETHIJACK,
	CMD_SETHIJKURL,
	CMD_SETHIJKURLS,
	CMD_GETBWSPEED,
	CMD_GETHOSTDATA,
	CMD_UNKNOWN
};

enum {
	NORMAL_USER = 0,	
	OTHERS_USER = 1	
};

enum {
	OFFLINE = 0, 
	ONLINE = 1
};

struct user_node
{
	uint8_t type;  
	uint8_t stat;
	__be32 saddr;
	unsigned char mac[6];  
	unsigned long first_used;
	unsigned long last_used;
	unsigned long timeout;

	struct user_node *next;
};

struct url_node
{
	char url[MAX_URL];
	int size;

	struct url_node *next;
};

struct hijack_node
{
	char hijack[MAX_URL],target[MAX_URL];
	int size;

	struct hijack_node *next;
};

struct ip_node
{
	__be32 saddr;
	void *data; 

	struct ip_node *next;
};

struct mac_node
{
	unsigned char mac[6];
	void *data; 

	struct mac_node *next;
};

struct push_config_t
{
	int enable;
	char url[MAX_URL];
	int size;

	unsigned long time;

	struct user_node push_list;
};

struct hijk_config_t
{
	int enable;
	char urls[2048];
	char url[MAX_URL];
	int size;

	struct url_node hijk_list;
};


#endif
