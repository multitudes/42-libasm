section	.text

global	list_sort
list_sort:
	push	r15
	push	r14
	push	r12
	push	rbx
	push	rax
	test	rdi, rdi
	je	.prepare_exit


	mov	r15, qword  [rdi]
	test	r15, r15
	je	.prepare_exit

	mov	rbx, qword  [r15 + 8]
	test	rbx, rbx
	je	.prepare_exit

	mov	r14, rsi
	lea	r12, [r15 + 8]
	jmp	.inner_loop

.LBB0_7:                                
	mov	rbx, qword  [rbx + 8]
.inner_loop:                               
	test	rbx, rbx
	je	.LBB0_8
                               
	mov	rdi, qword  [r15]
	mov	rsi, qword  [rbx]
	xor	eax, eax
	call	r14
	test	eax, eax
	jle	.LBB0_7

	mov	rax, qword  [r15]
	mov	rcx, qword  [rbx]
	mov	qword  [r15], rcx
	mov	qword  [rbx], rax
	jmp	.LBB0_7
.LBB0_8:                                
	mov	r15, qword  [r12]
	lea	r12, [r15 + 8]
	mov	rbx, qword  [r15 + 8]
	test	rbx, rbx
	jne	.inner_loop
.prepare_exit:
	add	rsp, 8
	pop	rbx
	pop	r12
	pop	r14
	pop	r15
	ret
