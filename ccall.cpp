extern "C" void adapterToC(const char* fmt, ...);

/*
 gcc -no-pie printf.o ccall.cpp
*/
int main() {
    char* text = "FUCK$";
    adapterToC("Hello, %d %d Moscow %s %d %x %s %c %s\n", -1ll, 160, "Test$", 160, 100, "Me$", 0x32, text);

    return 0;
}