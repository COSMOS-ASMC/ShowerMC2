include  $(COSMOSTOP)/site.config


EXTHDRS	      = $(LIBLOFTINC)/Zcode.h \
		$(LIBLOFTINC)/Zcondc.h \
		$(LIBLOFTINC)/Zcoord.h \
		$(COSMOSINC)/Zcoordtype.h \
		$(LIBLOFTINC)/Zdirec.h \
		$(LIBLOFTINC)/Zglobalc.h \
		$(LIBLOFTINC)/Zmagfield.h \
		$(LIBLOFTINC)/Zmanagerp.h \
		$(LIBLOFTINC)/Zmaxdef.h \
		$(LIBLOFTINC)/Zpos.h \
		$(LIBLOFTINC)/Zptcl.h \
		$(COSMOSINC)/Zstdatmosf.h \
		$(COSMOSINC)/Ztrack.h \
		$(LIBLOFTINC)/Ztrackp.h \
		$(COSMOSINC)/Ztrackv.h \
		$(LIBLOFTINC)/Zunionmap.h

# HDRS	      = cstdatmos0.fNew1.h \
#		cstdatmos0.fNew2.h \
#		cstdatmos0.fOld.h


MAKEFILE      = Makefile

OBJS	      = \
		catmosCnst1.o \
		catmosrho.o \
		catmosutil.o \
		ceCent2llh.o \
		cl2tTbl.o \
		cl2tTblA.o \
		clen2thick.o \
		cllh2eCent.o \
		cllh2sph.o \
		cgetMedia.o \
		csph2llh.o \
		cthick2len.o 


PRINT	      = pr

SHELL	      = /bin/sh

SRCS	      = catmosCnst1.f \
		catmosrho.f \
		catmosutil.f \
		ceCent2llh.f \
		cl2tTbl.f \
		cl2tTblA.f \
		clen2thick.f \
		cllh2eCent.f \
		cllh2sph.f \
		cgetMedia.f \
		csph2llh.f \
		cthick2len.f 


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
		cp -r  $(COSMOSTOP)/Data  $(COSMOSTOP)/Util *
		 $(COSMOSTOP)/UserHook  $(COSMOSTOP)/Scrpt *
		 $(COSMOSTOP)/Doc        $(TEMPLATE)/
		cp $(COSMOSTOP)/site.config $(TEMPLATE)/
		@echo "****" Installing header files into $(HEADER)
		cp -r $(COSMOSTOP)/cosmos  $(HEADER)/
		@echo "****" Installation ended.
		@echo "****" Owner and group should be changed by hand

print:
	@$(PRINT) $(HDRS) $(SRCS)
	make SeeSubDir "TARGET=$@"

tags:           $(HDRS) $(SRCS)
	@ctags $(HDRS) $(SRCS)
	make SeeSubDir "TARGET=$@"


Checkdir:
	@( cd $(COSMOSTOP)/lib; if [ ! -d  $(ARCH) ]; then  mkdir $(ARCH); fi)



SeeSubDir:
	@for i in  * \
	;do   \
		if [ -d  $$i ] ; then \
			(cd $$i; \
			if [ -f Makefile  -a  $$i != Test \
			-a $$i != Util -a $$i != UC  \
	                -a $$i != Ana  -a $$i != Ceren \
	                -a $$i != Data  -a $$i != cosmos \
	                -a $$i != Misc  -a $$i != MuUg \
	                -a $$i != Obso  -a $$i != TeX \
	                -a $$i != lib  -a $$i != UserHook \
	                -a $$i != Doc  -a $$i != Betterone \
	                -a $$i != Scrpt -a $$i != NotForExport ] ; then \
		            $(MAKE) $(TARGET) \
			;fi) \
		; fi \
	done
###
$(LIBRARY)(catmosCnst1.o): $(LIBLOFTINC)/Zglobalc.h 
$(LIBRARY)(ceCent2llh.o): $(LIBLOFTINC)/Zglobalc.h \
	$(LIBLOFTINC)/Zcoord.h \
	$(LIBLOFTINC)/Zunionmap.h \
	$(COSMOSINC)/Zcoordtype.h
$(LIBRARY)(clen2thick.o): $(COSMOSINC)/Ztrack.h \
	$(LIBLOFTINC)/Zcondc.h \
	$(LIBLOFTINC)/Zptcl.h \
	$(LIBLOFTINC)/Zunionmap.h \
	$(LIBLOFTINC)/Zcoord.h \
	$(LIBLOFTINC)/Zpos.h \
	$(LIBLOFTINC)/Zdirec.h \
	$(LIBLOFTINC)/Zmagfield.h \
	$(LIBLOFTINC)/Ztrackp.h \
	$(COSMOSINC)/Ztrackv.h \
	$(LIBLOFTINC)/Zmaxdef.h 

$(LIBRARY)(cllh2eCent.o): $(LIBLOFTINC)/Zglobalc.h \
	$(LIBLOFTINC)/Zcoord.h \
	$(LIBLOFTINC)/Zunionmap.h \
	$(COSMOSINC)/Zcoordtype.h
$(LIBRARY)(cllh2sph.o): $(LIBLOFTINC)/Zglobalc.h \
	$(LIBLOFTINC)/Zcoord.h \
	$(LIBLOFTINC)/Zunionmap.h \
	$(COSMOSINC)/Zcoordtype.h
$(LIBRARY)(cgretMedia.o): $(LIBLOFTINC)/Zmanagerp.h \
	$(LIBLOFTINC)/Zmaxdef.h
#	$(LIBLOFTINC)/Zcondc.h 

$(LIBRARY)(csph2llh.o): $(LIBLOFTINC)/Zglobalc.h \
	$(LIBLOFTINC)/Zcoord.h \
	$(LIBLOFTINC)/Zunionmap.h \
	$(COSMOSINC)/Zcoordtype.h
$(LIBRARY)(cthick2len.o): \
	$(COSMOSINC)/Ztrack.h \
	$(LIBLOFTINC)/Zcondc.h \
	$(LIBLOFTINC)/Zptcl.h \
	$(LIBLOFTINC)/Zunionmap.h \
	$(LIBLOFTINC)/Zcoord.h \
	$(LIBLOFTINC)/Zpos.h \
	$(LIBLOFTINC)/Zdirec.h \
	$(LIBLOFTINC)/Zmagfield.h \
	$(LIBLOFTINC)/Ztrackp.h \
	$(COSMOSINC)/Ztrackv.h \
	$(LIBLOFTINC)/Zmaxdef.h \
	$(LIBLOFTINC)/Zcode.h


$(LIBRARY):         \
               $(LIBRARY)(catmosCnst1.o) \
               $(LIBRARY)(catmosrho.o) \
               $(LIBRARY)(catmosutil.o) \
               $(LIBRARY)(ceCent2llh.o) \
               $(LIBRARY)(cl2tTbl.o) \
               $(LIBRARY)(cl2tTblA.o) \
               $(LIBRARY)(clen2thick.o) \
               $(LIBRARY)(cllh2eCent.o) \
               $(LIBRARY)(cllh2sph.o) \
               $(LIBRARY)(csph2llh.o) \
               $(LIBRARY)(cthick2len.o) \
               $(LIBRARY)(cgetMedia.o) 


