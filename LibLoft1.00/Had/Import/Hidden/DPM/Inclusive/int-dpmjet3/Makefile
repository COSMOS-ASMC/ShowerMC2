include  $(LIBLOFT)/site.config


EXTHDRS	      =

HDRS	      =


MAKEFILE      = Makefile

OBJS	      = int-distbndry.o \
		int-multi.o \
		int-sample-cospt.o \
		int-sample-cospt-0.0 \
		int-v1.o \
		int-v2.o \
		int-v3.o \
		int-v4.o \
		int-v5.o \
		int-v6.o \
		int-v7.o \
		int-v8.o \
		int-v9.o \
		int-variblock.o \
		int-vinterface2.o \
		int-x1.o \
		int-x2.o \
		int-x3.o \
		int-x4.o \
		int-x5.o \
		int-x6.o \
		int-x7.o \
		int-x8.o \
		int-x9.o \
		int-xinterface2.o

PRINT	      = pr

SHELL	      = /bin/sh

SRCS	      = int-distbndry.f \
		int-multi.f \
		int-sample-cospt.f \
		int-sample-cospt-0.f \
		int-v1.f \
		int-v2.f \
		int-v3.f \
		int-v4.f \
		int-v5.f \
		int-v6.f \
		int-v7.f \
		int-v8.f \
		int-v9.f \
		int-variblock.f \
		int-vinterface2.f \
		int-x1.f \
		int-x2.f \
		int-x3.f \
		int-x4.f \
		int-x5.f \
		int-x6.f \
		int-x7.f \
		int-x8.f \
		int-x9.f \
		int-xinterface2.f

SYSHDRS	      =

all:
	make	Checkdir $(LIBRARY) SeeSubDir "TARGET=$@"

clean:
	@rm -f $(OBJS) core  *~ a.out temp*.o 
	make SeeSubDir "TARGET=$@"

veryclean:
	@rm -f $(OBJS) core  *~ a.out temp*.o temp*.f
	make SeeSubDir "TARGET=$@"


clobber:
	@rm -f $(OBJS) $(LIBRARY) core tags
	make SeeSubDir "TARGET=$@"

depend:
	@mkmf -f $(MAKEFILE) ROOT=$(ROOT)
	make SeeSubDir "TARGET=$@"

echo:
	@echo $(HDRS) $(SRCS)
	make SeeSubDir "TARGET=$@"

extract:
	@ar x $(LIBRARY)


index:
	@ctags -wx $(HDRS) $(SRCS)
	make SeeSubDir "TARGET=$@"

install:	$(LIBRARY)
		@echo "****" Installing $(LIBRARY) into $(DEST)
		$(INSTALL) -f  $(DEST) $(LIBRARY)
		@echo "****" Installing Template files into $(TEMPLATE)
		cp -r  $(LIBLOFT)/Data  $(LIBLOFT)/Util *
		 $(LIBLOFT)/UserHook  $(LIBLOFT)/Scrpt *
		 $(LIBLOFT)/Doc        $(TEMPLATE)/
		cp $(LIBLOFT)/site.config $(TEMPLATE)/
		@echo "****" Installing header files into $(HEADER)
		cp -r $(LIBLOFT)/Header  $(HEADER)/
		@echo "****" Installation ended.
		@echo "****" Owner and group should be changed by hand

print:
	@$(PRINT) $(HDRS) $(SRCS)
	make SeeSubDir "TARGET=$@"

tags:           $(HDRS) $(SRCS)
	@ctags $(HDRS) $(SRCS)
	make SeeSubDir "TARGET=$@"


Checkdir:
	@( cd $(LIBLOFT)/lib; if [ ! -d  $(ARCH) ]; then  mkdir $(ARCH); fi)



SeeSubDir:
	@for i in  * \
	;do   \
		if [ -d  $$i ] ; then \
			(cd $$i; \
			if [ -f Makefile  -a  $$i != Test \
			-a $$i != Util -a $$i != UC  \
	                -a $$i != Ana  -a $$i != Ceren \
	                -a $$i != Data  -a $$i != Header \
	                -a $$i != Misc  -a $$i != MuUg \
	                -a $$i != Obso  -a $$i != TeX \
	                -a $$i != lib  -a $$i != UserHook \
	                -a $$i != Doc  -a $$i != Betterone \
	                -a $$i != Scrpt -a $$i != NotForExport ] ; then \
		            $(MAKE) $(TARGET) \
			;fi) \
		; fi \
	done

$(LIBRARY):         \
               $(LIBRARY)(int-distbndry.o) \
               $(LIBRARY)(int-multi.o) \
               $(LIBRARY)(int-sample-cospt.o) \
               $(LIBRARY)(int-v1.o) \
               $(LIBRARY)(int-v2.o) \
               $(LIBRARY)(int-v3.o) \
               $(LIBRARY)(int-v4.o) \
               $(LIBRARY)(int-v5.o) \
               $(LIBRARY)(int-v6.o) \
               $(LIBRARY)(int-v7.o) \
               $(LIBRARY)(int-v8.o) \
               $(LIBRARY)(int-v9.o) \
               $(LIBRARY)(int-variblock.o) \
               $(LIBRARY)(int-vinterface2.o) \
               $(LIBRARY)(int-x1.o) \
               $(LIBRARY)(int-x2.o) \
               $(LIBRARY)(int-x3.o) \
               $(LIBRARY)(int-x4.o) \
               $(LIBRARY)(int-x5.o) \
               $(LIBRARY)(int-x6.o) \
               $(LIBRARY)(int-x7.o) \
               $(LIBRARY)(int-x8.o) \
               $(LIBRARY)(int-x9.o) \
               $(LIBRARY)(int-xinterface2.o) 
