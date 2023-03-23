extern "C" void adapterToC(const char* fmt, ...);

/*
 gcc -no-pie printf.o ccall.cpp
*/
int main() {
    adapterToC("-What should you love?\n%d %s %x %d%%%c%b\n$", -1ll, "love$", 3802, 100, 33, 127);

    return 0;
}