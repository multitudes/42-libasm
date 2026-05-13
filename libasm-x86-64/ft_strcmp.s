section	.text
global	ft_strcmp            

; The orig strcmp(const char *s1, const char *s2)
; ------------------------------------------
; Compares the two strings s1 and s2.	
; Arguments are passed via registers by the caller:
;   rdi: pointer to first string (s1)
;   rsi: pointer to second string (s2)
; Returns: an integer less than, equal to, or greater than zero if s1 is
; respectively found to be less than, to match, or be greater than s2.

ft_strcmp:

.loop:
    mov al, [rdi]		; al is the lower 8 bits of rax
    mov bl, [rsi]		; bl is the lower 8 bits of rbx
    cmp al, bl          
    jne .diff           
    test al, al         ; Is it the end of string?
    jz .diff            ; If both are terminators and are null the strings are equal
    inc rdi
    inc rsi
    jmp .loop

.diff:
    movzx eax, al
    movzx ecx, bl
    sub eax, ecx        ; This gives you aas return the negative/positive/zero
    ret
