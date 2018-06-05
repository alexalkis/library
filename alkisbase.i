* samplebase.i -- definition of sample.library base

   IFND  ALKIS_BASE_I
ALKIS_BASE_I SET 1


   IFND  EXEC_TYPES_I
   INCLUDE  "exec/types.i"
   ENDC   ; EXEC_TYPES_I

   IFND  EXEC_LIBRARIES_I
   INCLUDE  "exec/libraries.i"
   ENDC   ; EXEC_LIBRARIES_I

;--------------------------
; library data structures
;--------------------------

;  Note that the library base begins with a library node

   STRUCTURE AlkisBase,LIB_SIZE
   UBYTE   sb_Flags
   UBYTE   sb_pad
   ;We are now longword aligned
   ULONG   sb_SysLib
   ULONG   sb_DosLib
   ULONG   sb_SegList
   LABEL   AlkisBase_SIZEOF


ALKISNAME   MACRO
      DC.B   'alkis.library',0
      ENDM

   ENDC  ;ALKIS_BASE_I
