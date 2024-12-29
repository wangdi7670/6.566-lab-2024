`exploit.py` and `vulnerable.c` are from blog

usage:
```
cc -m64   -c -o shellcode.o shellcode.S

objcopy -S -O binary -j .text shellcode.o shellcode.bin

gcc -g -fno-stack-protector -z execstack vulnerable.c -o vulnerable -D_FORTIFY_SOURCE=0

./exploit.py | env - setarch -R ./vulnerable
```