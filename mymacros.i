	ifnd	NDEBUG
        XREF	_kprintf
        endc
        
        IFND _LVORawDoFmt
_LVORawDoFmt    	EQU     -522
        ENDC
        
_LVORawPutChar		EQU	-516	* Private function in Exec
_LVORawMayGetChar	EQU	-510
_AbsExecBase		EQU  	4
        
	XDEF _LVORawPutChar
	XDEF _LVORawDoFmt
	XDEF _LVORawMayGetChar
	XDEF _AbsExecBase
	
DEBUG	EQU	1

DBUG	macro
	ifnd	NDEBUG

	; save all regs
	movem.l	d0/d1/a0/a1,-(a7)
	IFGE	NARG-9
		move.l	\9,-(sp)		; stack arg8
	ENDC
	IFGE	NARG-8
		move.l	\8,-(sp)		; stack arg7
	ENDC
	IFGE	NARG-7
		move.l	\7,-(sp)		; stack arg6
	ENDC
	IFGE	NARG-6
		move.l	\6,-(sp)		; stack arg5
	ENDC
	IFGE	NARG-5
		move.l	\5,-(sp)		; stack arg4
	ENDC
	IFGE	NARG-4
		move.l	\4,-(sp)		; stack arg3
	ENDC
	IFGE	NARG-3
		move.l	\3,-(sp)		; stack arg2
	ENDC
	IFGE	NARG-2
		move.l	\2,-(sp)		; stack arg1
	ENDC

PULLSP	SET	(NARG)<<2		
	pea.l	.n1\@
	jsr	_kprintf
	lea.l	PULLSP(sp),sp			
	movem.l	(a7)+,d0/d1/a0/a1
	bra.s	.n2\@

.n1\@	dc.b	\1,0
	cnop	0,2
.n2\@
	endc
	endm
