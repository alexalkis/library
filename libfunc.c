/* Copyright (C) 2018 by Alex */
#ifndef NDEBUG
void kprintf(const char *fmt, ...);
#define DBUG(...) kprintf(__VA_ARGS__)
#else
#define DBUG(...)
#endif

int Triple(register int n __asm("d0")) {
  DBUG("Inside Triple, with arg=%ld\n", n);
  return n+n+n;
}
