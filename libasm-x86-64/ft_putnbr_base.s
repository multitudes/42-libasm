section .text
global putnbr_base

extern write

; reverse
; ------------------------------------------
; Reverses a string in place.
; Arguments:
;   rdi: pointer to the start of the string
;   rsi: length of the string (excluding null terminator)
; Returns: nothing 
reverse:
	sub	esi, 1					; len - 1
	mov	ecx, 0					; left index = 0
	jmp	.condition
.loop:
	movsx	rdx, ecx				; just sign extend the pointer left index
	add	rdx, rdi					; rdx = string + left index		
	movzx	r8d, byte [rdx]			; load left char	
	movsx	rax, esi				; right index - address calculation needs 64-bit
	add	rax, rdi					; calculate address of right index
	add	ecx, 1						; left index++
	movzx	r9d, byte  [rax]		; load right char
	mov	byte  [rdx], r9b			; store right char at left index
	sub	esi, 1						; right index--
	mov	byte  [rax], r8b			; store left char at right index
.condition:
	cmp	esi, ecx					; compare right index with left index
	jg	.loop						; if right > left, continue 
	ret






check_base_len:
	mov	ecx, 0
.L5:
	movsx	rax, ecx
	movzx	esi, byte  [rdi+rax]
	test	sil, sil
	je	.L13
	cmp	sil, 43
	sete	dl
	cmp	sil, 45
	sete	al
	or	dl, al
	jne	.L10
	mov	eax, 0
.L7:
	cmp	ecx, eax
	jle	.L14
	lea	edx, 1[rax]
	cdqe
	cmp	byte  [rdi+rax], sil
	je	.L11
	mov	eax, edx
	jmp	.L7
.L14:
	add	ecx, 1
	jmp	.L5
.L13:
	cmp	ecx, 1
	jg	.L4
	mov	ecx, 0
	jmp	.L4
.L10:
	mov	ecx, 0
	jmp	.L4
.L11:
	mov	ecx, 0
.L4:
	mov	eax, ecx
	ret




get_num_and_base:
	push	r13
	push	r12
	push	rbp
	push	rbx
	mov	rbx, rdi
	mov	r13, rsi
	mov	r12, rdx
	mov	rbp, rcx
	mov	rdi, rdx
	call	check_base_len
	mov	dword 0[rbp], eax
	test	eax, eax
	je	.L15
	mov	eax, dword [rbx]
	cmp	eax, -2147483647
	jb	.L17
	neg	eax
	mov	dword [rbx], eax
.L17:
	mov	eax, dword  [rbx]
	cmp	eax, -2147483648
	je	.L20
	mov	eax, 1
.L15:
	pop	rbx
	pop	rbp

	pop	r12

	pop	r13

	ret
.L20:
	cdq
	idiv	dword  0[rbp]
	neg	edx
	movsx	rdx, edx
	movzx	eax, byte  [r12+rdx]
	mov	byte  0[r13], al
	mov	eax, dword  [rbx]
	cdq
	idiv	dword  0[rbp]
	mov	dword  [rbx], eax
	neg	eax
	mov	dword  [rbx], eax
	mov	eax, 1
	jmp	.L15





putnbr_base:
	push	r12
	push	rbp
	push	rbx
	sub	rsp, 80
	mov	dword 12[rsp], edi
	mov	rbp, rsi
	xor	eax, eax
	mov	r12d, edi
	mov	byte  27[rsp], 0
	lea	rcx, 28[rsp]
	lea	rsi, 27[rsp]
	lea	rdi, 12[rsp]
	mov	rdx, rbp
	call	get_num_and_base
	test	eax, eax
	je	.L21
	cmp	dword  12[rsp], 0
	jne	.L28
	mov	byte  32[rsp], 48
	mov	ebx, 1
	jmp	.L24
.L28:
	mov	ebx, 0
	jmp	.L24
.L25:
	cdq
	idiv	dword  28[rsp]
	movsx	rdx, edx
	movzx	ecx, byte  0[rbp+rdx]
	movsx	rdx, ebx
	mov	byte 32[rsp+rdx], cl
	mov	dword 12[rsp], eax
	lea	ebx, 1[rbx]
.L24:
	mov	eax, dword  12[rsp]
	test	eax, eax
	jg	.L25
	test	r12d, r12d
	js	.L30
.L26:
	lea	rbp, 32[rsp]
	mov	esi, ebx
	mov	rdi, rbp
	call	reverse
	movsx	rdx, ebx
	mov	rsi, rbp
	mov	edi, 1
	call	write
	cmp	byte  27[rsp], 0
	jne	.L31
.L21:
	add	rsp, 80
	pop	rbx
	pop	rbp
	pop	r12
	ret
.L30:
	movsx	rax, ebx
	mov	byte  32[rsp+rax], 45
	lea	ebx, 1[rbx]
	jmp	.L26
.L31:
	lea	rsi, 27[rsp]
	mov	edx, 1
	mov	edi, 1
	call	write
	jmp	.L21


