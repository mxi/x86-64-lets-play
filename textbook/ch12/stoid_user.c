#include <stdio.h>


static char const *number = "-12!24";

extern char *
stoid(
	unsigned long long *out,
	char const *buf,
	unsigned long long bufsz,
	char delim
);


int
main(void)
{
	unsigned long long n;
	char *delim = stoid(&n, number, 7, '!');
	printf("Parsed: %lld, Delim@: %p\n", n, delim);
	return 0;
}
