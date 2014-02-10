include ../common.mak

CFLAGS	= -Os -Wall $(EXTRACFLAGS)
CFLAGS	+= -I$(SRCBASE)/include -I$(TOP)/shared -I$(TOP)/libpcap
LDFLAGS	=
LIBS = -L$(TOP)/nvram -lnvram -L$(TOP)/shared -lshared -L$(TOP)/libpcap -lpcap

OBJS = wiviz.o wl_access.o channelhopper.o 

all: wiviz
	
wiviz: $(OBJS)
	@echo " [wiviz] CC -o $@"
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

	$(SIZECHECK)
	$(CPTMP)

clean:
	rm -f wiviz .*.depend
	rm -f *.o

install: all
	@echo " [wiviz] Installing..."
	install -D wiviz $(INSTALLDIR)/bin/wiviz
	$(STRIP) $(INSTALLDIR)/bin/wiviz
	chmod 0500 $(INSTALLDIR)/bin/wiviz

%.o: %.c .%.depend
	@echo " [wiviz] CC $@"
	@$(CC) $(CFLAGS) -c $<

.depend: $(OBJS:%.o=%.c)
	@$(CC) $(CFLAGS) -M $^ > .depend

.%.depend: %.c
	@$(CC) $(CFLAGS) -M $< > $@

-include $(OBJS:%.o=.%.depend)

