#include <stdio.h>
#include <stdarg.h>


extern "C" void kernel32connect(const char* fmt, ...);

extern "C" void kernel32connect(const char* fmt, ...) {
    va_list argptr = {};
    va_start(argptr, fmt);
    vfprintf(stderr, fmt, argptr);
    va_end(argptr);
}

/*
    g++ -c -static asmcall.cpp -o asmcallcpp.o
    nasm -f elf64 -l asmcall.lst asmcall.s
    gcc -no-pie asmcall.o asmcallcpp.o -o asmcall
*/