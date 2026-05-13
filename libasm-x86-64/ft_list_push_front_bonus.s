section	.text
global	ft_list_push_front

extern malloc

; ft_list_push_front(t_list **begin_list, void *data)
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
	test	rdi, rdi			; null pointer check for begin_list
	je		.ret				; if null, just return
	push	rbp					; save callee-saved registers
	push	rbx					; save callee-saved registers	
	mov	rbx, rdi				; save begin_list pointer in rbx
	mov	rbp, rsi				; save data pointer in rbp
	mov	edi, 16					; size of new t_list node (2 pointers)
	call	malloc wrt ..plt	; call malloc to allocate memory for new node
	test	rax, rax			; check if malloc returned NULL
	je	.prepare_exit			; if so, reinstate the callee saved regs from stack - exit
	mov	qword  [rax], rbp		; rbp is the data, I set new_node->data = data
	mov	rdx, qword  [rbx]	    ; rbx is begin_list, so rdx = *begin_list (the old head)
	mov	qword  8[rax], rdx		; set new_node->next = *begin_list (the old head)
	mov	qword  [rbx], rax		; set old *begin_list = new_node (update head)
.prepare_exit:
	pop	rbx
	pop	rbp
	ret
.ret:
	ret
