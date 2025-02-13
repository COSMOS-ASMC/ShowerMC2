!  next is to incldue MATHLOUSY 
#include "Zcondc.h"
!           test prog. is  in Epics/prog/Test/ (./testRange.sh)
!       memory allocation; to save it, use single precision
      module modepRange
      implicit none
#define USEREAL4
#if defined USEREAL4
      integer,parameter::prec=4
#else
      integer,parameter::prec=8
#endif
#if defined USEREAL4
#define kpolintpFE kpolintpSFE
#endif

!          usage:
!        When the nubmer of media is fixed,  
!       1) call  epRangeAlloc ( NoOfMedia )
!        Then, for each media 
!       2) call  epRangeMkTbl ( media, index)
!          At any time, the range in g/cm2 of a partcle can be obtained by
!       3) call epGetRang(idx, meida, Ptcl,  grmlen, cmlen)
!  epGetRange is intended to get range of a photon, electron, and  pi,mu,p
!  other heavy ion in a limited energy region where the particle is expected
!  to die soon. 
!  The range for mu,pi,K,p is calculated by assuming a scaling based on
!  proton.  R/M = Rp/Mp  
!  The range for heavy ion is calculated by assuming a scaling. 
!  The base is He (not proton).  As a result, at low enegies
!  where the range becomes order of 10 micron meter or less
!  the range is underestimated. In the actual simulation, this is
!  not a problem.  

!*****  Altough the variable name has log... 
!      log10 is not taken for speed up, (first prog. was to take log10) ***
!            
!                                          for gamma/elec
      real(8),parameter:: KE1 = 1.d-6   ! 1 keV  in GeV  
      real(8),parameter:: KE2 =1000.d-6 ! 1000 keV   energy range 
!                       for other; mu,pi,K,p, He, ...
      real(8),parameter:: gbeta1 =0.01d0 ! 
      real(8),parameter:: gbeta2 = 2.0d0 
      real(8),parameter:: dKE = 0.1d0     ! log10 step from Ex1 to Ex2        
#if defined (MATHLOUSY)

      real(8),parameter:: logKE1 = -6.d0 ! energy step is in log step
      real(8),parameter:: logKE2 = -3.d0
      integer,parameter:: nGBbin=
     *    (3.01029995663981195215d-1 - (-2) )/dKE+1

#else    

      real(8),parameter:: logKE1 = log10(KE1) ! energy step is in log step
      real(8),parameter:: logKE2 = log10(KE2)
      integer,parameter:: nGBbin= (log10(gbeta2)- log10(gbeta1) )/dKE+1

#endif

      integer,parameter:: nKEbin= ( logKE2- logKE1 )/dKE + 1
      real(prec),save:: logKEtbl(nKEbin)   ! log10(KE)
      real(prec),save:: logGBetatbl(nGBbin)  ! 
      real(prec),save,allocatable:: logGamLen(:,:)  !  gamma length(cm) (log is false)
                                                 ! for j-th media ... (:,j)
      real(prec),save,allocatable:: logEleLen(:,:) ! same for electron.
      real(prec),save,allocatable:: logChgLen(:,:)  ! same for mu,pi,p
      real(prec),save,allocatable:: logHILen(:,:)  ! same for He 
                                      !    For other charge use 
                                      !   dE/dx/Z^2 vs gbeta scaling      
                                      ! i.e. R/M = RHe/(Z/2)^2
      real(8),parameter::massElec = 0.511d-3    ! Me in Gev

!      real(8), parameter:: attenF = 3.0d0
      real(8), parameter:: attenF = 6.0d0
!      real(8), parameter:: elossF = 0.95d0
!      real(8), parameter:: dt=0.0025d0  !  step (g/cm2) to integrate 
                            !    dE/dx to get electron range
!      real(8), parameter:: dtc = 0.0025d0  !  step (g/cm2) to integrate heavy (p;mu,pi,)


      end module modepRange
!        don't use contains; 
      subroutine epRangeAlloc( nmedia )
!        allocate memory of nmedia-media's. 
      use modepRange
      implicit none
      
      integer,intent(in):: nmedia  ! in toal nmedia media exist
 
      if( .not.  allocated ( logGamLen ) )  then
         allocate(logGamLen(nKEbin,nmedia))
         allocate(logEleLen(nKEbin,nmedia))
         allocate(logChgLen(nGBbin,nmedia))
         allocate(logHILen(nGBbin,nmedia))
      endif
      end


      subroutine epRangeMkTbl(media, idx)
      use modepRange
      implicit none
#include "Zmedia.h"
#include "Zptcl.h"
       type(epmedia)::  media  ! input media
      integer,intent(in):: idx  ! media index 
      


      integer:: i, icon
      real(8):: E,  E5p, dedt, dedtfull, range
      real(8):: Esum, gbeta, ans, error, eps, ans2

      real(prec):: E4
      real(prec):: xsec(8)


      common /Zrange/ myPtcl, mymedia
       type(ptcl)::  myPtcl
       type(epmedia)::  mymedia
      external epRangeFunc
      real(8):: epRangeFunc
      
      mymedia = media
!/////////////
      mymedia%sh%tcut = 1.d10
      mymedia%sh%w0 = 1.d10
!//////////////////
      E = KE1
!           gamma 
      do i = 1, nKEbin
!         logKEtbl(i) = log10(E)
         logKEtbl(i) = E
         E4 = E
         call cGetXXsec(E4, media%xcom, media%xcom%size,
     *           7, 7, xsec, icon)
!            xsec(7) is total atten. coef. in cm2/g. 
         logGamLen(i, idx) =  xsec(7) 
         E = E * 10.d0**dKE
      enddo
!//////////
!      write(0,*) ' gamma table  created'
!/////////////



      eps = 1.d-7
!          electron range; use same logKEtbl
      call cmkptc(2, -1, -1, myPtcl)  ! electron
      E = KE1
      do i = 1, nKEbin
         Esum = E
!                      integrate from 0.3keV to Esum
         call kdexpIntF(epRangeFunc, 3.0d-7, Esum, eps,
     *        ans, error, icon)
!!!         if(icon /= 0 ) then
!!!            if( abs(ans) < 1.0 ) then
!!!               if(error > abs(ans)*0.03d0) then
!!!                  write(0,*) '***** warning'
!!!               endif
!!!            endif
!!!         endif

!            very small diff. by the next prog.
!         call  k16pGaussLeg(epRangeFunc, 3.d-7, Esum,10, ans2)
!         write(0,*) 'icon=',icon, ' ans =',ans,
!     *   ' ans2=', ans2, ' err=', error

         if(ans > 1.) then
            eps = 1.d-4
         endif
!!!!      very simple next method is too bad 
!!!!         E5p = Esum*(1.-elossF)  
!!!!         range = 0.
!!!            
!!!!         do while (Esum > E5p )
!!!!            myPtcl.fm.p(4) = E + masselec  ! only charge and Et are used below
!!!!            call epdedxe(media, myPtcl, dedt, dedtfull)
!!!!                                  ! they are GeV/(g/cm2)
!!!!            Esum =  Esum - dedtfull*dt
!!!!            range = range + dt
!!!!         enddo
!!!!!             correction + or -
!!!!         range = range + Esum/dedtfull
!!!!!//////////
!!!!         write(0,*) ' range =',range
!!!!!/////////////
         logEleLen(i, idx) =  ans
         E = E * 10.d0**dKE
      enddo
!//////////
!      write(0,*) ' electron table  created'
!/////////////

!           proton
      call cmkptc(6, -1, 1, myPtcl)  ! proton
      gbeta = gbeta1
      eps = 1.d-7

      do i = 1, nGBbin   
         logGBetatbl(i) = gbeta
         E = sqrt((myPtcl%mass*gbeta)**2 + myPtcl%mass**2) 
         Esum = E - myPtcl%mass
!/////////
         call kdexpIntF(epRangeFunc, 1d-6, Esum, eps,
     *        ans, error, icon)
!         if(icon /= 0 ) then
!            if( abs(ans) < 1.0 ) then
!               if(error > abs(ans)*0.03d0) then
!                  write(0,*) '***** warning2'
!               endif
!            endif
!         endif
!         call  k16pGaussLeg(epRangeFunc, 3.d-7, Esum,10, ans2)
!         write(0,*) 'icon=',icon, ' ans =',ans, ' ans2=', ans2,
!     *     ' gb=',gbeta, ' err=', error
!////////////////
         if(ans > 1.) then
            eps = 1.d-4
         endif
!!!         E5p = Esum*(1.-elossF)  ! 5 % 
!!!         range = 0.
!!!         do while (Esum > E5p )
!!!            myPtcl.fm.p(4) = E  
!!!            call epdedxNone(media, myPtcl, dedt, dedtfull)
!!!                                  ! they are GeV/(g/cm2)
!!!            Esum =  Esum - dedtfull*dtc
!!!            range = range + dtc
!!!         enddo
!!!!             correction + or -
!!!         range = range + Esum/dedtfull
!!!!         logChgLen(i, idx) =  range 

!//////////
!!         write(0,*) ' range =',range
!/////////////
         logChgLen(i, idx) =  ans/myPtcl%mass
         gbeta = gbeta * 10.d0**dKE
      enddo
!//////////
!      write(0,*) ' proton table  created'
!/////////////

!        He
      call cmkptc(9, 4, 2, myPtcl)  ! He
      gbeta = gbeta1
      eps = 1.d-7

      do i = 1, nGBbin   
         E = sqrt((myPtcl%mass*gbeta)**2 + myPtcl%mass**2) 
         Esum = E - myPtcl%mass
         call kdexpIntF(epRangeFunc, 1d-6, Esum, eps,
     *        ans, error, icon)
         if(ans > 1.) then
            eps = 1.d-4
         endif
         logHILen(i, idx) =  ans/myPtcl%mass
         gbeta = gbeta * 10.d0**dKE
      enddo
!//////////
!      write(0,*) ' He table  created'
!/////////////
      

      end
      function epRangeFunc(E)
      implicit none
#include "Zmedia.h"
#include "Zptcl.h"
#include "Zcode.h"

      common /Zrange/ myPtcl, mymedia
       type(ptcl)::  myPtcl
       type(epmedia)::  mymedia

      real(8):: epRangeFunc
      real(8),intent(in)::E !  kinetic energy GeV

      real(8):: dedtfull, dedt

      myPtcl%fm%p(4) = E  + myPtcl%mass
      if( myPtcl%code == kelec) then
         call epdedxe(mymedia, myPtcl, dedt, dedtfull)
      elseif( myPtcl%code == kgnuc ) then
         call epdedxhvy( mymedia, myPtcl, dedt, dedtfull)
      else
         call epdedxNone(mymedia, myPtcl, dedt, dedtfull)
      endif

      epRangeFunc = 1./dedtfull
      end


      subroutine epGetRange(idx, media, aPtcl,  grmlen, cmlen)
      use modepRange
      implicit none
#include "Zmedia.h"
#include "Zptcl.h"        
#include "Zcode.h"        
      integer,intent(in):: idx ! media index
       type(epmedia)::  media  ! input media corresponding to idx
       type(ptcl)::  aPtcl   ! input.  charged ptcl or photon

      real(8),intent(out):: grmlen  !  length in g/cm2  range of
                           ! this charged ptcl.
      real(8),intent(out):: cmlen   ! length in cm <-- grmlen

      real(prec):: error, grmlenS, gb
      real(prec):: Ek !  Ek (GeV) kinetic E/n.  

      real(8):: g




      if( aPtcl%code  == kelec ) then
         Ek = aPtcl%fm%p(4) - aPtcl%mass
!               electron
         if( Ek < KE1 ) then
            grmlen = logEleLen(1,idx) / 10.  ! normally absobed 
                                                ! instantly (< 1 keV). 
                     ! so assume very small range
         elseif(EK > KE2 ) then
            grmlen = logEleLen(nKEbin, idx) * 10.  ! normaally not
                                                 ! abosorbed. so assume large range
         else
!                     next call my be replaced by kpolintpSFE
!             see USEREAL4 at top
            call kpolintpFE(logKEtbl, 1, 
     *                      logEleLen(1,idx), 1, nKEbin,
     *             3,       Ek, grmlenS, error)
            grmlen = grmlenS
         endif

      elseif( aPtcl%code == kphoton ) then
         Ek = aPtcl%fm%p(4)
!           photon
         if( Ek < KE1 ) then
            grmlen = logGamLen(1,idx) * 10.  ! grmlen still 1/attenL so not "/10"
                                          ! factor 10 is to assure the instant absorption
         elseif(EK > KE2 ) then
            grmlen =logGamLen(nKEbin, idx) / 10.  ! normaally not abosorbed; make very long
                                                  ! so that tracking should continue 
         else
!                   to be judged by looking at path to the boundary and range
            call kpolintpFE(logKEtbl, 1, 
     *                      logGamLen(1,idx), 1, nKEbin,
     *             3,       Ek,  grmlenS, error)
            grmlen = grmlenS
         endif
 !              in the case of photon, only attenuation length is obtained
 !              so the range is stacastic. we take X so that  exp(-X/attenL) = 0.0024
 !              X/attenL= 6; i.e,  attenF=6 
         grmlen = attenF/ grmlen    ! AttenF x attenuation length  in g/cm2


      elseif( aPtcl%charge /= 0  .and. aPtcl%code /= kgnuc ) then
!      mu,pi,p
         g =  aPtcl%fm%p(4)/aPtcl%mass
         gb = sqrt(g**2 - 1.0d0)
         if( gb < gbeta1 ) then
            grmlen = logChgLen(1,idx) / 10.  ! normally absobed instantly
         elseif(gb > gbeta2 ) then
            grmlen = logChgLen(nGBbin, idx) * 10.  ! normaally not abosorbed
         else
            call kpolintpFE(logGBetatbl, 1, 
     *                      logChgLen(1,idx), 1, nGBbin,
     *             3,       gb, grmlenS, error)
            grmlen = grmlenS
         endif
         grmlen = grmlen/aPtcl%charge**2
         grmlen = grmlen * aPtcl%mass

      elseif( aPtcl%code == kgnuc ) then
!            heavy icon ; use scalig by using He
         g =  aPtcl%fm%p(4)/aPtcl%mass
         gb = sqrt(g**2 - 1.0d0)
         if( gb < gbeta1 ) then
            grmlen = logHILen(1,idx) / 10.  ! normally absobed instantly
         elseif(gb > gbeta2 ) then
            grmlen = logHILen(nGBbin, idx) * 10.  ! normaally not abosorbed
         else
            call kpolintpFE(logGBetatbl, 1, 
     *                      logHILen(1,idx), 1, nGBbin,
     *             3,       gb, grmlenS, error)
            grmlen = grmlenS
         endif
         grmlen = grmlen/(aPtcl%charge/2.0)**2
         grmlen = grmlen * aPtcl%mass
      else
         ! basically should not come here
         grmlen = 1000.
      endif
      cmlen = grmlen /(media%rho*media%rhoc)
      end


      subroutine epRange2E(idx, media, aPtcl,  cmlen, Ek)
!      get kinetic energy of a particle of which 
!      range (attenuation length) is a given input value. 
! ****  At presnet only for the photon. ****
      use modepRange
      implicit none
#include "Zmedia.h"
#include "Zptcl.h"        
#include "Zcode.h"        
      integer,intent(in):: idx ! media index
       type(epmedia)::  media  ! input media corresponding to idx
       type(ptcl)::  aPtcl   ! input.  charged ptcl or photon

      real(8),intent(in):: cmlen   ! range length in cm
      real(8),intent(out):: Ek   ! kinetic energy (GeV) of the
                         ! particle of which range is cmlen 

      real(prec):: error, grmlen, gb
      real(prec):: Ek4 !  Ek (GeV) kinetic E/n.  

      real(8):: g

      
      if( aPtcl%code == kphoton ) then
         grmlen = cmlen * media%rho*media%rhoc
!           photon
         if( grmlen < logGamLen(1,idx)  ) then
            Ek = KE1
         elseif(grmlen < logGamLen(nKEbin, idx) ) then
            call kpolintpFE( logGamLen(1,idx), 1, 
     *              logKEtbl, 1, nKEbin,
     *              3,  grmlen,  Ek4, error)
            Ek = Ek4
         else
            Ek = KE2
         endif
      else
         write(0,*)
     *         ' at present epRange2Ek is not usable for'
         write(0,*) ' particle code=',aPtcl%code
         stop
      endif
      end
