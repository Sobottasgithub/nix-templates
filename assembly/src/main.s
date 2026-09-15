.global main
.text

main:
    pushq   %rbp
    movq    %rsp, %rbp

    leaq    msg(%rip), %rdi
    movl    $0, %eax
    call    printf@PLT

    movl    $0, %eax

    movq    %rbp, %rsp
    popq    %rbp
    ret

.section .rodata
msg:
    .string "Hello, World!\n"
