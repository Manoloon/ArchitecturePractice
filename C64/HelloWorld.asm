screenSt = $0400
screenEn = $07E7
screenPo = $8000
main:
	LDA #$02
	STA $D020		; I/O border color
	STA $D021		; I/O background color
	STA screenPo	; Screen position
loop:
	JSR $E544		; ROM routine, clears screen
	JSR drawFrame	; here is the pulp of everything
	JSR checkKeyb
	INC screenPo	; increment current screen position
	JMP loop		; do loop forever
drawFrame:
	LDX #$00		; regX tracks index of char in the string
	LDY screenPo	; regY keeps scrolling screen position
	CPY #$20		; compare Y with constant 20
	BCS resetScreenPo ; branch if Y > 20 (store in carry bit)
drawMsgLoop:
	LDA msg,X		; load the xth char of the message
	BEQ return		; exit when zero char (end of string)
	AND #$3F		; convert ASCII to PETSCII
	STA screenSt,Y	; VDU: write char in A to memorymap offset Y
	INX				; increment index of char in message
	INY				; increment location on screen
	CPY #$20		; are we trying to write offscreen?
	BCS wrapAroundY ; if so, shift offset by screen witdh
	JMP drawMsgLoop	; loop (until all chars are done)
resetScreenPo:
	LDY #$00		
	STY screenPo	; reset the screen position to 0
	JMP drawMsgLoop
wrapAroundY:		; if Y trying to write offscreen, wrap
	TYA				; transfer Y to accumulator
	SBC #$20		; substract with carry
	TAY				; transfer accumulator to Y
	JMP drawMsgLoop
checkKeyb:
	JSR $FF9F		; ROM SCANKEY IO, writes keybmatrix to 00CB
	JSR $FFE4		; ROM GETIN, convert matrix to keycode in accumulator
	CMP #65			; compare accumulator to ASCII 'A'
	BNE return
	BRK				; if 'A' pressed, quit
return:
	RTS
msg:
	.byte "HELLO C64!\0"	; this is data, not an instruction