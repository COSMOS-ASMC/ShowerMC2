! ******************************************************************************
!       The user routines here are used only when you give 161 ~ 199 to the Trace value 
!       so that you  can manage the Cerenkov light output yourself.
!   The main purpose is to enable you to convert each track information to Cerekov light
!   on fly and output it with your desired format.  This will save the output disk file 
!   volume as compared to writing the track infomation directly by the standard way.
!  
!     This file is saved  as ctemplCeren.f
!   Each user hook program is supplied with #include "ctemplCeren.f"
!  (if not supplied, give it somewhere).
!   If you really want to make this file usable, save it as chookCeren.f (or whatever
!   you like), and change its content.
!   Then, you have to change the incldue statement in the user hook program which
!   really uses the chookCeren.f:
!        #include "chookCeren.f"
! ******************************************************************************
!  
      subroutine chookCerenS(no,  primary, angle)
      implicit none
!          This is called when one event generation starts.
!  
#include "Zmanagerp.h"
#include "Ztrack.h"
! #include "Zmagfield.h"      
#include "Ztrackp.h"
#include "Ztrackv.h"
#include "Zcode.h"
#include "Zmass.h"
#include "Zprimary.h"
#include "Zprimaryv.h"
#include "Zheavyp.h"
#include "Zincidentv.h"
!  
!  
      integer no  !  input.  Event number.
      type (primaries):: primary  ! input. Primary particle info.
      type (coord):: angle      !  input.  primary angle at the observation depth.
!    ***************
      integer ka        ! input. particle code
      integer chrg      ! input. particle charge
      real*8 e1         ! input. particle energy
      integer itb       ! input. time expressed in cemeter/beta at the segment top
      integer it        ! input. track segment length in cm/beta 
      type (coord):: f  ! input. f.r(i), i=1,3 are the x,y,z component of the
                        !        segment top. The coordinate system is by the Trace value
                        !        you gave.
      type (coord):: t  ! input. the same as above for the segment tail.
!     ****************
!  
!   ---------------------------------------------------------------------------------------
!        here  you may put some flag info. as header of each event;
!     The standard Cerenkov output routine writes the
!     following:
!  
!      no      ! event no
!      primary.particle.code ! intger: partilce code
!      primary.particle.fm.p(4)  ! energy
!      angle.r(1), angle.r(2), angle.r(3)      ! direction cos of primary at the observation level.
!      
!    
      return
!     *****************
      entry chookCeren(ka, chrg, e1, itb, it, f, t)
!        This is called whenever a charged particle is moved. Cerenkov threshold is
!     considered.
!     *****************
!     The standard Cerekov routine writes the following:
!  
!                 ka, chrg, sngl(e1), itb, it,
!     *           sngl(f.r(1)), sngl(f.r(2)), sngl(f.r(3)),
!     *           sngl(t.r(1)), sngl(t.r(2)), sngl(t.r(3))
!  
      return
!  
!     ******************
      entry chookCerenE(ka, chrg, e1, itb, it, f, t)
!         This is called when one event has been generated.
!         All values (ka etc) are 0. 
!     *******************
!     The standard Cerekov routine writes the following:
!
!                 ka, chrg, sngl(e1), itb, it,
!     *           sngl(f.r(1)), sngl(f.r(2)), sngl(f.r(3)),
!     *           sngl(t.r(1)), sngl(t.r(2)), sngl(t.r(3))
!
      end
