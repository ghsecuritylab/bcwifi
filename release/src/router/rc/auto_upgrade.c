/*
 *	http://update.server.com/files/lastest
 ****************************************************
 * 	lastest 文件格式
 * 	version: 0.0.1 	
 * 	file: http://update.server.com/files/firmware.trx
 * 	md5sum: 83081f198d0a890e6d2c33114ccd35c4  
 *****************************************************
 *
 */


#include "http.h"
#include "md5.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/reboot.h>

#define VERSION "0.0.1"
#define UPDATE_SERVER	"http://192.168.11.7/files/lastest"
#define FIRMWARE_PATH	"/tmp/firmware.trx"
#define MAX_TRX	(8*1024*1024)

struct firmware_t
{
	MD5_CTX ctx;

	char version[128], file[128], md5sum[128];

	char *trx;unsigned char digest[128], md5[128]; int size;
	char flags;
};

static char *trim_whitespace(char *str,char token1, char token2)
{
	char *p, *c, *t;
	p = c = str;

	while (*p)
	{
		if (*p != token1 && *p != token2)
		{
			*c = *p;
			c++;
		}
		p++;
	}

	*c = '\0';
	return str;
}

static int decode_response(char *http_response, struct firmware_t *firmware)
{
	int n = 0;
	char *p = http_response;	
	
	firmware->flags = 0x00;

	while (*p)
	{
		if (strncasecmp(p, "version:", 8) == 0) 	
		{	
			n = 0;
			p += 8;

			while (*p != '\r' && *p != '\n')			
			{
				firmware->version[n] = *p;	
				p++;n++;
			}
			firmware->version[n] = '\0';	

			if (n)
			{
				firmware->flags |= 0x01;
			}
		}else if (strncasecmp(p, "file:", 5) == 0)
		{
			n = 0;
			p += 5;

			while (*p != '\r' && *p != '\n')			
			{
				firmware->file[n] = *p;	
				p++;n++;
			}
			firmware->file[n] = '\0';	

			if (n)
			{
				firmware->flags |= 0x02;
			}
		}else if (strncasecmp(p, "md5sum:", 7) == 0)
		{
			n = 0;
			p += 7;

			while (*p != '\r' && *p != '\n')			
			{
				firmware->md5sum[n] = *p;	
				p++;n++;
			}
			firmware->md5sum[n] = '\0';	

			if (n)
			{
				firmware->flags |= 0x04;
			}

		}else 
			p++;	
	}

	if (firmware->flags == 0x07)
	{
		return 1;
	}
	else 
		return 0;
}

static int verify_md5sum(struct firmware_t *firmware)
{
	int n = 0;

	MD5_Init(&firmware->ctx);
	MD5_Update(&firmware->ctx, firmware->trx, firmware->size);
	MD5_Final(firmware->digest, &firmware->ctx);

	for (n = 0; n < 16; ++n) {
		snprintf(&(firmware->md5[n*2]), 16*2, "%02x", (unsigned int)firmware->digest[n]);
	}

	if (memcmp(firmware->md5, firmware->md5sum, 32) == 0)
		return 1;
	else 
		return 0;
}

static int write2disk(struct firmware_t *firmware)
{
	FILE *fp;

	if ((fp = fopen(FIRMWARE_PATH, "w"))!= NULL)
	{
		int size = fwrite(firmware->trx, 1, firmware->size, fp);
		free(firmware->trx);	
		fclose(fp);

		if (size == firmware->size)
		{
			return 1;
		}
	}

	free(firmware->trx);	
	return 0;
}

static int flash_firmware(void)
{
	FILE *fp;		

	if ((fp = popen("mtd-write -i /tmp/firmware.trx -d linux", "r")) != NULL)
	{
		char buf[128];
		fgets(buf, sizeof(buf), fp);		
		pclose(fp);

		if (strstr(buf, "successfully") != NULL)
		{
			return 1;
		}
	}

	return 0;
}

int auto_upgrade_main(void)
{
	struct firmware_t firmware;
	char http_response[512];
	char *trx;

	if (!http_get(UPDATE_SERVER, http_response, sizeof(http_response), 0))
	{
		fprintf(stderr, "获取更新文件失败！\n");
		return 0;
	}

	trim_whitespace(http_response, ' ', '\t');	

	if (!decode_response(http_response, &firmware))
	{	
		fprintf(stderr, "参数错误！\n");
		return 0;
	}

	if (strcmp(firmware.version, VERSION) == 0) 
	{
		fprintf(stderr, "固件版本一致！\n");
		return 0;
	}

	if ((firmware.trx = (char *)malloc(MAX_TRX)) == NULL)	
	{
		fprintf(stderr, "内存不足！\n");
		return 0;
	}

	if (!(firmware.size = http_get(firmware.file, firmware.trx, MAX_TRX, 0)))
	{
		fprintf(stderr, "下载固件失败！\n");
		return 0;
	}

	if (!verify_md5sum(&firmware))
	{
		fprintf(stderr, "固件MD5校验错误！\n");
		return 0;
	}
	
	if (!write2disk(&firmware))	
	{
		fprintf(stderr, "固件回写错误！\n");
		return 0;
	}
	
	if (!flash_firmware())
	{
		fprintf(stderr, "烧写固件失败！\n");
		return 0;
	}
	
	reboot(RB_AUTOBOOT);
}
