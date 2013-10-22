#ifndef HEADERS_H_
#define HEADERS_H_

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// openssl
#include <openssl/crypto.h>
#include <openssl/err.h>
#include <openssl/ssl.h>

void set_fips(void);
void print_ssl_error_stack(void);

enum { error_buf = 1024 };
enum { ERROR = 1 };

#endif /* HEADERS_H_ */
