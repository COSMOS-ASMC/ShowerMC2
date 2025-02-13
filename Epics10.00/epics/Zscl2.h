!          ngenpm: # of different ptcl species at generation
!          lnpic: location where # of pi+- is to be stored.
!          lnpi0: //                  pi0
!          lnkc:  //                  k+-
!          lnk0:   //                 k0
!          lnnb:   //                (n,n~) pair
!          lnddb:  //                (d,d~) pair
!          maxiso: max # of ptcls to be generated by isoropic p.s
!                  mechanism. (not neccry)
        parameter (ngenpm=6,  lnpic=1, lnpi0=2, lnkch=3, lnk0=4,
     *             lnnb=5, lnddb=6, maxiso=10)
!                            ***********
                             common /Zscl2/
!                            ***********
     1   aforl(nattrb), asvlp(nattrb), afort(nattrb), aforb(nattrb),
     2   gc, gcb, roots, esmax, gb, gbb, trgt(nattrb),
     3   dest1, dest2, ppcms(nattrb), ptcms(nattrb),
     4   ngen(ngenpm), emvptc, pvptcl(4)
