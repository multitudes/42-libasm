	section	.text

	global	ft_list_sort

	; void ft_list_sort(t_list **begin_list, int (*cmp)());
	; ------------------------------------------
	; Sorts the list's elements in ascending order by comparing 
	; two elements and their data using a comparison function.
	; Arguments are passed via registers by the caller:
	;   rdi: pointer to the head of the list (t_list **begin_list)
	;   rsi: pointer to the comparison function (int (*cmp)(void *, void *))
	; Returns: nothing
	; NB rbp, rbx, r12-r15 are callee-saved registers, which means:
	; our function must preserve their values if you use them
	; The function passed in rsi is a pointer to a comparison function 
	; that takes two void pointers as arguments and returns an integer.
	; (*cmp)(list_ptr->data, list_other_ptr->data);

	ft_list_sort:

		test    rdi, rdi            ; Is t_list **begin_list NULL?
		jz      .quick_ret
		mov     rax, qword [rdi]    ; Is *begin_list NULL (empty list)?
		test    rax, rax
		jz      .quick_ret
		test    rsi, rsi            ; Is the comparison function pointer NULL?
		jz      .quick_ret

		; FRAME PROLOGUE
		push    rbp
		mov     rbp, rsp

		; 3. PRESERVE CALLEE-SAVED REGISTERS (Maintain 16-byte alignment)
		push    rbx
		push    r12
		push    r13
		push    r14
		push    r15
		sub     rsp, 8              ; Explicitly allocate 8 bytes of alignment padding

		mov     r12, rdi            ; r12 = begin_list (t_list **)
		mov     r13, rsi            ; r13 = cmp function pointer

	.reset_outer:
		xor     ebx, ebx            ; Clear swap flag
		mov     r14, qword [r12]    ; r14 = current_node (Starts at Node 1)
		mov     r15, qword [r14 + 8]; r15 = next_node (Starts at Node 2)

	.inner_loop:                               
		test    r15, r15            ; Is next_node NULL?
		jz      .check_pass_done    ; If NULL, we reached the end of this pass
								
		; Prepare arguments for cmp(current->data, next->data)
		mov     rdi, qword [r14]    ; rdi = current_node->data
		mov     rsi, qword [r15]    ; rsi = next_node->data
		call    r13                 ; call comparison function
		
		test    eax, eax
		jle     .no_swap            ; If result <= 0, skip swap.1

		; Swap data pointers
		mov     rax, qword [r14]    
		mov     rcx, qword [r15]    
		mov     qword [r14], rcx    
		mov     qword [r15], rax    
		inc     ebx              ; swap flag to 1

	.no_swap:
		; Step both windows forward
		mov     r14, r15            
		mov     r15, qword [r15 + 8]
		jmp     .inner_loop

	.check_pass_done:                                
		test    ebx, ebx            ; Did we make any swaps?
		jnz     .reset_outer        ; If we swapped, do another pass.
		
	.full_exit:
		pop 	rcx             	; Clean alignment padding
		pop     r15                 ; Restore callee-saved registers                
		pop     r14
		pop     r13
		pop     r12
		pop     rbx
		pop     rbp
		ret

	.quick_ret:
		ret

section .note.GNU-stack noalloc noexec nowrite progbits
