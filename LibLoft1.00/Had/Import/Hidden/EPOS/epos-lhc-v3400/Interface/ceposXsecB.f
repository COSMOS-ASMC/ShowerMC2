!      implicit none
!        get x-section by calling ainit via standard way
!     
#include "Zptcl.h"
      include "../epos.inc"

      type(ptcl):: pj !  (hadronic) projectile ptcl (not gamma)
      type(ptcl):: tg !  target nucleus (including p/n)

      real(8):: xs
      integer,parameter::nmax=2000
      type(ptcl):: a(nmax)
      integer:: n, i
      integer:: initrn(2)=(/12345,-54321/)
!               first one is almost dummy
      call cmkSeed( initrn(1), initrn)
      call rnd1i(initrn)

      call ceposIniAll    ! once for all init

      call cmkptc(6,-1,1,pj)
      pj%fm%p(4) = 1000.
      call cmkptc(6,-1,1,tg)
      tg%fm%p(4) = tg%mass
      tg%fm%p(1:3) = 0.

      write(0,*) ' Enter projectile code, subcode, charge'
      read(*,*)  pj%code, pj%subcode, pj%charge
      write(0,*) 'your input: ',  pj%code, pj%subcode, pj%charge
      write(0,*) ' Enter target code, subcode, charge'
      read(*,*)  tg%code, tg%subcode, tg%charge
      write(0,*) 'your input: ',  tg%code, tg%subcode, tg%charge
      write(0,*) ' Enter projectile total energy in GeV'
      read(*,*) pj%fm%p(4)
      write(0,*) 'Your input:  ', pj%fm%p(4)
      pj%fm%p(1:2)=0.
      pj%fm%p(3) = sqrt(pj%fm%p(4)**2-pj%mass**2)
      if( pj%subcode > 64 .or. tg%subcode > 64 ) then
         isigma = 2   ! calculate AA x-sec. by some pseudo sim.
      else
         isigma = 0   ! no calc.  needed
      endif
      ionudi = 1    !  target side diff. negelcted  For AA consistent with x-section
                    !  ionudi=0: 

      call ceposIniOneEvent(pj, tg, xs)      
      write(0,*) ' xs =', xs
      call ceposGenOneEvent(a, n)
      if( n > nmax ) then
         write(0,*) ' n=', n, ' too big # of ptlcs'
         stop
      endif
      do i = 1, n
         write(0,*) a(i)%code, a(i)%charge, a(i)%fm%p(4)
      enddo

      end

