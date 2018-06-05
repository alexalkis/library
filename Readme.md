# A template for writting an Amiga library #

This is a template or skeleton for an Amiga library.
The framework has the following interesting features:

  * Makefile based, compiles and builds on modern toolchains (vasm, gcc6)
  * Library's functions can be written in assembly and in C
  * Debug system in-place for assembly and C (DBUG macro)
  
## Makefile based ##
The makefile tries to be smart and if you have installed gcc6 and in your path, it will probably find all paths that are needed.
It's designed around cross-compilation purposes.  If you have other tools (or even going native) you'll have to make changes on it.

You can run make on it in two ways:

* make [debug]
* make release

The default is debug (thus it is inferred when you just type 'make'), this builds everything with the debug-systen included.  Don't use this for released code.

The release (defines symbol 'NDEBUG' both in assembly and in C) ommits everything the debug-system uses and is like you never had any DBUG calls in your code.

Don't forget to use 'make clean' when you switch from one configuration to another.

Oh, near all the targets you'll see a bunch of copys (cp) using a destination path that make sense to me, change the destinations to where your virtual amiga hard-drives are.

## Debug system ##
Currently all debuging messages go to serial port.  The interface is kind of the same:

* Assembly, <kbd>DBUG "string with exec's RawDoFmt qualifiers like %ld\n",d0</kbd>
* C, <kbd>DBUG("string with exec's RawDoFmt qualifiers like %ld\n",d0);</kbd>


Copy the following to a file serial.sh, save it, and make it executable ('chmod +x serial.sh')

        #!/bin/sh
        echo "1.Leave this running in the background,\n2.Run fs-uae with --serial-port=/tmp/vser at the end"
        echo "3.On another terminal go type cat /tmp/hser"
        echo "4.Use redirection from Amiga-side e.g. yourexe >ser: and all your stdout (printfs etc) will appear on linux"
        OPTS=raw,echo=0,onlcr=0,echoctl=0,echoke=0,echoe=0,iexten=0
        exec socat "$@" pty,$OPTS,link=/tmp/vser pty,$OPTS,link=/tmp/hser


Run it in a linux termninal and follow the instructions.  The terminal where you'll type the 'cat /tmp/hser' is where all the debug output is going to appear.

## Structure ##
If you type make (or make release), you'll get

* tester, a small testing application that opens alkis.library and calls some of it's functions but doesn't output anything.  It sends debug messages to serial though.
* alkis.library, the sample library.  Mostly empty with placeholder functions for fun!

The library is based completely on the RKM sample library.

So, what do you have to do in order to write a library function?

Well, first you have to decide in what language you are gonna write the function.  If it's assembly, open alkislibrary.asm and code it in, if it's C open libfunc.c and code it in.  After you write the implementation, locate 'funcTable' in alkislibrary.asm and add the entry just above the end-marker (-1).  If you written C don't forget to add the '_' in front of the name.

After that, open alkis_lib.i and add a LIBDEF entry for your new function.

That's it, make, copy library to libs: and enjoy your hard work!

### Note for C implementation of library functions ###
All the functions in libraries take arguments in registers, while C by default expects them on stack.
The way to work around this, is in your function's definition, you have to tell gcc that the parameter(s) are coming on registers, and on which registers.

For example:

    int Triple(register int n __asm("d0")) {
      DBUG("Inside Triple, with arg=%ld\n", n);
      return n+n+n;
    }


## TODO ##
 * Figure if C structures can somehow automatically be produced (don't think so, probably going to have to write them myself)
 * Prototypes and inline from sfdc
 * Write .sfd file (auto-convert from .fd?)
 * Write a testerc.c to demonstrate usage from C
 
 
