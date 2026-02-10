section .text
global	strdup                       
extern malloc 


; char *strdup(const char *s);
; ------------------------------------------
; Duplicates the string s by allocating sufficient memory for a copy of s,
; copying the string, and returning a pointer to it.
; Arguments are passed via registers by the caller:
;   rdi: pointer to the source string (s)
; Returns: pointer to the duplicated string (or NULL if insufficient memory)

strdup:                              
; push the register on the stack, r15, r14 and rbx are callee saved registers
; their value will be later reinstated before returning.
	push	r15 
	push	r14
	push	rbx
; now initialize r15 with the source string pointer (s)
	mov	    r15, rdi
	xor	    ebx, ebx

; -- Find the length of the string (including null terminator) --
.len_loop:                              
	cmp	    byte [r15 + rbx], 0
; why use lea here? add and inc also increment rbx by 1, 
; but they do affect the CPU flags.
	lea	    rbx, [rbx + 1]
	jne	    .len_loop

; move the length of the string (in rbx) to rdi for malloc
; rbx already includes space for the null terminator.
	mov	    rdi, rbx
	call	malloc wrt ..plt
	test	rax, rax
	je	    .exit_error

; before copying save the source string pointer (in r14)
	mov	r14, rax
; If rbx is zero, there is nothing to copy, 
	test	rbx, rbx
	je	    .ret

; here I could call memcpy, but I will do it manually
.loop:
    mov     cl, [r15]    ; Load byte from source
    mov     [r14], cl    ; Store byte to destination
    inc     r15          ; Advance source pointer
    inc     r14          ; Advance destination pointer
    test    cl, cl      ; Check for null terminator
    jne     .loop        ; Repeat if not null
    jmp    .ret

.exit_error:
	xor	r14d, r14d
    mov rax, r14

; Here I reinstate the saved registers and return
.ret:
	pop	rbx
	pop	r14
	pop	r15
	ret

