* sample_rev.i version file (generated with the ``bumprev'' command)

VERSION         EQU     1
REVISION        EQU     0
DATE    MACRO
                dc.b    '2.6.18'
        ENDM
VERS    MACRO
                dc.b    'Alkis 1.0'
        ENDM
VSTRING MACRO
                dc.b    'alkis 1.0 (2.6.18)',13,10,0
        ENDM
VERSTAG MACRO
                dc.b    0,'$VER: alkis 1.0 (2.6.18)',0
        ENDM
