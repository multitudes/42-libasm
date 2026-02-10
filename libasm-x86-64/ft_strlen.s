section .text
global ft_strlen

ft_strlen:
    xor rax, rax            ; Initialize counter 'rax' to 0

.loop:
    cmp byte [rdi + rax], 0 ; Compare the character at s[rax] with the null terminator
    je .end                 ; If it's the end of the string, jump to .end
    inc rax                 ; Otherwise, increment the counter
    jmp .loop               ; Repeat the loop

.end:
    ret                     ; Return the count in 'rax'