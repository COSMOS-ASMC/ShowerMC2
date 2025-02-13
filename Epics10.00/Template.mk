include  $(EPICSTOP)/site.config

LIBS	      = $(LIBRARY)

MAKEFILE      = Makefile

OBJS	      =

PRINT	      = pr

#PROGRAM       = a.out
PROGRAM       = 

INSTALL	      = /etc/install
SHELL	      = /bin/sh

SRCS	      =

SYSHDRS	      =
EXTHDRS	      =

HDRS	      =


#all:		$(PROGRAM)
all:		$(OBJS)

#$(PROGRAM):     $(OBJS) $(LIBS)
#		@echo "Linking $(PROGRAM) ..."
#		@$(LD) $(LDFLAGS) $(OBJS) $(LIBS) -o $(PROGRAM)
#		@echo "done"

clean:;		@rm -f $(OBJS) core *~ a.out  

veryclean:;		@rm -f $(OBJS) core *~ a.out  temp*.f

clobber:;	@rm -f $(OBJS) $(PROGRAM) core tags

depend:;	@mkmf -f $(MAKEFILE) ROOT=$(ROOT)

echo:;		@echo $(HDRS) $(SRCS)

index:;		@ctags -wx $(HDRS) $(SRCS)

install:	$(PROGRAM)
		@echo Installing $(PROGRAM) in $(DEST)
		@-strip $(PROGRAM)
		@if [ $(DEST) != . ]; then \
		(rm -f $(DEST)/$(PROGRAM); $(INSTALL) -f $(DEST) $(PROGRAM)); fi

print:;		@$(PRINT) $(HDRS) $(SRCS)

tags:           $(HDRS) $(SRCS); @ctags $(HDRS) $(SRCS)

update:		$(DEST)/$(PROGRAM)

$(DEST)/$(PROGRAM): $(SRCS) $(LIBS) $(HDRS) $(EXTHDRS)
		@$(MAKE) -f $(MAKEFILE) ROOT=$(ROOT) DEST=$(DEST) install
