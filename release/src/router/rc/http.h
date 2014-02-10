#ifndef __HTTP_H
#define __HTTP_H

#include <stdlib.h>

extern int http_get(const char *server, char *buf, size_t count, off_t offset);
extern int http_post(const char *server, char *buf, size_t count);
#endif
