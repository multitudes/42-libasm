section	.text
global	list_size 

; list_size(t_list *lst)
; ------------------------------------------
; Counts the number of elements in a linked list.
; Arguments are passed via registers by the caller:
;   rdi: pointer to the head of the list (t_list *lst)
; Returns: the number of elements in the list (in rax)
; NB rdi is a caller-saved register in the x86-64 family
; this is equivalent in C to pass by value

list_size:                           
	xor		eax, eax				; Initialize counter and return rax reg to 0
	test	rdi, rdi				; Check if lst is NULL and return if so
	je		.end

.loop:                                
	mov		rdi, qword [rdi + 8]	; accesses the next pointer
	add		eax, 1					; Increment counter
	test	rdi, rdi				; Check if lst->next is NULL
	jne		.loop					; If not, continue the loop

.end:
	ret

