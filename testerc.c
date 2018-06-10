/* Copyright (C) 2018 by Alex */
#include <stdio.h>
#include <proto/exec.h>
#include "./inline.h"

int main(int argc, char **argv) {
  struct Library *AlkisBase;

  if (AlkisBase = OpenLibrary("alkis.library", 1)) {
    printf("Triple(40) = %ld (LIB: %lx)\n", Triple(40), AlkisBase);
    printf("Double(40) = %ld\n", Double(40));
    printf("AddThese(3,5)= %d\n", AddThese(3, 5));
    printf("Fib(12) = %d\n", Fib(12));
    CloseLibrary(AlkisBase);
    return 0;
  }
  return 20;
}
