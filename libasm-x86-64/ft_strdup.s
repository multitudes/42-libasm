section .text
global	ft_strdup                       
extern malloc 
extern __errno_location 


; char *strdup(const char *s);
; ------------------------------------------
; Duplicates the string s by allocating sufficient memory for a copy of s,
; copying the string, and returning a pointer to it.
; Arguments are passed via registers by the caller:
;   rdi: pointer to the source string (s)
; Returns: pointer to the duplicated string (or NULL if insufficient memory)

ft_strdup:                              
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
	je	    .malloc_error       ; Jump to error handling if malloc failed

; Save the allocated pointer (we'll return this)
	mov	r14, rax
; If rbx is zero, there is nothing to copy, 
	test	rbx, rbx
	je	    .prepare_ret

; here I could call memcpy, but I will do it manually
; Use rbx as destination counter
    xor rbx, rbx
.loop:
    mov     cl, [r15 + rbx]  ; Load byte from source
    mov     [r14 + rbx], cl  ; Store byte to destination
    test    cl, cl           ; Check for null terminator
    je      .prepare_ret     ; Exit if null terminator copied
    inc     rbx              ; Advance to next byte
    jmp     .loop            ; Repeat

.prepare_ret:
    mov     rax, r14         ; Return the allocated string pointer
    jmp     .ret

.malloc_error:
    ; Set errno to ENOMEM (12)
    call    __errno_location wrt ..plt
    mov     dword [rax], 12  ; ENOMEM = 12
    xor     eax, eax        ; Return NULL
	jmp	    .ret

; Here I reinstate the saved registers and return
.ret:
	pop	rbx
	pop	r14
	pop	r15
	ret

