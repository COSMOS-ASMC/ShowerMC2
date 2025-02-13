c     cp  this as testXsec.f and make; ./test$(ARCH)
c
#include "BlockData/cblkGene.h"
#include "Zphitsblk.h"
c  #include "phitsdummy.h"
      program testxs
      implicit none
#include "ZcosmosExt.h"


      integer incp, ia, iz
      real(8):: pA, pZ, tA, tZ
      real(8)::EMeV, sigt, sigr, sigs, bmax, EMeVpn
      integer narg, ldat
      character(10)::in

      narg=iargc()
      if( narg /= 3  .and. narg /= 4 ) then
         write(0,*) "Enter proj(1->p or 2->n) and  and target (A,Z)"
         write(0,*) "or"
         write(0,*) "Enter projectile  A, Z  and target  A, Z"
         stop
      endif

      tA=0

      if( narg == 3 ) then
         call getarg(1, in, ldat)
         read(in,*) incp
         call getarg(2, in, ldat)
         read(in,*) ia
         call getarg(3, in, ldat)
         read(in,*) iz
         write(0,*) 'proj =', incp, ' target A,Z=', ia, iz
      else
         call getarg(1, in, ldat)
         read(in,*) pA
         call getarg(2, in, ldat)
         read(in,*) pZ
         call getarg(3, in, ldat)
         read(in,*) tA
         call getarg(4, in, ldat)
         read(in,*) tZ
         write(0,*) 'proj A,Z =', pA, pZ, ' target A,Z=',tA, tZ
         call confirmicrhi(1, 0)
      endif

c       call myPhitsDummy


      EMeV = 1.
      write(0,*) ' Ekt(MeV) Ek/n(MeV)  SigT  SigInela  SigEla  (mb)'
c      write(0,*) ' If SigEla< 0, no elastic scat '
      write(*,*) '# Ekt(MeV) Ek/n(MeV)  SigT  SigInela  SigEla  (mb)'
      do while (EMeV < 5.e9)
         if( tA == 0. ) then
            call sigrc( incp, EMeV, ia, iz, sigt, sigr, sigs)
            EMeVpn= EMeV
         else
            call sighi(pA,pZ,EMeV,tA, tZ, sigr,sigs,bmax)
c            call shen(pA,pZ,EMeV,tA, tZ, sigr,sigs,bmax)  ! same effect as above
            sigt = sigr + sigs
            EMeVpn = EMeV/pA
         endif
         write(*,'(1p, 5g12.3)') 
     *         EMeV, EMeVpn, sigt*1.e3, sigr*1.e3, sigs*1.e3
         EMeV = EMeV *10.**0.1
      enddo
      call confirmicrhi(0, 0)
      end program
      subroutine confirmicrhi(in, ii)
      real(8):: bplus
      common /crshi/  bplus, icrhi, ijudg, imadj, iqmax 
      if( in == 1 ) then
         icrhi = ii
      endif
      write(0,*) ' icrhi=',icrhi
      write(0,*) ' 0--> sighi; 1--> nasa'
      end
