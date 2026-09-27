section	.text
global	ft_list_size 

; int ft_list_size(t_list *lst)
; ------------------------------------------
; Counts the number of elements in a linked list.
; Arguments are passed via registers by the caller:
;   rdi: pointer to the head of the list (t_list *lst)
; Returns: the number of elements in the list (in rax)
; NB rdi is a caller-saved register in the x86-64 family
; this is equivalent in C to pass by value
; ps a prologue is not needed here since we are not using 
; any callee-saved registers (rbp, rbx, r12-r15) and we are not
; allocating on the stack. 
; Because this function doesn't call any other functions (like malloc),
; doesn't use the stack for variables, and only touches scratch registers, 
; it is called a leaf function.  
; Leaf functions can omit the prologue entirely to save CPU cycles and run faster.

ft_list_size:                           
	xor		eax, eax				; Initialize counter and return rax reg to 0

.loop:                                
	test	rdi, rdi				; Check if lst is NULL and return if so
	je		.end
	mov		rdi, qword [rdi + 8]	; rdi now gets Node->next
	add		eax, 1					; Increment counter
	test	rdi, rdi				; Check if lst->next is NULL
	jne		.loop					; If not, continue the loop

.end:
	ret


section .note.GNU-stack noalloc noexec nowrite progbits
