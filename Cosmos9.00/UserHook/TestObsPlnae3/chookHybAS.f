c     ******************************************************************
c     *                                                                *
c     * chookHybAS. There are two routines here
c     *     chookHybAS: is the interface when a component A.S has been
c     *                made from an electron.  
c     *     chookHybAS2: is the interface which may be called at the 
c     *                 end of one event generation for air shower business.
c     *   Note: The former is called from the system.
c     *         The latter must be called in your chookEnEvent, if
c     *         necessary.  These are template rouitnes.  You must/may
c     *         modify them.  The latter may be included in your
c     *         chookEnEvent routine directly. The latter name 
c     *         can be another one.
c     *                                                        
c     ******************************************************************
c
c
c
      subroutine chookHybAS(el, never)
      implicit none

c      This routine is called at the end of the cobAS.f in Tracking/AS/,
c      that is, when a component A.S is made from an electron.  If the
c      user has nothing to do, give never=1,  then the
c      routine will not be called again.
c      If you have something to do (say, business for 
c      generating air fluorescence light), do it here.
c      Give never=0 in such a case.

#include "Ztrack.h"
#include "Zobs.h"
#include "Zobsv.h"
#include "Zelemagp.h"

      record /track/ el    ! input. an electron produced  component A.S
      integer never        ! input /output.  give 1 if you don't need
                           ! the routine else give 0.   

c     The following will be the typical stuff you may want to use in
c     this routine. (i=1, NoOfASSites; index for observation depths)
c
c   CompASNe(i):  component A.S size produced by the input electron.
c                 For depths where this value is 0, 
c                 avoid doing something here.  
c   CompASAge(i): age of component A.S produced by the input electron.
c                 If this value is 2.0, the A.S is assumed to be very
c                 old and the CompASNe(i) is 0.  You should skip
c                 treating deeper depths.
c

      real*8  zobas, zp
      real*8  elog, eno, age
      real*8  cvh2temp, tk  ! temperature in Kelvin
      real*8  dedx  ! to store <dE/dx> 
      real*8  cvh2den, rho  ! density of air in kg/m^3

      integer xsite
c
c     **********
      never = 1        ! change this to 0 if you need this routine
c     **********

      zp = el.pos.depth      ! starting vertical depth of
                             ! the component electron (kg/m^3)
c
c        get average dE/dx for every depth.
c


      do   xsite = 1, NoOfASSites
         age = CompASAge(xsite) 
         eno = CompASNe(xsite)


         if(age .eq. 2.) then
c            store 0 or ... in your own array 

            goto 100
         endif
         if(eno .gt. 0.) then
c      
c            you may do some business. Say  generate fluorescence light.
c            you may need some array to store the quantities
c            you compute here. (presumably in your own common block).
c        Following is typical quantities you may need for such a
c        computation
c             temerature in Kelvin of 'site'
            tk = cvh2temp(ASObsSites(xsite).pos.height)
c             density of air in kg/m^3;  multiply 10^-3 to get it in
c             g/cm^3.
            rho = cvh2den(ASObsSites(xsite).pos.height)  
            call cavedEdx(CompASNe(xsite), CompASAge(xsite), dedx)
c          ****** dedx >0 and in GeV/(kg/m^2). To convert it to
c          ****** MeV/(g/cm^2).  Multiply 100. 

c             vertical depth of site(  kg/m2)
            zobas=ASObsSites(xsite).pos.depth
            
c              log10 of elecrton energy  in terms of critical energy
            elog = log10(el.p.fm.p(4)/Ecrit) 
            
         endif
      enddo
  100 continue
      end
c
      subroutine chookHybAS2
      implicit none
c     
c           You may utilize this routine for computing, say,
c      air fluo. light.  for a given air shower.  This should
c      be called from chookEnEvent routine.
c
c
#include "Ztrack.h"
#include "Ztrackv.h"
#include "Zobs.h"
#include "Zobsp.h"
#include "Zobsv.h"



      real*8  eno, age,  zobas, nmu
      real*8  muonno(maxNoOfASSites)
      real*8  cvh2temp, tk  ! temperature in Kelvin
      real*8  dedx  ! to store <dE/dx> 
      real*8  eth
      real*8  cvh2den, rho  ! density in  kg/m^3.
c
      data eth/1.0/   ! dummy Emu threshold

      integer xsite
c
c      ******************** Below:  not usable for a while
c                                 (as of May/10,'97)
c                Nmu (E>Eth)
       call cgetNmu(eth, muonno)
c      ********************

      if(ObserveAS) then
c
         do   xsite = 1, NoOfASSites
            age = ASObsSites(xsite).esize
            eno =  ASObsSites(xsite).age
            nmu = muonno(xsite)
c             Ne or Nmu > 0
            if(eno .gt. 0. .or. nmu .gt. 0.)  then
c      
c            you may do some business. Say  generate fluorescence light.
c            you may need some array to store the quantities
c            you compute here. 
c        Following is typical quantities you may need for such a
c        computation
c             temerature in Kelvin of 'site'
               tk = cvh2temp(ASObsSites(xsite).pos.height)
c                 in kg/m^3; x 10^-3 in g/cm^3
               rho = cvh2den(ASObsSites(xsite).pos.height)

c                get average <dE/dx>at site            
               call cavedEdx(ASObsSites(xsite).esize, 
     *          ASObsSites(xsite).age,  dedx)
c      ******* dedx >0 and in GeV/(kg/m^2). To convert it to
c      ******* MeV/(g/cm^2).  Multiply 100. 

c             vertical depth of site(  kg/m2)
               zobas=ASObsSites(xsite).pos.depth
            endif
         enddo
      endif
      end









