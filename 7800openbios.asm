     ; ** Atari 7800 OpenBIOS

     ; **********************************************************************
     ; ** Created by Bob DeCrescenzo and Michael Saarna, 2021
     ; **
     ; ** the BIOS source code is provided here under the CC0 license.
     ; ** https://creativecommons.org/publicdomain/zero/1.0/legalcode
     ; **
     ; ** The in-BIOS game is all-rights-reserved, and not covered under the
     ; ** CC0. Please contact the authors for terms before redistributing.
     ; **********************************************************************

     processor 6502

     ; **********************************************************************
     ; ** BIOS TUNING
     ; **********************************************************************

DISPLAYTIME     = 10 ; length of fuji display in half-second ticks
SKIPMODE     = 0 ; 0=hold B+W skips fuji, 1=no B+W skips fuji

     ; **********************************************************************
     ; ** Register defines... 
     ; **********************************************************************

     ; ** TIA/INPTCTRL 00-1F...
INPTCTRL     = $01 ;Input control write-only
INPT0     = $08 ;Paddle Control Input 0 read-only
INPT1     = $09 ;Paddle Control Input 1 read-only
INPT2     = $0A ;Paddle Control Input 2 read-only
INPT3     = $0B ;Paddle Control Input 3 read-only
INPT4B     = $08 ;Joystick 0 Fire 1 read-only
INPT4A     = $09 ;Joystick 0 Fire 1 read-only
INPT5B     = $0A ;Joystick 1 Fire 0 read-only
INPT5A     = $0B ;Joystick 1 Fire 1 read-only
INPT4R     = $08 ;Joystick 0 Fire 1 read-only
INPT4L     = $09 ;Joystick 0 Fire 1 read-only
INPT5R     = $0A ;Joystick 1 Fire 0 read-only
INPT5L     = $0B ;Joystick 1 Fire 1 read-only
INPT4     = $0C ;Player 0 Fire Button Input read-only
INPT5     = $0D ;Player 1 Fire Button Input read-only
AUDC0     = $15 ;Audio Control Channel 0 write-only
AUDC1     = $16 ;Audio Control Channel 1 write-only
AUDF0     = $17 ;Audio Frequency Channel 0 write-only
AUDF1     = $18 ;Audio Frequency Channel 1 write-only
AUDV0     = $19 ;Audio Volume Channel 0 write-only
AUDV1     = $1A ;Audio Volume Channel 1 write-only

     ; MARIA 20-3F...
BACKGRND     = $20 ;Background Color write-only
P0C1     = $21 ;Palette 0 - Color 1 write-only
P0C2     = $22 ;Palette 0 - Color 2 write-only
P0C3     = $23 ;Palette 0 - Color 3 write-only
WSYNC     = $24 ;Wait For Sync write-only
P1C1     = $25 ;Palette 1 - Color 1 write-only
P1C2     = $26 ;Palette 1 - Color 2 write-only
P1C3     = $27 ;Palette 1 - Color 3 write-only
MSTAT     = $28 ;Maria Status read-only
P2C1     = $29 ;Palette 2 - Color 1 write-only
P2C2     = $2A ;Palette 2 - Color 2 write-only
P2C3     = $2B ;Palette 2 - Color 3 write-only
DPPH     = $2C ;Display List List Pointer High write-only
P3C1     = $2D ;Palette 3 - Color 1 write-only
P3C2     = $2E ;Palette 3 - Color 2 write-only
P3C3     = $2F ;Palette 3 - Color 3 write-only
DPPL     = $30 ;Display List List Pointer Low write-only
P4C1     = $31 ;Palette 4 - Color 1 write-only
P4C2     = $32 ;Palette 4 - Color 2 write-only
P4C3     = $33 ;Palette 4 - Color 3 write-only
CHARBASE     = $34 ;Character Base Address write-only
CHBASE     = $34 ;Character Base Address write-only
P5C1     = $35 ;Palette 5 - Color 1 write-only
P5C2     = $36 ;Palette 5 - Color 2 write-only
P5C3     = $37 ;Palette 5 - Color 3 write-only
OFFSET     = $38 ;Unused - Store zero here write-only
P6C1     = $39 ;Palette 6 - Color 1 write-only
P6C2     = $3A ;Palette 6 - Color 2 write-only
P6C3     = $3B ;Palette 6 - Color 3 write-only
CTRL     = $3C ;Maria Control Register write-only
P7C1     = $3D ;Palette 7 - Color 1 write-only
P7C2     = $3E ;Palette 7 - Color 2 write-only
P7C3     = $3F ;Palette 7 - Color 3 write-only

     ; ** PIA 280-2FF...
SWCHA     = $280 ;P0, P1 Joystick Directional Input read-write
SWCHB     = $282 ;Console Switches read-write
CTLSWA     = $281 ;I/O Control for SCHWA read-write
SWACNT     = $281 ;VCS name for above read-write
CTLSWB     = $283 ;I/O Control for SCHWB read-write
SWBCNT     = $283 ;VCS name for above read-write

TIM1T     = $294 ;Set 1 CLK Interval (838 nsec/interval) write-only
TIM8T     = $295 ;Set 8 CLK Interval (6.7 usec/interval) write-only
TIM64T     = $296 ;Set 64 CLK Interval (63.6 usec/interval) write-only
T1024T     = $297 ;Set 1024 CLK Interval (858.2 usec/interval) write-only
TIM64TI     = $29E ;Interrupt timer 64T write-only

     SEG.U data

     ORG $40

     ; **********************************************************************
     ; ** Zero page memory for the BIOS. The in-BIOS game can use any/all of 
     ; ** the ZP memory.
     ; **********************************************************************

     ; ** frame counter
FrameCounter     ds.b 1
     ; ** 32-frames counter
FrameCounter32     ds.b 1

     ; ** The color of the first line of the fuji colorbar
FujiColor     ds.b 1

     ; ** The BIOS wipes the Fuji display in and out. This is the index to
     ; ** the wipe state.
WipeLevel     ds.b 1

     ; ** our NMI pointer for "JMP (NMIRoutine)"
NMIRoutine     ds.b 1
NMIRoutineHi     ds.b 1

     ; ** temp memory pointers, currently only used for clearing memory
Temp1Lo     ds.b 1
Temp1     = Temp1Lo
Temp1Hi     ds.b 1

     ; ** type of Cart in the slot
CartTypeDetected     ds.b 1

     echo "" 
     echo " *****************************************************************" 
     echo " ** BIOS Build Info (non-game)"
     echo " ** --------------------------"

     echo " ** Zero Page bytes free: ",($FF-*)d
     if (*>$FF)
         echo "ABORT: Too many zero page locations defined!"
         ERR 
     endif


     ; **********************************************************************
     ; ** Some BIOS specfic defines...
     ; **********************************************************************

DllRam     = $2600 ; to 187F 
DlRam     = $2680 ; to 199f. 12 bytes each visible DL, plus 2 zeros
CartCheckRam     = $2300 ; to 27FF

     ; **********************************************************************
     ; ** Start of the ROM...
     ; **********************************************************************
     
     SEG ROM

     ORG $C000,0 ; *************

     ; **********************************************************************
     ; ** Game graphics block or other data.
     ; ** Resides in 8k from C000 to DFFF
     ; **********************************************************************

     incbin "kiloparsec.bl1"

     ; **********************************************************************
     ; ** Long section of fuji graphics data follows. Skip ahead to "Start" 
     ; ** to get to the code.
     ; **********************************************************************
     
     ORG $E000,0

fuji00
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
fuji01
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
fuji02
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
fuji03
     HEX 001ffffc3fffffff0ffffe000000000000000000000000
fuji04
     HEX 003ffff83fffffff07ffff000000000000000000000000
fuji05
     HEX 007ffff83fffffff07ffff800000000000000000000000
fuji06
     HEX 01fffff03fffffff03ffffe00000000000000000000000
fuji07
     HEX 07ffffe03fffffff01fffff00000000000000000000000
fuji08
     HEX 1fffffc03fffffff00fffffe0000000000000000000000
fuji09
     HEX ffffff803fffffff007fffffc000000000000000000000
fuji10
     HEX fffffe003fffffff001ffffff800000000000000000000

     ORG $E100,0 ; *************

     ;fuji00
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji01
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji02
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji03
     HEX 001ffffc3fffffff0ffffe000000000000000000000000
     ;fuji04
     HEX 003ffff83fffffff07ffff000000000000000000000000
     ;fuji05
     HEX 007ffff83fffffff07ffff800000000000000000000000
     ;fuji06
     HEX 01fffff03fffffff03ffffc00000000000000000000000
     ;fuji07
     HEX 07ffffe03fffffff01fffff00000000000000000000000
     ;fuji08
     HEX 1fffffc03fffffff00fffffc0000000000000000000000
     ;fuji09
     HEX 7fffff803fffffff007fffff8000000000000000000000
     ;fuji10
     HEX fffffe003fffffff001ffffff800000000000000000000

     ORG $E200,0 ; *************

     ;fuji00
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji01
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji02
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji03
     HEX 001ffffc3fffffff0ffffe000000000000000000000000
     ;fuji04
     HEX 003ffff83fffffff07ffff000000000000000000000000
     ;fuji05
     HEX 007ffff83fffffff07ffff800000000000000000000000
     ;fuji06
     HEX 01fffff03fffffff03ffffc00000000000000000000000
     ;fuji07
     HEX 03ffffe03fffffff01fffff00000000000000000000000
     ;fuji08
     HEX 1fffffc03fffffff00fffffc0000000000000000000000
     ;fuji09
     HEX 7fffff803fffffff007fffff8000000000000000000000
     ;fuji10
     HEX fffffe003fffffff001ffffff000000000000000000000

     ORG $E300,0 ; *************

     ;fuji00
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji01
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji02
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji03
     HEX 001ffffc3fffffff0ffffe000000000000000000000000
     ;fuji04
     HEX 003ffffc3fffffff0fffff000000000000000000000000
     ;fuji05
     HEX 007ffff83fffffff07ffff800000000000000000000000
     ;fuji06
     HEX 00fffff03fffffff03ffffc00000000000000000000000
     ;fuji07
     HEX 03ffffe03fffffff01fffff00000000000000000000000
     ;fuji08
     HEX 0fffffc03fffffff00fffffc0000000000000000000000
     ;fuji09
     HEX 7fffff803fffffff007fffff8000000000000000000000
     ;fuji10
     HEX ffffff003fffffff003ffffff000000000000000000000

     ORG $E400,0 ; *************

     ;fuji00
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji01
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji02
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji03
     HEX 001ffffc3fffffff0ffffe000000000000000000000000
     ;fuji04
     HEX 003ffffc3fffffff0fffff000000000000000000000000
     ;fuji05
     HEX 007ffff83fffffff07ffff800000000000000000000000
     ;fuji06
     HEX 00fffff83fffffff07ffffc00000000000000000000000
     ;fuji07
     HEX 03fffff03fffffff03ffffe00000000000000000000000
     ;fuji08
     HEX 0fffffe03fffffff01fffffc0000000000000000000000
     ;fuji09
     HEX 3fffff803fffffff007fffff0000000000000000000000
     ;fuji10
     HEX ffffff003fffffff003fffffe000000000000000000000

     ORG $E500,0 ; *************

     ;fuji00
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji01
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji02
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji03
     HEX 001ffffc3fffffff0ffffe000000000000000000000000
     ;fuji04
     HEX 003ffffc3fffffff0fffff000000000000000000000000
     ;fuji05
     HEX 007ffff83fffffff07ffff800000000000000000000000
     ;fuji06
     HEX 00fffff83fffffff07ffffc00000000000000000000000
     ;fuji07
     HEX 03fffff03fffffff03ffffe00000000000000000000000
     ;fuji08
     HEX 0fffffe03fffffff01fffff80000000000000000000000
     ;fuji09
     HEX 3fffff803fffffff007fffff0000000000000000000000
     ;fuji10
     HEX ffffff003fffffff003fffffe000000000000000000000

     ORG $E600,0 ; *************

     ;fuji00
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji01
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji02
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji03
     HEX 001ffffc3fffffff0ffffe000000000000000000000000
     ;fuji04
     HEX 001ffffc3fffffff0ffffe000000000000000000000000
     ;fuji05
     HEX 003ffff83fffffff07ffff000000000000000000000000
     ;fuji06
     HEX 00fffff83fffffff07ffff800000000000000000000000
     ;fuji07
     HEX 03fffff03fffffff03ffffe00000000000000000000000
     ;fuji08
     HEX 0fffffe03fffffff01fffff80000000000000000000000
     ;fuji09
     HEX 3fffffc03fffffff00fffffe0000000000000000000000
     ;fuji10
     HEX ffffff003fffffff003fffffe000000000000000000000

     ORG $E700,0 ; *************

     ;fuji00
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji01
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji02
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji03
     HEX 000ffffc3fffffff0ffffc000000000000000000000000
     ;fuji04
     HEX 001ffffc3fffffff0ffffe000000000000000000000000
     ;fuji05
     HEX 003ffff83fffffff07ffff000000000000000000000000
     ;fuji06
     HEX 00fffff83fffffff07ffff800000000000000000000000
     ;fuji07
     HEX 01fffff03fffffff03ffffe00000000000000000000000
     ;fuji08
     HEX 07ffffe03fffffff01fffff80000000000000000000000
     ;fuji09
     HEX 1fffffc03fffffff00fffffe0000000000000000000000
     ;fuji10
     HEX ffffff003fffffff003fffffc000000000000000000000

     ORG $E800,0 ; *************

fuji11
     HEX fffff0003fffffff0003ffffffc0000000000000000000
fuji12
     HEX ffffc0003fffffff0000fffffffe000000000000000000
fuji13
     HEX fffc00003fffffff00000ffffffff80000000000000000
fuji14
     HEX ffc000003fffffff000000fffffffff000000000000000
fuji15
     HEX f80000003fffffff00000007fffffffff8000000000000
fuji16
     HEX 000000003fffffff000000001fffffffffff8000000000
fuji17
     HEX 000000003fffffff00000000003fffffffffffff000000
fuji18
     HEX 000000003fffffff0000000000003ffffffffffffffffc
fuji19
     HEX 000000003fffffff000000000000001ffffffffffffffc
text00
     HEX 0000ffff0fffffffff0ffff00003fffffffc07fe
text01
     HEX 0003ffffc0007fe0003ffffc0003fe0001ff87fe

     ORG $E900,0 ; *************

     ;fuji11
     HEX fffff8003fffffff0007ffffff80000000000000000000
     ;fuji12
     HEX ffffc0003fffffff0000fffffffc000000000000000000
     ;fuji13
     HEX fffe00003fffffff00001ffffffff00000000000000000
     ;fuji14
     HEX ffc000003fffffff000000ffffffffe000000000000000
     ;fuji15
     HEX f80000003fffffff00000007fffffffff0000000000000
     ;fuji16
     HEX 000000003fffffff000000003ffffffffffe0000000000
     ;fuji17
     HEX 000000003fffffff00000000007ffffffffffffc000000
     ;fuji18
     HEX 000000003fffffff0000000000007fffffffffffffffe0
     ;fuji19
     HEX 000000003fffffff000000000000003ffffffffffffffc
     ;text00
     HEX 00007ffe0fffffffff07ffe00003fffffff807fe
     ;text01
     HEX 0003ffffc0007fe0003ffffc0003fe0003ff87fe

     ORG $EA00,0 ; *************

     ;fuji11
     HEX fffff8003fffffff0007ffffff00000000000000000000
     ;fuji12
     HEX ffffc0003fffffff0000fffffff8000000000000000000
     ;fuji13
     HEX fffe00003fffffff00001fffffffe00000000000000000
     ;fuji14
     HEX ffe000003fffffff000001ffffffffc000000000000000
     ;fuji15
     HEX fc0000003fffffff0000000fffffffffe0000000000000
     ;fuji16
     HEX 800000003fffffff000000007ffffffffff80000000000
     ;fuji17
     HEX 000000003fffffff0000000000fffffffffffff0000000
     ;fuji18
     HEX 000000003fffffff000000000000fffffffffffffffe00
     ;fuji19
     HEX 000000003fffffff00000000000000fffffffffffffffc
     ;text00
     HEX 00007ffe0fffffffff07ffe00003fffffff007fe
     ;text01
     HEX 0001ffff80007fe0001ffff80003fe0003ff87fe

     ORG $EB00,0 ; *************

     ;fuji11
     HEX fffffc003fffffff000fffffff00000000000000000000
     ;fuji12
     HEX ffffe0003fffffff0001fffffff8000000000000000000
     ;fuji13
     HEX fffe00003fffffff00001fffffffc00000000000000000
     ;fuji14
     HEX ffe000003fffffff000001ffffffff8000000000000000
     ;fuji15
     HEX fe0000003fffffff0000001fffffffffc0000000000000
     ;fuji16
     HEX 800000003fffffff000000007ffffffffff00000000000
     ;fuji17
     HEX 000000003fffffff0000000001ffffffffffffc0000000
     ;fuji18
     HEX 000000003fffffff000000000001ffffffffffffffe000
     ;fuji19
     HEX 000000003fffffff00000000000001fffffffffffffffc
     ;text00
     HEX 00007ffe0fffffffff07ffe00003ffffffe007fe
     ;text01
     HEX 0001ffff80007fe0001ffff80003fe0007ff07fe

     ORG $EC00,0 ; *************

     ;fuji11
     HEX fffffc003fffffff000ffffffe00000000000000000000
     ;fuji12
     HEX ffffe0003fffffff0001fffffff0000000000000000000
     ;fuji13
     HEX ffff00003fffffff00003fffffffc00000000000000000
     ;fuji14
     HEX fff000003fffffff000003ffffffff0000000000000000
     ;fuji15
     HEX fe0000003fffffff0000001fffffffff00000000000000
     ;fuji16
     HEX c00000003fffffff00000000ffffffffffe00000000000
     ;fuji17
     HEX 000000003fffffff0000000003ffffffffffff00000000
     ;fuji18
     HEX 000000003fffffff000000000003ffffffffffffff8000
     ;fuji19
     HEX 000000003fffffff00000000000003fffffffffffffffc
     ;text00
     HEX 00003ffc0fffffffff03ffc00003ffffffc007fe
     ;text01
     HEX 0001ffff80007fe0001ffff80003fe000fff07fe

     ORG $ED00,0 ; *************

     ;fuji11
     HEX fffffc003fffffff000ffffffe00000000000000000000
     ;fuji12
     HEX fffff0003fffffff0003ffffffe0000000000000000000
     ;fuji13
     HEX ffff80003fffffff00007fffffff800000000000000000
     ;fuji14
     HEX fff800003fffffff000007fffffffe0000000000000000
     ;fuji15
     HEX ff0000003fffffff0000003ffffffffe00000000000000
     ;fuji16
     HEX e00000003fffffff00000001ffffffffff800000000000
     ;fuji17
     HEX 000000003fffffff0000000007fffffffffffc00000000
     ;fuji18
     HEX 000000003fffffff000000000007fffffffffffffc0000
     ;fuji19
     HEX 000000003fffffff00000000000007fffffffffffffffc
     ;text00
     HEX 00003ffc0fffffffff03ffc00001ffffff8007fe
     ;text01
     HEX 0001ffff80007fe0001ffff80003fe001fff07fe

     ORG $EE00,0 ; *************

     ;fuji11
     HEX fffffc003fffffff000ffffffc00000000000000000000
     ;fuji12
     HEX fffff0003fffffff0003ffffffe0000000000000000000
     ;fuji13
     HEX ffff80003fffffff00007fffffff000000000000000000
     ;fuji14
     HEX fff800003fffffff000007fffffffe0000000000000000
     ;fuji15
     HEX ff0000003fffffff0000007ffffffffc00000000000000
     ;fuji16
     HEX e00000003fffffff00000001ffffffffff000000000000
     ;fuji17
     HEX 000000003fffffff0000000007fffffffffff000000000
     ;fuji18
     HEX 000000003fffffff00000000000ffffffffffffff00000
     ;fuji19
     HEX 000000003fffffff0000000000000ffffffffffffffffc
     ;text00
     HEX 00001ff80fffffffff01ff800000fffffe0007fe
     ;text01
     HEX 0000ffff00007fe0000ffff00003fe007ffe07fe

     ORG $EF00,0 ; *************

     ;fuji11
     HEX fffffc003fffffff000ffffffc00000000000000000000
     ;fuji12
     HEX fffff0003fffffff0003ffffffc0000000000000000000
     ;fuji13
     HEX ffff80003fffffff00007ffffffe000000000000000000
     ;fuji14
     HEX fff800003fffffff000007fffffffc0000000000000000
     ;fuji15
     HEX ff8000003fffffff0000007ffffffff800000000000000
     ;fuji16
     HEX f00000003fffffff00000003fffffffffc000000000000
     ;fuji17
     HEX 000000003fffffff000000000fffffffffffc000000000
     ;fuji18
     HEX 000000003fffffff00000000001fffffffffffffc00000
     ;fuji19
     HEX 000000003fffffff0000000000001ffffffffffffffffc
     ;text00
     HEX 00000ff00fffffffff00ff0000003ffff00007fe
     ;text01
     HEX 0000ffff0fffffffff0ffff00003fffffffe07fe

     ORG $F000,0 ; *************

text02
     HEX 000ffc3ff0007fe000ffc3ff0003fe0007ff07fe
text03
     HEX 007ff00ffe007fe007ff00ffe003fe3fffe007fe
text04
     HEX 01ffffffff807fe01ffffffff803fe0ffc0007fe
text05
     HEX 0ffe00007ff07fe0ffe00007ff03fe007fe007fe
text06
     HEX 3ff000000ffc7fe3ff000000ffc3fe0003ff07fe
text07
     HEX 0000000000000000000000000000000000000000
text08
     HEX 0ffffff87fc1ff0007ffe1fff80000fffc3fff00
text09
     HEX 00007f00fe003f81fc0000000fe03f80000001fc
text10
     HEX 000ff0003ffffe07f000000003f8fe000000007f
text11
     HEX 00fe0003f8000fe3f800000007f07f00000000fe
text12
     HEX 1fe00001fc001fc01ff80007fe0003ff0000ffc0
text13
     HEX 3c000000007f00000000ffc0000000001ff80000

     ORG $F100,0 ; *************

     ;text02
     HEX 000ffc3ff0007fe000ffc3ff0003fe0003ff07fe
     ;text03
     HEX 003ff00ffc007fe003ff00ffc003fe1ffff007fe
     ;text04
     HEX 01ffffffff807fe01ffffffff803fe0ff80007fe
     ;text05
     HEX 0ffe00007ff07fe0ffe00007ff03fe00ffc007fe
     ;text06
     HEX 3ff800001ffc7fe3ff800001ffc3fe0007ff07fe
     ;text07
     HEX 0000000000000000000000000000000000000000
     ;text08
     HEX 3ffffff83ffffe0003fffffff000007ffffffe00
     ;text09
     HEX 00007f80fc001f80fe0000001fc01fc0000003f8
     ;text10
     HEX 0007f0001ffffc07f000000003f8fe000000007f
     ;text11
     HEX 00ff0003f8000fe3f800000007f07f00000000fe
     ;text12
     HEX 0fe00001fc001fc03fe00001ff0007fc00003fe0
     ;text13
     HEX 7e00000003ffe000000ffffc00000001ffff8000

     ORG $F200,0 ; *************

     ;text02
     HEX 000ffc3ff0007fe000ffc3ff0003fe0003ff87fe
     ;text03
     HEX 003ff00ffc007fe003ff00ffc003fe0ffff807fe
     ;text04
     HEX 00ffffffff007fe00ffffffff003fe1ff00007fe
     ;text05
     HEX 07ffffffffe07fe07ffffffffe03fe01ffc007fe
     ;text06
     HEX 3ff800001ffc7fe3ff800001ffc3fe000ffe07fe
     ;text07
     HEX 0000000000000000000000000000000000000000
     ;text08
     HEX 7ffffffc3ffffe0001ffffffe000003ffffffc00
     ;text09
     HEX 00003f80fc001f80ff0000003fc01fe0000007f8
     ;text10
     HEX 0007f8001ffffc07f000000003f8fe000000007f
     ;text11
     HEX 007f0003fc001fe3f800000007f07f00000000fe
     ;text12
     HEX 0ff00001f8000fc07fc00000ff800ff800001ff0
     ;text13
     HEX fe0000000ffff800003fffff00000007ffffe000

     ORG $F300,0 ; *************

     ;text02
     HEX 0007fe7fe0007fe0007fe7fe0003fe0001ff87fe
     ;text03
     HEX 003ff00ffc007fe003ff00ffc003fe03fffc07fe
     ;text04
     HEX 00ffc003ff007fe00ffc003ff003fe1ff00007fe
     ;text05
     HEX 07ffffffffe07fe07ffffffffe03fe01ff8007fe
     ;text06
     HEX 1ff800001ff87fe1ff800001ff83fe000ffc07fe
     ;text07
     HEX 0000000000000000000000000000000000000000
     ;text08
     HEX 7ffffffc1ffffc00007fffff8000000ffffff000
     ;text09
     HEX 00003fc0fc001f807f8000007f800ff000000ff0
     ;text10
     HEX 0003f8003ffffe03f000000003f07e000000007e
     ;text11
     HEX 007f8001fc001fc3f000000003f07e000000007e
     ;text12
     HEX 07f00003f8000fe07f8000007f800ff000000ff0
     ;text13
     HEX ff0000001ffffc00007fffff8000000ffffff000

     ORG $F400,0 ; *************

     ;text02
     HEX 0007fe7fe0007fe0007fe7fe0003fe0001ff87fe
     ;text03
     HEX 001ff81ff8007fe001ff81ff8003fe00fffc07fe
     ;text04
     HEX 00ffc003ff007fe00ffc003ff003fe3ff80007fe
     ;text05
     HEX 03ffffffffc07fe03ffffffffc03fe03ff0007fe
     ;text06
     HEX 1ffc00003ff87fe1ffc00003ff83fe001ffc07fe
     ;text07
     HEX 7fe0000007fe7fe7fe0000007fe3fe0000ffe7fe
     ;text08
     HEX 7ffffffc0ffff800003fffff00000007ffffe000
     ;text09
     HEX 00001fe0fc001f807fc00000ff800ff800001ff0
     ;text10
     HEX 0003fc003ffffe03f800000007f07f00000000fe
     ;text11
     HEX 003f8001fe003fc7f000000003f8fe000000007f
     ;text12
     HEX 07f80003f8000fe0ff0000003fc01fe0000007f8
     ;text13
     HEX 7f0000003ffffe0001ffffffe000003ffffffc00

     ORG $F500,0 ; *************

     ;text02
     HEX 0007fe7fe0007fe0007fe7fe0003fe0001ff87fe
     ;text03
     HEX 001ff81ff8007fe001ff81ff8003fe003ffe07fe
     ;text04
     HEX 007fe007fe007fe007fe007fe003fe3ffe0007fe
     ;text05
     HEX 03ffffffffc07fe03ffffffffc03fe03ff0007fe
     ;text06
     HEX 1ffc00003ff87fe1ffc00003ff83fe003ff807fe
     ;text07
     HEX 7fe0000007fe7fe7fe0000007fe3fe0001ffc7fe
     ;text08
     HEX 3ffffff803ffe000000ffffc00000001ffff8000
     ;text09
     HEX 00001fe0fc001f803fe00001ff0007fc00003fe0
     ;text10
     HEX 0001fe007fc1ff03f800000007f07f00000000fe
     ;text11
     HEX 001fc000ff80ff87f000000003f8fe000000007f
     ;text12
     HEX 03f80003f8000fe0fe0000001fc01fc0000003f8
     ;text13
     HEX 7f8000007fffff0003fffffff000007ffffffe00

     ORG $F600,0 ; *************

     ;text02
     HEX 0003fe7fc0007fe0003fe7fc0003fe0001ff87fe
     ;text03
     HEX 001ff81ff8007fe001ff81ff8003fe001ffe07fe
     ;text04
     HEX 007fe007fe007fe007fe007fe003fe3fff8007fe
     ;text05
     HEX 03ffffffffc07fe03ffffffffc03fe07fe0007fe
     ;text06
     HEX 0ffc00003ff07fe0ffc00003ff03fe003ff007fe
     ;text07
     HEX 7ff000000ffe7fe7ff000000ffe3fe0001ffc7fe
     ;text08
     HEX 0ffffff000ff80000000ffc0000000001ff80000
     ;text09
     HEX 00000ff0fe003f801ff80007fe0003ff0000ffc0
     ;text10
     HEX 0000fe007f007f03f800000007f07f00000000fe
     ;text11
     HEX 001fe000ffffff87f000000003f8fe000000007f
     ;text12
     HEX 01fc0003f8000fe1fc0000000fe03f80000001fc
     ;text13
     HEX 3f800000ffc1ff8007ffe1fff80000fffc3fff00

     ORG $F700,0 ; *************

     ;text02
     HEX 0003ffffc0007fe0003ffffc0003fe0001ff87fe
     ;text03
     HEX 001ffc3ff8007fe001ffc3ff8003fe000fff07fe
     ;text04
     HEX 007fe007fe007fe007fe007fe003fe3fffc007fe
     ;text05
     HEX 01ffffffff807fe01ffffffff803fe07fc0007fe
     ;text06
     HEX 0ffc00003ff07fe0ffc00003ff03fe007ff007fe
     ;text07
     HEX 3ff000000ffc7fe3ff000000ffc3fe0003ff87fe
     ;text08
     HEX 0000000000000000000000000000000000000000
     ;text09
     HEX 00000ff07f007f000ffe001ffc0001ffc003ff80
     ;text10
     HEX 0000ff00fe003f81fc0000000fe03f80000001fc
     ;text11
     HEX 000fe0007fffff07f000000003f8fe000000007f
     ;text12
     HEX 01fe0003f8000fe1fc0000000fe03f80000001fc
     ;text13
     HEX 1fc00000fe003f800ffe001ffc0001ffc003ff80

     ; **********************************************************************
     ; ** Bios code start
     ; **********************************************************************

     ORG $F800
     
RESET
Start
     lda #$00 ; Make sure volume is off. Also INPTCTRL=0 because INPTCTRL
     sta AUDV0 ; listens to all TIA locations until locked.
     sta AUDV1

     ; Initialize the hardware
     sei
     cld
     lda #$02
     sta INPTCTRL ; enable BIOS+Maria
     ldx #$FF
     txs ; setup the 6502 stack
     lda #$7F
     sta CTRL ; disable DMA
     lda #$00
     sta BACKGRND ; black background

     ; ** Before we clear memory, here are some notes about handling RAM+ROM 
     ; ** when BIOS mode is enabled...
     ; ** 
     ; ** The BIOS ROM and Cart-ROM are banked via INPTCTRL. When INPTCTRL is
     ; ** set to BIOS-enabled, the Cart doesn't see the address lines 
     ; ** A12+A14+A15.
     ; ** 
     ; ** This forces many high addresses to appear very-low to the cart, but 
     ; ** also has side-effects:
     ; **
     ; ** -the BIOS can't access RAM below $2000 without bus-conflict with
     ; ** VCS carts and the CC2. If the VCS carts are ARM based, the conflicts
     ; ** seem to cause the ARM to crash.
     ; **
     ; ** -the 6502 can't access BIOS ROM from Cxxx or Dxxx while a cart is
     ; ** plugged-in, or else the cart will see it as a request for 0xxx. 
     ; ** This isn't a big for a ROM-based cart, but it will bus conflict with 
     ; ** any carts that respond to 0xxx. I'm looking at you, CC2, but it could
     ; ** could also mess with homebrew devices in the 450-45F range.

     ; ** Clear 2000-27FF, pg0+pg1 memory.
ClearMemPages
     lda #0
     tay ; y=0
     sta Temp1Lo
     ldx #$20
ClearMemPagesLoop
     stx Temp1Hi ; needed here for when we step on ZP memory
     sta (Temp1Lo),y ;Store data
     iny ;Next byte
     bne ClearMemPagesLoop
     inx
     cpx #$28
     bne ClearMemPagesLoop

     ; ** Copy the 2600 Bootstrap to RIOT RAM
     ldx #$7F
Copy2600CodeLoop
     lda Start2600,x
     sta $0480,x
     dex
     bpl Copy2600CodeLoop

     ; ** Setup the in-memory cart-check and in-memory 7800 cart-execute
     ldy #0
SetupCartCheckLoop
     lda CartCheckRom,y
     sta CartCheckRam,y
     dey
     bne SetupCartCheckLoop

     ; ** Clear TIA+MARIA registers
     lda #$00
     tax
Load7800CartClearLoop
     sta $01,x
     inx
     cpx #$2C
     bne Load7800CartClearLoop

     ; ** Re-set INPTCTRL, because the TIA register clear also hit INPTCTRL
     lda #$02
     sta INPTCTRL

     lda #$FF
     ldx #$3F
Load7800CartClearLoop2
     sta $2000,x
     sta $2100,x
     dex
     bpl Load7800CartClearLoop2

     ; ** Check the underlying cart and set CartTypeDetected
     jmp CartCheckRam

CartReturnFromRam

     ; ** Check if a 2600 cart is inserted. If so, run it right away, no fuji
     lda CartTypeDetected
     cmp #1
     bne skipGoto2600mode
     jmp Goto2600mode
skipGoto2600mode

     ; ** setup the BIOS NMI pointer while DMA is still off.
     lda #<BIOSNMI
     sta NMIRoutine
     lda #>BIOSNMI
     sta NMIRoutineHi

     ; ** copy DL objects from ROM into RAM
     ldy #0
CopyDLRom
     lda DLROM,y
     sta DlRam+24,y
     iny
     cpy #(DLROMEND-DLROM)
     bne CopyDLRom

     ; ** copy DLL from ROM into RAM, but keep the logo hidden for the wipe
     lda #12
     sta WipeLevel
     jsr UpdateDLLRom

     ; **********************************************************************
     ; ** Start the display, and do the main loop.
     ; **********************************************************************

     jsr WaitForVblankEnd
     jsr WaitForVblankStart

     lda #>DllRam
     sta DPPH
     lda #<DllRam
     sta DPPL
     lda #%01000011 ; enable DMA, RM=320A/C
     sta CTRL

     lda #$0f
     sta P0C2 
     sta P1C2 
     
Main
MainLoop

     ; ** We're at the top of vblank, so we can modify the DL to perform the 
     ; ** wipe.
     ldy #0 ; fade-in
     lda FrameCounter32
     beq contWipeUpdate
     ldy #1 ; fade-out
     cmp #(DISPLAYTIME-1)
     beq contWipeUpdate
     jmp skipWipeUpdate
contWipeUpdate
     lda FrameCounter
     lsr
     bcs skipWipeUpdate
     and #15
     eor WipeDirTable,y
     sta WipeLevel

     jsr UpdateDLLRom
skipWipeUpdate

LeaveLoaderCheck
     ; ** react to B+W to skip the fuji
     lda SWCHB
     and #%00001000
     bne CheckFrameCounter
     jmp LeaveLoader
CheckFrameCounter
     ; ** Check if the display time has expired...
     lda FrameCounter32
     cmp #DISPLAYTIME
     bne skipLeaveLoader
     jmp LeaveLoader
skipLeaveLoader

     jsr WaitForVblankEnd

     ; *** We're at the top of the visible screen
     ; *** ...but we have nothing to do here.

     jsr WaitForVblankStart

     jmp MainLoop

WipeDirTable
     .byte 15,0

     ; ** Utility routines

LeaveLoader
     ; ** Leave the loader and launch the cart or BIOS game, 
     ; ** depending on CartTypeDetected

     lda #$60
     sta CTRL
     sta WSYNC

     lda CartTypeDetected
     bne skipGameStart
     sta $8000
     ; If we're here, no cart is inserted.
     jmp GameStart
skipGameStart

     ; If we're here, a 7800 cart is inserted
     jmp Load7800CartRam

Load7800CartRam     = (Load7800CartRom - CartCheckRom + CartCheckRam) 

     ; The ROM routine we use to check the underlying cart type.
     ; Don't use JMP or JSR in here, except to exit back to ROM.
CartCheckRom
     lda #$06 
     sta INPTCTRL ; switch to cart rom

     lda #$00
     sta CartTypeDetected

     ; Do Rom checks and set CartTypeDetected:
     ; 0 = no cart
     ; 1 = 2600
     ; 2 = 7800

     ; ** Start with this 2600 test first. The others seem to reliably crash
     ; ** ARM based carts...

     lda $1BEA ; see if the 4k mirror ROM is interfering with Maria RAM
     eor #$FF
     sta $1BEA
     tay 
     cpy $1BEA 
     bne Set2600CartMode

     ; ** Then move on to empty cart tests...

     ldy #$FF ;Compare FE00-FE7F with FE80-FEFF
     ldx #$7F ;if they aren't the same start internal game
CompareMemoryLoop
     lda $FE00,x ; first iteration is $FE7F ($FE00 + $7F)
     cmp $FD80,y ; first iteration is $FE7F ($FD80 + $FF)
     bne CartCheckRomReturn
     dey ;
     dex ;
     bpl CompareMemoryLoop
     
     lda $FFFC ;If reset vector contains $FFFF
     and $FFFD ;start internal game
     cmp #$FF ;
     beq CartCheckRomReturn
     
     lda $FFFC ;If reset vectore contains $0000
     ora $FFFD ;start internal game
     beq CartCheckRomReturn

     ; ** Then back to the 2600 tests...

     lda $FFF8 ;Check region verification
     ora #$FE 
     cmp #$FF
     bne Set2600CartMode

     lda $FFF8 
     eor #$F0
     and #$F0
     bne Set2600CartMode

     lda $FFF9 ;Check ROM start
     and #$0B 
     cmp #$03 
     bne Set2600CartMode
     
     lda $FFF9 ;If ROM start page <4 branch
     and #$F0 ; 
     cmp #$40 ; 
     bcc Set2600CartMode ;Start 2600 mode? 

     sbc #$01 
     cmp $FFFD 
     bcs Set2600CartMode ;Start 2600 mode?

     ldx #$05
CompareMemoryLoop2
     lda $FFFA,x
     cmp $DFFA,x ; If it's a 2600 cart, the 6502 vectors.
     bne Set7800CartMode ; will match at FFFx, DFFx, BFFx, etc.. 
     cmp $BFFA,x ; Checking multiple mirrors may seem 
     bne Set7800CartMode ; excessive, but Galaga has a copy of
     cmp $9FFA,x ; it's cart vectors at DFFx.
     bne Set7800CartMode
     cmp $7FFA,x
     bne Set7800CartMode
     cmp $5FFA,x
     bne Set7800CartMode
     dex
     bpl CompareMemoryLoop2
     bmi Set2600CartMode ; always taken

Set7800CartMode
     inc CartTypeDetected
Set2600CartMode
     inc CartTypeDetected

CartCheckRomReturn
     lda #$02 ; switch back to BIOS rom
     sta INPTCTRL ; switch to cart rom
     jmp CartReturnFromRam

Load7800CartRom
     ; We set the 6502 state similar to when leaving the NTSC BIOS.

     lda #$FF
     sta $40
     sta $41
     sta $42
     sta $43
     sta $44
     sta $45
     sta $46
     sta $47
     sta $48

     lda #$60
     sta CTRL

Load7800CartWait
     bit MSTAT
     bpl Load7800CartWait

     ldx #$06 ; both the NTSC and PAL BIOS do the rather odd init below.
     stx INPTCTRL
     ldx #$FF
     txs
     cld
     jmp ($FFFC)

Goto2600mode
     lda #$02
     sta $01
     jmp $0480 ;Execute 2600 Cart
     
WaitForVblankEnd
     bit MSTAT
     bmi WaitForVblankEnd
     rts
WaitForVblankStart
     bit MSTAT
     bpl WaitForVblankStart
     rts

UpdateDLLRom
     ldy #(DLLROMEND-DLLROM-1)
CopyDLLRom
     lda DLLROM,y
     sta DllRam,y
     dey
     bpl CopyDLLRom

     ; ** Routine to blank the DLs for wipe reveal. WipeLevel ranges from 0 
     ; ** to 12

BlankDLRom
     ldy #0
     ldx #(22*3)
     lda WipeLevel
     asl
     adc WipeLevel
     sta Temp1 ; Temp1 = WipeLevel * 3
BlankDLRomLoop
     cpy Temp1
     beq BlankEnd
     lda #>BLANKDL
     sta DllRam+VISIBLEOFFSET+1,y
     sta DllRam+VISIBLEOFFSET-2,x
     lda #<BLANKDL
     sta DllRam+VISIBLEOFFSET+2,y
     sta DllRam+VISIBLEOFFSET-1,x
     dex
     dex
     dex
     iny
     iny
     iny
     jmp BlankDLRomLoop
BlankEnd
     rts


     ; ************** DLL data ******

DLLROM

     ; Overscan lines: 25
     .byte $0F ; 16 lines
     .byte >BLANKDL
     .byte <BLANKDL

     .byte $07 ; 8 lines
     .byte >BLANKDL
     .byte <BLANKDL

     .byte $80 ; 1 line, with NMI
     .byte >BLANKDL
     .byte <BLANKDL

VISIBLEStart
VISIBLEOFFSET     = (VISIBLEStart-DLLROM)

     ; Visible lines: 192

DLMEMVAL     SET DlRam
BLANKDL     = DLMEMVAL + 10 ; first visible DL terminator used for blank zones
     echo " ** DL Memory Start: ",(DLMEMVAL)
     REPEAT 24
     .byte $07 ; 8 lines
     .byte >DLMEMVAL
     .byte <DLMEMVAL
DLMEMVAL     SET DLMEMVAL + 12 ; 12 = 2x5-byte objects + 2-byte terminator
     REPEND
     echo " ** DL Memory End: ",(DLMEMVAL-1) 
     echo " ** DL Memory Size: ",(DLMEMVAL-1-DlRam)

VISIBLEEND
VISIBLESIZE     = (VISIBLEEND-VISIBLEStart)

     ; More overscan lines: 80

     REPEAT 5
     .byte $0F ; 16 lines
     .byte >BLANKDL
     .byte <BLANKDL
     REPEND

     ; Total provided lines = 25 + 192 + 80 = 297
     ; Required, NTSC:243, PAL:293

DLLROMEND

     echo " ** DLL ROM Start: ",(DLLROM)
     echo " ** DLL ROM End: ",(DLLROMEND)
     echo " ** DLL ROM Size: ",(DLLROMEND-DLLROM)d

DLROM
     ; zone 0
     .byte <fuji00,$40,>fuji00,$09,$04
     .byte $00,$00,$00,$00,$00
     .byte $00,$00

     ; zone 1
     .byte <fuji01,$40,>fuji01,$09,$04
     .byte $00,$00,$00,$00,$00
     .byte $00,$00

     ; zone 2
     .byte <fuji02,$40,>fuji02,$09,$04
     .byte <text00,$40,>text00,$2c,$4c
     .byte $00,$00

     ; zone 3
     .byte <fuji03,$40,>fuji03,$09,$04
     .byte <text01,$40,>text01,$2c,$4c
     .byte $00,$00

     ; zone 4
     .byte <fuji04,$40,>fuji04,$09,$04 
     .byte <text02,$40,>text02,$2c,$4c
     .byte $00,$00

     ; zone 5
     .byte <fuji05,$40,>fuji05,$09,$04
     .byte <text03,$40,>text03,$2c,$4c
     .byte $00,$00

     ; zone 6
     .byte <fuji06,$40,>fuji06,$09,$04
     .byte <text04,$40,>text04,$2c,$4c
     .byte $00,$00

     ; zone 7
     .byte <fuji07,$40,>fuji07,$09,$04
     .byte <text05,$40,>text05,$2c,$4c
     .byte $00,$00

     ; zone 8
     .byte <fuji08,$40,>fuji08,$09,$04
     .byte <text06,$40,>text06,$2c,$4c
     .byte $00,$00

     ; zone 9
     .byte <fuji09,$40,>fuji09,$09,$04
     .byte <text07,$40,>text07,$2c,$4c
     .byte $00,$00

     ; zone 10
     .byte <fuji10,$40,>fuji10,$09,$04
     .byte <text08,$40,>text08,$2c,$4c
     .byte $00,$00

     ; zone 11
     .byte <fuji11,$40,>fuji11,$09,$04
     .byte <text09,$40,>text09,$2c,$4c
     .byte $00,$00

     ; zone 12
     .byte <fuji12,$40,>fuji12,$09,$04
     .byte <text10,$40,>text10,$2c,$4c
     .byte $00,$00

     ; zone 13
     .byte <fuji13,$40,>fuji13,$09,$04
     .byte <text11,$40,>text11,$2c,$4c
     .byte $00,$00

     ; zone 14
     .byte <fuji14,$40,>fuji14,$09,$04
     .byte <text12,$40,>text12,$2c,$4c
     .byte $00,$00

     ; zone 15
     .byte <fuji15,$40,>fuji15,$09,$04
     .byte <text13,$40,>text13,$2c,$4c
     .byte $00,$00

     ; zone 16
     .byte <fuji16,$40,>fuji16,$09,$04
     .byte $00,$00,$00,$00,$00
     .byte $00,$00

     ; zone 17
     .byte <fuji17,$40,>fuji17,$09,$04
     .byte $00,$00,$00,$00,$00
     .byte $00,$00

     ; zone 18
     .byte <fuji18,$40,>fuji18,$09,$04
     .byte $00,$00,$00,$00,$00
     .byte $00,$00

     ; zone 19
     .byte <fuji19,$40,>fuji19,$09,$04
     .byte $00,$00,$00,$00,$00
     .byte $00,$00

DLROMEND

NMI

     jmp (NMIRoutine)

BIOSNMI
     pha
     tya
     pha
     txa
     pha
     cld

     inc FrameCounter
     lda FrameCounter
     and #31
     bne SkipFrameCounter32Update
     inc FrameCounter32
SkipFrameCounter32Update

     lda FrameCounter
     and #3
     bne SkipFujiColorIncrement
     inc FujiColor
SkipFujiColorIncrement

     ldy #192
     ldx FujiColor
FujiColorsLoop
     stx WSYNC
     stx P0C2
     inx
     dey
     bne FujiColorsLoop
     
     ; restore the registers 
     pla
     tax
     pla
     tay
     pla
     rti

IRQ
     RTI

     ; **********************************************************************
     ; *** The 2600 Boot Loader. Actually runs from $480.
     ; **********************************************************************

Start2600
     lda #$00
     tax 
     sta $01 ;Turn off MARIA
Start2600_LOOPCLEARTIA
     sta $03,x ;Clear TIA registers
     inx ;
     cpx #$2A ;
     bne Start2600_LOOPCLEARTIA
     sta $02 ;WSYNC
     lda #$04
     nop 
     bmi Start2600_BRANCH2 
     ldx #$04
Start2600_LOOP2
     dex 
     bpl Start2600_LOOP2
     txs 
     sta $0110
     jsr $04CB
     jsr $04CB
     sta $11
     sta $1B
     sta $1C
     sta $0F
     nop 
     sta $02
     lda #$00
     nop 
     bmi Start2600_BRANCH2
     bit $03
     bmi Start2600_BRANCH3
Start2600_BRANCH2
     lda #$02
     sta $09
     sta $F112
     bne Start2600_BRANCH4
Start2600_BRANCH3
     bit $02
     bmi Start2600_BRANCH5
     lda #$02
     sta $06
     sta $F118
     sta $F460
     bne Start2600_BRANCH4
Start2600_BRANCH5
     sta $2C
     lda #$08
     sta $1B
     jsr $04CB
     nop 
     bit $02
     bmi Start2600_BRANCH2
Start2600_BRANCH4
     lda #$FD
     sta $08
     jmp ($FFFC)

     jsr $F444
     lda $82
     bpl Start2600_BRANCH6
     lda #$00
Start2600_BRANCH6
     asl
     asl
     clc 
     adc $83
     sta $55
     lda #$01
     rts 
     ;END OF CODE AT $480

     ORG $FC00
     
     ; **********************************************************************
     ; ** Second game block. There's just under 1k of extra game data that
     ; ** can go here. If your 8k game doesn't need it, you can skip it.
     ; **********************************************************************
     incbin "kiloparsec.bl2"

GameStart
     ; Starts Internal Game
     LDA #$13 ;LOCK IN MARIA MODE
     STA INPTCTRL
     jsr GameStart_SCREENOF
GameStart_01
     bit MSTAT
     bmi GameStart_01

     jmp $CBCC ;Entry Point of Game

GameStart_SCREENOF
     BIT MSTAT ;IS VBLANK ENDED YET?
     BMI GameStart_SCREENOF
GameStart_SCREENON
     BIT MSTAT ;IS VBLANK STARTED YET?
     BPL GameStart_SCREENON
     RTS

     echo " **",($FFF7-*)d,"bytes of BIOS ROM free."

     echo " *****************************************************************" 

     ; ** 7800 bytes and 6502 vectors

     ORG $FFF8
     .byte $FF ;Region verification
     .byte $F7 ;ROM checksum $f000-$ffff
     .word NMI
     .word RESET
     .word IRQ
