         ifp1
         use   os9defs
         endc

tylg     set   Prgrm+Objct   
atrv     set   ReEnt+rev
rev      set   $00
edition  set   1

         mod   eom,name,tylg,atrv,start,size

stack    rmb   200
size     equ   .

name     fcs   /testcwai/
         fcb   edition

start
         cwai  #$FF
         
         clrb
         os9   F$Exit

         emod
eom      equ   *
         end
