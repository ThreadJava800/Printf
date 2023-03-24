#include <stdio.h>
#include <stdarg.h>


extern "C" void kernel32connect(const char* fmt, ...);

extern "C" void kernel32connect(const char* fmt, ...) {
    va_list args = {};
    va_start(args, fmt);

    vfprintf(stderr, fmt, args);
    
    va_end(args);
}

/*
    g++ -c -static asmcall.cpp -o asmcallcpp.o
    nasm -f elf64 -l asmcall.lst asmcall.s
    gcc -no-pie asmcall.o asmcallcpp.o -o asmcall
*/