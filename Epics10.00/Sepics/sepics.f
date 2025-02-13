!      ***************************************************************
!      *                                                             *
!      * Sepics: A  Standard program which uses EPICS
!      *                                                             *
!      ***************************************************************
!
       subroutine sepics(ngen)
       implicit none
#include  "ZepPos.h"
#include  "Zep3Vec.h"
#include  "Zswk.h"
       integer ngen  ! output. # of events generated in this run

       integer icon
       
       nevc = 0  ! for safety.  >=9.06
!             init sepics, epics
       call sopen

!             generate showers until required # or
!             time lack
!          *** until loop*** 
       do while (.true.)
          call s1set(icon)

          if         (icon .ne. 0)
     *                       goto 10
       enddo
 10    continue
!             end of all events or time lacks
       call epeaev
       call sclose(ngen)
       end
!      ****************
       subroutine sopen
       implicit none
!              read control parameters
#include  "ZsepManager.h"
#include  "ZepDirec.h"
#include  "ZepTrackp.h"
#include  "ZepPos.h"
#include  "Zep3Vec.h"
#include  "Zsparm.h"
#include  "Zswk.h"

        character*150 msg
        character*100 cosmosparam
        integer i, klena, n
!
        cosmosparam  = ' '
        read(*, *, end=100) EpicsFile, ConfigFile, SepicsFile, cont,
     *   cosmosparam

        call sparmr(SepicsFile)
!          check DCInp
        if(InputA .eq. 'fix') then
           if(abs( DCInp%x**2 + DCInp%y**2 + DCInp%z**2 - 1.d0)
     *        .gt. 1.d-3) then
              call cerrorMsg('sum of DCInp**2 is far from 1', 0)
           else
!              normalize so
              call epadjdir(DCInp)
           endif
        endif
!
!                   init epics
        if(cosmosparam .ne. ' ') then
           call epicosmos(cosmosparam)
        endif

        call epiaev(EpicsFile, ConfigFile)

        if(Trace .and. Nevent .gt. 20) then
           call cerrorMsg('********* Warning **********',1)
           call cerrorMsg(
     *     'Do you really want to take trace on so many events ?',
     *     1)
           call cerrorMsg(
     *     'If not, make "Trace f" in epicsfile', 1)
        endif
!              incident energy sampling. initializaiton 
!           check primary and outprimary
        if( trim(PrimaryFile) == trim(OutPrimaryFile) ) then
           if( Light == 21 ) then
              write(0, *)  ' PrimaryFile=OutPrimaryFile when'  
              write(0, *) ' Light=', Light
              stop
           endif
        endif
!           PrimaryFile may contain: e.g     ../Input/+primary 
!            or /-filename.   
        call epSeePMfile(PrimaryFile, Inp1ry)

        if(Inp1ry .eq. 0 ) then
           !  primary is ordinary one
           Inpxyz = 0
           Inpdir = 0
           Inperg  = 0
           Inptime = 0
           Inpdisk = 0
           Inpwgt = 0
           Inpwl = 0
           Inppol = 0
           Inpmass =0
           Inpcn = 0
           Inpuser = 0
!           InpLight = 0
           call ciniSPrim(PrimaryFile)
        else
           ! primary  is in +xxx or -xxx file
           call epLightIOreadIni
        endif

!            inquire form
        call epqfrm(formx)
        if(formx .eq. 'cyl') then
           call epqcyl(rcyl)
        elseif(formx .eq. 'pipe' ) then
           call epqpip(rpipi, rpipo)
        endif


        call epqcnf(orgw, abcw)

!        call epqworld(nwld, wstruct) 
!
        if(.not. cont) then
!               to keep first exEcution date: get date & time
!             call kqymd(pdatE0)
!             call kqhms(ptimE0)
        endif
!
!                initialize random no.
!cc          if(cont) then
!cc              call scontr(IoCont)
!cc         else
              if(Ir1(2) .ge. 0) then
                 call rnd1i(Ir1)
              else
                 call cmkSeed(0, Ir1)
                 call rnd1i(Ir1)
              endif
!cc          endif
          return
!         ---------------- Error -----------------
 100      continue
          write(msg, *) 'EpicsFile=',EpicsFile
          call cerrorMsg(msg, 1)
          write(msg, *) 'ConfigFile=', ConfigFile
          call cerrorMsg(msg, 1)
          write(msg, *) ' SepicsFile=',  SepicsFile
          call cerrorMsg(msg, 1)
          write(msg, *) ' cont info=', cont
          call cerrorMsg(msg, 1)
          write(msg,*) ' no control parameters'
          call cerrorMsg(msg, 0)
       end
      

       subroutine ssetip3( aTrack, icon)
       implicit none
#include  "ZsepManager.h"
#include  "ZepTrack.h"
#include  "Zsparm.h"
#include  "Zcode.h"
       type(epTrack)::  aTrack
       integer  icon  ! output. 0  -- go ahead.   1-- call  this again to set multiple 1ries
!                      -1--> EOF
       integer  nf, fc
       integer code, subcode, chg 
       real*8 erg, xin, yin, zin, wx, wy, wz, u, norm
       integer maxfn
       integer::totalcn
       parameter (maxfn = 15)
       character*20 field(maxfn)

 10    continue
       buf = ' '
       subcode = 0

      if(Inp1ry < 0 ) then
!     read(Ioprim,  end= 100 )  buf
         read(Ioprim,  end = 100)  code,
     *        subcode, chg, erg,  xin, yin, zin,
     *        wx, wy, wz, 
     *        aTrack%wl, aTrack%p%mass,  aTrack%cn
         if( code == -1000 ) then
                ! read dE of each comp.
            call epLightIOreaddE(totalcn,0)  ! 0 no need to alloc
            icon = 1
            return              !************************
         endif
         aTrack%p%code = code
      else
          read(Ioprim, '(a)', end= 100 )  buf
          call kgetField(buf, field, maxfn, nf)
          if(nf .eq. 0 )  then
             if( Inpmul .eq. 1) then
!                ! read dE   ; head trip ?? not needed
!                call epLightIOreaddE(totalcn, 0)
                icon = 1
                return          !****************
             else
!     neglect blank line          
                goto 10
             endif
          endif
          
          fc = 1
          read(field(fc), *) code
          if(Inpsubcode .eq. 1) then
             fc = fc + 1
             read(field(fc), *)  subcode
          endif
          fc = fc + 1
          read(field(fc), *)  chg
          if(Inperg .gt. 0) then
             fc = fc + 1 
             read(field(fc), *)   erg
          endif
          if( Inpxyz .gt. 0 ) then
             fc = fc + 1
             read( field(fc), *)   xin
             fc = fc + 1
             read( field(fc), *)   yin
             fc = fc + 1
             read( field(fc), *)   zin
          endif

          if( Inpdir .gt. 0 ) then
             fc = fc + 1
             read( field(fc), *)   wx
             fc = fc + 1
             read( field(fc), *)   wy
             fc = fc + 1
             read( field(fc), *)   wz
!              the acuracy of input data may not be enough
             norm = sqrt( wx**2 + wy**2 + wz**2 )
             wx = wx/norm
             wy = wy/norm
             wz = wz/norm
          endif

          if( Inpwgt  >  0 ) then
             fc = fc + 1          
             read( field(fc), *)  aTrack%wgt
          endif

          if( Inpwl  >  0 ) then
             fc = fc + 1          
             read( field(fc), *)  aTrack%wl
          endif
          
          if( Inppol  >  0 ) then
             fc = fc + 1          
             read( field(fc), *)  aTrack%pol
          endif
          
          if(Inpmass > 0 ) then
             fc = fc + 1
             read( field(fc), *)  aTrack%p%mass
          endif

          if( Inpcn  >  0 ) then
             fc = fc + 1          
             read( field(fc), *)  aTrack%cn
          endif

          if( Inptime .gt. 0 ) then
             fc = fc + 1
             read( field(fc), *)   aTrack%t 
             aTrack%t = aTrack%t*29.98d0 ! cm (t is nsec)
          endif

          if( Inpuser .gt. 0 ) then
             fc = fc + 1
             read( field(fc), *)   aTrack%user
          endif

!         check number of field; some redandant field may exist at the last part, so
!         nf many not be equal to fc. but must be nf >= fc
          if(nf .lt.  fc) then
             call cerrorMsg(
     *      'No. of fields in primary data is too few', 1)
             call cerrorMsg('data given is', 1)
             call cerrorMsg(buf, 1)
             stop 9999
          endif
       endif

       if(subcode .eq. 0 .and.  chg .eq. 0) then
          call rndc(u)
          if(code .eq. kkaon) then
             if(u .lt. 0.5) then
                subcode = k0l
             else
                subcode = k0s
             endif
          elseif(code .eq. knuc) then
             if(u .lt. 0.5) then
                subcode = antip
             else
                subcode = regptcl
             endif
          endif
       endif

       call cmkptc( code, subcode, chg, aTrack%p)

       if(Inpxyz .eq. 1) then
          aTrack%pos%x = xin
          aTrack%pos%y = yin
          aTrack%pos%z = zin
!            for safety
          PosInp%x = xin
          PosInp%y = yin
          PosInp%z = zin
       endif
       if(Inpdir .eq. 1) then
          aTrack%w%x = wx
          aTrack%w%y = wy
          aTrack%w%z = wz
!            for safety also set next
          DCInp%x = wx
          DCInp%y = wy
          DCInp%z = wz
       endif

       aTrack%p%fm%p(4)  =  erg
        ! >>>>>>>>>>>>>light
       if( code > 0 .or. code == kchgPath ) then
          if(Inperg .eq. 1) then
             aTrack%p%fm%p(4) =  aTrack%p%fm%p(4) + aTrack%p%mass
          endif
       endif
        !<<<<<<<<<<<<<<<<<<
       icon = 0
       return
 100   icon = -1
       end

      subroutine  s1set(icon)
      use modV1ry
      implicit none
#include  "ZsepManager.h"
#include  "ZepTrackp.h"
#include  "ZepTrackv.h"       
! #include  "ZepPos.h"
! #include  "ZepDirec.h"
! #include  "Zep3Vec.h"
#include  "Zsparm.h"
#include  "Zswk.h"
      integer icon
      character*80 msg

      integer jcon
      integer nev ! >=9.06

      call epqevn(nev)  ! >=9.06
!      if(nevc .ge. Nevent) then  ! <=9.05
      if(nev-1 .ge. Nevent) then  ! >=9.06
         icon=1
      else
!                 get random no. for this event
         call rnd1s(Ir1st)
         if(LogIr) then
!             record Seed in err out
            write(msg, *) Ir1st, nevc + 1
            call cerrorMsg(msg, 1)
         endif
!                 init 1 event. (clear arrays etc)
         call epi1ev(jcon)
!                    jcon=0-->user set the incident
!            else   set incident ptcl(s) by sepics
         if(jcon .ne. 0) then
            call ssetip(icon)
         else
            icon = 0       ! this is needed 2004. May 2
         endif
         if( .not. FreeC .and. icon == 0 ) then
            call epSetupV1ry(jcon) ! jcon not used at present.
         else
            V1ry = 0
         endif
         

         if(icon .eq. 0) then
!                  check time using stack area data
            call stimec(icon)
         endif
         if(icon .eq. 0) then
!              time and incident are available  for the generation
!              generate 1 event
            call epgen
!              end of 1 event
            call epe1ev
            call se1ev
         endif
      endif
      end
!     ****************
      subroutine se1ev
      implicit none
!             end of 1 event
#include  "ZepPos.h"
#include  "Zep3Vec.h"
#include  "Zswk.h"
          nevc=nevc+1
       end

!     ***************
       subroutine sqtevn(nev)
       implicit none
#include  "ZepPos.h"
#include  "Zep3Vec.h"
#include  "ZepDirec.h"
#include  "Zsparm.h"
#include  "Zswk.h"

      integer nev, icon

!           inquire total # of events created
          nev=nevc
          return
!      *****************
       entry sqcont(icon)
          if(cont) then
             icon=1
          else
             icon=0
          endif
       end

      subroutine  sqCompEvents(ntried, ngenerated)
      implicit none
      integer,intent(out):: ntried      ! # of events tried to be generated
      integer,intent(out):: ngenerated  ! # of events actually generated
                   ! they may be differ if the user discard some
                   ! events
      call sqtevn(ntried)
      call epqevn(ngenerated) 
      ngenerated = ngenerated -1  ! -1 is for completely generated ones.
      end


      subroutine ssetip( icon )
      implicit none
#include  "ZsepManager.h"
#include  "ZepTrackp.h"
      integer icon  !  output.  0
      integer eventn
      icon = 0
      
      if( Light == 22 ) then
            ! must read primary and 1st col info.
         call epLightIOread1stCol(eventn,icon)
         if(icon /= 0 ) return
      endif
      if( Inpmul .eq. 1) then
!            multiple particles are incident; icon = 1--> end of a bunch
         do while ( icon .eq. 0 )
            call ssetip2( icon )
         enddo
         if(icon .eq. 1) icon = 0
      else
         call ssetip2( icon )
      endif
      end

      subroutine ssetip2( icon )
      use modShiftInciPos, only: ShiftInciPos
      implicit none
#include  "Zcode.h"
#include  "ZsepManager.h"
#include  "ZepTrackp.h"
#include  "ZepTrack.h"
#include  "Zep3Vec.h"
#include  "Zswk.h"
#include  "Zsparm.h"
#include  "Zglobalc.h"
      
       type(epTrack)::  aTrack
       type(epTrack):: InciTrack, bTrack
      integer ns, i, j, icon
      logical ok
      real*8 sume, theta, phi, r
       type(epPos)::  org, rxyz
       type(epDirec)::  norm
      character*40 msg
      real(8):: wl0 
      real(8):: r2, r02, cb, dj

!             set incident ptcl
!               fix energy (momentum yet)
      if(Inp1ry .eq. 0 ) then
         call sfixe(aTrack)
         if( aTrack%p%code == klight ) then
            call epLightE2wl(aTrack%p%fm%p(4), 1.d0, wl0, wl0)
            aTrack%wl = wl0
         endif
         icon = 0
      else
         call ssetip3(aTrack, icon)

         if(icon .ne. 0) return ! ************ EOF or end of 1 bunch of incidents
      endif

!               fix position
      ok = .false.


!      do while (.not. ok)
         if(Inpxyz .eq. 0) then
            call sfixp(aTrack)
         endif
!               fix angle
         if(Inpdir .eq. 0) then
            call sfixa(aTrack)
         endif

         if(Inpxyz .eq. 0.) then
            if(InputP .eq. 'fix') then
               aTrack%pos=PosInp
               aTrack%w%x = DCInp%x
               aTrack%w%y = DCInp%y
               aTrack%w%z = DCInp%z
            elseif(InputP .eq. 'usph' .or.
     *             InputP .eq. 'g->sph' .or.
     *             InputP .eq. 'u->sph' ) then
!                normal vector is the particle position to the center
               call epqwcoord(org, rxyz)
               norm%x =-( aTrack%pos%x - org%x )
               norm%y =-( aTrack%pos%y - org%y )
               norm%z =-( aTrack%pos%z - org%z )
               call epadjdir(norm)
!                  convert direction cos to world coord.
               call ctransVectZ(norm, DCInp, aTrack%w)
            elseif(InputP(2:3) .eq. '+z') then
               aTrack%w%x = DCInp%x
               aTrack%w%y = DCInp%y
               aTrack%w%z = DCInp%z
            elseif(InputP(2:3) .eq. '-z') then
               aTrack%w%x = DCInp%x
               aTrack%w%y = DCInp%y
               aTrack%w%z = -DCInp%z
            elseif(InputP(2:3) .eq. '+y') then              
               aTrack%w%x = DCInp%x
               aTrack%w%y = DCInp%z
               aTrack%w%z = DCInp%y
            elseif(InputP(2:3) .eq. '-y') then              
               aTrack%w%x = DCInp%x
               aTrack%w%y = -DCInp%z
               aTrack%w%z = DCInp%y
            elseif(InputP(2:3) .eq. '+x') then              
               aTrack%w%x = DCInp%z
               aTrack%w%y = DCInp%x
               aTrack%w%z = DCInp%y
            elseif(InputP(2:3) .eq. '-x') then              
               aTrack%w%x = -DCInp%z
               aTrack%w%y = DCInp%x
               aTrack%w%z = DCInp%y
            elseif(InputP .eq. 'g->sph2'
     *        .or. InputP .eq. 'u->sph2' ) then
!
!              DCInp gives teta and phi .  opening angle is 90 deg
               call epqwcoord(org, rxyz)
                            ! rxyz.x= should be the radius of the sphere
               r = rxyz%x -EpsLeng
               theta = acos(-DCInp%z)*Todeg
               phi = atan2(-DCInp%y, -DCInp%x)*Todeg
               if(InputP .eq. 'g->sph2') then
                  call epgonSphere(1, Hwhm, r, 
     *              theta, phi, 90.0d0, aTrack%pos)
               else
                  call epgonSphere(1, -1.0d0, r, 
     *              theta, phi, 90.0d0, aTrack%pos)
               endif
               aTrack%pos%x = aTrack%pos%x + org%x
               aTrack%pos%y = aTrack%pos%y + org%y
               aTrack%pos%z = aTrack%pos%z + org%z
               aTrack%w = DCInp
            else
               write(msg,*)' InputP=',InputP, ' and ',
     *             InputA,' incompatible'
               call cerrorMsg(msg, 0)
            endif
         endif
!      enddo
!               fix others

      call sfixo(aTrack)

!               set them
!      if(Inpdisk .eq. 0) then
       !>>>>>>>>>>>>>light
      if( Inpcn > 0 ) then
         ! if Cn is given, the coordinate is assumed to be local
! so that eppush is ok
         call eppush(aTrack)
      else
         if( ShiftInciPos /= " " ) then
            call epshiftInciPos(aTrack%pos)
         endif
         call epputTrack(aTrack)
      endif
       !<<<<<<<<<<<<<<
!      else
!         call epputTrk2(Inpdisk, aTrack)   ! not used now v9.00
!      endif
      InciTrack = aTrack
      return
!      *****************
       entry stimec(icon)
!      *****************
!         icon=0---> time available;  currently no check
           icon = 0
       return
!      ***************
       entry epqInci(bTrack)
       bTrack = InciTrack
       end
       subroutine sclose(nev)
       implicit none
#include  "ZepManager.h"
#include  "ZsepManager.h"
#include  "ZepPos.h"
#include  "ZepDirec.h"
#include  "Zep3Vec.h"
#include  "Zsparm.h"
#include  "Zswk.h"

      integer nev
      character*150 msg

!               end of all events
!c          call scontw(IoCont)
!c          call timepc(6)
!              inquire # of events created in this run
          call epqevn(nev)  
!              print message
!             get  current random no.
          call rnd1s(Ir1)
          write(msg,*) ' # created in this run=',nev-1,
     *     ' current total #=',nevc,
     *     ' destination #=',Nevent,
     *     ' next ir=', Ir1
          if(MsgLevel -1 .ge. 0) then
             call cerrorMsg(msg, 1)
          endif
          call epcloseStackDisk  ! delete stack disk if used
       end
      subroutine sfixe(aTrack)
       implicit none
#include  "ZsepManager.h"

#include  "ZepTrack.h"
#include  "ZepTrackp.h"
#include  "Zep3Vec.h"
#include  "Zcnfig.h"
#include  "Zswk.h"
#include  "Zsparm.h"
#if defined NEXT486
#define IMAG_P dimag
#elif defined PCLinux 
#define IMAG_P dimag
#else
#define IMAG_P imag
#endif


       type(epTrack)::  aTrack
       real*8 u, r,   dx, dy, cs, sn
       real*8 st, pw
       type(epPos)::  org, rxyz
       logical ok
       character*70 msg
!cc       real*8 fai


!           sample incident particle
       
       call epsampPtcl(aTrack%p)
       return
!      *******************
       entry sfixp(aTrack)
!      *******************
!          sample incident x,y,z position;  world coord.
       if(InputP .eq. 'fix') then
#if defined IBMAIX
          call epsubpos(PosInp, aTrack%pos)
#else
          aTrack%pos = PosInp
#endif
       elseif( (InputP(1:2) .eq. 'u-' .and. InputP(1:3) .ne. 'u->')
     *       .or.   InputP(1:2) .eq. 'u+' ) then
!            uniform in Xrange, Yrange,  Zrange        
          call rndc(u)
          aTrack%pos%x
     *        = ( IMAG_P(Xrange) - real(Xrange) )* u
     *          + real(Xrange)
          call rndc(u)          
          aTrack%pos%y
     *        = ( IMAG_P(Yrange) - real(Yrange) )* u
     *          + real(Yrange)
          call rndc(u)           
          aTrack%pos%z
     *        = ( IMAG_P(Zrange) - real(Zrange) )* u
     *          + real(Zrange)

       elseif(InputP .eq. 'usph') then
          call epqwcoord(org, rxyz)
                         ! rxyz.x= should be the radius of the sphere
          r = rxyz%x -EpsLeng
!                                  teta       phi      o.a
          call epuonSphere(1, r, PosInp%x, PosInp%y, PosInp%z,
     *       aTrack%pos)
          aTrack%pos%x = aTrack%pos%x + org%x
          aTrack%pos%y = aTrack%pos%y + org%y
          aTrack%pos%z = aTrack%pos%z + org%z
!            angle is later fixed.
       elseif(InputP .eq. 'g->sph') then
!
!           PosInp.x = teta, PosInp.y = phi, PosInp.z = opening angl
!           Instead of ProfR,  R * sin(O.A) is used.
!     
          if(PosInp%z .gt. 90.) then
             call cerrorMsg("Zinp > 90 for InputP=g->sph", 0)
          endif
          call epqwcoord(org, rxyz)
                            ! rxyz.x= should be the radius of the sphere
          r = rxyz%x -EpsLeng

          call epgonSphere(1, Hwhm, r, PosInp%x, PosInp%y, PosInp%z,
     *       aTrack%pos)

          aTrack%pos%x = aTrack%pos%x + org%x
          aTrack%pos%y = aTrack%pos%y + org%y
          aTrack%pos%z = aTrack%pos%z + org%z
!            angle is later fixed.
       elseif(InputP .eq. 'g->sph2') then
!               this case you  InpDir!=0 or DCInp must be given
!               wait until angle is given                   
       elseif(InputP .eq. 'u->sph') then
          if(PosInp%z .gt. 90.) then
             call cerrorMsg("Zinp > 90 for InputP=u->sph", 0)
          endif
          call epqwcoord(org, rxyz)
                            ! rxyz.x= should be the radius of the sphere
          r = rxyz%x -EpsLeng
!            For  negative HWHM, uniform distribution is employed
          call epgonSphere(1, -1.0d0, r, PosInp%x, PosInp%y, PosInp%z,
     *       aTrack%pos)
          aTrack%pos%x = aTrack%pos%x + org%x
          aTrack%pos%y = aTrack%pos%y + org%y
          aTrack%pos%z = aTrack%pos%z + org%z
!            angle is later fixed.
!  
       elseif( InputP .eq. 'u->sph2') then
!               this case  InpDir!=0 or DCInp must be given
!               wait until angle is given                   
!  
       elseif(InputP(1:1) .eq. 'g') then
!                  gaussian density beam
          call epGaussb(Hwhm, ProfR, dx, dy)
          if(InputP(3:3) .eq.  'z') then
!                 around Xinp, Yinp
             aTrack%pos%x = PosInp%x + dx
             aTrack%pos%y = PosInp%y + dy
             aTrack%pos%z = PosInp%z
          elseif(InputP(3:3) .eq. 'y') then
             aTrack%pos%x = PosInp%x + dx
             aTrack%pos%y = PosInp%y
             aTrack%pos%z = PosInp%z + dy
          elseif(InputP(3:3) .eq. 'x') then
             aTrack%pos%x = PosInp%x
             aTrack%pos%y = PosInp%y + dx
             aTrack%pos%z = PosInp%z + dy
          else
             write(msg,*) ' InputP=',InputP, ' invalid'
             call cerrorMsg(msg,  1)
             call cerrorMsg("see sepicsfile in FirstKiss",0)
          endif
       else
          write(msg,*) ' InputP=',InputP, ' invalid'
          call cerrorMsg(msg,  1)
          call cerrorMsg("see sepicsfile in FirstKiss",0)
       endif
       return
!       ****************************************
        entry sfixa(aTrack)
!          DCInp is fixed. aTrack.w is not yet  given
        if(InputA .eq. 'fix' ) then
!          nothing to do; DCInp is used.
        else
           if(InputA .eq. 'is') then
              call rndc(u)
              DCInp%z= ( IMAG_P(CosNormal) - real(CosNormal) )* u
     *          + real(CosNormal)
           elseif(InputA(1:3) .eq. 'cos') then
              read(InputA(4:12), *) pw
              call rndc(u)
              if(pw .ne. -1.d0) then
                 DCInp%z=
     *             ( (IMAG_P(CosNormal)**(pw+1.d0) - 
     *             real(CosNormal)**(pw+1.d0))* u
     *             + real(CosNormal)**(pw+1.d0))**(1.d0/(pw+1.d0))
              else
                 DCInp%z =(IMAG_P(CosNormal)/real(CosNormal))**u *
     *             real(CosNormal)
              endif
           else
              write(msg,*) ' InputA=',InputA, ' not supported'
              call cerrorMsg(msg, 0)
           endif
!
!cc           call rndc(fai)
!           fai= (fai+1.)*3.14159265 
!           cs = cos(fai)
!cc           sn = sin(fai)
!
           call kcossn(cs,sn)
           st= sqrt( 1.d0 - DCInp%z**2)
           DCInp%x = st * cs
           DCInp%y = st * sn
        endif
        return
!        ***************************
        entry sfixo(aTrack)
!              fix time of incidence
        if( Inptime .eq. 0 ) then
           aTrack%t = 0.d0
        endif
!           fix momentum 
        call epe2p(aTrack)  ! direction & e--> px,py,pz
       end
!           for ibm
       subroutine epsubpos(inp, out)
       implicit none
#include "ZepPos.h"
       type(epPos)::  inp, out
       out =inp
       end
      
!      *********************
       subroutine scontw(io)
       implicit none
#include  "ZsepManager.h"
#include  "ZepPos.h"
#include  "ZepDirec.h"
#include  "Zep3Vec.h"
#include  "Zsparm.h"
#include  "Zswk.h"
      integer io

      character*2 qmk1/" '"/, qmk2/"',"/

!
               write(io, *) nevc, Ir1st,
     *         qmk1,pdatE0,qmk2, qmk1, ptimE0,qmk2
               call sparmw(io)
               return
!
!      ******************
       entry scontr(io)
               read(io, *, end=100) nevc, Ir1, pdatE0,
     *               ptimE0
               call rnd1r(Ir1)
               rewind io
               return
  100      continue
           stop 'no cont information'
       end
