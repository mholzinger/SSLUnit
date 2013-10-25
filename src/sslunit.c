#include "sslunit.h"

int gi_fips_mode = 0;

int main(int argc, char* argv[])
{
	set_fips();
	(void)printf("FIPS Mode = <%d>\n", gi_fips_mode);
}

/*----------------------------------------------------------------------------*/
void print_ssl_error_stack(void)
{
	/* loop to clear the openssl error stack on non-zero ERR_get_error */
    char error_msg[error_buf];
	unsigned long ul_error = ERR_get_error();

	while (ul_error != 0)
	{
		ERR_error_string_n(ul_error, error_msg, (size_t)error_buf);
		(void)printf("<%s>\n", error_msg);
		ul_error = ERR_get_error();
	}

	/* tidy */
	(void)memset((void*)error_msg, 0, sizeof(error_msg));
	ul_error = 0;
}

/*----------------------------------------------------------------------------*/
void set_fips(void)
{
	(void)SSL_library_init();
	SSL_load_error_strings();

	if (!FIPS_mode_set(1))
	{
		printf("FIPS mode has not been set\n");
		print_ssl_error_stack();
	}

	gi_fips_mode = FIPS_mode();
}

/*----------------------------------------------------------------------------*/
