/* Copyright (C) 2018 by Alex */
#include <proto/exec.h>
#include "./inline.h"

#ifndef NDEBUG
void kprintf(const char *fmt, ...);
#define DBUG(...) kprintf(__VA_ARGS__)
#else
#define DBUG(...)
#endif


int main(int argc, char **argv) {
  struct Library *AlkisBase;

  if (AlkisBase = OpenLibrary("alkis.library", 1)) {
    DBUG("Triple(40) = %ld (LIB: %lx)\n", Triple(40), AlkisBase);
    DBUG("Double(40) = %ld\n", Double(40));
    DBUG("AddThese(3,5)= %ld\n", AddThese(3, 5));
    DBUG("Fib(12) = %ld\n", Fib(12));
    CloseLibrary(AlkisBase);
    return 0;
  }
  return 20;
}
