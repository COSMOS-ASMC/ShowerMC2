      subroutine ctrackingAll
      use modEMcontrol
!     **************************************************
!       tracking particles given in the stack area.
!       During tracking, new particles may be produced
!       and pushed in the stack area.  They are all
!       treated here, until all particles are processed.
!     **************************************************
      implicit none
#include  "Zcode.h"
#include  "Ztrack.h"
! #include  "Zmagfield.h"
#include  "Ztrackv.h"
#include  "Ztrackp.h"
#include "Zincidentv.h"
#include "ZmediaLoft.h"
      
      integer moreptcl, jold, icon
      real*8 smallAS/1./   ! electrons < 1GeV cannot make AS at all.
!c      real*8 u, iwgt	
      real*8 cosfromaxis
      external cblkTracking
!//////
      logical show
      common /showshow/ show
!////////////
!
      integer:: node
      real(8):: rho
      real(8),external:: cvh2den
      
!      ***  do until no more ptcl in stack
      do while (.true.)
!           get one particle from stack
         call cpop(TrackBefMove, moreptcl)
         
!     track is not yet moved but make a copy for safety (without this
!     problem after path truncation could happen.
         
         MovedTrack = TrackBefMove
!     rhoc is put here for safety here--> rhoc should  not be modified;.
!     it is used as if   media%rho* media%rhoc wwre rho originally given.
!     (moved from ccompPathEnd). Instead, rrho in modEMcontrol
!     is used  
!
         if(moreptcl .eq. 0) goto 100 !  exit         
!
         rho = cvh2den(TrackBefMove%pos%height) * 1.0d-3 ! g/cm3
!!     !         rrho = rho/(Media(MediaNo)%rhoc *
!!     now we change rhoc during exectution (in Cosmos)
         Media(MediaNo)%rhoc =  rho/Media(MediaNo)%rho
         rrho =  Media(MediaNo)%rhoc  
!     rrho may be used to get rho inside a decsendent of epdeedxe
!     for the dencity effect in dE/dx or possibly in other places
!
         

         call rndsw(jold, 1)    !  specify 1st generator.

         if( NoOfMedia > 1 ) then
!              update current Media No.
            call cvh2mediaNo(TrackBefMove%pos%height, MediaNo)
         endif
         
         call cifDead(TrackBefMove, icon)  ! generator may be switched to 2
            
!                     icon=0; alive, 1 E<Emin, 2 long flight 3 h>H 4 h<L
!                             5 angle>limit
!          Hybrind  AS generation. 
         if(ObserveAS .and. icon .le. 1 ) then
            if(TrackBefMove%p%code .eq. kelec) then
               if(TrackBefMove%asflag .eq. 0) then
                  if(TrackBefMove%p%fm%p(4) .le. EasWait) then
                     if(TrackBefMove%p%fm%p(4) .gt. smallAS) then ! 95/08/17
                        call cscalerProd(TrackBefMove%vec%w,
     *                       DcAtObsXyz, cosfromaxis)
                        if(cosfromaxis .gt. 0.5 ) then
!     as gneration for e with 60 deg or less from axis
                           call cobAS(TrackBefMove)
                        endif
                     endif
                     TrackBefMove%asflag =1
                  endif
               endif
            elseif(TrackBefMove%p%code .eq. kphoton) then
               if(icon .eq. 1) then
                  if(TrackBefMove%asflag .eq. 0) then
                     if(TrackBefMove%p%fm%p(4) .gt. smallAS) then
                        icon = 0 ! follow until it becomes e-pair
                     endif
                  endif
               endif
            endif
         endif
!        ----------------------------
         if(icon .eq. 0) then
!              see if heavy and ssp is needed; icon =1 --> SSP so skip tracking here
            call cforceSSP(TrackBefMove, icon)
            if(icon .eq. 0) then
               call cTracking
            endif
         else
!             already dead ptcl has been considered in cifDead; nothing todo
         endif
      enddo
 100  continue
      end
! -------------------------------------tracking a ptcl
      subroutine cTracking
      use modColInfo
      use modEMcontrol
      use modSetIntInf
      implicit none

#include  "Ztrack.h"
! #include  "Zmagfield.h"      
#include  "Ztrackv.h"
#include  "Ztrackp.h"
#include  "Zobs.h"
#include  "Zobsp.h"
#include  "Zobsv.h"
#include  "Zincidentv.h"
#include  "Zcode.h"
#include  "Zmanagerp.h"
#include  "Zstackv.h"
#include  "Zevhnv.h"
!                next is for DEBUG
!//////
      logical show
      common /showshow/ show
!/////////
#define DEBUG 0


      logical reset
      real*8 cosangle
      character*70 msg
      integer nextwhere, never, ptclidx
!c      integer icon

#if DEBUG == 1
      deb=.true.
      call checkstat('before fixModel')
#endif

      call cfixModel( TrackBefMove%p )      ! fix interaction model.
      call cfixMag            !   Mag field
!           sample interaction length.  The path may
!           be truncated to a shorter one than really sampled.
!           In that case, MoveStat == Truncated.
#if DEBUG == 1
      call checkstat('before csampIntl')
#endif
      call csampIntL
#if DEBUG == 1
      call checkstat('after csampIntl')
#endif
!           Truncate the path if it is too long. Note, the truncated
!           path in the above process may be again truncated to
!           a shorter one. This happens, for example, if ptcl energy
!     is low.  Path inf is reset in IntInfArray.

      call ctruncPath

#if DEBUG == 1
      call checkstat('after ctruncPath')
#endif

!           compute path end inf. including scattering and
!           mag. deflection.  Path end inf is set in MovedTrack
      call ccompPathEnd

#if DEBUG == 1
      call checkstat('after ccompPathEnd')
#endif
!           see if MovedTrack crosses an observation site.
!         (or reaches BorderHeightL)  If so, reset MovedTrack. 
      call cifXObsSite(nextwhere)
!     if(TrackBefMove%p%charge .ne. 0 .and. Eabsorb(1) .ne. 0) then
      if(TrackBefMove%p%charge .ne. 0 .and. Eabsorb /= 0) then      
!               4th arg. not used now
         call chookEabsorb(TrackBefMove, MovedTrack, EnergyLoss, 0)
      endif
#if DEBUG == 1
      call checkstat('after cifXObsSite')
#endif
      if(Trace .ne. 0) then
         if( mod(Trace, 10) .le. 2) then
            call cputTrInfo     ! put trace info.
         elseif(mod(Trace,10) .le. 4) then
            if( TrackBefMove%pos%height .le. HeightList(1)) then
               call cputTrInfo  ! put trace info.
            endif
         endif
      endif
#if DETAILED_TRACKING >= 3
!            the user may kill the ptcl
      call cobservation(8)
#endif
!     
      if(MoveStat .eq. Truncated) then
!        &&&&&&&&&&&&&& some may lose energy by dE/dx etc. 
!                       This should be recorded
         if(Job .eq. 'newskel' .and. 
     *        (MovedTrack%p%fm%p(4) - MovedTrack%p%mass) .lt. 
     *        KEminObs(1))  then
            never = -1
            call chookEInt(never) !???
         endif
!        &&&&&&&&&&&&
!              stack current ptcl
         call cpush(MovedTrack)
      elseif(MoveStat .eq. ToInteract ) then
         if(Zfirst%pos%depth .eq. 0.) then
!            if(  (MovedTrack.p.code .ge. kpion  .and. 
!     *            MovedTrack.p.code .le. knuc ) .or.
!     *         MovedTrack.p.code .eq. kgnuc ) then
!            from  v.7.10
            if(  (IncidentCopy%p%code .ge. kpion  .and. 
     *            IncidentCopy%p%code .le. knuc ) .or.
     *            IncidentCopy%p%code .eq. kgnuc ) then

!
!                   from  v6.31 1ry is judged by Stack_pos
!                  (even if this is not used, almost no problem)
!                     ! if no stack, the particle should be 1ry (since Zfirst=0)

               if( Stack_pos .eq. 0 .and.
     *             IntInfArray(ProcessNo)%process .eq. 'coll') then
                  reset = .true.
               else
                  reset = .false.
               endif
            else
               reset = .true.
            endif
            if(reset) then
!             reset minimum time to reach the obs level (time from this
!             hight to the obs. level), if no mag. exists until
!                  the first collision point. or ptcl goes streight
!                  comment out from v6.31
!               call cresetTimer(MovedTrack)

               Zfirst = MovedTrack
               FirstColA = TargetNucleonNo
               FirstColZ = TargetProtonNo
               FirstColXs = TargetXs
            endif
         endif
#if DETAILED_TRACKING >= 1 
         call cobservation(4)
#endif

#if DEBUG == 1
         call checkstat('before cinteraction')
#endif
         call cinteraction
      elseif(MoveStat .eq. ToBeObserved ) then
         ptclidx = MovedTrack%p%code  ! make 4 byte integer
         ptclidx = min(ptclidx, 8)   ! this is only for using KEminObs
         if(MovedTrack%p%fm%p(4)-MovedTrack%p%mass 
     *        .ge. KEminObs(ptclidx) ) then    ! .gt. for <= uv6.00
!             call only for high energy particles
!                  (at AS generation, some ptcl may have < KEminObs
!                  or some may loose energy by dE/dx etc.
            call cobservation(2)

            if(Job .eq. 'newskel' .and.
     *          EndLevel .lt. NoOfSites .and. 
     *          MovedTrack%where .eq. EndLevel ) then
!                in this case, even E> KEminObs must be recorded
!                 for skeleton making for kahanshin
!                  where should be +1 at flesh time

               MovedTrack%where = MovedTrack%where + 1
               never = -3
               call chookEInt(never)
               MovedTrack%where = MovedTrack%where - 1 ! for safty
            endif
         elseif(Job .eq. 'newskel'  .and. 
     *          EndLevel .eq. NoOfSites .and.
     *          MovedTrack%where .lt. EndLevel )  then
!            &&&&&&  this is to be recorded
!                where should be + 1 at flesh time
            MovedTrack%where = MovedTrack%where + 1
            never = -2
            call chookEInt(never)
            MovedTrack%where = MovedTrack%where - 1
!            &&&&& 
         endif
!               update observation place
!         if(abs(ObsPlane) .eq. perpendicular) then
         MovedTrack%where = nextwhere
!                  if more obs-site, stack current ptcl.
         if(.not. Upgoing) then ! incident is downgoing
            if(MovedTrack%where .gt. EndLevel) then
                                ! no need to stack; discard ptcl.
            else
               MovedTrack%where =max( MovedTrack%where*1, 1)
               call cpush(MovedTrack)
            endif
         else                   !incident is  Upgoing
            if(MovedTrack%where .lt.1 ) then
                                ! no need to stack
            else
               MovedTrack%where =
     *              min(MovedTrack%where*1, EndLevel)
               call cpush(MovedTrack)
            endif
         endif
!        else
!            MovedTrack.where = nextwhere
!            call cpush(MovedTrack)
!         endif
      elseif(MoveStat .eq. BorderL) then
         call cobservation(3)
         call cpush(MovedTrack)
      elseif(MoveStat .eq. BorderH) then
         call cobservation(1)
         call cpush(MovedTrack)
      else
         write(msg, *) ' movestat=',MoveStat,' invalid'
         call cerrorMsg(msg, 0)
      endif   
      end
!          obso; see calling place      
!      subroutine cresetTimer(aTrack)
!      implicit none
!#include  "Ztrack.h"
!! #include  "Zmagfield.h"      
!#include  "Ztrackv.h"
!#include  "Ztrackp.h"
!#include  "Zobs.h"
!#include  "Zobsp.h"
!#include  "Zobsv.h"
!#include  "Zincidentv.h"
!#include  "Zcode.h"
!#include  "Zmanagerp.h"
!      type(track)::aTrack
!!             reset minimum time to reach the obs level (time from this
!!             hight to the obs. level), if no mag. exists until
!!                  the first collision point. or ptcl goes streight
!      if(mod(HowGeomag, 2) .eq. 1 .or. 
!     *     IncidentCopy%p%charge .eq. 0 .and.
!     *     ObsPlane .ne. 3) then
!         call csetMinTime(aTrack)
!      else
!!         MovedTrack.t = 0.     ! bug bef uv6.09 ;;; but why commentout ??? 
!      endif
!      end
!!           if you activate the next routine, Epics will have link problem!!!
!ccc   #if DEBUG > 0
      subroutine checkstat(str)
      use modSetIntInf
      implicit none
#include  "Ztrack.h"
! #include  "Zmagfield.h"      
#include  "Ztrackv.h"
#include  "Ztrackp.h"
#include  "Zobs.h"
#include  "Zobsv.h"
#include  "Zevhnv.h"

      logical deb
      common /cdebug/deb

      character*(*) str
      integer i
      integer nc
      data nc/0/

      nc = nc + 1
!      if(nc .gt. 750) then
!      if( deb) then
            write(0,*) ' ActiveModel=',ActiveMdl
            write(0,*) str, ' code=',TrackBefMove%p%code,
     *         ' sub',TrackBefMove%p%subcode,
     *         ' chg',TrackBefMove%p%charge
            write(0,*) 'Px,y,z e=', TrackBefMove%p%fm%p(1:4)
            write(0,*)  'Move stat=',MoveStat
            write(0, *) ' where', TrackBefMove%where
            write(0,*)  ' h==', TrackBefMove%pos%height,
     *       ' d=', TrackBefMove%pos%depth
            write(0,*) ' cos=',TrackBefMove%vec%coszenith
            do i = 1, NumberOfInte
               write(0, *) ' process=',IntInfArray(i)%process
               write(0, *) ' thickness=',IntInfArray(i)%thickness
               write(0, *) ' length=',IntInfArray(i)%length
            enddo
            write(0,*)'  ProcessNo=', ProcessNo
            write(0,*)  '--------------'
!         endif
!         endif
      end
!cccc  #endif
!-------------------------------------------------------
      subroutine cfixMag
      implicit none
#include "Ztrack.h"
! #include "Zmagfield.h"
#include "Ztrackv.h"
#include "Ztrackp.h"
#include "Zobs.h"
#include "Zobsp.h"
#include "Zobsv.h"

      real*8 x/0./, y/0./, z/0./
      save x, y, z
      real*8 distant
      integer icon
      real*8 u

      if(HowGeomag .le. 2 .or. HowGeomag .eq. 31) then
!             distant; change of B is < 1 % (for default
!             MagChgDist =20 km; you can change it)
         call clengSmallBC(TrackBefMove, distant)

         if( (TrackBefMove%pos%xyz%r(1) - x)**2 + 
     *        (TrackBefMove%pos%xyz%r(2) - y)**2 + 
     *        (TrackBefMove%pos%xyz%r(3) - z)**2 
     *        .gt. distant**2) then
!              if more than MagChgDist m from previous mag set.,
!               reset mag field.
!
            call cgetMagF(YearOfGeomag,  TrackBefMove%pos%xyz, 
     *                Mag, icon)

            call ctransMagTo('xyz', TrackBefMove%pos%xyz, 
     *        Mag, Mag)
            x = TrackBefMove%pos%xyz%r(1)
            y = TrackBefMove%pos%xyz%r(2)
            z = TrackBefMove%pos%xyz%r(3)

         endif
      else
         Mag = MagfieldXYZ
      endif
      end

!     --------------------------------------------------
      subroutine csampIntL
      use modSetIntInf
      use modColInfo
!!      use modXsecMedia
!     **************************************************
!          
!          sample interaction length 
!          and interaction type.
!       Method.  Sample interaction lengths for all possible 
!                interactions (for collisions, in kg/m2, for decay
!                in m).  They are stored in a record /intinf/ IntInfArray
!                given in Ztrackv.h;  
!            In the routine,  cfixProc, 
!                we take the minimum of values given in kg/m2, and
!                convert it in real length (m).  In this process,
!                path truncation may occur (if the particle is
!                going upward, and there is very thin air there,
!                then the given thickness may not be realized.
!                Or if the length is too large and accuracy 
!                of convesion is not enough due to the earch
!                curverture)
!                If the decay process exists, we compare the length
!                given by the above treatment, and take shorter one.
!                If decay length is shorter,  we assume the decay
!                takes place, else some collision takes place if
!                the path is not truncated. In the latter case,
!                if the path is truncated, MoveStat == Truncated
!                is set.
      implicit none
#include  "Zglobalc.h"
#include  "ZmediaLoft.h"
#include  "Zcode.h"
#include  "Ztrack.h"
! #include  "Zmagfield.h"      
#include  "Ztrackv.h"
#include  "Ztrackp.h"

!      real*8 leng/1.d50/   ! will  be truncated  by ctruncPath -->Infty
      integer:: jcon
!/////////
      logical::show
      common /showshow/ show
!//////////

!     **************************************************
      call ciniSmpIntL   ! init for interaction length sampling

      if(Reverse .ne. 0) then
         call csetIntInf(Infty, .true., 'none')
         ProcessNo = 1
      else
         if(TrackBefMove%p%code .eq. kphoton) then
            call cpreSampGIntL(Media(MediaNo))
            call cfixProc(1, Media(MediaNo)%X0kg)
         elseif(TrackBefMove%p%code .eq. kelec) then
            call cpreSampEIntL(Media(MediaNo))
            call cfixProc(2, Media(MediaNo)%X0kg)
         else
            call cpreSampNEPIntL(Media(MediaNo))
            call cfixProc(3, Media(MediaNo)%X0kg)            
!               non Electron Photon  Interaction.
         endif
!!!!!!!!
!         write(0,*) ' after fix proc ProecessNo=',ProcessNo
!         write(0,*) ' process=', IntInfArray(ProcessNo)%process
!         write(0,*) ' length(m)= ' , IntInfArray(ProcessNo)%length 
!         write(0,*) ' thikness(kg/m2)=',IntInfArray(ProcessNo)%thickness 
!!!!!!!!!!!!         
         if( IntInfArray(ProcessNo)%process == 'coll' ) then
!               some of the code can not deal with coll.of sigma 
!               etc.
            call cseeColPossible( TrackBefMove%p, jcon)
            if( jcon == -1) then
!                  then force to decay
               call cresetIntInf
            else
               call cfixTarget( Media(MediaNo) )
            endif
         elseif( IntInfArray(ProcessNo)%process == 'photop') then
            call  cfixTarget( Media(MediaNo) )
         elseif( IntInfArray(ProcessNo)%process == 'nuci') then
            call cfixTargetMuNI( Media(MediaNo) )
         endif

         if(.not. Freec .and. Zfirst%pos%depth .eq. 0.) then
            IntInfArray(ProcessNo)%length = 0.
            IntInfArray(ProcessNo)%thickness = 0.
         endif
      endif

      end
!     ***********************
!          truncate a path of the particle, if the path
!        given in InfIntArray is too long, or the path traverses
!        an observation depth.
      subroutine ctruncPath
      use modSetIntInf
      implicit none
#include  "Zcode.h"
#include  "Ztrack.h"
! #include  "Zmagfield.h"      
#include  "Ztrackv.h"
! #include  "ZmediaLoft.h"


      real*8 leng, thick
      real(8),parameter::veryshort=0.1 ! 10cm
      real(8),parameter::verylow=2d-3 !  2MeV
!
!//////////////////
      logical show
      common /showshow/ show
!////////////

      call cmaxMovLen(leng, thick)

      if(leng .lt. IntInfArray(ProcessNo)%length ) then
         MoveStat = Truncated
         IntInfArray(ProcessNo)%length = leng
         IntInfArray(ProcessNo)%thickness  = thick
         IntInfArray(ProcessNo)%process = "trunc"
         if(leng < veryshort ) then
!            some very unhappy case, B and dE/dx forces
!             muon (typically) path very short and the
!             muon cannot decay, while E loss is very small
!             and muon KE is still > 0 after the path.
!             This is repeated and KE becomes smaller and
!             smaller (say, until 10^-13 GeV); it may need
!             huge steps for traveling only a few cm and   
!             cpu time more than 5 sec.  This is avoided
!             by next 
            if( MovedTrack%p%code == kmuon .or.
     *          MovedTrack%p%code == kpion .or.
     *          MovedTrack%p%code == kkaon ) then
               if( MovedTrack%p%fm%p(4)- MovedTrack%p%mass 
     *            < verylow ) then
!                  force to decay; 
                  MoveStat = ToInteract

                  IntInfArray(ProcessNo)%process = 'decay'
!                  
               endif
            endif
         endif
      endif
      end
!      *************** for same model, we must use simple super position for heavy
!      If so, current particle is decomposed into nucelons and put into stack
!      and icon =1  is made. else icon = 0
      subroutine  cforceSSP(atrack, icon)
      implicit none
#include "Ztrack.h"
#include "Zevhnv.h"
#include "Zevhnp.h"
#include "Zcode.h"
#include "Zmass.h"

      integer icon
      type(track)::atrack  ! input current projectile.

      type(track)::pj
      integer i, j
      real*8  p, po, pr

      icon = 0
      if(atrack%p%code .eq. kgnuc) then
         call cfixModel(atrack%p)
         if(ActiveMdl .eq. 'dpmjet3' .and. 
     *      atrack%p%subcode .gt. 18) then
!/////            icon = 1 ///// 
         elseif( ActiveMdl .eq. 'incdpm3') then
            icon = 1
         endif
      endif
      if( icon  .eq. 1 ) then
         pj = atrack
         pj%p%fm%p(4) = atrack%p%fm%p(4)/atrack%p%subcode
         pj%p%mass = masp
         pj%p%code = knuc
         pj%p%subcode = -1
         pj%p%charge = 1

         p = sqrt(pj%p%fm%p(4)**2 - masp**2)      
!          next one leads to seg. violation on opteron and ifc64
!         po = atrack.p.fm.p(1)**2 + atrack.p.fm.p(2)**2 +
!     *           atrack.p.fm.p(3)**2 
!       (  still by version 9. )

         po = atrack%p%fm%p(1)**2 + atrack%p%fm%p(2)**2
         po = po +  atrack%p%fm%p(3)**2 

         po = sqrt(po)
         pr = p/po
         do j = 1, 3
            pj%p%fm%p(j) = atrack%p%fm%p(j)*pr
         enddo
         do i = 1, atrack%p%charge
            call cpush(pj)
         enddo

         pj%p%mass = masn
         p = sqrt(pj%p%fm%p(4)**2 - masn**2)      
         pr = p/po
         pj%p%charge = 0
         do j = 1, 3
            pj%p%fm%p(j) = atrack%p%fm%p(j)*pr
         enddo
         do i = 1, atrack%p%subcode - atrack%p%charge
            call cpush(pj)
         enddo
      endif
      end

      subroutine cgetMagF(yearin, pos, B,  icon)
      use modAtmosDef      
      implicit none

#include "Zglobalc.h"
#include "Zmanagerp.h"      
#include "Zcoord.h"
#include "Zmagfield.h"
      
      real(8),intent(in):: Yearin !  2020.5  etc
      type(coord),intent(in)::pos !  position vector where mag. field
         ! is wanted. pos%sys must contain the coord. sys.  unit is 
      type(magfield),intent(out)::B ! obtained magnetic field. B%sys
             ! should contain the system (one of xyz,ned,hva)
             ! field strength is in T.
      integer,intent(out):: icon ! 0 is OK.

      if( ObjFile == " " ) then
         call cgeomag(yearin, pos, B, icon)  ! Earth
      else
         call cmyBfield(yearin, pos, B, icon)  ! non Earth
      endif
      end
            

