section	.text
global	list_remove_if    

extern free

; list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(), void (*free_fct)(void *))
; ------------------------------------------
; Removes from the list all elements for which the comparison function returns 0
; Arguments are passed via registers by the caller:
;   rdi: pointer to the head of the list (t_list **begin_list)
;   rsi: pointer to the data to be compared (void *data_ref)
;   rdx: pointer to the comparison function (int (*cmp)())
;   rcx: pointer to the function used to free the data of an element (void (*free_fct)(void *))
; Returns: nothing
; NB rbp, rbx, r12, r13, r14 and r15 are callee-saved registers, which means:
; our function must preserve their values if you use them


list_remove_if:                      
	push	rbp
	push	r15
	push	r14
	push	r13
	push	r12
	push	rbx

	push	rax 			; this one is not callee saved but I need storage
	mov	qword [rsp], rcx 	; store the free_fct pointer on the stack
	
	test	rdi, rdi		; null pointer check for begin_list
	je	.return	


	mov	r12, rdi			; r12 = begin_list
	mov	rbx, qword  [rdi]	; rbx = current node = *begin_list
	test	rbx, rbx		; if current node is NULL, just return
	je	.return

	mov	r15, rdx			; load r15 = cmp function pointer
	mov	r13, rsi			; load r13 = data_ref
	xor	ebp, ebp			; rbp = prev - will track the previous node (initially NULL)
	jmp	.loop

.continue:                                
	mov	r14, qword  [rbx + 8]	; advance current to next node (offset 8)
	mov	rbp, rbx				; rbp = prev = rbx

.continue_no_advance:                               
	mov	rbx, r14				; now rbx = current 
	test	r14, r14			; if current is NULL, just return
	je	.return

.loop:                                
	mov	rdi, qword  [rbx]	   	; before call to cmp load in rdi the rbx->data (offset 0)
	mov	rsi, r13		   		; before call to cmp data_ref - in rsi because of function call 2nd param
	xor	eax, eax				; clear rax before function call
	call	r15					; Call cmp(rbx->data, data_ref)	
	test	eax, eax			; test return value
	jne	.continue					; if not zero, continue to next node

	; cmp returned 0 - Node needs to be removed
	; there is a little game here tohandle the case where prev is NULL (removing head)
	; I compute the address of prev->next in rax assuming prev is not NULL
	; then I test if prev is NULL and if so I cmove rax to the address of *begin_list
	; so in both cases rax ends up with the address where I need to store current->next
	; then I do the store operation to unlink the node
	lea	rax, [rbp + 8]				; rax = address of prev->next assuming prev is not null
	test	rbp, rbp				; test if prev is NULL
	cmove	rax, r12				; conditional move if rbp is zero - NULL then rax = r12 (address of *begin_list)
									
	mov	rcx, qword [rbx + 8]		; rcx = current->next (offset 8)
	mov	qword  [rax], rcx			; prev->next = current->next or *begin_list = current->next if prev is NULL
	mov	rdi, qword  [rbx]			; prepare for call rdi = rbx->data (offset 0)
	mov	r14, qword  [rbx + 8]		; save rbx->next (offset 8)
	call	qword  [rsp]   		; call the free_fct function stored on stack earlier             
	mov	rdi, rbx				; again prepare for free of the node itself
	call	free wrt ..plt
	jmp	.continue_no_advance    ; I continue without advancing - r14 already has next node

.return:
	add	rsp, 8
	pop	rbx
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rbp
	ret
