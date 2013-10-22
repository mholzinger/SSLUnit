ARCHTYPE = $(shell uname -m)
CC = gcc

SSLFIPSDIR    = /usr/local/ssl/fips
FIPS_INCLUDE  = $(SSLFIPSDIR)/include
FIPSMODULE    = $(SSLFIPSDIR)/lib/fipscanister.o
FIPSLD_CC     = $(CC) -L$(SSLFIPSDIR)/fips/lib -Wl,-R$(SSLFIPSDIR)/fips/lib
LIBCRYPTO     = 

LDFLAGS       = -lssl -lcrypto

CFLAGS = -I$(FIPS_INCLUDE) $(PLATFORM) -march=native -std=c99 -D_POSIX_SOURCE -pedantic -Wall $(DEBUG_FLAGS) \
		 ${DISPLAYCERTINFO} ${VERBOSE} -D_GNU_SOURCE $(CXXFLAGS) $(LARGEFILES)
COMPILE.c = $(CC) $(CFLAGS) $(PLATFORM) -c

ifeq ($(ARCHTYPE),x86_64)
LARGEFILES =
else
LARGEFILES = -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
endif


OS = $(shell uname -s)
OUTPUT_OPTION = -o $@

PROG = sslunit
PROGOBJS = $(PROG).o
RM = rm -rf

vpath %.c src

ifeq ($(OS),Darwin)
	CXXFLAGS   = -D_DARWIN_C_SOURCE
	PLATFORM   := -DTOSDARWIN
else
	ifeq ($(OS),Linux)
		PLATFORM   := -DTOSLINUX
	endif
endif

ifdef TDEBUG
	DEBUG_FLAGS = -DTDEBUG -g -ggdb -Wall
else
	DEBUG_FLAGS =
endif

all: clean $(PROG)

.PHONY: clean
clean:
	@echo 'clean'
	$(RM) *.o $(PROG) *._* *~
	@echo ' '

$(PROG): $(PROGOBJS)
	@echo 'Building target: $@'
	env FIPSLD_CC=gcc $(SSLFIPSDIR)/bin/fipsld -L$(SSLFIPSDIR)/lib -Wl,-R$(SSLFIPSDIR)/lib $(PROGOBJS) $(SSLFIPSDIR)/lib/fipscanister.o -lssl -lcrypto -ldl -o $(PROG)
	@echo 'Finished building target: $@'
	@echo ' '

$(PROG).o: src/$(PROG).c
	@echo 'Building target: $@'
	$(CC) $(CFLAGS) -c $(OUTPUT_OPTION) src/$(PROG).c
	@echo 'Finished building target: $@'
	@echo ' '
