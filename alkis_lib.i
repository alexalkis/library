  INCLUDE  <exec/types.i>
  INCLUDE  <exec/libraries.i>

*----- LIBINIT initializes an LVO value to -30 to skip the first four
*----- 6-byte required library vectors (Open, Expunge, etc)
  LIBINIT
*----- LIBDEF assigns the current LVO value to a label, and then
*----- bumps the LVO value by -6 in preparation for next LVO label
*----- This assigns the value -30 to our first _LVO label
  LIBDEF      _LVODouble     ;-30
  LIBDEF      _LVOAddThese   ;-36
  LIBDEF      _LVOFib
  LIBDEF      _LVOTriple     ; Note that even if the name is _Triple we can make the offset Triple

             
