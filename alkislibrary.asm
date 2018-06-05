*******************************************************************************************
*   sample.library.asm -- Example run-time library source code
*
*   Assemble and link, without startup code, to create Sample.library,
*     a LIBS: drawer run-time shared library
*
*  Linkage Info:
*  FROM     sample.library.o
*  LIBRARY  LIB:Amiga.lib
*  TO       sample.library
*******************************************************************************************

   SECTION   code

   NOLIST
	INCLUDE "exec/types.i"
	INCLUDE "exec/initializers.i"
	INCLUDE "exec/libraries.i"
	INCLUDE "exec/lists.i"
	INCLUDE "exec/alerts.i"
	INCLUDE "exec/resident.i"
	INCLUDE "libraries/dos.i"
	include <lvo/exec_lib.i>
	

	INCLUDE "asmsupp.i"
	INCLUDE "alkisbase.i"
	INCLUDE "alkis_rev.i"

	include mymacros.i
	
   LIST

   XDEF   InitTable                    ;------ These don't have to be external but it helps
   XDEF   Open                         ;------ some debuggers to have them globally visible
   XDEF   Close
   XDEF   Expunge
   XDEF   Null
   XDEF   LibName
   XDEF   Double
   XDEF   AddThese

   XREF   _AbsExecBase

   XLIB   OpenLibrary
   XLIB   CloseLibrary
   XLIB   Alert
   XLIB   FreeMem
   XLIB   Remove

   ; The first executable location.  This should return an error in case someone tried to
   ; run you as a program (instead of loading you as a library).
Start:
   MOVEQ   #-1,d0
   rts

;------------------------------------------------------------------------------------------
; A romtag structure.  Both "exec" and "ramlib" look for this structure to discover magic
; constants about you (such as where to start running you from...).  The include file
; sample_rev.i (created by hand or preferable with the developer tool ``bumprev''
; resolves the VERSION, REVISION, and VSTRING.
;------------------------------------------------------------------------------------------
   ; Few people will need a priority and should leave it at zero.  The RT_PRI field is used
   ; in configuring the ROMs.  Use "mods" from wack to look at other romtags in the system.
MYPRI   EQU   0

RomTag:
               ;STRUCTURE RT,0
     DC.W    RTC_MATCHWORD      ; UWORD RT_MATCHWORD
     DC.L    RomTag             ; APTR  RT_MATCHTAG
     DC.L    EndCode            ; APTR  RT_ENDSKIP
     DC.B    RTF_AUTOINIT       ; UBYTE RT_FLAGS
     DC.B    VERSION            ; UBYTE RT_VERSION  (defined in sample_rev.i)
     DC.B    NT_LIBRARY         ; UBYTE RT_TYPE
     DC.B    MYPRI              ; BYTE  RT_PRI
     DC.L    LibName            ; APTR  RT_NAME
     DC.L    IDString           ; APTR  RT_IDSTRING
     DC.L    InitTable          ; APTR  RT_INIT  table for InitResident()

   ; this is the name that the library will have
LibName:   ALKISNAME
   ; standard name/version/date ID string from bumprev-created sample_rev.i
IDString:  VSTRING

dosName:   DOSNAME

				; force word alignment
	;;    ds.w   0
	cnop 0,2

   ; The romtag specified that we were "RTF_AUTOINIT".  This means that the RT_INIT
   ; structure member points to one of these tables below.  If the AUTOINIT bit was not
   ; set then RT_INIT would point to a routine to run.

InitTable:
   DC.L   AlkisBase_SIZEOF ; size of library base data space
   DC.L   funcTable         ; pointer to function initializers
   DC.L   dataTable         ; pointer to data initializers
   DC.L   initRoutine       ; routine to run


funcTable:

   ;------ standard system routines
   dc.l   Open
   dc.l   Close
   dc.l   Expunge
   dc.l   Null

   ;------ my libraries definitions
   dc.l   Double
   dc.l   AddThese
	dc.l	Fib
	dc.l	_Triple
   ;------ function table end marker
   dc.l   -1


   ; The data table initializes static data structures.  The format is specified in
   ; exec/InitStruct routine's manual pages.  The INITBYTE/INITWORD/INITLONG routines are
   ; in the file "exec/initializers.i".  The first argument is the offset from the library
   ; base for this byte/word/long.  The second argument is the value to put in that cell.
   ; The table is null terminated.
   ; NOTE - LN_TYPE below is a correction - old example had LH_TYPE.

dataTable:
        INITBYTE        LN_TYPE,NT_LIBRARY
        INITLONG        LN_NAME,LibName
        INITBYTE        LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
        INITWORD        LIB_VERSION,VERSION
        INITWORD        LIB_REVISION,REVISION
        INITLONG        LIB_IDSTRING,IDString
        DC.L   0

   ; This routine gets called after the library has been allocated.  The library pointer is
   ; in D0.  The segment list is in A0.  If it returns non-zero then the library will be
   ; linked into the library list.

initRoutine:
	DBUG "initRoutine entered\n"
   ;------ get the library pointer into a convenient A register
   move.l   a5,-(sp)
   move.l   d0,a5

   ;------ save a pointer to exec
   move.l   a6,sb_SysLib(a5)

   ;------ save a pointer to our loaded code
   move.l   a0,sb_SegList(a5)

   ;------ open the dos library
   lea   dosName(pc),a1
   CLEAR   d0
   CALLSYS   OpenLibrary

   move.l   d0,sb_DosLib(a5)
   bne.s   1$

   ;------ can't open the dos!  what gives
   ALERT   AG_OpenLib!AO_DOSLib

1$:
   ;------ now build the static data that we need
   ;
   ; put your initialization here...
   ;

   move.l   a5,d0
   move.l   (sp)+,a5
   rts

;------------------------------------------------------------------------------------------
; here begins the system interface commands.  When the user calls OpenLibrary/CloseLibrary/
; RemoveLibrary, this eventually gets translated into a call to the following routines
; (Open/Close/Expunge).  Exec has already put our library pointer in A6 for us.  Exec has
; turned off task switching while in these routines (via Forbid/Permit), so we should not
; take too long in them.
;------------------------------------------------------------------------------------------

   ; Open returns the library pointer in d0 if the open was successful.  If the open failed
   ; then null is returned.  It might fail if we allocated memory on each open, or if only
   ; open application could have the library open at a time...

Open:      ; ( libptr:a6, version:d0 )
	
   ;------ mark us as having another opener
   addq.w   #1,LIB_OPENCNT(a6)
	DBUG "Open entered (# of times opened: %d)\n",LIB_OPENCNT(a6)
   ;------ prevent delayed expunges
   bclr   #LIBB_DELEXP,sb_Flags(a6)

   move.l   a6,d0
   rts

   ; There are two different things that might be returned from the Close routine.  If the
   ; library is no longer open and there is a delayed expunge then Close should return the
   ; segment list (as given to Init).  Otherwise close should return NULL.

Close:      ; ( libptr:a6 )

   ;------ set the return value
   CLEAR   d0

   ;------ mark us as having one fewer openers
   subq.w   #1,LIB_OPENCNT(a6)

   ;------ see if there is anyone left with us open
   bne.s   1$

   ;------ see if we have a delayed expunge pending
   btst   #LIBB_DELEXP,sb_Flags(a6)
   beq.s   1$

   ;------ do the expunge
   bsr   Expunge
1$:
   rts

   ; There are two different things that might be returned from the Expunge routine.  If
   ; the library is no longer open then Expunge should return the segment list (as given
   ; to Init).  Otherwise Expunge should set the delayed expunge flag and return NULL.
   ;
   ; One other important note: because Expunge is called from the memory allocator, it may
   ; NEVER Wait() or otherwise take long time to complete.

Expunge:   ; ( libptr: a6 )
	DBUG "Expunge called\n"
   movem.l   d2/a5/a6,-(sp)
   move.l   a6,a5
   move.l   sb_SysLib(a5),a6

   ;------ see if anyone has us open
   tst.w   LIB_OPENCNT(a5)
   beq   1$

   ;------ it is still open.  set the delayed expunge flag
   bset   #LIBB_DELEXP,sb_Flags(a5)
   CLEAR   d0
   bra.s   Expunge_End

1$:
   ;------ go ahead and get rid of us.  Store our seglist in d2
   move.l   sb_SegList(a5),d2

   ;------ unlink from library list
   move.l   a5,a1
   CALLSYS   Remove

   ;
   ; device specific closings here...
   ;

   ;------ close the dos library
   move.l   sb_DosLib(a5),a1
   CALLSYS   CloseLibrary

   ;------ free our memory
   CLEAR   d0
   move.l   a5,a1
   move.w   LIB_NEGSIZE(a5),d0

   sub.l   d0,a1
   add.w   LIB_POSSIZE(a5),d0

   CALLSYS   FreeMem

   ;------ set up our return value
   move.l   d2,d0

Expunge_End:
   movem.l   (sp)+,d2/a5/a6
   rts

Null:
   CLEAR   d0
   rts

;------------------------------------------------------------------------------------------
; Here begins the library specific functions.  Both of these simple functions are entirely
; in assembler, but you can write your functions in C if you wish and interface to them
; here.  If, for instance, the bulk of the AddThese function was written in C, you could
; interface to it as follows:
;
;   - write a C function  addTheseC(n1,n2) and compile it
;   - XDEF _addThese C  in this library code
;   - change the AddThese function code below to:
;       move.l d1,-(sp)     ;push rightmost C arg first
;       move.l d0,-(sp)     ;push other C arg(s), right to left
;       jsr    _addTheseC   ;call the C code
;       addq   #8,sp        ;fix stack
;       rts                 ;return with result in d0
;------------------------------------------------------------------------------------------

*----- Double(d0)
Double:
   lsl     #1,d0
   rts

*----- AddThese(d0,d1)
AddThese:
   add.l   d1,d0
   rts

*----- Fib(d0)
Fib:
	movem.l d2-d3,-(sp)       ; Store used registers
	moveq  	#1,d1             ; d1 = 1
	moveq  	#0,d2             ; d2 = 0
	moveq  	#1,d3             ; d3 = 1
.loop                      ; 
	cmp.l   #1,d0             ; while (d0 > 1)
	ble     .exit             ; {
	move.l  d2,d1             ;   d1  = d2
	add.l   d3,d1             ;   d1 += d3
	move.l  d3,d2             ;   d2  = d3
	move.l  d1,d3             ;   d3  = d1
	sub.l   #1,d0             ;   d0 -= 1
	bra     .loop             ; }
.exit                      ; 
	move.l  d1,d0             ; Put the result in d0
	movem.l (sp)+,d2-d3       ; Restore used registers
	rts                       ; Exit from the Sub-Routine
	
   ; EndCode is a marker that show the end of your code.  Make sure it does not span
   ; sections nor is before the rom tag in memory!  It is ok to put it right after the ROM
   ; tag--that way you are always safe.  I put it here because it happens to be the "right"
   ; thing to do, and I know that it is safe in this case.
EndCode:

	END
	
