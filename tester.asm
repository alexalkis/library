	include <dos/dos.i>
	include <dos/dosextens.i>
	include <exec/macros.i>
	include <lvo/exec_lib.i>
	include alkis_lib.i
	include "mymacros.i"

start:	
	move.l	$4.w,a6
	sub.l	a1,a1
	JSRLIB	FindTask
	move.l	d0,a5		;a5 holds our task
	moveq	#1,d0
	lea	ALKISLIBNAME(pc),a1
	JSRLIB	OpenLibrary
	DBUG	"OpenLibrary: d0=%lx\n",d0
	tst.l	d0
	beq	.didntopen
	move.l	d0,a6
	move.l	#1971,d0
	DBUG	"Pre   call: d0=%ld\n",d0
	JSRLIB	Double
	DBUG	"After call: d0=%ld\n",d0

	moveq	#1,d7
.floop
	move.l	d7,d0
	JSRLIB	Fib
	DBUG	"Fib(%ld)=%ld\n",d7,d0
	addq	#1,d7
	cmp.w	#11,d7
	bne.s	.floop
	
;;; ok, let's call the one written in C language
	move.l	#1971,d0
	JSRLIB  Triple
	DBUG	"Triple(1971)=%ld\n",d0
	
;;; close library and exit
	move.l	a6,a1
	move.l	$4.w,a6
	JSRLIB	CloseLibrary
	moveq	#0,d0
	rts

.didntopen
	DBUG "AlkisLibrary failed to open\n"
	move.l	#ERROR_INVALID_RESIDENT_LIBRARY,pr_Result2(a5)
	moveq	#20,d0
	rts
	
ALKISLIBNAME dc.b "alkis.library",0
	
