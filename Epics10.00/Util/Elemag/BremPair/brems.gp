# set log y
unset key
set xr[1.e-8:1]
# set yr[0:1.4]
 set label 1 sprintf("Ek=%12.3e GeV", Ek) at  graph 0.3, graph 0.1 textcolor lt 3
plot "WWW/brems.hist" u 1:($2*$1)  w his lw 3, "WWW/brems.func" w l lw 3 lt 3
pause mouse

#set term png nocrop medium size 480,360
#set term png nocrop medium size 640,480
# next:  can fit 6 graphs in A4 portrate
set term png nocrop medium size  288,216



