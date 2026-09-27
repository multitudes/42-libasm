section	.text
global	ft_list_push_front

extern malloc

; void ft_list_push_front(t_list **begin_list, void *data)
; ------------------------------------------
; Adds a new element at the beginning of the list.
; Arguments are passed via registers by the caller:
;   rdi: pointer to the head of the list (t_list **begin_list)
;   rsi: pointer to the data to be stored in the new element (void *data)
; Returns: nothing
; NB rbp and rbx are callee-saved registers, which means:
; our function must preserve their values if you use them
; 

ft_list_push_front:
	push	rbp					; function prologue
	mov rbp, rsp
	
	push	rbx					; save callee-saved registers
	push    r12                 ; Moves stack to 32 bytes to maintain 16-byte alignment
	
	test	rdi, rdi			; null pointer check for begin_list
	je		.ret				; if null, just return
	
	mov     rbx, rdi            ; rbx = begin_list
    mov     r12, rsi            ; r12 = data
    mov     rdi, 16				; size of new t_list node (2 pointers)

	call	malloc wrt ..plt	; call malloc to allocate memory for new node
	test	rax, rax			; check if malloc returned NULL
	je	.ret					; if so, exit

	mov	qword [rax], r12		; r12 is the data, I set new_node->data = data
	mov	rdx, qword [rbx]	    ; rbx is begin_list, so rdx = *begin_list (the old head)
	mov	qword [rax + 8], rdx	; set new_node->next = *begin_list (the old head)
	mov	qword [rbx], rax		; set old *begin_list = new_node (update head)

.ret:
	pop r12
	pop	rbx
	pop	rbp
	ret

section .note.GNU-stack noalloc noexec nowrite progbits
