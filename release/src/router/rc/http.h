#ifndef __HTTP_H
#define __HTTP_H

#include <stdlib.h>

extern int http_get(const char *url, char *data, size_t count, off_t offset);
extern int http_post(const char *url, char *data, size_t count);
#endif
