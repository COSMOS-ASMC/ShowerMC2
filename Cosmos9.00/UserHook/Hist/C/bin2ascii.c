#include <stdio.h>
#include <string.h>
#include <stdlib.h>
/*
c  Usage: compile:  make -f bin2ascii.mk
c         execution:
c            set environmental variable HISTFILE0 to be
c            a binary hist file.
c            Optionally you may give another env. var.
c            HYBFILE0 to be a hybrid data output file
c            made by a program in UserHook/DisPara/FleshHist
c            or UserHook/ForTA.  If this is not given, 
c            no special treatment of mergining hybrid result.
c            (If the event is generated by using DisPara,
c             you need to merge hybrid data, otherwise
c             the hybrid data in the binary hist is not
c             correct. )
c        bin2ascii$ARCH > xxxx.hist
c
*/
#include "Z90histfuncdef.h"
#include "Z90histc.h"
#include "Z90histo.h"
#include "Z90hist1.h"
int main(){
  struct histogram1 h10;
  char *hist0;
  char histid0[7];
  float normf=-1.0;
  FILE *fn0;

  if( ( hist0=getenv("HISTFILE0") ) == NULL ) {
    fprintf(stderr, "Env. var. HISTFILE0 not given\n");
    exit (1);
  }
  fn0 =  fopen(hist0, "rb");
  if( fn0 == NULL) {
    fprintf(stderr,"File %s  not exist\n", hist0);
    exit (1);
  }
  fprintf(stderr, "File %s opened\n", hist0);

  //      call openhyb(iconhyb) 
  //  do while(.true.)

  int nid;
    //         read( fn0, end=1000 ) histid0
    //  100     continue
  size_t size;
  size=sizeof("#hist1");
  while ( ( nid = fread( histid0, 1, size, fn0)) > 0 ){
    
    //    fprintf(stderr, "nid=%d id is %s\n",nid, histid0);

    if( strcmp(histid0,"#hist1") == 0 ) {
	//call kwhistr(h10, fn0, icon0)
      int icon0; 
      kwhistr( &h10, fn0, icon0);
	/*
           if(iconhyb .eq. 1)  then
              call mergehyb1(h10)
           endif
	*/
	//call kwhists(h10, normf)
      kwhists0(0);   // integral from -inf

      kwhists( &h10, normf);
      
      //  call kwhistpr(h10, -6) !  to stdout
      kwhistpr( &h10, stdout);
      //call kwhistd(h10)
      kwhistd( &h10);
    }
    else {
	//  elseif(histid0 .eq. '#hist2' ) then
      fprintf(stderr, "id=%s not supported\n", histid0);
      exit(1);
    }
  }
  fprintf(stderr,"all events processed\n");
  return 0;
}
