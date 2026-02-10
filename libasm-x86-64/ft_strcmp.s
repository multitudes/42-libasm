section	.text
global	strcmp            

; strcmp(const char *s1, const char *s2)
; ------------------------------------------
; Compares the two strings s1 and s2.	
; Arguments are passed via registers by the caller:
;   rdi: pointer to first string (s1)
;   rsi: pointer to second string (s2)
; Returns: an integer less than, equal to, or greater than zero if s1 is
; respectively found to be less than, to match, or be greater than s2.

strcmp:

; Initialize rax to 0, which will hold the return value.
	xor	eax, eax
; move rdi (s1) to rcx and then rsi (s2) will be or'd with rcx.
; If both rdi and rsi are NULL (0), then rcx will be 0 and the ZF 
; will be set. This is the behaviour of the strcmp.
	mov	rcx, rdi
	or	rcx, rsi
	je	.ret

; Load the byte at the memory address pointed to by rdi 
; (the current character of the first string) 
; into the register al (the lower 8 bits of rax).
	mov	al, byte [rdi]
	test al, al
	je .end
	add	rdi, 1
.loop:                                
	cmp	al, byte [rsi]      ; Compare current char from s1 (in al) 
                            ; to current char from s2
	jne	.end                ; If not equal, jump to end        
	add	rsi, 1              ; Move to next char in s2
	movzx	eax, byte [rdi] ; Load next char from s1 into eax
	add	rdi, 1
	test	al, al          ; Check if new char is null terminator
	jne	.loop
.end:
	movzx	eax, al
	movzx	ecx, byte  [rsi]
	sub	eax, ecx
.ret:
	ret
