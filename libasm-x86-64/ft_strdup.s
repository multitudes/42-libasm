section .text
global	ft_strdup
extern ft_strlen
extern ft_strcpy
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
; Save callee-saved registers to the stack.
; These must be preserved across function calls per System V ABI.
; We use these to store variables that must survive the call to malloc.
	push	r15 				; to save the source string pointer
	push	rbx					; to save the length of the string
	push    r14            		; for alignment- stack must be a multiple of 16.. and will contain destination

	mov	    r15, rdi			
	xor	    ebx, ebx

	call 	ft_strlen    			; Length comes back in RAX
    inc  	rax          			; Add 1 for null terminator
	mov  	rbx, rax     	   		; SAVE length in rbx before it's lost
    mov  	rdi, rax       	 	; Also put it in rdi for malloc

	call	malloc wrt ..plt 	; rax will then contain the pointer to the allocated memory or NULL on failure
	test	rax, rax
	je	    .malloc_error       ; Jump to error handling if malloc failed
	
; RAX now has the new destination pointer
; R15 still has the source string pointer
    
    mov     rdi, rax        ; 1st arg for strcpy: destination
    mov     rsi, r15        ; 2nd arg for strcpy: source
    call    ft_strcpy       ; This copies the string AND returns the pointer in RAX
    jmp     .ret

.malloc_error:
    ; Set errno to ENOMEM (12)
    call    __errno_location wrt ..plt
    mov     dword [rax], 12  ; ENOMEM = 12
    xor     eax, eax        ; Return NULL
	jmp	    .ret

; Here I reinstate the saved registers and return
.ret:
	pop	r14
	pop	rbx
	pop	r15
	ret


section .note.GNU-stack noalloc noexec nowrite progbits
