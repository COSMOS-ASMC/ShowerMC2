c 05.02.2008 Main program and random number generator of epos
c (Do not compile it for CONEX or Corsika)

c-----------------------------------------------------------------------
      program aamain
c-----------------------------------------------------------------------

      include 'epos.inc'
      common/photrans/phoele(4),ebeam,noevt

      save nopeno
      call aaset(0)
      call atitle
      call xiniall

9999  continue
      call aread
      if(nopen.eq.-1) then !after second round aread
        nopen=nopeno
        iecho=1
        call xiniall
        goto 9999
      endif
      call utpri('aamain',ish,ishini,4)
      if(model.ne.1)call IniModel(model)

      if(iappl.ne.0)then
        if(abs(idprojin).eq.12)then  !fake e-A collision with gamma(pi0)-A
          noebin=-nevent
          nevent=1
          if(elepti.le.1.)stop 'electron energy not defined'
          if(ebeam.le.1.)stop 'proton energy not defined'
          irescl=0     !no rescaling because of electron
          write(ifmt,'(a,i10,a,f6.2,a,f8.2,a)')'generate',-noebin
     & ,'  events for electron on proton =',elepti,' ->',ebeam,'  ...'
        else
          if(ebeam.gt.0.)stop 'ebeam need abs(idproj)=12 for DIS'
        endif
        noevt=0
        do nrebin= 1,abs(noebin)
 66       continue
          call ainit
                                ! if (nrebin.eq.1) call xini
          if(nevent.gt.0)then
            if(noebin.ge.0)then
              write(ifmt,'(a,i10,a,f10.2,a)')'generate',nevent
     &       ,'  events for engy =',engy,'  ...'
            endif
            if(icotabr.eq.1)nevent=1
            if(icotabr.eq.1)nrevt=1
            if(nfull.gt.0)nevent=nfreeze*nfull
            if(mod(nevent,nfreeze).ne.0)
     &        stop'nevent must be a multiple of nfreeze!!!!!!!!!      '
            if(istore.ne.0) call bstora
            do  n=1,nevent
              if(irewch.eq.1)rewind(ifch)
              nfr=mod(n-1,nfreeze)*ispherio
              if(nfr.ne.0)goto77
              do nin=1,iabs(ninicon)
                if(icotabr.eq.0)call aepos(isign(1,-ninicon)*nin)
                if(icocore.ne.0)call IniCon(nin)
              enddo
              if(noevt.eq.1)goto 66   !fake DIS
  77          if(ispherio.ne.0)then
                if(nfr.eq.0)write(ifmt,'(a)')
     &           'spherio evolution + hadronization ...'
                if(mod(nfr+1,50).eq.0)
     &          write(ifmt,*)'hadronization ',nfr+1,' / ',nfreeze
c                  call spherio2(nrevt,nfr)
                if(ish.ge.2)call alist('list after spherio&',1,nptl)
                call decayall(1)
                if(ish.ge.2)call alist('list after decay&',1,nptl)
              endif
              call aafinal
              if(iurqmd.eq.1)call urqmd(n)
              call afinal
              call xana
              if(istore.ge.1.and.istore.le.4) call bstore
              if(istore.eq.5) call ustore
              if(nfr+1.eq.nfreeze.or.ispherio.eq.0)call aseed(1)
            enddo
            call astati
          else
            call xana
          endif
        enddo
        call bfinal
        if(noebin.lt.0)call phoGPHERAepo(2)  !statistic for fake DIS
      endif
      if(istore.eq.3) write(ifdt,*) ' 0 0 '
      write(6,'(a)')'rewind copy-file'
      rewind (ifcp)
      nopeno=nopen
      nopen=-1
      iecho=0
      call utprix('aamain',ish,ishini,4)
      goto 9999

      end


c-----------------------------------------------------------------------
      function rangen()
c-----------------------------------------------------------------------
c     generates a random number
c-----------------------------------------------------------------------
      include 'epos.inc'
      double precision dranf
 1    rangen=sngl(dranf(dble(rangen)))
      if(rangen.le.0.)goto 1
      if(rangen.ge.1.)goto 1
      if(irandm.eq.1)write(ifch,*)'rangen()= ',rangen

      return
      end

c-----------------------------------------------------------------------
      double precision function drangen(dummy)
c-----------------------------------------------------------------------
c     generates a random number
c-----------------------------------------------------------------------
      include 'epos.inc'
      double precision dummy,dranf
      drangen=dranf(dummy)
      if(irandm.eq.1)write(ifch,*)'drangen()= ',drangen

      return
      end
c-----------------------------------------------------------------------
      function cxrangen(dummy)
c-----------------------------------------------------------------------
c     generates a random number
c-----------------------------------------------------------------------
      include 'epos.inc'
      double precision dummy,dranf
      cxrangen=sngl(dranf(dummy))
      if(irandm.eq.1)write(ifch,*)'cxrangen()= ',cxrangen

      return
      end



c Random number generator from CORSIKA *********************************




C=======================================================================

      DOUBLE PRECISION FUNCTION DRANF(dummy)

C-----------------------------------------------------------------------
C  RAN(DOM  NUMBER) GEN(ERATOR) USED IN EPOS
C  If calling this function within a DO-loop
C  you should use an argument which prevents (dummy) to draw this function 
C  outside the loop by an optimizing compiler.
C-----------------------------------------------------------------------
      implicit none
      common/eporansto2/irndmseq
      integer irndmseq
      double precision uni,dummy
C-----------------------------------------------------------------------

      call RMMARD( uni,1,irndmseq)

      DRANF = UNI
      UNI = dummy        !to avoid warning

      RETURN
      END


c-----------------------------------------------------------------------
      subroutine ranfgt(seed)
c-----------------------------------------------------------------------
c Initialize seed in EPOS : read seed (output)
c Since original output seed and EPOS seed are different,
c define output seed as : seed=ISEED(3)*1E9+ISEED(2)
c but only for printing. Important values stored in /eporansto/
c Important : to be call before ranfst
c-----------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER          KSEQ
      PARAMETER        (KSEQ = 2)
      COMMON /CRRANMA3/CD,CINT,CM,TWOM24,TWOM48,MODCNS
      DOUBLE PRECISION CD,CINT,CM,TWOM24,TWOM48
      INTEGER          MODCNS
      COMMON /CRRANMA4/C,U,IJKL,I97,J97,NTOT,NTOT2,JSEQ
      DOUBLE PRECISION C(KSEQ),U(97,KSEQ)
      INTEGER          IJKL(KSEQ),I97(KSEQ),J97(KSEQ),
     *                 NTOT(KSEQ),NTOT2(KSEQ),JSEQ
      common/eporansto/diu0(100),iiseed(3)
      double precision    seed,diu0
      integer iiseed,i

      iiseed(1)=IJKL(1)
      iiseed(2)=NTOT(1)
      iiseed(3)=NTOT2(1)
      seed=dble(iiseed(3))*dble(MODCNS)+dble(iiseed(2))
      diu0(1)=C(1)
      do i=2,98
        diu0(i)=U(i-1,1)
      enddo
      diu0(99)=dble(I97(1))
      diu0(100)=dble(J97(1))
      return
      end

c-----------------------------------------------------------------------
      subroutine ranfst(seed)
c-----------------------------------------------------------------------
c Initialize seed in EPOS :  restore seed (input)
c Since original output seed and EPOS seed are different,
c define output seed as : seed=ISEED(3)*1E9+ISEED(2)
c but only for printing. Important values restored from /eporansto/
c Important : to be call after ranfgt
c-----------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER          KSEQ
      PARAMETER        (KSEQ = 2)
      COMMON /CRRANMA3/CD,CINT,CM,TWOM24,TWOM48,MODCNS
      DOUBLE PRECISION CD,CINT,CM,TWOM24,TWOM48
      INTEGER          MODCNS
      COMMON /CRRANMA4/C,U,IJKL,I97,J97,NTOT,NTOT2,JSEQ
      DOUBLE PRECISION C(KSEQ),U(97,KSEQ)
      INTEGER          IJKL(KSEQ),I97(KSEQ),J97(KSEQ),
     *                 NTOT(KSEQ),NTOT2(KSEQ),JSEQ
      common/eporansto/diu0(100),iiseed(3)
      double precision    seedi,seed,diu0
      integer i,iiseed

      seedi=seed
      IJKL(1)=iiseed(1)
      NTOT(1)=iiseed(2)
      NTOT2(1)=iiseed(3)
      C(1)=diu0(1)
      do i=2,98
        U(i-1,1)=diu0(i)
      enddo
      I97(1)=nint(diu0(99))
      J97(1)=nint(diu0(100))
      return
      end

c-----------------------------------------------------------------------
      subroutine ranflim(seed)
c-----------------------------------------------------------------------
      double precision seed
      if(seed.gt.1d9)stop'seed larger than 1e9 not possible !'
      end

c-----------------------------------------------------------------------
      subroutine ranfcv(seed)
c-----------------------------------------------------------------------
c Convert input seed to EPOS random number seed
c Since input seed and EPOS (from Corsika) seed are different,
c define input seed as : seed=ISEED(3)*1E9+ISEED(2) 
c-----------------------------------------------------------------------
      IMPLICIT NONE
      COMMON /CRRANMA3/CD,CINT,CM,TWOM24,TWOM48,MODCNS
      DOUBLE PRECISION CD,CINT,CM,TWOM24,TWOM48
      INTEGER          MODCNS
      common/eporansto/diu0(100),iiseed(3)
      double precision    seed,diu0
      integer iiseed

      iiseed(3)=nint(seed/dble(MODCNS))
      iiseed(2)=nint(mod(seed,dble(MODCNS)))

      return
      end

c-----------------------------------------------------------------------
      subroutine ranfini(seed,iseq,iqq)
c-----------------------------------------------------------------------
c Initialize random number sequence iseq with seed
c if iqq=-1, run first ini
c    iqq=0 , set what sequence should be used
c    iqq=1 , initialize sequence for initialization
c    iqq=2 , initialize sequence for first event
c-----------------------------------------------------------------------
      IMPLICIT NONE
      COMMON /CRRANMA3/CD,CINT,CM,TWOM24,TWOM48,MODCNS
      DOUBLE PRECISION CD,CINT,CM,TWOM24,TWOM48
      INTEGER          MODCNS
      common/eporansto/diu0(100),iiseed(3)
      double precision    seed,diu0
      integer iiseed
      common/eporansto2/irndmseq
      integer irndmseq
      integer iseed(3),iseq,iqq,iseqdum
 
      if(iqq.eq.0)then
        irndmseq=iseq
      elseif(iqq.eq.-1)then
        iseqdum=0
        call RMMAQD(iseed,iseqdum,'R')   !first initialization
      elseif(iqq.eq.2)then
        irndmseq=iseq
        if(seed.ge.dble(MODCNS))then
           write(*,'(a,1p,e8.1)')'seedj larger than',dble(MODCNS)
           stop 'Forbidden !'
        endif
        iiseed(1)=nint(mod(seed,dble(MODCNS)))
c iiseed(2) and iiseed(3) defined in aread
        call RMMAQD(iiseed,iseq,'S') !initialize random number generator
      elseif(iqq.eq.1)then        !dummy sequence for EPOS initialization
        irndmseq=iseq
        if(seed.ge.dble(MODCNS))then
           write(*,'(a,1p,e8.1)')'seedi larger than',dble(MODCNS)
           stop 'Forbidden !'
        endif
        iseed(1)=nint(mod(seed,dble(MODCNS)))
        iseed(2)=0
        iseed(3)=0
        call RMMAQD(iseed,iseq,'S') !initialize random number generator
      endif
      return
      end

C=======================================================================

      SUBROUTINE RMMARD( RVEC,LENV,ISEQ )

C-----------------------------------------------------------------------
C  C(ONE)X
C  R(ANDO)M (NUMBER GENERATOR OF) MAR(SAGLIA TYPE) D(OUBLE PRECISION)
C
C  THESE ROUTINES (RMMARD,RMMAQD) ARE MODIFIED VERSIONS OF ROUTINES
C  FROM THE CERN LIBRARIES. DESCRIPTION OF ALGORITHM SEE:
C               http://consult.cern.ch/shortwrups/v113/top.html
C  IT HAS BEEN CHECKED THAT RESULTS ARE BIT-IDENTICAL WITH CERN
C  DOUBLE PRECISION RANDOM NUMBER GENERATOR RMM48, DESCRIBED IN
C               http://consult.cern.ch/shortwrups/v116/top.html
C  ARGUMENTS:
C   RVEC   = DOUBLE PREC. VECTOR FIELD TO BE FILLED WITH RANDOM NUMBERS
C   LENV   = LENGTH OF VECTOR (# OF RANDNUMBERS TO BE GENERATED)
C   ISEQ   = # OF RANDOM SEQUENCE
C
C  VERSION OF D. HECK FOR DOUBLE PRECISION RANDOM NUMBERS.
C  ADAPTATION  : T. PIEROG    IK  FZK KARLSRUHE FROM D. HECK VERSION
C  DATE     : Feb  17, 2009
C-----------------------------------------------------------------------

      IMPLICIT NONE
      INTEGER          KSEQ
      PARAMETER        (KSEQ = 2)
      COMMON /CRRANMA3/CD,CINT,CM,TWOM24,TWOM48,MODCNS
      DOUBLE PRECISION CD,CINT,CM,TWOM24,TWOM48
      INTEGER          MODCNS
      COMMON /CRRANMA4/C,U,IJKL,I97,J97,NTOT,NTOT2,JSEQ
      DOUBLE PRECISION C(KSEQ),U(97,KSEQ),UNI
      INTEGER          IJKL(KSEQ),I97(KSEQ),J97(KSEQ),
     *                 NTOT(KSEQ),NTOT2(KSEQ),JSEQ

      DOUBLE PRECISION RVEC(*)
      INTEGER          ISEQ,IVEC,LENV
      SAVE

C-----------------------------------------------------------------------

      IF ( ISEQ .GT. 0  .AND.  ISEQ .LE. KSEQ ) JSEQ = ISEQ
      
      DO   IVEC = 1, LENV
        UNI = U(I97(JSEQ),JSEQ) - U(J97(JSEQ),JSEQ)
        IF ( UNI .LT. 0.D0 ) UNI = UNI + 1.D0
        U(I97(JSEQ),JSEQ) = UNI
        I97(JSEQ)  = I97(JSEQ) - 1
        IF ( I97(JSEQ) .EQ. 0 ) I97(JSEQ) = 97
        J97(JSEQ)  = J97(JSEQ) - 1
        IF ( J97(JSEQ) .EQ. 0 ) J97(JSEQ) = 97
        C(JSEQ)    = C(JSEQ) - CD
        IF ( C(JSEQ) .LT. 0.D0 ) C(JSEQ)  = C(JSEQ) + CM
        UNI        = UNI - C(JSEQ)
        IF ( UNI .LT. 0.D0 ) UNI = UNI + 1.D0
C  AN EXACT ZERO HERE IS VERY UNLIKELY, BUT LET'S BE SAFE.
        IF ( UNI .EQ. 0.D0 ) UNI = TWOM48
        RVEC(IVEC) = UNI
      ENDDO

      NTOT(JSEQ) = NTOT(JSEQ) + LENV
      IF ( NTOT(JSEQ) .GE. MODCNS )  THEN
        NTOT2(JSEQ) = NTOT2(JSEQ) + 1
        NTOT(JSEQ)  = NTOT(JSEQ) - MODCNS
      ENDIF

      RETURN
      END

C=======================================================================

      SUBROUTINE RMMAQD( ISEED, ISEQ, CHOPT )

C-----------------------------------------------------------------------
C  R(ANDO)M (NUMBER GENERATOR OF) MA(RSAGLIA TYPE INITIALIZATION) DOUBLE
C
C  SUBROUTINE FOR INITIALIZATION OF RMMARD
C  THESE ROUTINE RMMAQD IS A MODIFIED VERSION OF ROUTINE RMMAQ FROM
C  THE CERN LIBRARIES. DESCRIPTION OF ALGORITHM SEE:
C               http://consult.cern.ch/shortwrups/v113/top.html
C  FURTHER DETAILS SEE SUBR. RMMARD
C  ARGUMENTS:
C   ISEED  = SEED TO INITIALIZE A SEQUENCE (3 INTEGERS)
C   ISEQ   = # OF RANDOM SEQUENCE
C   CHOPT  = CHARACTER TO STEER INITIALIZE OPTIONS
C
C  CERN PROGLIB# V113    RMMAQ           .VERSION KERNFOR  1.0
C  ORIG. 01/03/89 FCA + FJ
C  ADAPTATION  : T. PIEROG    IK  FZK KARLSRUHE FROM D. HECK VERSION
C  DATE     : Feb  17, 2009
C-----------------------------------------------------------------------

      IMPLICIT NONE
      INTEGER          KSEQ
      PARAMETER        (KSEQ = 2)
      COMMON /CRRANMA3/CD,CINT,CM,TWOM24,TWOM48,MODCNS
      DOUBLE PRECISION CD,CINT,CM,TWOM24,TWOM48
      INTEGER          MODCNS
      COMMON /CRRANMA4/C,U,IJKL,I97,J97,NTOT,NTOT2,JSEQ
      DOUBLE PRECISION C(KSEQ),U(97,KSEQ),UNI
      INTEGER          IJKL(KSEQ),I97(KSEQ),J97(KSEQ),
     *                 NTOT(KSEQ),NTOT2(KSEQ),JSEQ

      DOUBLE PRECISION CC,S,T,UU(97)
      INTEGER          ISEED(3),I,IDUM,II,II97,IJ,IJ97,IORNDM,
     *                 ISEQ,J,JJ,K,KL,L,LOOP2,M,NITER
      CHARACTER        CHOPT*(*), CCHOPT*12
      LOGICAL          FIRST
      SAVE
      DATA             FIRST / .TRUE. /, IORNDM/11/, JSEQ/1/

      
C-----------------------------------------------------------------------

      IF ( FIRST ) THEN
        TWOM24 = 2.D0**(-24)
        TWOM48 = 2.D0**(-48)
        CD     = 7654321.D0*TWOM24
        CM     = 16777213.D0*TWOM24
        CINT   = 362436.D0*TWOM24
        MODCNS = 1000000000
        FIRST  = .FALSE.
        JSEQ   = 1
      ENDIF
      CCHOPT = CHOPT
      IF ( CCHOPT .EQ. ' ' ) THEN
        ISEED(1) = 54217137
        ISEED(2) = 0
        ISEED(3) = 0
        CCHOPT   = 'S'
        JSEQ     = 1
      ENDIF

      IF     ( INDEX(CCHOPT,'S') .NE. 0 ) THEN
        IF ( ISEQ .GT. 0  .AND.  ISEQ .LE. KSEQ ) JSEQ = ISEQ
        IF ( INDEX(CCHOPT,'V') .NE. 0 ) THEN
          READ(IORNDM,'(3Z8)') IJKL(JSEQ),NTOT(JSEQ),NTOT2(JSEQ)
          READ(IORNDM,'(2Z8,Z16)') I97(JSEQ),J97(JSEQ),C(JSEQ)
          READ(IORNDM,'(24(4Z16,/),Z16)') U
          IJ = IJKL(JSEQ)/30082
          KL = IJKL(JSEQ) - 30082 * IJ
          I  = MOD(IJ/177, 177) + 2
          J  = MOD(IJ, 177)     + 2
          K  = MOD(KL/169, 178) + 1
          L  = MOD(KL, 169)
          CD =  7654321.D0 * TWOM24
          CM = 16777213.D0 * TWOM24
        ELSE
          IJKL(JSEQ)  = ISEED(1)
          NTOT(JSEQ)  = ISEED(2)
          NTOT2(JSEQ) = ISEED(3)
          IJ = IJKL(JSEQ) / 30082
          KL = IJKL(JSEQ) - 30082*IJ
          I  = MOD(IJ/177, 177) + 2
          J  = MOD(IJ, 177)     + 2
          K  = MOD(KL/169, 178) + 1
          L  = MOD(KL, 169)
          DO   II = 1, 97
            S = 0.D0
            T = 0.5D0
            DO   JJ = 1, 48
              M = MOD(MOD(I*J,179)*K, 179)
              I = J
              J = K
              K = M
              L = MOD(53*L+1, 169)
              IF ( MOD(L*M,64) .GE. 32 ) S = S + T
              T = 0.5D0 * T
            ENDDO
            UU(II) = S
          ENDDO
          CC    = CINT
          II97  = 97
          IJ97  = 33
C  COMPLETE INITIALIZATION BY SKIPPING (NTOT2*MODCNS+NTOT) RANDOMNUMBERS
          NITER = MODCNS
          DO   LOOP2 = 1, NTOT2(JSEQ)+1
            IF ( LOOP2 .GT. NTOT2(JSEQ) ) NITER = NTOT(JSEQ)
            DO   IDUM = 1, NITER
              UNI = UU(II97) - UU(IJ97)
              IF ( UNI .LT. 0.D0 ) UNI = UNI + 1.D0
              UU(II97) = UNI
              II97     = II97 - 1
              IF ( II97 .EQ. 0 ) II97 = 97
              IJ97     = IJ97 - 1
              IF ( IJ97 .EQ. 0 ) IJ97 = 97
              CC       = CC - CD
              IF ( CC .LT. 0.D0 ) CC  = CC + CM
            ENDDO
          ENDDO
          I97(JSEQ) = II97
          J97(JSEQ) = IJ97
          C(JSEQ)   = CC
          DO   JJ = 1, 97
            U(JJ,JSEQ) = UU(JJ)
          ENDDO
        ENDIF
      ELSEIF ( INDEX(CCHOPT,'R') .NE. 0 ) THEN
        IF ( ISEQ .GT. 0 ) THEN
          JSEQ = ISEQ
        ELSE
          ISEQ = JSEQ
        ENDIF
        IF ( INDEX(CCHOPT,'V') .NE. 0 ) THEN
          WRITE(IORNDM,'(3Z8)') IJKL(JSEQ),NTOT(JSEQ),NTOT2(JSEQ)
          WRITE(IORNDM,'(2Z8,Z16)') I97(JSEQ),J97(JSEQ),C(JSEQ)
          WRITE(IORNDM,'(24(4Z16,/),Z16)') U
        ELSE
          ISEED(1) = IJKL(JSEQ)
          ISEED(2) = NTOT(JSEQ)
          ISEED(3) = NTOT2(JSEQ)
        ENDIF
      ENDIF

      RETURN
      END

c Random number generator from CERN LIB *********************************

c
cc-----------------------------------------------------------------------
c      real function ranf(dummy)
cc-----------------------------------------------------------------------
cc     uniform random number generator from cern library
cc-----------------------------------------------------------------------
c      double precision    dranf,    g900gt,   g900st
c      double precision    ds(2),    dm(2),    dseed
c      double precision    dx24,     dx48
c      double precision    dl,       dc,       du,       dr
c      logical             single
c      data      ds     /  1665 1885.d0, 286 8876.d0  /
c      data      dm     /  1518 4245.d0, 265 1554.d0  /
c      data      dx24   /  1677 7216.d0  /
c      data      dx48   /  281 4749 7671 0656.d0  /
c      double precision dummy,a
c      single  =  .true.
c      goto 10
c      entry dranf(dummy)
c      a=dummy
c      single  =  .false.
c  10  dl  =  ds(1) * dm(1)
c      dc  =  dint(dl/dx24)
c      dl  =  dl - dc*dx24
c      du  =  ds(1)*dm(2) + ds(2)*dm(1) + dc
c      ds(2)  =  du - dint(du/dx24)*dx24
c      ds(1)  =  dl
c      dr     =  (ds(2)*dx24 + ds(1)) / dx48
c      if(single)  then
c         ranf  =  sngl(dr)
c      else
c         dranf  =  dr
c      endif
c      return
c      entry g900gt()
c      g900gt  =  ds(2)*dx24 + ds(1)
c      return
c      entry g900st(dseed)
c      ds(2)  =  dint(dseed/dx24)
c      ds(1)  =  dseed - ds(2)*dx24
c      g900st =  ds(1)
c      return
c      end
c
cc-----------------------------------------------------------------------
c      subroutine ranfgt(seed)
cc-----------------------------------------------------------------------
c      double precision    seed,     g900gt,   g900st,   dummy
c      seed  =  g900gt()
c      return
c      entry ranfst(seed)
c      dummy  =  g900st(seed)
c      return
c      end
cc-----------------------------------------------------------------------
c      subroutine ranfcv(seed)
cc-----------------------------------------------------------------------
cc Convert input seed to EPOS random number seed
cc Useless with ranf
cc-----------------------------------------------------------------------
c      double precision seed,dummy
c      dummy=seed
c
c      return
c      end
c
cc-----------------------------------------------------------------------
c      subroutine ranfini(seed,iseq,iqq)
cc-----------------------------------------------------------------------
cc Initialize random number sequence iseq with seed
cc if iqq=-1, run first ini : useless with ranf
cc    iqq=0 , set what sequence should be used
cc    iqq=1 , initialize sequence for initialization
cc    iqq=2 , initialize sequence for first event
cc-----------------------------------------------------------------------
c      IMPLICIT NONE
c      COMMON /CRRANMA3/CD,CINT,CM,TWOM24,TWOM48,MODCNS
c      DOUBLE PRECISION CD,CINT,CM,TWOM24,TWOM48
c      INTEGER          MODCNS
c      common/eporansto/diu0(100),iiseed(3)
c      double precision    seed,diu0
c      integer iiseed
c      common/eporansto2/irndmseq
c      integer irndmseq
c      integer iseed(3),iseq,iqq,iseqdum
c 
c      if(iqq.eq.0)then
c        call ranfst(seed)
c      elseif(iqq.eq.-1)then
c        iseqdum=iseq
c        iseed(1)=iseq
c      elseif(iqq.eq.2)then
c        if(seed.gt.1d15)stop'seedj larger than 1e15 not possible !'
c        call ranfst(seed)
c      elseif(iqq.eq.1)then        !dummy sequence for EPOS initialization
c        if(seed.gt.1d15)stop'seedi larger than 1e15 not possible !'
c        call ranfst(seed)
c      endif
c      return
c      end
c
