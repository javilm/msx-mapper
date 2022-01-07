; bin2str.as - Convert binary numbers to (hexa)decimal ASCII strings

		; Binary to hexadecimal
		global	bin2hex4	; 4-bit bin to hex (A-F)
		global	bin2hex8	; 8-bit bin to hex (00-FF)
		global	bin2hex16	; 16-bit bin to hex (0000-FFFF)

		; Binary to decimal
		global	bin2dec8	; 8-bit bin to dec (__0-255)
		global	bin2dec16	; 16-bit bin to dec (____0-65535)

; --- CODE SEGMENT ---

		cseg

; bin2hex4 - 4-bit binary to ASCII conversion
;
; This routine converts the 4-bit value contained in the lower nibble of
; register A into a 1-byte hexadecimal character. The caller is responsible
; for allocating the output byte. The upper nibble of A is ignored.
; If A is between 0-9 this routine can also be used to convert into a single
; decimal digit.
;
; Input:	A	Binary value to convert
;		DE	Pointer to the output buffer
; Output:	Buffer pointed to by DE filled with an (hexa)decimal digit
; Modifies:	AF, BC, DE, HL

bin2hex4:	ld	b,0

		; Use only the lower nibble in A
		and	000001111b
		ld	c,a
		ld	hl,hexdigits
		add	hl,bc
		ld	a,(hl)
		ld	(de),a

		ret

; bin2hex8 - 8-bit binary to ASCII conversion
;
; This routine converts the 8-bit value contained in register A into a 2-byte
; hexadecimal string. The caller is responsible for allocating the 2-byte
; output buffer
;
; Input:	A	Binary value to convert
;		DE	Pointer to the output buffer
; Output:	Buffer pointed to by DE filled with two hexadecimal digits
; Modifies:	AF, BC, DE, HL

bin2hex8:	push	af
		ld	b,0

		; First digit (upper 4 bits of A)
		and	011110000b
		rlca
		rlca
		rlca
		rlca
		ld	c,a
		ld	hl,hexdigits
		add	hl,bc
		ld	a,(hl)
		ld	(de),a
		inc	de

		; Second digit (lower 4 bits of A)
		pop	af
		and	000001111b
		ld	c,a
		ld	hl,hexdigits
		add	hl,bc
		ld	a,(hl)
		ld	(de),a

		ret

; bin2hex16 - 16-bit binary to ASCII conversion
;
; This routine converts the 16-bit value contained in register HL into a 4-byte
; hexadecimal string. The caller is responsible for allocating the output
; buffer.
;
; Input:	HL	Binary value to convert
;		DE	Pointer to the output buffer
; Output:	Buffer pointed to by DE filled with four hexadecimal digits
; Modifies:	AF, BC, DE, HL
; Notes:	Calls bin2hex2 twice and takes advantage of the fact that DE
;		is incremented during the call to that function.

bin2hex16:	push	hl

		; Most significant byte (contained in H)
		ld	a,h
		call	bin2hex8

		pop	hl
		inc	de	; bin2hex increments DE only once, so we need
				; to increment it again to point to the third
				; character.

		; Least significant byte (contained in L)
		ld	a,l
		call	bin2hex8

		ret

; bin2dec8 - 8-bit binary to ASCII decimal string (0-255)
;
; Converts the 8-bit value contained in register A into a 3-character decimal
; string. The caller must allocate the output buffer. Right-justified and
; leading zeroes represented as the filler character passed in E.
;
; Input:	A	Binary value to convert
;		HL	Pointer to output buffer
;		E	Filler character for leading zeroes
; Output:	Buffer filled with 3 characters representing the binary value
; Modifies:	AF, BC, DE, HL
; Notes:	No effort done to optimize for special cases such as the input
;		value being already 0.

bin2dec8:	ld	d,0		; Use D as a flag to determine whether
					; to output the filler character (D=0)
					; or a digit (D=1)

		ld	c,100		; Hundreds
		call	bin2dec8.do
		ld	c,10		; Tens
		call	bin2dec8.do
		ld	c,1		; Singles
		ld	d,1		; Last zero must always be output even
					; if leading.
bin2dec8.do:	ld	b,"0"-1
bin2dec8.l:	inc	b
		sub	c
		jr	nc,bin2dec8.l

		; 1) Restore value in A
		add	a,c

		; 2) If D=1 then put B in (HL)
		bit	0,d	
		jr	z,bin2dec8.out1	; Z: put E, NZ: put B
		ld	(hl),b
		jr	bin2dec8.out3

		; 3) If B="0" then put E in (HL)
bin2dec8.out1:	push	af
		ld	a,b
		cp	"0"
		jr	nz,bin2dec8.out2
		pop	af
		ld	(hl),e
		jr	bin2dec8.out3

		; 4) Else (when B>"0") set D to 1, put B in (HL)
bin2dec8.out2:	pop	af
		ld	d,1
		ld	(hl),b

		; Increment HL and return
bin2dec8.out3:	inc	hl
		ret

; bin2dec16 - 16-bit binary to ASCII decimal string (0-65535)
;
; Converts the 16-bit value contained in register HL into a 5-character decimal
; string. The caller must allocate the output buffer. Right-justified and
; leading zeroes represented as spaces.
;
; Input:	HL	Binary value to convert
;		IX	Pointer to the output buffer
;		E	Filler character for leading zeroes
; Output:	Buffer filled with 5 characters representing the binary value
; Modifies:

bin2dec16:	; Prefill the output buffer with the filler character
		push	hl	; Save the binary value stored in HL

		push	ix	; = ld hl,ix
		pop	hl	;

		ld	(hl),e

		push	ix	; = ld de,ix
		pop	de	;
		inc	de

		ld	bc,4
		ldir

		pop	hl	; Restore the binary value in HL

		; Use bit 0 of register C as a flag. As long as it is still
		; zero this routine will output the filler character instead of
		; leading zeroes.
		ld	c,0

		ld	de,10000	; Tens of thousands
		call	bin2dec16.do
		ld	de,1000	; Thousands
		call	bin2dec16.do
		ld	de,100		; Hundreds
		call	bin2dec16.do
		ld	de,10		; Tens
		call	bin2dec16.do
		; XXX here we have to set the flag that indicates that we are
		; outputting digits. The last zero must be always output even
		; if it's leading.
		ld	c,1		; Make sure output flag is set
		ld	de,1		; Singles
bin2dec16.do:	ld	b,"0"-1
		scf			; Make sure carry is reset before						; entering the loop
		ccf
bin2dec16.l:	inc	b
		sbc	hl,de
		jr	nc,bin2dec16.l

bin2dec16.out:	; Restore value in HL
		add	hl,de

		; 1) Test whether we're still outputting leading zeroes (C=0).
		; If no (NZ) then we go to o4.
bin2dec16.o1:	bit 	0,c
		jr	nz,bin2dec16.o4

		; 2) Test whether B is "0". If yes then go to o5 (but restore
		;    the value in A first).
		push	af
		ld	a,b
		cp	"0"
		jr	z,bin2dec16.o2
		pop	af
		; 3) Set C to 1
		ld	c,1
		jr	bin2dec16.o4

bin2dec16.o2:	pop	af
		jr	bin2dec16.o5

		; 4) Write character in B to (IX+0)
bin2dec16.o4:	ld	(ix+0),b

		; 5) Increment IX pointer adn return
bin2dec16.o5:	inc	ix
		ret

; --- DATA SEGMENT ---

		dseg

hexdigits:	defb	"0123456789ABCDEF"
