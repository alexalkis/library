ifeq (, $(shell which vasm))
 AS = vasmm68k_mot
 #$(info "vasm not found")
else
 AS = vasm
 #$(info  "vasm found")
endif

#Try to find the asm includes relative to gcc6
GCC6PATH := $(shell echo `whereis m68k-amigaos-gcc` | rev | cut -d'/' -f3- | rev |  cut -d' ' -f2-)
ifeq (,$(wildcard $(GCC6PATH)/m68k-amigaos/sys-include/exec/exec.i))
#$(info "file doesn't exists")
ASMINC = -I$(GCC6PATH)/m68k-amigaos/ndk-include/
else
#$(info "file exists")
ASMINC = -I$(GCC6PATH)/m68k-amigaos/sys-include/
endif
#ASMINC = -I$(GCC6PATH)/m68k-amigaos/sys-include/ -I$(GCC6PATH)/m68k-amigaos/ndk-include/


GIT_VERSION := $(shell git log -1 --date=short --pretty='format:%cd %h')
CURDATE := $(shell date '+%Y-%m-%d %H:%M:%S')
SYNTHVER := $(GIT_VERSION) (Built: $(CURDATE))
#$(info $(SYNTHVER))

CC=m68k-amigaos-gcc
CFLAGS += -Wall -O3 -fomit-frame-pointer
ASFLAGS+= $(ASMINC) -esc -Fhunk -quiet

OBJS=tester.o
LOBJS=alkislibrary.o libfunc.o

debug: tester testerc alkis.library
debug: OBJS+=  $(GCC6PATH)/m68k-amigaos/ndk/lib/linker_libs/debug.lib
debug: LOBJS+= $(GCC6PATH)/m68k-amigaos/ndk/lib/linker_libs/debug.lib

release: ASFLAGS+= -DNDEBUG
release: CFLAGS+= -DNDEBUG
release: tester testerc alkis.library




tester: $(OBJS)
	vlink -s -o tester $(OBJS) 
	@ls -l tester
	@-cp tester "/media/sf_shared/Amiga1.3/alkis/" 2>>/dev/null || true
	@-cp tester "/media/sf_shared/AmigaHDa1200/asm/" 2>>/dev/null || true
	@-cp tester "/home/alex/Documents/FS-UAE/Hard Drives/13hd/t/" 2>>/dev/null || true
	@-cp tester "/home/alex/Documents/FS-UAE/Hard Drives/AmigaHD/t/asm/" 2>>/dev/null || true

tester.o: tester.asm mymacros.i alkis_lib.i
	$(AS) $(ASFLAGS) tester.asm -o tester.o


alkis.library: $(LOBJS)
	vlink -s -o alkis.library $(LOBJS)
	@ls -l alkis.library
	@-cp alkis.library "/media/sf_shared/Amiga1.3/alkis/" 2>>/dev/null || true
	@-cp alkis.library "/media/sf_shared/AmigaHDa1200/asm/" 2>>/dev/null || true
	@-cp alkis.library "/home/alex/Documents/FS-UAE/Hard Drives/13hd/t/" 2>>/dev/null || true
	@-cp alkis.library "/home/alex/Documents/FS-UAE/Hard Drives/AmigaHD/t/asm/" 2>>/dev/null || true

alkislibrary.o: alkislibrary.asm mymacros.i
	$(AS) $(ASFLAGS) alkislibrary.asm -o alkislibrary.o

libfunc.o: libfunc.c
	$(CC) $(CFLAGS) -c libfunc.c -o libfunc.o

testerc: testerc.c inline.h
	$(CC) -noixemul $(CFLAGS) -o testerc testerc.c
	@ls -l testerc
	@-cp testerc "/home/alex/Documents/FS-UAE/Hard Drives/AmigaHD/t/asm/" 2>>/dev/null || true

inline.h: alkis_lib.sfd
	sfdc --mode=macros alkis_lib.sfd >inline.h

clean:
	@rm -rf *.o *~ tester alkis.library TAGS inline.h testerc

TAGS:
	find . $(GCC6PATH)/m68k-amigaos/sys-include/ $(GCC6PATH)/m68k-amigaos/ndk-include/ -type f -iname "*.[ch]" | etags -
