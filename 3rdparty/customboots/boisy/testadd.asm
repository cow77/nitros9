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

name     fcs   /testadd/
         fcb   edition

start
         orcc  #IntMasks

* set up appropriate registers for test
         lda   #0

VAL      equ   1

top
* 100 instructions in series
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         adda  #VAL
         lbra  top

         clrb
         os9   F$Exit

         emod
eom      equ   *
         end