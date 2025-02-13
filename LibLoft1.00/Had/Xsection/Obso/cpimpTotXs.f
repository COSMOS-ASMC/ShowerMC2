!        pi-p total xsection , elastic xs
      subroutine cpimpTotXs(p, xs)
      implicit none
#include "Zmass.h"
      real*8 p  ! input.  momentum of n. in GeV
      real*8 xs     ! output. total np cross section in mb
      integer np, i, m
      real*8  error
      parameter (np=65, m=5)
      real*8  px(np), mb(np)
      real*8  Z, Y1, Y2, B, s, rts, s0, eta1, eta2
 
      parameter(Z=20.86, Y1=19.24, Y2=6.03, B=0.308, 
     *   s0=5.38**2, eta1=0.458, eta2=0.545)
          data ( px(i), i=           1 ,           np )/
     1   0.1320    ,  0.1553    ,  0.1730    ,  0.1844    ,
     2   0.2044    ,  0.2178    ,  0.2356    ,  0.2474    ,
     3   0.2624    ,  0.2798    ,  0.3027    ,  0.3196    ,
     4   0.3425    ,  0.3688    ,  0.4151    ,  0.4340    ,
     5   0.4581    ,  0.5030    ,  0.5495    ,  0.6033    ,
     6   0.6494    ,  0.6721    ,  0.6888    ,  0.7094    ,
     7   0.7599    ,  0.7867    ,  0.8024    ,  0.8388    ,
     8   0.8767    ,  0.9073    ,  0.9344    ,  0.9622    ,
     9   0.9812    ,   1.006    ,   1.046    ,   1.067    ,
     a    1.116    ,   1.149    ,   1.219    ,   1.300    ,
     b    1.385    ,   1.470    ,   1.614    ,   1.763    ,
     c    1.926    ,   2.094    ,   2.334    ,   2.814    ,
     d    3.376    ,   4.361    ,   6.154    ,   8.814    ,
     e    11.61    ,   16.06    ,   23.46    ,   32.47    ,
     f    46.73    ,   70.64    ,   99.20    ,   130.0    ,
     g    175.5    ,   218.0    ,   284.3    ,   401.2    ,
     h    518.1                                                         
     * /   
           data ( mb(i), i=           1 ,           np )/
     1    21.81    ,   17.87    ,   17.87    ,   20.68    ,
     2    29.12    ,   37.17    ,   47.45    ,   57.69    ,
     3    65.18    ,   70.13    ,   65.98    ,   57.21    ,
     4    47.06    ,   37.16    ,   29.10    ,   27.38    ,
     5    26.18    ,   26.72    ,   28.51    ,   31.57    ,
     6    36.70    ,   40.46    ,   42.83    ,   45.34    ,
     7    44.61    ,   39.48    ,   36.99    ,   36.10    ,
     8    37.44    ,   41.62    ,   46.08    ,   51.02    ,
     9    55.80    ,   59.31    ,   55.57    ,   51.22    ,
     a    42.65    ,   39.31    ,   36.98    ,   36.38    ,
     b    36.83    ,   35.94    ,   34.79    ,   35.07    ,
     c    36.08    ,   36.37    ,   35.20    ,   32.85    ,
     d    31.66    ,   30.15    ,   28.47    ,   26.89    ,
     e    26.02    ,   25.29    ,   24.98    ,   24.77    ,
     f    24.36    ,   24.16    ,   24.15    ,   24.25    ,
     g    24.34    ,   24.64    ,   24.74    ,   25.14    ,
     h    25.55                                                         
     * /   
      save    
      if(p .gt. 300.) then
!         s =(M+E)^2 - p^2  = M^2 + m^2 +2ME
!           = 
         s = masp**2 + maspic**2 + 2*masp*sqrt(p**2 + maspic**2)
         rts = sqrt(s)
         xs =Z + B*log(s/s0)**2 + Y1*(1./s)**eta1 -Y2*(1./s)**eta2 
      elseif( p .gt. 0.2) then   
         call kpolintplogxyFE(px, 1, mb, 1, np, m, 3,  p, xs, error) 
      else
         call cpimpElaXs(p, xs)
      endif
      end
!         
      subroutine cpimpElaXs(p, xs)
!           pi+ p elastic cross section in mb
      implicit none
      real*8 p ! input.  momentum of n in GeV
      real*8  xs   ! output np elastic xs. mb.

       integer np, m, i
       parameter (np=52, m=5)
       real*8 px(np), mb(np)
       real*8 error
       real*8 xssave/-1./
           data ( px(i), i=           1 ,           np )/
     1   0.1320    ,  0.1553    ,  0.1731    ,  0.1845    ,
     2   0.2017    ,  0.2171    ,  0.2280    ,  0.2418    ,
     3   0.2527    ,  0.2680    ,  0.2871    ,  0.3076    ,
     4   0.3232    ,  0.3480    ,  0.3785    ,  0.4056    ,
     5   0.4454    ,  0.5187    ,  0.5611    ,  0.6159    ,
     6   0.6374    ,  0.6760    ,  0.7242    ,  0.7608    ,
     7   0.7915    ,  0.8480    ,  0.9085    ,  0.9354    ,
     8   0.9823    ,   1.007    ,   1.052    ,   1.089    ,
     9    1.128    ,   1.221    ,   1.354    ,   1.531    ,
     a    1.988    ,   2.361    ,   2.904    ,   3.901    ,
     b    5.191    ,   7.546    ,   10.29    ,   14.03    ,
     c    19.51    ,   27.40    ,   38.66    ,   63.24    ,
     d    100.9    ,   170.9    ,   263.4    ,   366.3                  
     * /   
           data ( mb(i), i=           1 ,           np )/
     1    21.81    ,   17.87    ,   15.43    ,   13.60    ,
     2    11.46    ,   11.37    ,   12.90    ,   16.87    ,
     3    19.70    ,   22.07    ,   24.94    ,   23.46    ,
     4    19.14    ,   15.05    ,   11.98    ,   10.78    ,
     5    9.501    ,   10.06    ,   11.74    ,   13.93    ,
     6    16.12    ,   18.75    ,   20.09    ,   18.44    ,
     7    16.12    ,   14.80    ,   14.98    ,   19.05    ,
     8    23.44    ,   25.33    ,   23.63    ,   20.50    ,
     9    16.38    ,   13.70    ,   12.27    ,   10.47    ,
     a    8.894    ,   8.098    ,   7.434    ,   6.578    ,
     b    5.566    ,   5.006    ,   4.689    ,   4.304    ,
     c    3.871    ,   3.626    ,   3.467    ,   3.301    ,
     d    3.220    ,   3.180    ,   3.325    ,   3.577                  
     * /   

       save
! 
       if( p .gt. 300.) then
!           assume prop.to total
          if( xssave .lt. 0.) then
             call cpimpTotXs(px(np), xssave)
          endif
          call cpimpTotXs(p, xs)
          xs = xs * mb(np)/xssave
       elseif(p .gt. px(1)) then
          call kpolintplogxyFE(px, 1, mb, 1, np, m, 3, p, xs, error) 
       else
!            get value at 0.1
          xs = mb(1)
       endif
       end
      subroutine cpimpInelaXs(p, xs)
      implicit none
      real(8),intent(in)::p
      real(8),intent(out)::xs

      real(8)::txs, exs
      call cpimpTotXs(p, txs)
      call cpimpElaXs(p, exs)
      xs =max( txs - exs, 0.d0)
      end
