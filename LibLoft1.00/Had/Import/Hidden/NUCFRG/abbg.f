      module modNUCFRAG
!      implicit none
cABBGNUCFRAG.  AN ALGORITHM FOR A SEMIEMPIRICAL NUCLEAR FRAGMENTATION           
c1   MODEL.  F.F. BADAVI, L.W. TOWNSEND, J.W. WILSON, J.W. NORBURY.             
cREF. IN COMP. PHYS. COMMUN. 47 (1987) 281                                      
C                                                                              
!         KOUNT2: # of data in IZZ2,.. SIG3 below
!         IZZ2: Z of fragment
!         IPP2: A of fragment  
!         SIG2: fragmentation cross-section (mb)
!         SIG3: photon-induced fragmentation cross-section (mb)

      integer,parameter::IM=257,ICH=103,IEL=5,IMM=IM*IEL
      integer,save:: KOUNT2
      integer,save:: IZZ2(IMM) = 0, IPP2(IMM) = 0
      real(4),save:: SIG2(IMM) = 0., SIG3(IMM) = 0.        
c      DATA IZZ2,SIG2,IPP2,SIG3/IMM*0,IMM*0.,IMM*0,IMM*0./                      
      contains

      subroutine cNucFragXsec(PA, PZ, KEpn, TA, TZ)
      use NucMassFormula
C                        
      integer,intent(in):: PA, PZ  ! projectile A and Z
      real(8),intent(in):: KEpn  ! proj. KE/N in GeV
      integer,intent(in):: TA, TZ ! target A,Z
!           output will be in KOUNT2, IZZ2, IPP1, SIG2,SIG3

C                                                                              
      DIMENSION A(ICH),IZZ(IM,IEL),IPP(IM,IEL),SIG(IM,IEL)                     
      DIMENSION SIGEM1(IM,IEL),SIGEM2(IM,IEL)                                  
C                                                                              
      REAL MEXCESP,MEXCEGN,MEXCEGP                                             
C                                                                              
      DATA A/1.008,4.0026,6.941,9.012,10.81,12.011,14.007,15.999,              
     +18.998,20.179,22.99,24.31,26.98,28.09,30.974,32.06,35.453,               
     +39.948,39.102,40.08,44.96,47.9,50.94,52.,54.94,55.85,58.93,              
     +58.71,63.55,65.37,69.72,72.59,74.92,78.96,79.904,83.8,85.47,             
     +87.62,88.91,91.22,92.91,95.94,99.,101.07,102.91,106.4,107.87,            
     +112.4,114.82,118.69,121.75,127.6,126.9,131.3,132.91,137.34,              
     +138.91,140.12,140.91,144.24,147.,150.4,151.96,157.25,158.93,             
     +162.5,164.93,167.26,168.93,173.04,174.97,178.49,180.95,183.85,           
     +186.2,190.2,192.2,195.09,196.97,200.59,204.37,207.2,208.98,              
     +210.,210.,222.,223.,226.,227.,232.04,231.,238.03,237.,244.,              
     +243.,245.,247.,249.,254.,255.,256.,254.,257./                            
      DATA IZZ,IPP,SIG,SIGEM1,SIGEM2/IMM*0,IMM*0,IMM*0.,IMM*0.,IMM*0./         

C                                                                              
      KOUNT=0                                                                  
      KOUNT2=0                                                                 
      KDUM1=0                                                                  
      KDUM2=0                                                                  
      SUM=0.                                                                   
      SUMNUC=0.                                                                
      SUMEM=0.                                                                 
      ITRAP=0                                                                  
C                                                                              
C   PROJ. ENERGY IN MEV/AMU                                                    
C                                                                              
      ENG = KEpn*1000.    !  MeV/n
c      WRITE(6,1)                                                               
c1     FORMAT(' INPUT PROJ. ENERGY IN MEV/AMU')                                 
C      READ(5,*) ENG                                                            
C                                                                              
C   CHARGE OF PROJ.                                                            
C                                                                              
c      WRITE(6,12)                                                              
c12    FORMAT(' INPUT CHARGE OF PROJ.')                                         
c      READ(5,*) ICHARGE                                                        
      ICHARGE= PZ                                                        
      ZZP=ICHARGE
      AZP=A(ICHARGE)
C                                                                              
C   CHARGE OF TARGET                                                           
C                                                                              
c      WRITE(6,5)                                                               
c5     FORMAT(' INPUT CHARGE OF TARGET')                                        
c      READ(5,*) JZTI                                                           
      JZTI = TZ
      ZZT=JZTI                                                                 
      AZT=A(JZTI)                                                              
C !!!!!          work around for dueteron / triton KK
      if( PZ <= 1 ) then 
         DUM1 = 0.
         DUM2 = 0.
         goto 1000
      endif
C   GDR WIDTH (MEV)                                                            
C                                                                              
c      WRITE(6,2)                                                               
c2     FORMAT(' INPUT GDR WIDTH (MEV)')                                         
c      READ(5,*) WIDTH                                                          
      WIDTH = cPhotoDissociWidth(PA, PZ)
C                                                                              
C   PROTON BRANCHING RATIO                                                     
C                                                                              
c      WRITE(6,4)                                                               
c4     FORMAT(' INPUT PROTON BRANCHING RATIO')                                  
c      READ(5,*) FRCPROT                                                        
      FRCPROT = cgpByWH(PZ)
C                                                                              
C   MASS EXCESS OF PROJ.                                                       
C                                                                              
c      WRITE(6,6)                                                               
c6     FORMAT(' INPUT MASS EXCESS OF PROJ.(MEV) USE CORRECT SIGN')              
c      READ(5,*) MEXCESP                                                        
      MEXCESP = cNucMassExcessMeV(PA, PZ)
C                                                                              
C   MASS EXCESS OF FINAL NUCLEUS FOR (GAMMA,N) REACTION                        
C                                                                              
c      WRITE(6,7)                                                               
c7     FORMAT(' INPUT MASS EXCESS OF FINAL NUCLEUS FOR (GAMMA,N)',              
c     +' REACTION (MEV) USE CORRECT SIGN')                                      
c      READ(5,*) MEXCEGN                                                        
      MEXCEGN = cNucMassExcessMeV(PA-1, PZ)
C                                                                              
C   MASS EXCESS OF FINAL NUCLEUS FOR (GAMMA,P) REACTION                        
cC                                                                              
c      WRITE(6,8)                                                               
c8     FORMAT(' INPUT MASS EXCESS OF FINAL NUCLEUS FOR (GAMMA,P)',              
c     +' REACTION (MEV) USE CORRECT SIGN')                                      
c      READ(5,*) MEXCEGP                                                        
      MEXCEGP = cNucMassExcessMeV(PA-1, PZ-1)
C                                                                              
      QQEM=FRAG2(ZZP,AZP,ZZT,AZT,WIDTH,FRCPROT,MEXCESP,MEXCEGN,                
     +MEXCEGP,ENG,DUM1,DUM2)                                                   
C
 1000 continue

      IPROJ=IFIX(A(ICHARGE)+.5)                                                
C                                                                              
C   UPPER LIMIT OF LOOP 10 IS = IPROJ-1                                        
C                                                                              
      ITOP=IPROJ-1                                                             
C                                                                              
      DO 10 J=1,ITOP                                                           
      KOUNT=KOUNT+1                                                            
      IP=IPROJ-J                                                               
      AP=IP                                                                    
      IZ=AP/(1.+SNF(AP))+.5                                                    
      IZM=IZ-3                                                                 
C                                                                              
      DO 10 I=1,5                                                              
      KOUNT2=KOUNT2+1                                                          
      IZ=IZM+I                                                                 
      IZZ(J,I)=IZ                                                              
      IPP(J,I)=IP                                                              
      IF((IZ.GT.ICHARGE).OR.(IZ.LT.1))THEN                                     
      SIG(J,I)=-1.                                                             
      GO TO 10                                                                 
      END IF                                                                   
C                                                                              
      QQQJ=FRAG(ICHARGE,IPROJ,IZ,IP,ENG,SIGMA,A,JZTI)                          
C                                                                              
      QQQJ=QQQJ*SIGMA*1.E27                                                    
      SIG(J,I)=QQQJ                                                            
      IF(IZ.EQ.ICHARGE.AND.KDUM1.EQ.0) THEN                                    
      SIGEM1(J,I)=DUM2                                                         
      KDUM1=1                                                                  
      ELSE                                                                     
      SIGEM1(J,I)=0.0                                                          
      END IF                                                                   
      IF(IZ.EQ.ICHARGE-1.AND.KDUM2.EQ.0) THEN                                  
      SIGEM2(J,I)=DUM1                                                         
      KDUM2=1                                                                  
      ELSE                                                                     
      SIGEM2(J,I)=0.0                                                          
      END IF                                                                   
10    CONTINUE                                                                 
C                                                                              
      CALL SORT(IZZ,IPP,SIG,SIGEM1,SIGEM2,KOUNT,KOUNT2,ICHARGE,                
     +IZZ2,SIG2,IPP2,SIG3)                                                     
C                                                                              
c      WRITE(7,67)                                                              
c67    FORMAT(//)                                                               
C                                                                              
      DO 3 I=1,KOUNT2                                                          
         IF((IZZ2(I).GT.ICHARGE).OR.(IZZ2(I).LT.1)) GO TO 3                       
         IF(SIG2(I).EQ.-1.) GO TO 3                                               
         IF(ITRAP.NE.0) GO TO 34                                                  
c      WRITE(7,11)                                                              
c11    FORMAT(1X,'CHARGE(ZF)',2X,'MASS(AF)',2X,'NUC.FRAG.CRS.(MB)',             
c     +2X,'EM.CRS.(MB)',2X,'(NUC.+EM.)CRS.(MB)',/,                              
c     +1X,10('='),2X,8('='),2X,17('='),2X,11('='),2X,18('='),/)                 
34    CONTINUE                                                                 
c      WRITE(7,109) IZZ2(I),IPP2(I),SIG2(I),SIG3(I),SIG2(I)+SIG3(I)             
c109   FORMAT(3X,I3,8X,I3,3(6X,G14.4))                                          
      SUM=SUM+SIG2(I)+SIG3(I)                                                  
      SUMNUC=SUMNUC+SIG2(I)                                                    
      SUMEM=SUMEM+SIG3(I)                                                      
c      IF(IZZ2(I).NE.IZZ2(I+1)) WRITE(7,111) SUMNUC,SUMEM,SUM                   
c111   FORMAT(23X,17('-'),2X,11('-'),2X,18('-'),/,23X,                          
c     +G14.4,6X,G14.4,2X,'TOTAL=',G14.4)                                        
c      IF(IZZ2(I).NE.IZZ2(I+1)) WRITE(7,108)                                    
c108   FORMAT(/,1X,72('-'),/)                                                   
      IF(IZZ2(I).NE.IZZ2(I+1)) THEN                                            
      SUM=0.                                                                   
      SUMNUC=0.                                                                
      SUMEM=0.                                                                 
      END IF                                                                   
      IF(IZZ2(I).EQ.IZZ2(I+1)) THEN                                            
      ITRAP=1                                                                  
      ELSE                                                                     
      ITRAP=0                                                                  
      END IF                                                                   
3     CONTINUE                                                                 

c      STOP                                                                     
      end   subroutine cNucFragXsec
C                                                                              
C************FUNCTION FRAG(IZP,IAP,JZF,JAF,EN,SIGMA,A,JZTI)************        
C                                                                              
C   FUNCTION FRAG CALCULATES FRAGMENTATION PROBALITY FOR                       
C   MATERIAL FOR SPECIFIC ISOTOPE                                              
C                                                                              
      FUNCTION FRAG(IZP,IAP,JZF,JAF,EN,SIGMA,A,JZTI)                           
C                                                                              
      DIMENSION A(1),RHO(1)                                                    
C                                                                              
C   RHO IS DENSITY OF TARGET(#/CC) AND IS SET TO 1.0                           
C   IF TARGET IS A SINGLE ELEMENT                                              
C                                                                              
      DATA RHO/1./                                                             
C                                                                              
      AP=IAP                                                                   
      ZP=IZP                                                                   
      QTOT=0.                                                                  
      STOT=0.                                                                  
      IF(JZTI.GT.1) GO TO 2001                                                 
C                                                                              
C   FRAGMENTATION ON PROTON TARGET                                             
C                                                                              
      IF(EN.LT.25) EN=25.                                                      
      CALL YIELDX(IZP,IAP,JZF,JAF,EN,QJ)                                       
      QTOT=RHO(1)*QJ                                                           
      SIGMA=45.*AP**.7*(1.+.016*SIN(5.3-2.62*ALOG(AP)))                        
      IF(EN.GT.2000.) GO TO 2000                                               
      SIGMA=SIGMA*(1-.62*TEXP(-EN/200.)*SIN(10.6/EN**.28))                     
 2000 CONTINUE                                                                 
      STOT=RHO(1)*SIGMA                                                        
      SIGMA=STOT*1.E-27                                                        
      QTOT=QTOT*1.E-27/SIGMA                                                   
      FRAG=QTOT                                                                
      RETURN                                                                   
 2001 CONTINUE                                                                 
      JAT=IFIX(A(JZTI)+.5)                                                     
      AT=JAT                                                                   
      AF=JAF                                                                   
      ZF=JZF                                                                   
C                                                                              
C   FRAGMENTATION ON HEAVY TARGETS (A>=2)                                      
C                         
      CALL YIELDH(AP,ZP,AT,AF,ZF,QJ,SOG,SIGT)                                  
      QTOT=QTOT+QJ*RHO(1)                                                      
      SIGAPAT=50.*(AP**.3333+AT**.3333-.2-1./AP-1./AT)**2                      
      STOT=STOT+RHO(1)*SIGAPAT                                                 
      SIGMA=STOT*1.E-27                                                        
      QTOT=QTOT*1.E-27/SIGMA                                                   
      FRAG=QTOT                                                                
      RETURN                                                                   
      END FUNCTION FRAG
C                                                                              
C*FUNCTION FRAG2(ZP,AP,ZT,AT,WIDTH,FRCPROT,MEXCESP,MEXCEGN,MEXCEGP,TLAB,       
C* DUM1,DUM                                                                    
      FUNCTION FRAG2(ZP,AP,ZT,AT,WIDTH,FRCPROT,MEXCESP,MEXCEGN,                
     +MEXCEGP,TLAB,DUM1,DUM2)                                                  
C                                                                              
      PARAMETER(II=900)                                                        
C                                                                              
      DIMENSION EPHOTON(II),SIGMANU(II)                                        
C                                                                              
      REAL NE(II),MNCSQ,MNEUTRN,MPROTON,MSTAR,J,NT,NP,MEXCESP,K0,K1,           
     +MEXCEGN,MEXCEGP,MPROJ,MFINGN,MFINGP,NEE,INTP,INTN,INTSUM                 
C                                                                              
      PI=3.14159265                                                            
      FSC=1./137.03604                                                         
      HBARC=197.32858                                                          
      MNCSQ=938.95                                                             
      MNEUTRN=939.5731                                                         
      MPROTON=938.2796                                                         
      AMU=931.5016                                                             
      MSTAR=.7*MNCSQ                                                           
      J=36.8                                                                   
      Q=17.0                                                                   
      EPSILON=.0768                                                            
C                                                                              
      NT=AT-ZT                                                                 
      NP=AP-ZP                                                                 
      R10T=2.919557+1.009951E-1*ZT-5.009579E-4*ZT**2                           
      R10P=2.919557+1.009951E-1*ZP-5.009579E-4*ZP**2                           
      DEE=0.0                                                                  
      BMIN=R10T+R10P-DEE                                                       
      MPROJ=MEXCESP+AP*AMU                                                     
      MFINGN=MEXCEGN+(AP-1)*AMU                                                
      MFINGP=MEXCEGP+(AP-1)*AMU                                                
      ETHSHGN=((MFINGN+MNEUTRN)**2-MPROJ**2)/(2*MPROJ)                         
      ETHSHGP=((MFINGP+MPROTON)**2-MPROJ**2)/(2*MPROJ)                         
      GAMMA=1.+TLAB/MNCSQ                                                      
      VEL=SQRT(1.-1./GAMMA**2)                                                 
      SIGMAM=120.*NP*ZP/(PI*AP*WIDTH)                                          
      R0=1.18*AP**(1./3.)                                                      
      U=3.*J*AP**(-1./3.)/Q                                                    
      EGDR=SQRT(8.*J*HBARC**2/(MSTAR*R0**2)*1./(1.+U-(1.+                      
     +EPSILON+3.*U)*EPSILON/(1.+EPSILON+U)))                                   
      IF(ETHSHGN.LT.ETHSHGP) THEN                                              
      EPHOTON(1)=ETHSHGN                                                       
      END IF                                                                   
      IF(ETHSHGN.GT.ETHSHGP) THEN                                              
      EPHOTON(1)=ETHSHGP                                                       
      END IF                                                                   
      EPHOMAX=50.0                                                             
      NPTS=200                                                                 
      EINT=(EPHOMAX-EPHOTON(1))/(NPTS-1.)                                      
      SUM=0.                                                                   
      SUMP=0.                                                                  
      SUMN=0.                                                                  
C                                                                              
      DO 1 I=1,NPTS                                                            
      EPHOTOM=EPHOTON(1)+(I-1)*EINT                                            
      EPHOTON(I)=EPHOTOM                                                       
      SIGMAMU=SIGMAM/(1.+(EPHOTOM**2-EGDR**2)**2/(EPHOTOM**2*WIDTH**2))        
      SIGMANU(I)=SIGMAMU                                                       
      ECUTOFF=HBARC*GAMMA*VEL/BMIN                                             
      G=EPHOTOM/ECUTOFF                                                        
C                                                                              
      CALL BESSEL(G,K0,K1)                                                     
C                                                                              
      NEE=2.*ZT**2*FSC/(EPHOTOM*PI*VEL**2)*(G*K0*K1-.5*VEL**2*G**2*            
     +(K1**2-K0**2))                                                           
      NE(I)=NEE                                                                
      FUNCTN=SIGMAMU*NEE                                                       
      IF(I.EQ.1.OR.I.EQ.NPTS) THEN                                             
      FUNCTN=0.5*FUNCTN                                                        
      END IF                                                                   
      SUM=SUM+FUNCTN                                                           
      FUNCTNP=FRCPROT*FUNCTN                                                   
      FUNCTNN=(1.-FRCPROT)*FUNCTN                                              
      IF(EPHOTOM.LT.ETHSHGP) THEN                                              
      FUNCTNP=0.                                                               
      END IF                                                                   
      IF(EPHOTOM.LT.ETHSHGN) THEN                                              
      FUNCTNN=0.                                                               
      END IF                                                                   
      SUMP=SUMP+FUNCTNP                                                        
      SUMN=SUMN+FUNCTNN                                                        
1     CONTINUE                                                                 
C                                                                              
      INTP=EINT*SUMP                                                           
      INTN=EINT*SUMN                                                           
      INTSUM=INTP+INTN                                                         
      DUM1=INTP                                                                
      DUM2=INTN                                                                
      FRAG2=INTSUM                                                             
      RETURN                                                                   
      END  FUNCTION FRAG2
C**************SUBROUTINE BESSEL(G,K0,K1)***********************               
C                                                                              
      SUBROUTINE BESSEL(G,K0,K1)                                               
C                                                                              
      DIMENSION A(30),B(27)                                                    
C                                                                              
      REAL I0,I1,K0,K1                                                         
C                                                                              
      DATA (A(I),I=1,30)/                                                      
     +       3.5156229,3.0899424,1.2067492,.2659732,.0360768,.0045813,         
     +      .39894228,.01328592,.00225319,.00157565,.00916281,.02057706,       
     +    .02635537,.01647633,.00392377,.87890594,.51498869,.15084934,         
     +     .02658733,.00301532,.00032411,.39894228,.03988024,.00362018,        
     +      .00163801,.01031555,.02282967,.02895312,.01787654,.00420059/       
      DATA (B(I),I=1,27)/                                                      
     +       .57721566,.42278420,.23069756,.0348859,.00262698,.0001075,        
     +      .0000074,1.25331414,.07832358,.02189568,.01062446,.00587872,       
     +      .00251540,.00053208,.15443144,.67278579,.18156897,.01919402,       
     +   .00110404,.00004686,1.25331414,.23498619,.03655620,.01504268,         
     +       .00780353,.00325614,.00068245/                                    
C                                                                              
      T=G/3.75                                                                 
      IF(G.LE.3.75) THEN                                                       
      I0=1.+A(1)*T**2+A(2)*T**4+A(3)*T**6+A(4)*T**8+A(5)*T**10                 
     +     +A(6)*T**12                                                         
      I1=G*(.5+A(16)*T**2+A(17)*T**4+A(18)*T**6+A(19)*T**8                     
     +        +A(20)*T**10+A(21)*T**12)                                        
      ELSE                                                                     
      I0=1./SQRT(G)*EXP(G)*(A(7)+A(8)/T+A(9)/T**2-A(10)/T**3                   
     +    +A(11)/T**4-A(12)/T**5+A(13)/T**6-A(14)/T**7+A(15)/T**8)             
      I1=1./SQRT(G)*EXP(G)*(A(22)-A(23)/T-A(24)/T**2+A(25)/T**3                
     +   -A(26)/T**4+A(27)/T**5-A(28)/T**6+A(29)/T**7-A(30)/T**8)              
      END IF                                                                   
      S=G/2.                                                                   
      IF(G.LE.2.) THEN                                                         
      K0=-ALOG(S)*I0-B(1)+B(2)*S**2+B(3)*S**4+B(4)*S**6+B(5)*S**8              
     +   +B(6)*S**10+B(7)*S**12                                                
      K1=ALOG(S)*I1+1./G*(1.+B(15)*S**2-B(16)*S**4-B(17)*S**6-                 
     +   B(18)*S**8-B(19)*S**10-B(20)*S**12)                                   
      ELSE                                                                     
      K0=1./SQRT(G)*EXP(-G)*(B(8)-B(9)/S+B(10)/S**2-B(11)/S**3                 
     +   +B(12)/S**4-B(13)/S**5+B(14)/S**6)                                    
      K1=1./SQRT(G)*EXP(-G)*(B(21)+B(22)/S-B(23)/S**2+B(24)/S**3               
     +   -B(25)/S**4+B(26)/S**5-B(27)/S**6)                                    
      END IF                                                                   
      RETURN                                                                   
      END SUBROUTINE BESSEL
C                                                                              
C**SUBROUTINE SORT(IZZ,IPP,SIG,SIGEM1,SIGEM2,KOUNT,KOUNT2,ICHARGE,******       
C                  IZZ2,SIG2,IPP2,SIG3)                                        
C                                                                              
      SUBROUTINE SORT(IZZ,IPP,SIG,SIGEM1,SIGEM2,KOUNT,KOUNT2,ICHARGE,          
     +IZZ2,SIG2,IPP2,SIG3)                                                     
C                                                                              
      PARAMETER(IM=257,ICH=103,IEL=5,IDUM=IM*IEL)                              
C                                                                              
      DIMENSION IZZ(IM,IEL),IPP(IM,IEL),SIG(IM,IEL)                            
      DIMENSION IZZ2(IDUM),SIG2(IDUM),IPP2(IDUM)                               
      DIMENSION SIG3(IDUM),SIGEM1(IM,IEL),SIGEM2(IM,IEL)                       
C                                                                              
      DO 1 I=1,5                                                               
C                                                                              
      DO 2 J=1,KOUNT                                                           
      IZZ2(J+(I-1)*KOUNT)=IZZ(J,I)                                             
      IPP2(J+(I-1)*KOUNT)=IPP(J,I)                                             
      SIG2(J+(I-1)*KOUNT)=SIG(J,I)                                             
      IF(SIGEM1(J,I).NE.0.) THEN                                               
      SIG3(J+(I-1)*KOUNT)=SIGEM1(J,I)                                          
      ELSE                                                                     
      SIG3(J+(I-1)*KOUNT)=SIGEM2(J,I)                                          
      END IF                                                                   
2     CONTINUE                                                                 
C                                                                              
1     CONTINUE                                                                 
C                                                                              
      DO 10 I=1,KOUNT2-1                                                       
      N=I+1                                                                    
C                                                                              
      DO 10 J=N,KOUNT2                                                         
      IF(IZZ2(I).GE.IZZ2(J)) GO TO 10                                          
      TEMP=IZZ2(I)                                                             
      IZZ2(I)=IZZ2(J)                                                          
      IZZ2(J)=TEMP                                                             
      TEMP=IPP2(I)                                                             
      IPP2(I)=IPP2(J)                                                          
      IPP2(J)=TEMP                                                             
      TEMP=SIG2(I)                                                             
      SIG2(I)=SIG2(J)                                                          
      SIG2(J)=TEMP                                                             
      TEMP=SIG3(I)                                                             
      SIG3(I)=SIG3(J)                                                          
      SIG3(J)=TEMP                                                             
10    CONTINUE                                                                 
C                                                                              
      RETURN                                                                   
      END SUBROUTINE SORT
                                                                     
C                                                                              
C****************SUBROUTINE YIELDX(IZ,IA,JZ,JA,EJ,QJ)*****************         
C                                                                              
      SUBROUTINE YIELDX(IZ, IA, JZ, JA, EJ, QJ)                                
C                                                                              
      QJ = 0                                                                   
      IF(IZ+1.LT.JZ) RETURN                                                    
      IF(IA.LT.JA) RETURN                                                      
      IF(JA.LE.0.OR.JZ.LT.0) RETURN                                            
      IF(JA.EQ.1.AND.JZ*JZ.LE.1) CALL YIELDN(IZ,IA,JZ,JA,EJ,QJ)                
      IF(JA.EQ.4) CALL YIELDA(IZ,IA,JZ,JA,EJ,QJ)                               
      IF(JA.EQ.2.OR.JA.EQ.3) CALL YIELDT(IZ,IA,JZ,JA,EJ,QJ)                    
      IF(JA.LE.4) RETURN                                                       
      AP=IA                                                                    
      ZF=JZ                                                                    
      AF=JA                                                                    
      IF(IZ*IA.EQ.JZ*JA) RETURN                                                
C                                                                              
C   IF FRAGMENTS MASS IS GREATER THAN 4 USE RUDSTAM                            
C                                                                              
      QJ=CROS(AP,ZF,AF,EJ)                                                     
      IF((IA-JA).GT.1)GO TO 2001                                               
      IF((IZ-JZ).GE.0.AND.(IZ-JZ).LE.1)QJ=0.04                                 
 2001 CONTINUE                                                                 
      SIGMA=45.*AP**.7*(1.+.016*SIN(5.3-2.62*ALOG(AP)))                        
      IF(EJ.GT.2000.) GO TO 2000                                               
      SIGMA=SIGMA*(1-.62*TEXP(-EJ/200.)*SIN(10.6/EJ**.28))                     
 2000 CONTINUE                                                                 
      QJ=QJ*SIGMA                                                              
      IF(JA.EQ.8) QJ=QJ/10.                                                    
      RETURN                                                                   
      END  SUBROUTINE YIELDX
C                                                                              
C*************************FUNCTION SNF(A)****************************          
C                                                                              
C   FUNCTION SNF RELATES MASS AND CHARGE ON NUCLEAR STABILITY CURVE            
C                                                                              
      FUNCTION SNF(A)                                                          
C                                                                              
      SNF=1.011363617+A*(3.522612875E-3-A*5.340775146E-6)                      
      RETURN                                                                   
      END FUNCTION SNF
C                                                                              
C***************SUBROUTINE YIELDN(IZP,IAP,IZF,IAF,EJ,QJ)**************         
C                                                                              
C   SUBROUTINE YIELDN IS BERTINI NUCLEON PRODUCTION IN COLLISION WITH          
C   PROTONS                                                                    
      SUBROUTINE YIELDN(IZP,IAP,IZF,IAF,EJ,QJ)                                 
C                                                                              
      DIMENSION AT(10),AH(10,2),AL(10,2),CN(10,2)                              
C                                                                              
      DATA AT/1.,2.,3.,4.,5.,6.,12.,16.,27.,64./                               
      DATA AH/0.,0.,0.,0.,0.,.34,.42,.42,.54,.48,                              
     +         .34,.34,.34,.34,0.,.39,.2,.2,.32,.56/                           
      DATA AL/0.,0.,0.,0.,0.,.33,.396,.407,.322,.411,                          
     +        0.,0.,0.,0.,0.,.22,.24,.26,.387,.619/                            
      DATA CN/0.,1.,1.5,1.,1.,1.,1.29,1.42,1.71,4.19,                          
     +        2.,2.,2.,1.5,1.,1.,2.14,2.42,2.69,2.56/                          
C                                                                              
      N=IZF+1                                                                  
      AP=IAP                                                                   
      EN=EJ/AP                                                                 
      A3=AP**.6667                                                             
      IF(IAP.GT.6) GO TO 10                                                    
      SIG  =45.*AP**.7*(1.+.016*SIN(5.3-2.62*ALOG(AP)))                        
      IF(EN.GT.2000.) GO TO 2000                                               
      SIG  =SIG  *(1-.62*TEXP(-EN/200.)*SIN(10.6/EN**.28))                     
 2000 CONTINUE                                                                 
      IF( EN.LT.400.) QJ=CN(IAP,N)*(EN/400.)**AL(IAP,N)                        
      IF( EN.GE.400.) QJ=CN(IAP,N)*(EN/400.)**AH(IAP,N)                        
      QJ=QJ*SIG                                                                
      RETURN                                                                   
   10 IF(IAP.GT.12) GO TO 12                                                   
      IAT=7                                                                    
      A1=6.**.6667                                                             
      A2=12.**.6667                                                            
      GO TO 100                                                                
   12 IF(IAP.GT.16) GO TO 16                                                   
      IAT=8                                                                    
      A1=12.**.6667                                                            
      A2=16.**.6667                                                            
      GO TO 100                                                                
   16 IF(IAP.GT.27) GO TO 27                                                   
      IAT=9                                                                    
      A1=16.**.6667                                                            
      A2=27.**.6667                                                            
      GO TO 100                                                                
   27 IAT=10                                                                   
      A1=27.**.66667                                                           
      A2=64.**.6667                                                            
  100 IF(EN.GT.400.) GO TO 200                                                 
      Q2=CN(IAT,N)*(EN/400.)**AL(IAT,N)                                        
      IAT=IAT-1                                                                
      Q1=CN(IAT,N)*(EN/400.)**AL(IAT,N)                                        
      QJ=Q2+(Q1-Q2)*(A3-A2)/(A1-A2)                                            
      SIG  =45.*AP**.7*(1.+.016*SIN(5.3-2.62*ALOG(AP)))                        
      IF(EN.GT.2000.) GO TO 2001                                               
      SIG  =SIG  *(1-.62*TEXP(-EN/200.)*SIN(10.6/EN**.28))                     
 2001 CONTINUE                                                                 
      QJ=QJ*SIG                                                                
      RETURN                                                                   
  200 Q2=CN(IAT,N)*(EN/400.)**AH(IAT,N)                                        
      IAT=IAT-1                                                                
      Q1=CN(IAT,N)*(EN/400.)**AH(IAT,N)                                        
      QJ=Q2+(Q1-Q2)*(A3-A2)/(A1-A2)                                            
      SIG  =45.*AP**.7*(1.+.016*SIN(5.3-2.62*ALOG(AP)))                        
      IF(EN.GT.2000.) GO TO 2002                                               
      SIG  =SIG  *(1-.62*TEXP(-EN/200.)*SIN(10.6/EN**.28))                     
 2002 CONTINUE                                                                 
      QJ=QJ*SIG                                                                
      RETURN                                                                   
      END SUBROUTINE YIELDN
C                                                                              
C***************SUBROUTINE YIELDA(IZP,IAP,IZF,IAF,EJ,QJ)***************        
C                                                                              
CSUBROUTINE YIELDA IS BERTINI ALPHA PRODUCTION IN COLLISION WITH PROTONS       
C                                                                              
      SUBROUTINE YIELDA(IZP,IAP,IZF,IAF,EJ,QJ)                                 
C                                                                              
      EJ=EJ/IAP                                                                
      IF(IZF.EQ.2 ) GO TO 2                                                    
      QJ=0.                                                                    
      RETURN                                                                   
    2 AP=IAP                                                                   
      AP3=AP**.33333                                                           
      IF(IAP.LE.16) GO TO 16                                                   
      IF(IAP.LT.27) GO TO 27                                                   
      QJU=.009*EJ**.4                                                          
      IF(EJ.LE.400.) GO TO 27                                                  
      QJU=7.26E-4*EJ**.82                                                      
      IF(EJ.LT.2700.) GO TO 27                                                 
      QJU=.473                                                                 
   27 QJL=.055*EJ**.4                                                          
      IF(EJ.LT.110.) GO TO 100                                                 
      QJL=.36                                                                  
      IF(EJ.LT.460.) GO TO 100                                                 
      QJL=3.6E-3*EJ**.75                                                       
      IF(EJ.LT.900.) GO TO 100                                                 
      QJL=.59                                                                  
  100 IF(IAP.LT.27) GO TO 110                                                  
      QJ=QJL+(QJU-QJL)*(AP3-3.)                                                
      GO TO 155                                                                
  110 CONTINUE                                                                 
      QJU=QJL                                                                  
   16 QJL=.162*EJ**.35                                                         
      IF(EJ.LT.50.) GO TO 120                                                  
      QJL=.637                                                                 
      IF(EJ.LT.300) GO TO 120                                                  
      QJL=.321*EJ**.12                                                         
      IF(EJ.LT.600.) GO TO 120                                                 
      QJL=.692                                                                 
  120 CONTINUE                                                                 
      IF(IAP.LE.16) GO TO 130                                                  
      QJ=QJL+(QJU-QJL)*(AP3-2.52)/.48                                          
      GO TO 155                                                                
  130 CONTINUE                                                                 
      QJ=QJL*(16./AP)**.3                                                      
      IF(IAP.LT.5)QJ=0.                                                        
  155 SIG  =45.*AP**.7*(1.+.016*SIN(5.3-2.62*ALOG(AP)))                        
      IF(EJ.GT.2000.) GO TO 2000                                               
      SIG  =SIG  *(1-.62*TEXP(-EJ/200.)*SIN(10.6/EJ**.28))                     
 2000 CONTINUE                                                                 
      QJ=QJ*SIG                                                                
      EJ=EJ*AP                                                                 
      RETURN                                                                   
      END SUBROUTINE YIELDA
C                                                                              
C****************SUBROUTINE YIELDT(IZP,IAP,IZF,IAF,EJ,QJ)***************       
C                                                                              
CSUBROUTINE YIELDT IS BERTINI MASS 3 PRODUCTION IN COLLISION WITH PROTON       
C                                                                              
      SUBROUTINE YIELDT(IZP,IAP,IZF,IAF,EJ,QJ)                                 
C                                                                              
      DIMENSION A(3),F(3,3)                                                    
C                                                                              
      DATA F/.32,.025,.05,.57,.071,.11,2.,.4,.3/                               
      DATA A/16.,27.,64./                                                      
C                                                                              
      ITYPE=0                                                                  
      AP=IAP                                                                   
      AP3=AP**.3333                                                            
      QJ=0.                                                                    
      IF(IZF.GT.2.OR.IZF.LT.1) RETURN                                          
      CALL YIELDA(IZP,IAP,2,4,EJ,QJA)                                          
      IF(IZF.EQ.1.AND.IAF.EQ.2)ITYPE=1                                         
      IF(IZF.EQ.1.AND.IAF.EQ.3)ITYPE=2                                         
      IF(IZF.EQ.2.AND.IAF.EQ.3) ITYPE=3                                        
      IF(ITYPE.EQ.0) RETURN                                                    
      IF(IAP.LE.5) GO TO 5                                                     
      IF(IAP.LE.16)GO TO 16                                                    
      IF(IAP.LE.27.) GO TO 27                                                  
      FAC=F(ITYPE,2)+(F(ITYPE,3)-F(ITYPE,2))*(AP3-3.)                          
      QJ=FAC*QJA                                                               
      RETURN                                                                   
    5 CONTINUE                                                                 
      IF(IAP.EQ.5) RETURN                                                      
      IF(IAP.EQ.4.AND.ITYPE.GT.1)RETURN                                        
      IF(IAP.LT.3)RETURN                                                       
      EN=EJ/AP                                                                 
      SIG  =45.*AP**.7*(1.+.016*SIN(5.3-2.62*ALOG(AP)))                        
      IF(EN.GT.2000.) GO TO 2000                                               
      SIG  =SIG  *(1-.62*TEXP(-EN/200.)*SIN(10.6/EN**.28))                     
 2000 CONTINUE                                                                 
      QJ=SIG/2.                                                                
      RETURN                                                                   
   27 FAC=F(ITYPE,1)+(F(ITYPE,2)-F(ITYPE,1))*(AP3-2.52)/.48                    
      QJ=FAC*QJA                                                               
      RETURN                                                                   
   16 QJ=F(ITYPE,1)*QJA                                                        
      RETURN                                                                   
      END  SUBROUTINE YIELDT
C                                                                              
C*******SUBROUTINE GEODA(AP,AT,AF,SIGT,SIG,ABR,ABL,SIGP,ABRP,ABLP)******       
C                                                                              
C   SUBROUTINE GEODA CALCULATES ABLATION AND ABRATION CROSS SEC.               
C                                                                              
      SUBROUTINE GEODA(AP,AT,AF,SIGT,SIG,ABR,ABL,SIGP,ABRP,ABLP)               
C                                                                              
      RP=1.26*AP**.3333                                                        
      RT=1.26*AT**.3333                                                        
      BMAX=RP+RT                                                               
C                                                                              
C   FRAGMENTATION WITH FRICTIONAL SPECTATOR INTERACTION (F.S.I.)               
C                   
      CALL BSEACH(AP,RP,RT,AF+.5,B2,ABR2,ABL2)                                 
      CALL BSEACH(AP,RP,RT,AF-.5,B1,ABR1,ABL1)                                 
C                                                                              
C   SIG IS FRAGMENTATION CROSS SECTION                                         
C   SIGT IS ABSORPTION CROSS SECTION                                           
C                                                                              
      SIG=10.*3.1415*(B2**2-B1**2)                                             
      SIGT=10.*3.1415*(BMAX-.504)**2                                           
      ABL=(ABL1+ABL2)/2.                                                       
      ABR=(ABR1+ABR2)/2.                                                       
C                                                                              
C   FRAGMENTATION WITHOUT F.S.I.                                               
C                                                                              
      CALL BSEEK(AP,RP,RT,AF+.5,B2,ABR2,ABL2)                                  
      CALL BSEEK(AP,RP,RT,AF-.5,B1P,ABR1,ABL1)                                 
C                                                                              
C   SIGP IS FRAGMENTATION CROSS SECTION                                        
C                                                                              
      SIGP=10.*3.1415*(B2**2-B1P**2)                                           
      SIGTP=10.*3.1415*(BMAX-.504)**2                                          
      ABLP=(ABL1+ABL2)/2.                                                      
      ABRP=(ABR1+ABR2)/2.                                                      
      IF(AF.EQ.1.)GO TO 17                                                     
      IF(AF.EQ.5.) SIG=0.0                                                     
      IF(AF.EQ.5.) SIGP=0.                                                     
      IF(AF.EQ.8.)SIG=SIG/10.                                                  
      IF(AF.EQ.8.) SIGP=SIGP/10.                                               
      IF(AF.EQ.9.)SIG=.5*SIG                                                   
      IF(AF.EQ.9.) SIGP=.5*SIGP                                                
      RETURN                                                                   
   17 CONTINUE                                                                 
C                                                                              
C   CENTRAL COLLISION YIELD IF AF=1                                            
C                                                                              
      SIG1=10.*3.1415*B1**2                                                    
       SIG1P=10.*3.1415*B1P**2                                                 
      ABL=ABL*SIG/(SIG+SIG1)                                                   
      ABLP=ABLP*SIGP/(SIGP+SIG1P)                                              
      ABR=(ABR*SIG+AP*SIG1)/(SIG+SIG1)                                         
      ABRP=(ABRP*SIGP+AP*SIG1P)/(SIGP+SIG1P)                                   
      SIGP=SIGP+SIG1P                                                          
      SIG=SIG+SIG1                                                             
      RETURN                                                                   
      END SUBROUTINE GEODA
C                                                                              
C*****************SUBROUTINE BSEACH(AP,RT,RP,AF,B,ABR,ABL)*************        
C                                                                              
C   SUBROUTINE BSEACH USES A GEOMETRICAL APPROACH TO FIND ABR AND ABL          
C   CALCUILATES DELTAA AS A FUNCTION OF IMPACT PARAMETER                       
C   INCLUDES F.S.I.                                                            
C                                                                              
      SUBROUTINE BSEACH(AP,RP,RT,AF,B,ABR,ABL)                                 
C                                                                              
      FSI=1.                                                                   
1     CONTINUE                                                                 
      ABLMIN=0.                                                                
      ABLMAX=0.                                                                
      ABRMIN=AP                                                                
      ABRMAX=0.                                                                
      BMAX=RT+RP                                                               
      BMIN=0.                                                                  
      XAVE=1.5                                                                 
      UN=RP/BMAX                                                               
      UM=RT/RP                                                                 
      IIT=0                                                                    
   70 CONTINUE                                                                 
      IF(IIT.EQ.13)GO TO 2000                                                  
      B=(BMAX+BMIN)/2.                                                         
      BTA=B/(RP+RT)                                                            
      IF(RT.LT.RP) GO TO 1000                                                  
      IF(B.LT.(RT-RP)) GO TO 10                                                
      P=.125*SQRT(UM*UN)*(1./UM-2.)*((1.-BTA)/UN)**2                           
     +-.125*(.5*SQRT(UM*UN)*(1./UM-2.)+1.)*((1.-BTA)/UN)**3                    
      F=.75*SQRT(1.-UN)*((1.-BTA)/UN)**2-.125*(3*SQRT(1.-UN)-1)                
     +*((1-BTA)/UN)**3                                                         
      GO TO 20                                                                 
   10 CONTINUE                                                                 
      P=-1.                                                                    
      F=1.                                                                     
      GO TO 20                                                                 
 1000 CONTINUE                                                                 
      IF(B.LT.(RP-RT)) GO TO 1010                                              
      P=.125*SQRT(UN*UM)*(1./UM-2.)*((1.-BTA)/UN)**2                           
     +-.125*(.5*SQRT(UN/UM)*(1/UM-2)-(SQRT(1-UM*UM)/UN-1)*SQRT((2-UM)          
     +*UM)/UM**3)*((1-BTA)/UN)**3                                              
      F=.75*SQRT(1-UN)*((1-BTA)/UN)**2                                         
     +-.125*(3*SQRT(1-UN)/UM-(1-(1-UM*UM)**1.5)*(1-(1-UM)**2)**.5              
     +/UM**3)*((1-BTA)/UN)**3                                                  
      GO TO 20                                                                 
 1010 CONTINUE                                                                 
      P=(SQRT(1-UM*UM)/UN-1)*SQRT(1-(BTA/UN)**2)                               
      F=(1-(1-UM*UM)**1.5)*SQRT(1-(BTA/UN)**2)                                 
20    ROT=ABS(B-RP)                                                            
      ROP=ABS(B-RT)                                                            
      IF(ROT.GE.RT) ROT=RT                                                     
      IF(ROP.GT.RP) ROP=RP                                                     
C                                                                              
C   CLT IS LONGITUDINAL CHORD IN TARGET                                        
C   CLP IS LONGITUDINAL CHORD IN PROJECTILE                                    
C                                                                              
      CLT=2.*SQRT(RT*RT-ROT*ROT+1.E-12)                                        
      CLP=2.*SQRT(RP*RP-ROP*ROP+1.E-12)                                        
      ATTEN=1.-.5*TEXP(-CLT/XAVE)-.5*TEXP(-CLP/XAVE)                           
C                                                                              
C   ABL HERE IS DUE TO SURFACE DEFORMATION ONLY                                
C                                                                              
      ABL=4.*3.1415*RP*RP*(1.+P-(1.-F)**.6667)*.095                            
      RO=ABS(B-RT)                                                             
C                                                                              
C   FUDGE IS A SEMI-EMPRICAL CORRECTION TO DEFORMATION ENERGY                  
C                                                                              
      FUDGE=1+10.*F+25*F*F                                                     
      IF(RO.LT.RP)GO TO 333                                                    
      RO=RP                                                                    
      FUDGE=2*FUDGE                                                            
 333  AEX=1.3*CLP                                                              
      BP=(RP*RP+B*B-RT*RT)/(2.*B+1.E-12)                                       
      IF (BP.LT.0.) BP=0.                                                      
      IF(BP.GE.RP)BP=RP-1.E-12                                                 
      CT=2.*SQRT(RP*RP-BP*BP)                                                  
      IF(CT.LT.1.5)CT=1.5                                                      
C                                                                              
C   AEX IS THE F.S.I. ENERGY CORRECTION                                        
C                                                                              
      AEX =AEX*(1.+(CT-1.5)/3.)                                                
      ABL=ABL*FUDGE+AEX*FSI                                                    
C                                                                              
C   AFP IS THE FINAL FRAGMENT MASS                                             
C                                                                              
      AFP=AP-(F*AP+ABL)*ATTEN                                                  
      IIT=IIT+1                                                                
      IF(AF.GE.AFP) GO TO 21                                                   
      BMAX=B                                                                   
      ABRMAX=AP*F*ATTEN                                                        
      ABLMAX=ABL*ATTEN                                                         
      GO TO 199                                                                
   21 CONTINUE                                                                 
      BMIN=B                                                                   
      ABLMIN=ABL*ATTEN                                                         
      ABRMIN=AP*F*ATTEN                                                        
  199 CONTINUE                                                                 
      IF(ABS(AF-AFP).LT..0005) GO TO 2000                                      
      GO TO 70                                                                 
 2000 CONTINUE                                                                 
      ABL=(ABLMIN+ABLMAX)/2.                                                   
      B=(BMAX+BMIN)/2.                                                         
      ABR=(ABRMAX+ABRMIN)/2.                                                   
      RETURN                                                                   
!      ENTRY BSEEK  must be below; KK (otherwise ifort no error but
!          result strange. gfortran and many; seg. fault) 
      ENTRY BSEEK(AP,RP,RT,AF,B,ABR,ABL)
      FSI=0.                                                                   
      GO TO 1                                                                  
      END SUBROUTINE BSEACH
C*************SUBROUTINE YIELDH(AP,ZP,AT,AF,ZF,QJ,SOG,SIGT)************        
C                                                                              
C   SUBROUTINE YIELH CALCULATES FRAGMENTATION CROSS SEC. FOR SPECIFIC          
C   FRAGMENT                                                                   
      SUBROUTINE YIELDH(AP,ZP,AT,AF,ZF,QJ,SOG,SIGT)                            
C                                                                              
      QJ=0.                                                                    
      SOG=0.                                                                   
      SOGP=0.                                                                  
      IF(AF.LE.4.) GO TO 4                                                     
      CALL LIMIT(AF,ZF,ITOP,IBOTTOM)                                           
      IF((ZF.LT.IBOTTOM).AND.(ZF.GT.ITOP)) RETURN                              
      CALL GEOFR(AP,ZP,AT,AF,ZF,ITOP,IBOTTOM,FNOR)                             
      CALL GEODA(AP,AT,AF,SIGT,SOG,ABR,ABL,SOGP,ABRP,ABRL)                     
      QJ=FNOR*(SOG+SOGP)/2.                                                    
      SOG =QJ                                                                  
      RETURN                                                                   
    4 CONTINUE                                                                 
      IF(AP.EQ.1.) QJ=45.*AT**.7                                               
      IF(ZF*AF.EQ.ZP*AP) RETURN                                                
      IF(ZF*AF.GT.8.) RETURN                                                   
      IF(ZF.GT.AF) RETURN                                                      
      IF(ZF*AF.EQ.4.) RETURN                                                   
      IMAX=AP-1                                                                
C                                                                              
      DO 10 IA=1,IMAX                                                          
      AAF=IA                                                                   
      CALL LIMIT(AAF,ZF,ITOP,IBOTTOM)                                          
C                                                                              
      DO 11 IZ=IBOTTOM,ITOP                                                    
      ZZF=IZ                                                                   
      CALL GEOFR(AP,ZP,AT,AAF,ZZF,ITOP,IBOTTOM,FNOR)                           
      CALL GEODA(AP,AT,AAF,SIGT,SOOG,ABR,ABL,SOOGP,ABRP,ABLP)                  
      SOG=SOG+SOOG*FNOR                                                        
      SOGP=SOGP+SOOGP*FNOR                                                     
      ZBR=ABR*ZP/AP                                                            
      ZBRP=ABRP*ZP/AP                                                          
      ZBL=ZP-ZZF-ZBR                                                           
      ZBLP=ZP-ZZF-ZBRP                                                         
      IAAL=ABL/4.                                                              
      IAALP=ABLP/4.                                                            
      IZAL=ZBL/2.                                                              
      IZALP=ZBLP/2.                                                            
      NAL=IAAL                                                                 
      NALP=IAALP                                                               
      IF(IAAL.GT.IZAL) NAL=IZAL                                                
      IF(IAALP.GT.IZALP) NALP=IZALP                                            
      AN=ABL-NAL*4.                                                            
      ANP=ABLP-NALP*4.                                                         
      ZN=ZBL-NAL*2.                                                            
      ZNP=ZBLP-NALP*2.                                                         
      IF(AF.EQ.4.)GO TO 12                                                     
      IF(AF.EQ.1.) GO TO 13                                                    
      GO TO 11                                                                 
   12 QJ=QJ+(NAL*SOOG*FNOR+NALP*SOOGP*FNOR)/2.                                 
      GO TO 11                                                                 
   13 CONTINUE                                                                 
      IF(ZF.EQ.1.) GO TO 14                                                    
      QJ=QJ+((AN-ZN+ABR-ZBR)*SOOG*FNOR+(ANP-ZNP+ABRP-ZBRP)*SOOGP*FNOR)/2       
      GO TO 11                                                                 
   14 QJ=QJ+((ZN+ZBR)*SOOG*FNOR+(ZNP+ZBRP)*SOOGP*FNOR)/2.                      
   11 CONTINUE                                                                 
C                                                                              
   10 CONTINUE                                                                 
C                                                                              
      RETURN                                                                   
      END SUBROUTINE YIELDH
C                                                                              
C*****************SUBROUTINE LIMIT(AF,ZF,ITOP,IBOTTOM)****************         
C                                                                              
C     USING RUDSTAM FORMULAS, FOR A GIVEN FRAGMENT MASS AF,                    
C     SUBROUTINE LIMIT CALCULATES LOWER AND UPPER BOUND OF                     
C     FRAGMENTATION ISOTOPES                                                   
C                                                                              
C                                                                              
      SUBROUTINE LIMIT(AF,ZF,ITOP,IBOTTOM)                                     
C                                                                              
      DATA S,T/.486,3.8E-4/                                                    
C                                                                              
      ITOP=IFIX(S*AF-T*AF**2)+2                                                
      IBOTTOM=IFIX(S*AF-T*AF**2)-2                                             
      IF(IBOTTOM.LT.1) IBOTTOM=1                                               
      RETURN                                                                   
      END SUBROUTINE LIMIT
C                                                                              
C***********SUBROUTINE GEOFR(AP,ZP,AT,AF,ZF,ITOP,IBOTTOM,FNOR)********         
C                                                                              
C   SUBROUTINE GEOFR CALCULATES FNOR (NORMALIZATION) FACTOR FOR                
C   RUDSTAM CHARGE DISTRIBUTION                                                
C                                                                              
       SUBROUTINE GEOFR(AP,ZP,AT,AF,ZF,ITOP,IBOTTOM,FNOR)                      
C                                                                              
       DATA D,S,T/.45,.486,3.8E-4/                                             
C                                                                              
       R=11.8*AF**(-D)                                                         
       F1=TEXP(-R*(ABS(ZF-S*AF+T*AF**2)**1.5))                                 
       FN=0.                                                                   
C                                                                              
       DO 10 I=IBOTTOM,ITOP                                                    
       FI=TEXP(-R*(ABS(I-S*AF+T*AF**2)**1.5))                                  
       FN=FN+FI                                                                
10     CONTINUE                                                                
C                                                                              
       FNOR=F1/FN                                                              
       IF(AF.LT.AP-1.) RETURN                                                  
       FNOR=0.                                                                 
       IF(ZF.EQ.ZP) FNOR=0.5                                                   
       IF(ZF.EQ.ZP-1.) FNOR=0.5                                                
       IF(AF.GE.AP) FNOR=0.                                                    
       IF(AF.EQ.8..AND.ZF.EQ.4.) FNOR=0.                                       
       IF(AF.EQ.5.) FNOR=0.                                                    
       IF(AF.EQ.9..AND.ZF.EQ.5.) FNOR=0.                                       
       RETURN                                                                  
       END SUBROUTINE GEOFR
C                                                                              
C*********************FUNCTION CROS(AT,Z,A,ENG)***********************         
C                                                                              
C     FUNCTION CROS IS RUDSTOM FIVE PARAMETER FORMULA DESCRIBING CROSS         
C     SEC. FOR PRODUCTION OF FRAGMENTS FROM PROTON NUCLEI BOMBARDED            
C     WITH HEAVY ION                                                           
C                                                                              
      FUNCTION CROS(AT,Z,A,ENG)                                                
C                                                                              
      REAL K,L                                                                 
C                                                                              
      DATA D,E,G,H,K,L/11.8,.45,.25,.0074,1.73,.0071/                          
C                                                                              
      V=3.8E-4                                                                 
      S=0.486                                                                  
      R=D*A**(-E)                                                              
      IF(ENG.LT.2100.) P=20.*(ENG**(-.77))                                     
      IF(ENG.GE.2100.) P=0.056                                                 
      IF(ENG.LT.240.) F2=TEXP(K-L*ENG)                                         
      IF(ENG.GE.240.) F2=1.                                                    
      X2=F2                                                                    
      F1=TEXP(-G+H*AT)                                                         
      X6=ABS(Z-S*A+V*A**2)                                                     
      X5=TEXP(P*A-R*(X6**1.5))                                                 
      X1=F1                                                                    
      X3=P*D**.66666*AT**(-2*E/3)                                              
      X4=1.79*(TEXP(P*AT)*(1.-2*E/(3*P*AT))-1+2*E/3+2*E/(3*P*AT))              
      CROS=X1*X2*X3*X5/X4                                                      
      RETURN                                                                   
      END FUNCTION CROS
C                                                                              
C***********************FUNCTION TEXP(X)******************************         
C                                                                              
      FUNCTION   TEXP(X)                                                       
      IF(X .LT.-100.)   X=-100.                                                
      IF(X .GT. 100.)   X=100.                                                 
      TEXP =EXP(X)                                                             
      END       FUNCTION   TEXP
      end module modNUCFRAG
