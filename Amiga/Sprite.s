custom        equ    $DFF000
bplcon0       equ    $100
bplcon1       equ    $102
bplcon2       equ    $104
bpl1mod       equ    $108
ddfstrt       equ    $092
ddfstop       equ    $094
diwstrt       equ    $08E
diwstop       equ    $090
copjmp1       equ    $088
cop1lc        equ    $080
dmacon        equ    $096
sprptr        equ    $120

COLOR00       equ    $180
COLOR01       equ    COLOR00+$02
COLOR17       equ    COLOR00+$22
COLOR18       equ    COLOR00+$24
COLOR19       equ    COLOR00+$26

BPL1PTH       equ    $0E0 
BPL1PTL       equ    BPL1PTH+$02
SPR0PTH       equ    sprptr+$00
SPR0PTL       equ    SPR0PTH+$02
SPR1PTH       equ    sprptr+$04
SPR1PTL       equ    SPR1PTH+$02
SPR2PTH       equ    sprptr+$08
SPR2PTL       equ    SPR2PTH+$02
SPR3PTH       equ    sprptr+$0C
SPR3PTL       equ    SPR3PTH+$02
SPR4PTH       equ    sprptr+$10
SPR4PTL       equ    SPR4PTH+$02
SPR5PTH       equ    sprptr+$14
SPR5PTL       equ    SPR5PTH+$02
SPR6PTH       equ    sprptr+$18
SPR6PTL       equ    SPR6PTH+$02
SPR7PTH       equ    sprptr+$1C 
SPR7PTL       equ    SPR7PTH+$02

SHIPSPRITE    equ    $25000
DUMMYSPRITE   equ    $30000
COPPERLIST    equ    $20000
BITPLANE1     equ    $21000

; DEFINE BITPLANE1
       lea    custom,a0
       move.w #$1200,bplcon0(a0)
       move.w #$0000,bpl1mod(a0)
       move.w #$0000,bplcon1(a0)
       move.w #$0024,bplcon2(a0)
       move.w #$0038,ddfstrt(a0)
       move.w #$00D0,ddfstop(a0)

; define display window
       move.w #$3C81,diwstrt(a0)
       move.w #$FFC1,diwstop(a0)

; put rgb constant
       move.w #$000F,COLOR00(a0)
       move.w #$0000,COLOR01(a0)
       move.w #$0FF0,COLOR17(a0)
       move.w #$00FF,COLOR18(a0)
       move.w #$0F0F,COLOR19(a0)

; copy copper list
       move.l #COPPERLIST,a1
       lea    copperl(pc),a2 
cloop:
       move.l (a2)+,(a1)+
       cmp.l  #-1,(a2)
       bne    cloop

; copy sprite to addresses
       move.l #SHIPSPRITE,a1
       lea    sprite(pc),a2
sprloop:
       move.l (a2),(a1)+
       cmp.l  #$00000000,(a2)+
       bne    sprloop

; all 8 sprites are activated
; write blank sprite to dummy
       move.l #$00000000,DUMMYSPRITE

; point copper at list data
       move.l #COPPERLIST,cop1lc(a0)

gameloop:
; fill bitplane pixels
       move.l #BITPLANE1,a1
       move.w #1999,D0
floop:
       move.l #$FFFFFFFF,(a1)+
       dbf    D0,floop

; start DMA
       move.w D0,copjmp1(a0)
       move.w #$83A0,dmacon(a0)

; here will be the game logic

  jmp  gameloop

  ; copper list for one bitplane and 8 sprites
copperl:
       dc.w   BPL1PTH,$0002
       dc.w   BPL1PTL,$1000
       dc.w   SPR0PTH,$0002
       dc.w   SPR0PTL,$5000
       dc.w   SPR1PTH,$0003
       dc.w   SPR1PTL,$0000
       dc.w   SPR2PTH,$0003
       dc.w   SPR2PTL,$0000
       dc.w   SPR3PTH,$0003
       dc.w   SPR3PTL,$0000
       dc.w   SPR4PTH,$0003
       dc.w   SPR4PTL,$0000
       dc.w   SPR5PTH,$0003
       dc.w   SPR5PTL,$0000
       dc.w   SPR6PTH,$0003
       dc.w   SPR6PTL,$0000
       dc.w   SPR7PTH,$0003
       dc.w   SPR7PTL,$0000
       dc.w   $FFFF,$FFFE 

; sprite data stores x,y
sprite:
       dc.w   $6DA0,$7200
       dc.w   $0000,$33CC
       dc.w   $FFFF,$0FF0
       dc.w   $0000,$3C3C 
       dc.w   $0000,$0FF0 

       dc.w   $0000,$0000