# Printf
## What is it?
This is my own c-like printf function written on assembly, using NASM.\
I also learned how to [call c++ function from assembly](https://github.com/ThreadJava800/Printf/blob/main/asmcall.s) and [vice versa](https://github.com/ThreadJava800/Printf/blob/main/ccall.cpp).

## How to use it?
For now my function parses : 
%b (bin), %o (oct), %x (hex), %c (ascii symbol), %s (string) and %d (decimal) alongside with %% (just %).\
I use CDECL call format.

Examples of execution from c++ and assembly you can see in [here](https://github.com/ThreadJava800/Printf/blob/main/ccall.cpp) and [here](https://github.com/ThreadJava800/Printf/blob/main/asmcall.s) respectively.