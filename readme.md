`exploit.py` and `vulnerable.c` are from blog

usage:
```
gcc -g -fno-stack-protector -z execstack vulnerable.c -o vulnerable -D_FORTIFY_SOURCE=0

./exploit.py | env - setarch -R ./vulnerable
```