#include "rc.h"
#include <stdarg.h>
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

#define NIPQUAD_FMT "%02x.%02x.%02x.%02x"
#define NIPQUAD(addr) \
	((unsigned char *)&addr)[0], \
	((unsigned char *)&addr)[1], \
	((unsigned char *)&addr)[2], \
	((unsigned char *)&addr)[3]

struct post_config
{
	char post_url[512];
	int post_interval;
};

struct buffer
{
	char data[1024];
	int len;
};

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


static void post_init(struct post_config *conf, const char *url, int interval) 
{
	memset(conf, 0x00, sizeof(struct post_config));
	strcpy(conf->post_url, url);	
	conf->post_interval = interval;	
}

static int post_configure(struct post_config *conf)
{
	int size = 0;
	char buf[128];	

	if ((size = http_get(conf->post_url, buf, sizeof(buf), 0)) > 0)
	{
		buf[size] = '\0';	

		char *p = buf;
		int ok = 0;

		while (*p)
		{
			if (strncmp(p, "hb_url:", 7) == 0)
			{
				int n = 0;

				p += 7;
				
				while (*p != '\r' && *p != '\n')
				{
					conf->post_url[n] = *p;
					n++;p++;
				}
				conf->post_url[n] ='\0';

				ok++;
			}else if (strncmp(p, "hb_interval:", 12) == 0)
			{
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

				ok++;
			}else 
				p++;
		}

		if (ok == 2)
		{
			return 1;
		}else 
			return 0;
	}

	return 0;
}

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

static void post_thread(struct post_config *conf)
{
	unsigned long speed[2]; 
	unsigned char mac[256][6];
	unsigned char device_mac[6];
	struct buffer buf;
	meminfo_t mem;

	//
	get_memory(&mem);

	buffer_init(&buf);
	ioctl_wrapper(CMD_GETBWSPEED, &speed);
	ioctl_wrapper(CMD_GETHOSTDATA, &mac);

	sscanf(nvram_safe_get("sb/1/macaddr"), "%2hhx:%2hhx:%2hhx:%2hhx:%2hhx:%2hhx", &device_mac[0], &device_mac[1], &device_mac[2], &device_mac[3], &device_mac[4], &device_mac[5]);  
	buffer_add(&buf, "&device_mac=%02x:%02x:%02x:%02x:%02x:%02x", device_mac[0], device_mac[1], device_mac[2], device_mac[3], device_mac[4], device_mac[5]);
	buffer_add(&buf, "&upload_speed=%lu&download_speed=%lu", speed[0], speed[1]);
	buffer_add(&buf, "&totalram=%ld&freeram=%ld&shareram=%ld&bufferram=%ld&cached=%ld&totalswap=%ld&freeswap=%ld&totalfreeram=%ld", mem.total, mem.free, mem.shared, mem.buffers, mem.cached, mem.swaptotal, mem.swapfree, mem.maxfreeram);

	int n = mac[0][0];

	buffer_add(&buf, "&online_num=%d", n);
	while (n)
	{
		buffer_add(&buf, "&online_list[]=%02x:%02x:%02x:%02x:%02x:%02x", mac[n][0], mac[n][1], mac[n][2], mac[n][3], mac[n][4], mac[n][5]);
		n--;
	}

	printf("post_msg:\r\n{\r\n%s\r\n}\r\n", buffer_data(&buf));
	http_post(conf->post_url, buffer_data(&buf), buffer_len(&buf));  
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
	int next_wait = 3;
	struct post_config config;

	if (daemon(1, 1) == -1)
	{
		return 0;
	}

	post_init(&config, "http://plat.3gtest.gionee.com/api/wifi/hb", 30);

retry:
	if (post_configure(&config))
	{
		while (1)
		{
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
	}else {
		sleep(next_wait);
		goto retry;
	}
}
