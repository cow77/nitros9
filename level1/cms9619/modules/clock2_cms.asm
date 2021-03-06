********************************************************************
* Clock2 - CMS Tick/RTC Driver
*
* $Id$
*
* Configure the MC6840 to output a ~60Hz signal to the MC6821 CA1.
* Use CMS DEBUG09 ROM routines to set the RTC on CMS 9619.
* RTC is EPSON 58321B connected through MC6821 PIA port B
* and a decoder for the READ, WRITE, and ADDRESS WRITE lines.
*
* http://pdf.datasheetcatalog.com/datasheet/epson/RTC58321.pdf
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2020/01/07  Eric S. Pooch
* Created.
*
          nam       Clock2
          ttl       CMS RTC Driver

          ifp1
          use       defsfile
          endc

tylg      set       Sbrtn+Objct
atrv      set       ReEnt+rev
rev       set       $00
edition   set       1

RTC.Base  equ       RTCBase        RTC is on PIA0

RTC.TYr   equ       $0C            RTC 10 year digit address
RTC.WkR   equ       $06            RTC week register address

* These ROM-based subroutines could be incorporated in future revisions.
* Each needs PIA base address in regU, RTC address in regB, value in regA
RTCRead   equ    $E7AF             DEBUG09 RTC read  subroutine
RTCWrite  equ    $E71D             DEBUG09 RTC write subroutine
RTCSSReg  equ    $E7DB             DEBUG09 RTC Std Signal config subroutine

          mod       eom,name,tylg,atrv,JmpTable,RTC.Base

name      fcs       "Clock2"
          fcb       edition

* Three Entry Points:
*   - Init
*   - GetTime
*   - SetTIme
JmpTable
          lbra  Init               Init regular interrupt
          bra   GetTime
          nop
          lbra  SetTime

********************************************************************
SetTime
          pshs u,y,x,d
          ldx  #D.Time             Start of OS9 DP System Date/Time in DP
          ldu  #RTC.Base
          ldb  #RTC.TYr            Start at the RTC decade digit register
SetTim1   lda  ,x+                 Get the next time unit value
          bsr  bin2bcd             Convert regA from binary to BCD
          pshs a                   save BCD
          lsra
          lsra
          lsra
          lsra                     10s nibble in regA, hi bits clear

          cmpb #RTC.WkR            On Week register...
          bne  SetTim2
          decb                     skip it. Now on 10 Hr digit register...
          ora  #$08                force 24 Hr Clock (not AM/PM)
SetTim2   jsr  RTCWrite            write the 10s digit to RTC
          decb                     Decrement the RTC address
          puls a                   Restore BCD value
          anda #$0f                1s nibble in regA
          jsr  RTCWrite            Write the 1s digit to RTC
          decb                     Decrement RTC address to smaller time unit
          bpl  SetTim1             Continue with the next time unit
          bra  UpdLeave

************************************************
bin2bcd
*
* in  A= value in binary
* out A= value in BCD
*
          pshs b
          clrb
bcdnxt    cmpa #10                 for each 10s
          bcs  bcddone
          addd #$f610              decrease bin regA by 10 add bcd $10 to regB
          bra  bcdnxt
bcddone   pshs b
          adda ,s+                 finally, add back the 10s to regA for BCD
          puls b,pc                return

********************************************************************
GetTime
          pshs u,y,x,d
          ldx  #D.Time             Start of OS9 DP System Date/Time in DP
          ldu  #RTC.Base
          ldb  #RTC.TYr            Start at the RTC decade digit register
GetTim1   jsr  RTCRead             Read the 10s digit from RTC
          cmpb #RTC.WkR            On Week register...
          bne  GetTim2
          decb                     skip it. Now on 10 Hr digit register...
          jsr  RTCRead
          anda #$03                get the digit, not AM/PM or 24/12 setting
GetTim2   asla
          asla
          asla
          asla                     Move 10s digit to the high nibble
          pshs a                   Save 10s nibble
          decb                     Decrement RTC address to 1s digit
          jsr  RTCRead             Read the 1s digit from RTC, reconfig the SSR
          adda ,s+                 Add back the 10s digit to regA for BCD
          bsr  bcd2bin             Convert regA from BCD to binary
          sta  ,x+                 Store value in OS9 DP System Date/Time
          decb                     Decrement RTC address to smaller time unit
          bpl  GetTim1             Get the next time unit


UpdLeave  lda  3,u                 get PIA0 CRB
          ora  #%00000011          re-enable interrupts on CB1
          sta  3,u                 save to PIA0 CRB
          puls d,x,y,u,pc

************************************************
bcd2bin
*
* in  A= value in BCD
* out A= value in binary
*
          pshs b
          tfr  a,b
          andb #15                 keep the lowest digit
          pshs b                   save it
          anda #$f0
          ldb  #160
          mul                      times 10
          adda ,s+                 add back partials
          puls b,pc                return

********************************************************************
Init
          ifeq    ClocType-MC6840
* Configure the MC6840 PTM timer 1 to output a ~60Hz square wave on O1.
* Add a jumper from TS14-1 to TS10-2 (or anywhere on the right side) to
* connect O1 of the clock to PIA0 CB1, and
* add a jumper to TS10-17,18 to jump PIA0 IRQB to the IRQ encoder.
* The standard NitrOS-9 System Clock will handle things from there.
*
          pshs  d,x

          lda  #$01           enable Control Reg 1
          sta  CR2SR          Control Reg 1 (CR10) may now be written @ CR13
          sta  CR13           All timers held in preset (not decrementing)
*         ldx  #$4000         Calculation: 1/((16384+1)(2E-6)/2) = 61.03Hz.
          ldx  #$4119         ~60Hz.
          stx  MSBT1

          lda  #%10000010     E clk, continuous, mask interrupts, output,
          sta  CR13           CR10: operate clocks
          endc
          puls d,x

          ifeq ClocType-RTC58321
* Configure the RTC58321 RTC to output standard signals on D0-D3.
* Add a jumper to TS10-5,6 to use the 1 sec reference signal, and
* add a jumper to TS10-17,18 to jump PIA0 IRQB to the IRQ encoder.
* The standard NitrOS-9 System Clock will handle things from there.
*
          pshs u,d
          ldu  #RTC.Base
          jsr  RTCSSReg
          lda  3,u                 get PIA0 CRB
          ora  #%00000011          re-enable interrupts on CB1
          sta  3,u                 save to PIA0 CRB
          puls u,d
          endc
          rts

************************************************
          emod
eom       equ   *
          end
