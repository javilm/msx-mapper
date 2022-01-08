; mapper.as : Test the mapper support routines

		.z80

		include		dos2func.inc

		; External routines
		external	bin2hex4
		external	bin2hex16
		external	bin2dec8
		external	bin2dec16

BDOS		equ	00005h
HOKVLD		equ	0fb20h
EXTBIO		equ	0ffcah

; Macro to execute MSX-DOS2 system calls
system		macro	func
		ld	c,func
		call	BDOS
		endm

		cseg

mapper:		; Check for extended BIOS supoprt
		ld	a,(HOKVLD)
		and	000000001b
		jr	nz,mapper.1	; Z:  No extended BIOS detected
					; NZ: Extended BIOS detected
		; Z
		ld	l,1		; Terminate w/error: no extended BIOS
		jp	exit
		; NZ
mapper.1:	; Get address of the mapper variables table via a call to
		; the extended BIOS
		xor	a		; A=0
		ld	de,00401h	; D=4, E=1
		call	EXTBIO
		ld	(pri_mapp_slt),a
		ld	(p_mapper_tbl),hl

		; Count and print the total amount of memory in the mappers
		; as detected by MSX-DOS2
		call	count_ram_s
		call	print_tot_ram

		; Print the "Memory mappers detected by MSX-DOS2" string:
		ld	de,str4
		system	_STROUT

		; Print information on all the mappers detected by MSX-DOS2
		ld	ix,(p_mapper_tbl)
mapper.loop:	ld	a,(ix+0)
		or	a
		jr	z,mapper.end	; Z: no more mappers, NZ: more mappers

		call	mapper_info	; This routine doesn't change IX

		ld	bc,8		; Skip to the next entry
		add	ix,bc

		jr	mapper.loop	; Repeat while there are more mappers

		; Terminate program
mapper.end:	system	_TERM0

; count_ram_s - Count the total amount of 16Kb RAM segments in the system (as
; detected by MSX-DOS2).
; Input:	None
; Output:	(total_ram_s)	Filled with the total number of RAM segments
;		(sys_ram_s)	Filled with the number of segments allocated to
;				the operating system
;		(user_ram_s)	Filled with the number of segments allocated to
;				the user
; Modifies:	AF,BC,HL,IX
;
count_ram_s:	; Initialize variables
		ld	hl,0
		ld	(total_ram_s),hl
		ld	(free_ram_s),hl
		ld	(sys_ram_s),hl
		ld	(user_ram_s),hl

		; Loop through the mapper table counting segments
		ld	ix,(p_mapper_tbl)
count_ram_s.l:	ld	a,(ix+0)	; Check whether we're walked the whole
		or	a		; table
		ret	z

		; Total number of segments
		ld	a,(ix+1)
		call	count_255
		ld	hl,(total_ram_s)
		add	hl,bc
		ld	(total_ram_s),hl

		; Number of free segments
		ld	a,(ix+2)
		call	count_255
		ld	hl,(free_ram_s)
		add	hl,bc
		ld	(free_ram_s),hl

		; Segments allocated to the system
		ld	a,(ix+3)
		call	count_255
		ld	hl,(sys_ram_s)
		add	hl,bc
		ld	(sys_ram_s),hl

		; Segments allocated to the user
		ld	a,(ix+4)
		call	count_255
		ld	hl,(user_ram_s)
		add	hl,bc
		ld	(user_ram_s),hl

		; Skip to next entry
		ld	c,8
		add	ix,bc

		jr	count_ram_s.l

; count_255 - Handle the especial case when MSX-DOS2 reports 255 segments
; instead of 256 in a 4MB memory mapper.
; Input:	A	Value of the total/free/system/user segments entry in
;			the mapper variables table for the current mapper.
; Output:	BC	Set to the correct number of 16Kb segments in the
;			mapper
; Modifies:	AF, BC
;
count_255:	cp	255
		jr	nz,count_255.1
		ld	bc,256
		ret
count_255.1:	ld	b,0
		ld	c,a
		ret

; print_tot_ram - Print the total amount of RAM segments in the memory mappers
; detected by MSX-DOS2. The variables used by this routine need to be
; initialized first by the count_ram_s routine.
; Input:	None
; Output:	String printed to output
; Modifies:	AF, HL, DE
; Notes:	This routine reads one by one the four variables total_ram_s,
;		free_ram_s, sys_ram_s and user_ram_s, multiplies them by 16 in
;		order to calculate the amount of Kb based on the number of RAM
;		segments, and converts the binary values into decimal strings,
;		then prints a string describing all the RAM detected by
;		MSX-DOS2.
;
print_tot_ram:	; Total RAM in Kb
		ld	hl,(total_ram_s)
		call	mulhl16
		ld	e,0
		ld	ix,strram.0
		call	bin2dec16

		; RAM assigned to the system
		ld	hl,(sys_ram_s)
		call	mulhl16
		ld	e,0
		ld	ix,strram.1
		call	bin2dec16

		; RAM assigned to the user
		ld	hl,(user_ram_s)
		call	mulhl16
		ld	e,0
		ld	ix,strram.2
		call	bin2dec16

		; Free RAM
		ld	hl,(free_ram_s)
		call	mulhl16
		ld	e,0
		ld	ix,strram.3
		call	bin2dec16

		; Print the string describing the RAM in system
		ld	de,strram
		system	_STROUT

		ret

; mulhl__ - Several entry points to multiply HL by 16, 8, 4, 2 via shifts.
; Input:	HL	Value to multiply
; Output:	None other than the new value in HL
; Modifies:	HL
;
mulhl16:	add	hl,hl	; Multiply HL by 16
mulhl8:		add	hl,hl	; Multiply HL by 8
mulhl4:		add	hl,hl	; Multiply HL by 4
mulhl2:		add	hl,hl	; Multiply HL by 2
		ret

		dseg

		; "Total XXXXXkb (YYYYYKb sys, ZZZZZKb user, WWWWWKb free)."
strram:		defb	"Total "
strram.0:	defs	5
		defb	"Kb ("
strram.1:	defs	5
		defb	"Kb sys, "
strram.2:	defs	5
		defb	"Kb user, "
strram.3:	defs	5
		defb	"Kb free).",13,10,"$"

total_ram_s:	defs	2	; Total of 16Kb RAM segments
free_ram_s:	defs	2	; # of free 16Kb segments
sys_ram_s:	defs	2	; # of 16Kb segments allocated to the system
user_ram_s:	defs	2	; # of 16Kb segments allocated to the user

		cseg

; mapper_info - Prints all the information for a memory mapper entry.
; Input:	IX	Pointer to the mapper entry in the mapper variables
;			table maintained by MSX-DOS2
; Output:	String printed to output.
; Modifies:	AF, BC, DE, HL
;
mapper_info:	; Print string if this is the primary mapper
		ld	a,(pri_mapp_slt)
		cp	(ix+0)
		jr	nz,mapper_info.1

		; Print "[PRIMARY] " if this is the primary mapper
		ld	de,str0
		system	_STROUT

mapper_info.1:	ld	a,(ix+0)	; "Slot X: " / "Expanded slot X-Y: "
		call	dec_slt_add

		; Print Kb in system segments
		ld	a,(ix+3)
		call	count_255
		ld	h,b
		ld	l,c
		call	mulhl16
		push	ix
		ld	ix,str5.0
		ld	e,0
		call	bin2dec16
		pop	ix

		; Print Kb in user segments
		ld	a,(ix+4)
		call	count_255
		ld	h,b
		ld	l,c
		call	mulhl16
		push	ix
		ld	ix,str5.1
		ld	e,0
		call	bin2dec16
		pop	ix

		; Print free Kb
		ld	a,(ix+2)
		call	count_255
		ld	h,b
		ld	l,c
		call	mulhl16
		push	ix
		ld	ix,str5.2
		ld	e,0
		call	bin2dec16
		pop	ix

		; Print the completed string
		ld	de,str5.0
		system	_STROUT

		ret

; dec_slt_add - Decode an slot address in binary A___BBCC format and
; print the description string:
;   "slot C" if A = 0
;   "expanded slot C-B" if A = 1
; Input:	A	Slot address to decode
; Output:	Format string str2.0 filled and printed to output
; Modifies:	AF, BC, DE, HL
;
dec_slt_add:	; Check whether the address points to a primary or an expanded
		; slot
		ld	e,a		; Save slot address in E for later
		and	010000000b
		jr	z,dec_slt_add.p	; Z if primary, NZ if expanded

dec_slt_add.e:	; The slot address represents and expanded slot
		; Decode primary slot number
		push	de		; Save the slot address stored in E
		ld	a,e
		and	000000011b	; Get two lower bits
		ld	de,str3.1	; X in "expanded slot Y-X"
		call	bin2hex4

		; Decode expanded slot number
		pop	de		; Restore slot address saved in E
		ld	a,e
		and	000001100b	; Get expanded slot from bits 3-2
		rrca
		rrca
		ld	de,str3.2	; Y in "expanded slot Y-X"
		call	bin2hex4

		; Print the full description string
		ld	de,str3.0
		system	_STROUT

		ret

dec_slt_add.p:	; The slot address represents a primary slot
		; Decode the slot number
		ld	a,e		; Restore slot address from reg E
		and	000000011b	; Get two lower bits
		ld	de,str2.1	; X in "slot X."
		call	bin2hex4

		; Print the description string
		ld	de,str2.0
		system	_STROUT

		ret

; Put an error code in L (0-127). This function will print the error message
; associated with that error and terminate the program.
; WARNING: no check done to confirm that the error code is in range.
exit:		ld	h,0
		sla	l
		ld	de,error_ptr
		add	hl,de		; HL now points to the pointer to the
					; string
		ld	e,(hl)
		inc	hl
		ld	d,(hl)		; DE now points to the string
		system	_STROUT		; Print the error message
		system	_TERM0		; Terminate

; Copy of the jump table to the mapper support routines
ALL_SEG:	defs	3
FRE_SEG:	defs	3
RD_SEG:		defs	3
WR_SEG:		defs	3
CAL_SEG:	defs	3
CALLS:		defs	3
PUT_PH:		defs	3
GET_PH:		defs	3
PUT_P0:		defs	3
GET_P0:		defs	3
PUT_P1:		defs	3
GET_P1:		defs	3
PUT_P2:		defs	3
GET_P2:		defs	3
PUT_P3:		defs	3
GET_P3:		defs	3

		dseg

pri_mapp_slt:	defs	1	; Slot address of the primary mapper
p_mapper_tbl:	defs	2	; Pointer to the mapper table

error_ptr:	defw	err_0
		defw	err_1

		; Status strings
		; "[PRIMARY] "
str0:		defb	"[PRIMARY] $"
;str1:		XXX UNUSED
		; "Slot X: "
str2.0:		defb	"Slot "
str2.1:		defs	1
		defb	": $"
		; "Expanded slot X-Y: "
str3.0:		defb	"Expanded slot "
str3.1:		defs	1
		defb	"-"
str3.2:		defs	1
		defb	": $"
str4:		defb	"Memory mappers detected by MSX-DOS2:",13,10,"$"
		; "XXXXXKb sys, YYYYYKb user, ZZZZZKb free."
str5.0:		defs	5
		defb	"Kb sys, "
str5.1:		defs	5
		defb	"Kb user, "
str5.2:		defs	5
		defb	"Kb free.",13,10,"$"
str.crlf:	defb	13,10,"$"

		; Error strings
err_0:		defb	"No error.$"
err_1:		defb	"ERROR: No extended BIOS support detected.$"

