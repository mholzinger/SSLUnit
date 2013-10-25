ARCHTYPE = $(shell uname -m)
CC = gcc

FIPS_MAJ=2.0

OPENSSLDIR    = /usr/local/ssl
FIPS_INCLUDE  = $(OPENSSLDIR)/include
FIPSMODULE    = $(OPENSSLDIR)/lib/fipscanister.o
LIBCRYPTO     = $(OPENSSLDIR)/lib/libcrypto.a
PROG = sslunit
OBJS = $(PROG).o

CFLAGS = -I$(FIPS_INCLUDE) $(PLATFORM) -march=native -std=c99 -D_POSIX_SOURCE \
	-pedantic -Wall $(DEBUG_FLAGS) -D_GNU_SOURCE $(CXXFLAGS) $(LARGEFILES)
COMPILE.c = $(CC) $(CFLAGS) $(PLATFORM) -c
RM = rm -rf

ifeq ($(ARCHTYPE),x86_64)
LARGEFILES =
else
LARGEFILES = -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
endif


OS = $(shell uname -s)
OUTPUT_OPTION = -o $@

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

$(PROG): $(OBJS)
	@echo 'Building target: $@'
	env FIPSLD_CC=$(CC) $(OPENSSLDIR)/fips-$(FIPS_MAJ)/bin/fipsld \
		-o $(PROG) $(OBJS) $(LIBCRYPTO) -lssl -ldl
	@echo 'Finished building target: $@'
	@echo ' '

$(PROG).o: src/$(PROG).c
	@echo 'Building target: $@'
	$(CC) $(CFLAGS) -c $(OUTPUT_OPTION) src/$(PROG).c
	@echo 'Finished building target: $@'
	@echo ' '
