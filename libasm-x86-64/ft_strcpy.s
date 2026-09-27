section	.text
global ft_strcpy                       

; strcpy(char *dest, const char *src)
; ------------------------------------------
; Copies the string pointed to by src (including the null terminator)
; to the buffer pointed to by dest.
; Arguments are passed via registers by the caller:
;   rdi: pointer to destination buffer (dest)
;   rsi: pointer to source string (src)
; Returns: pointer to destination buffer (dest) in rax

ft_strcpy:
    mov rax, rdi        ; Save original destination pointer for the return value.

.loop:
    mov cl, [rsi]       ; Load one byte from the source (src). cl is the lower 8 bits of rcx, which we use as a temporary register.
    mov [rdi], cl       ; Store that byte in the destination (dest).
    inc rsi             ; Increment src pointer.
    inc rdi             ; Increment dest pointer.
    test cl, cl         ; Check if the byte we just moved was the null terminator.
    jne .loop           ; If not null, repeat the loop.

    ret                 ; Return. 'rax' still holds the original destination address.

section .note.GNU-stack noalloc noexec nowrite progbits
