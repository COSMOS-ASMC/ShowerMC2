        blockdata epblkepics
#include  "ZepTrackp.h"
!        data  Bxu/0./, Byu/0./, Bzu/0./
!        data  Exu/0./, Eyu/0./, Ezu/0./
!        data  MagField/0/,  ElecField/0/ --> HowMagField, HowElecField
!          in EMcontrol
!        data  Excom1/1.d-3/, Excom2/1.d-3/
!	data  LPMeffect/.true./  
!        data  Tcoef/5.d0/
!        data  Tmin/1.d-3/
!        data  EdepdEdx/.true./
        data  HowQuench/1/
!	data  TargetElecBrems/0/
        data  TimeStruc/.false./
!        data  Moliere/1/
	data  AutoEmin /2/  
        data  EminElec/611.d-6/
        data  EminGamma/100.d-6/
!        data  EpartialSC/10./
!        data  Flpm/1./
        data  EminH/0./               ! will be set max(5MeV,KEmin)

!        data  EupperBndCS/100.d-3/
!        data  IncGp/4/
!        data  HowNormBrems/-1/
        data  Trace/.false./
        data  TraceErg/0., 1.d12, 0., 1.d12, 0.,1.d12/
        data  FreeC/.true./
        data  EpsLeng/1.d-6/
!        data  RecoilKEmin/100.d-6
!   	data  Eanihi/10.d-3/

!        data  Knckon/.true./
!        data  AngleB/.false./
!        data  ALateCor/1/
!        data  Sync  /0/
!        data  SyncLoop /10.d0/
        data  Escat/19.3d-3/
!        data  MuNI/0/
!        data  MuBr/0/
!        data  MuPr/0/
!        data  MagPair/0/
	data  StoppingPw /1/
	data  SrimEmax /0.09d0/
	data  Zcorrec/.true./
!        data  PhitsXs /0/
!        data  JamXs /0/
!        data  Photo/.true./
!        data  ElowerBndPair/2.d-3/	  
        end
