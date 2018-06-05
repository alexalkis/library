ifeq (, $(shell which vasm))
 AS = vasmm68k_mot
 #$(info "vasm not found")
else
 AS = vasm
 #$(info  "vasm found")
endif

#Try to find the asm includes relative to gcc6
GCC6PATH := $(shell echo `whereis m68k-amigaos-gcc` | rev | cut -d'/' -f3- | rev |  cut -d' ' -f2-)
ASMINC =$(GCC6PATH)/m68k-amigaos/sys-include/


GIT_VERSION := $(shell git log -1 --date=short --pretty='format:%cd %h')
CURDATE := $(shell date '+%Y-%m-%d %H:%M:%S')
SYNTHVER := $(GIT_VERSION) (Built: $(CURDATE))
#$(info $(SYNTHVER))

CC=m68k-amigaos-gcc
CFLAGS += -Wall -O3 -fomit-frame-pointer
ASFLAGS+= -I$(ASMINC) -esc -Fhunk

debug: tester alkis.library
#debug: ASFLAGS+= 

release: ASFLAGS+= -DNDEBUG
release: CFLAGS+= -DNDEBUG
release: tester alkis.library

OBJS=tester.o
LOBJS=alkislibrary.o libfunc.o


tester: $(OBJS)
	vlink -s -o tester $(OBJS) $(GCC6PATH)/m68k-amigaos/ndk/lib/linker_libs/debug.lib
	@ls -l tester
	@-cp tester "/media/sf_shared/Amiga1.3/alkis/" 2>>/dev/null || true
	@-cp tester "/media/sf_shared/AmigaHDa1200/asm/" 2>>/dev/null || true
	@-cp tester "/home/alex/Documents/FS-UAE/Hard Drives/13hd/t/" 2>>/dev/null || true

tester.o: tester.asm mymacros.i alkis_lib.i
	$(AS) $(ASFLAGS) tester.asm -o tester.o


alkis.library: $(LOBJS)
	vlink -s -o alkis.library $(LOBJS) $(GCC6PATH)/m68k-amigaos/ndk/lib/linker_libs/debug.lib
	@ls -l alkis.library
	@-cp alkis.library "/media/sf_shared/Amiga1.3/alkis/" 2>>/dev/null || true
	@-cp alkis.library "/media/sf_shared/AmigaHDa1200/asm/" 2>>/dev/null || true
	@-cp alkis.library "/home/alex/Documents/FS-UAE/Hard Drives/13hd/t/" 2>>/dev/null || true

alkislibrary.o: alkislibrary.asm mymacros.i
	$(AS) $(ASFLAGS) alkislibrary.asm -o alkislibrary.o

libfunc.o: libfunc.c
	$(CC) $(CFLAGS) -c libfunc.c -o libfunc.o

clean:
	@rm -rf *.o *~ tester alkis.library TAGS

TAGS:
	find . $(GCC6PATH)/m68k-amigaos/sys-include/ -type f -iname "*.[ch]" | etags -
