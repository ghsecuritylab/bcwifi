#include "rc.h"
#include <stdarg.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/sysinfo.h>
#include <sys/reboot.h>
#include <sys/socket.h>
#include <errno.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <linux/common/common.h>

#define SecretKey "2d3636d347b965123a4b6fecc2cd04b3"
#define NIPQUAD_FMT "%02x.%02x.%02x.%02x"
#define NIPQUAD(addr) \
	((unsigned char *)&addr)[0], \
	((unsigned char *)&addr)[1], \
	((unsigned char *)&addr)[2], \
	((unsigned char *)&addr)[3]

struct post_config
{
	char post_url[512];
	char cfg_url[512];
	int post_interval;
	int reboot;
	int reconnect;
	int upgrade;
	char mac[17];
	uint32_t ht;
};

struct buffer
{
	char data[1024];
	int len;
};

typedef struct {
	unsigned long total;
	unsigned long free;
	unsigned long shared;
	unsigned long buffers;
	unsigned long cached;
	unsigned long swaptotal;
	unsigned long swapfree;
	unsigned long maxfreeram;
} meminfo_t;

/* Return a 32-bit CRC of the contents of the buffer. */
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

static void buffer_init(struct buffer *buf)
{
	memset(buf, 0x00, sizeof(struct buffer));
}

static int buffer_add(struct buffer *buf, const char *fmt, ...) 
{
	va_list  ap;

	va_start(ap, fmt);
	buf->len += vsprintf(buf->data + buf->len, fmt, ap); 
	va_end(ap);
}

static int buffer_len(struct buffer *buf)
{
	return buf->len;
}

static char *buffer_data(struct buffer *buf)
{
	return buf->data;
}


static void post_init(struct post_config *conf) 
{
	unsigned char device_mac[6];
	char htstr[50];
	memset(conf, 0x00, sizeof(struct post_config));

	sscanf(nvram_safe_get("sb/1/macaddr"), "%2hhx:%2hhx:%2hhx:%2hhx:%2hhx:%2hhx", &device_mac[0], &device_mac[1], &device_mac[2], &device_mac[3], &device_mac[4], &device_mac[5]);  
	sprintf(conf->mac, "%02x:%02x:%02x:%02x:%02x:%02x", device_mac[0], device_mac[1], device_mac[2], device_mac[3], device_mac[4], device_mac[5]);

	//get ht
	sprintf(htstr, "%s:%s", conf->mac, SecretKey);
	conf->ht = crc32(0, htstr, sizeof(htstr));

	sprintf(conf->cfg_url, "http://plat.3gtest.gionee.com/api/wifi/cfg?ht=%u",conf->ht);
	strcpy(conf->post_url, "http://plat.3gtest.gionee.com/api/wifi/hb");	
	conf->post_interval = 30;	
	conf->reboot = 0;
	conf->reconnect = 0;
}

static int post_configure(struct post_config *conf) {

	int size = 0;
	char buf[128];	

	if ((size = http_get(conf->cfg_url, buf, sizeof(buf), 0)) > 0)
	{
		buf[size] = '\0';	

		char *p = buf;
		while (*p) {
			if (strncmp(p, "hb_url:", 7) == 0) {
				int n = 0;

				p += 7;
				
				while (*p != '\r' && *p != '\n')
				{
					conf->post_url[n] = *p;
					n++;p++;
				}
				conf->post_url[n] ='\0';

			} else if (strncmp(p, "hb_interval:", 12) == 0) {
				int n = 0;
				char time[128];	
			
				p += 12;

				while (*p != '\r' && *p != '\n')
				{
					time[n] = *p;
					n++;p++;
				}
				time[n] ='\0';
				conf->post_interval = atoi(time);	

			} else if (strncmp(p, "reboot:", 7) == 0) {
				int n = 0;
				char reboot[128];	
			
				p += 7;
				while (*p != '\r' && *p != '\n')
				{
					reboot[n] = *p;
					n++;p++;
				}
				reboot[n] ='\0';
				conf->reboot = atoi(reboot);			

			} else if (strncmp(p, "reconnect:", 10) == 0) {
				int n = 0;
				char reconnect[128];

				p += 10;
				while (*p != '\r' && *p != '\n')
				{
					reconnect[n] = *p;
					n++;p++;
				}
				reconnect[n] ='\0';
				conf->reconnect = atoi(reconnect);
			} else if (strncmp(p, "upgrade:", 8) == 0) {
				int n = 0;
				char upgrade[128];

				p += 8;
				while (*p != '\r' && *p != '\n')
				{
					upgrade[n] = *p;
					n++;p++;
				}
				upgrade[n] ='\0';
				conf->upgrade = atoi(upgrade);
			}else {
				p++;	
			}
		}
	}
	return 1;
}

static int get_memory(meminfo_t *m)
{
	FILE *f;
	char s[128];
	int ok = 0;

	memset(m, 0, sizeof(*m));
	if ((f = fopen("/proc/meminfo", "r")) != NULL) {
		while (fgets(s, sizeof(s), f)) {
#ifdef LINUX26
			if (strncmp(s, "MemTotal:", 9) == 0) {
				m->total = strtoul(s + 12, NULL, 10) * 1024;
				++ok;
			}
			else if (strncmp(s, "MemFree:", 8) == 0) {
				m->free = strtoul(s + 12, NULL, 10) * 1024;
				++ok;
			}
			else if (strncmp(s, "Buffers:", 8) == 0) {
				m->buffers = strtoul(s + 12, NULL, 10) * 1024;
				++ok;
			}
			else if (strncmp(s, "Cached:", 7) == 0) {
				m->cached = strtoul(s + 12, NULL, 10) * 1024;
				++ok;
			}
#else
			if (strncmp(s, "Mem:", 4) == 0) {
				if (sscanf(s + 6, "%ld %*d %ld %ld %ld %ld", &m->total, &m->free, &m->shared, &m->buffers, &m->cached) == 5)
					++ok;
			}
#endif
			else if (strncmp(s, "SwapTotal:", 10) == 0) {
				m->swaptotal = strtoul(s + 12, NULL, 10) * 1024;
				++ok;
			}
			else if (strncmp(s, "SwapFree:", 9) == 0) {
				m->swapfree = strtoul(s + 11, NULL, 10) * 1024;
				++ok;
#ifndef LINUX26
				break;
#endif
			}
		}
		fclose(f);
	}
	if (ok == 0) {
		return 0;
	}
	m->maxfreeram = m->free;
	if (nvram_match("t_cafree", "1")) m->maxfreeram += (m->cached + m->buffers);
	return 1;
}

static int wanstatus() {

	if ((using_dhcpc()) && (f_exists("/var/lib/misc/dhcpc.renewing"))) {
		return 1;//"Renewing...";
	}
	else if (check_wanup()) {
		return 2;//"Connected";
	}
	else if (f_exists("/var/lib/misc/wan.connecting")) {
		return 3;//"Connecting...";
	}
	else {
		return 4;//"Disconnected";
	}
}

static void post_thread(struct post_config *conf)
{
	unsigned long speed[2]; 
	unsigned char mac[256][6];
	struct buffer buf;
	meminfo_t mem;
	int status = wanstatus();
	
	//
	get_memory(&mem);
	
	buffer_init(&buf);
	ioctl_wrapper(CMD_GETBWSPEED, &speed);
	ioctl_wrapper(CMD_GETHOSTDATA, &mac);

	//get config;
	post_configure(conf);

	

	buffer_add(&buf, "&device_mac=%s", conf->mac);
	buffer_add(&buf, "&ht=%u", conf->ht);
	buffer_add(&buf, "&ip=%s", nvram_safe_get("lan_ipaddr"));
	buffer_add(&buf, "&wl_ssid=%s", nvram_safe_get("wl0_ssid"));
	buffer_add(&buf, "&wanstatus=%d", status);
	//buffer_add(&buf, "&interval=%d&reboot=%d&reconnect=%d", conf->post_interval, conf->reboot, conf->reconnect);
	buffer_add(&buf, "&upload_speed=%lu&download_speed=%lu", speed[0], speed[1]);
	buffer_add(&buf, "&totalram=%ld&freeram=%ld&shareram=%ld&bufferram=%ld&cached=%ld&totalswap=%ld&freeswap=%ld&totalfreeram=%ld", mem.total, mem.free, mem.shared, mem.buffers, mem.cached, mem.swaptotal, mem.swapfree, mem.maxfreeram);

	int n = mac[0][0];
	buffer_add(&buf, "&online_num=%d", n);
	while (n)
	{
		buffer_add(&buf, "&online_list[]=%02x:%02x:%02x:%02x:%02x:%02x", mac[n][0], mac[n][1], mac[n][2], mac[n][3], mac[n][4], mac[n][5]);
		n--;
	}

	//printf("post_msg:\r\n{\r\n%s\r\n}\r\n", buffer_data(&buf));	
	http_post(conf->post_url, buffer_data(&buf), 512);

	if (conf->reboot == 1) {
		conf->reboot = 0;

		sleep(2);

		set_action(ACT_REBOOT);
		//	kill(1, SIGTERM);
		sync();
		reboot(RB_AUTOBOOT);

	} else if (conf->reconnect == 1) {
		conf->reconnect = 0;

		char *argv[] = { "dhcpc-renew", NULL };
		_eval(argv, NULL, 0, NULL);
	} else if (conf->upgrade) {
		start_auto_upgrade();
	}
}

void start_post(void)
{
	xstart("post");
}

void stop_post(void)
{
	killall_tk("post");
}

int post_main(void)
{
	struct post_config config;
	//int next_wait = 3;
	if (daemon(1, 1) == -1)
	{
		return 0;
	}

	post_init(&config);
	while (1) {
		pid_t pid;

		pid = fork();

		if (pid == 0)
		{
			post_thread(&config);
			exit(0);
		}else if (pid > 0) {
			waitpid(pid, NULL, 0);
			sleep(config.post_interval);
		}else {
			exit(0);
		}
	}
}
