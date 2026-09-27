section .text
global ft_strlen

; ft_strlen(const char *rdi)
; ------------------------------------------
; Behaves like the C strlen() function.
; Arguments are passed via registers by the caller.
; the args for ft_strlen are already in the right registers:
;   rdi: pointer to string to measure
; returns: length of string (in rax) 
; No prologue is needed since we don't use the stack or call other functions.
ft_strlen:
    xor rax, rax            ; Initialize counter 'rax' to 0

.loop:
    cmp byte [rdi + rax], 0 ; Compare the character at s[rax] with the null terminator
    je .end                 ; If it's the end of the string, jump to .end
    inc rax                 ; Otherwise, increment the counter
    jmp .loop               ; Repeat the loop

.end:
    ret                     ; Return the count in 'rax'

section .note.GNU-stack noalloc noexec nowrite progbits
