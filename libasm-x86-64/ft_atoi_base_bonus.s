section .text
global ft_atoi_base

; ft_atoi_base(char *str, char *base)
; ------------------------------------------
; Converts the initial portion of the string pointed to by str
; into an integer representation, where str is in a specific base.
; Arguments are passed via registers by the caller:
;   rdi: pointer to the string (str)
;   rsi: pointer to the base string
; Returns: integer value in rax
; Returns 0 if invalid base

ft_atoi_base:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	
	mov r12, rdi			; r12 = str
	mov r13, rsi			; r13 = base
	xor r14d, r14d			; r14d = sign (0 = positive, 1 = negative)
	
	; Validate base
	call .validate_base
	test eax, eax
	jz .return_zero
	
	mov r15d, eax			; r15d = base length (at least 2 if valid)
	
	; Skip whitespace at the beginning of str
	mov rsi, r12
.skip_whitespace:
	movzx eax, byte [rsi]
	cmp al, ' '
	je .ws_found
	cmp al, 9				; tab
	je .ws_found
	cmp al, 10				; newline
	je .ws_found
	cmp al, 11				; vertical tab
	je .ws_found
	cmp al, 12				; form feed
	je .ws_found
	cmp al, 13				; carriage return
	je .ws_found
	jmp .check_sign
	
.ws_found:
	add rsi, 1
	jmp .skip_whitespace
	
	; Handle optional sign
.check_sign:
	movzx eax, byte [rsi]
	cmp al, '+'
	je .skip_plus
	cmp al, '-'
	jne .parse_number
	mov r14d, 1				; set negative flag
	add rsi, 1
	jmp .parse_number
	
.skip_plus:
	add rsi, 1
	
	; Convert the number
.parse_number:
	xor eax, eax			; eax = result
	
.parse_loop:
	movzx ecx, byte [rsi]
	test cl, cl
	jz .apply_sign
	
	; Find current character in base
	mov rdx, r13
	xor r8d, r8d			; r8d = digit value
	
.find_in_base:
	movzx ebx, byte [rdx]
	test bl, bl
	jz .parse_end			; character not found in base, stop parsing
	
	cmp bl, cl
	je .digit_found
	
	add rdx, 1
	add r8d, 1
	jmp .find_in_base
	
.digit_found:
	; Check if digit value is valid (< base length)
	cmp r8d, r15d
	jge .parse_end
	
	; result = result * base + digit_value
	mov ebx, r15d			; ebx = base length
	imul eax, ebx			; eax = result * base
	add eax, r8d			; eax += digit_value
	
	add rsi, 1
	jmp .parse_loop
	
.parse_end:
	; Apply sign if negative
.apply_sign:
	test r14d, r14d
	jz .return_result
	neg eax
	
.return_result:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
	
.return_zero:
	xor eax, eax
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
	
	; Validate base: must have at least 2 chars, no duplicates, no +/-/whitespace
	; Returns: base length in eax (0 if invalid)
.validate_base:
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	
	; Check if base has at least 2 characters
	movzx eax, byte [r13]
	test al, al
	jz .base_invalid
	
	movzx eax, byte [r13 + 1]
	test al, al
	jz .base_invalid
	
	; Check each character in base
	mov rsi, r13			; rsi = base pointer (outer loop)
	
.validate_outer:
	movzx eax, byte [rsi]
	test al, al
	jz .base_valid_ret
	
	; Check for invalid characters: +, -, whitespace
	cmp al, '+'
	je .base_invalid
	cmp al, '-'
	je .base_invalid
	cmp al, ' '
	je .base_invalid
	cmp al, 9				; tab
	je .base_invalid
	cmp al, 10				; newline
	je .base_invalid
	cmp al, 11				; vertical tab
	je .base_invalid
	cmp al, 12				; form feed
	je .base_invalid
	cmp al, 13				; carriage return
	je .base_invalid
	
	; Check for duplicates: compare with all previous characters
	mov rdx, r13			; rdx = start of base
	
.check_duplicates:
	cmp rdx, rsi
	je .no_duplicate		; reached current character without finding duplicate
	
	movzx ecx, byte [rdx]
	cmp cl, al
	je .base_invalid		; found duplicate
	
	add rdx, 1
	jmp .check_duplicates
	
.no_duplicate:
	add rsi, 1
	jmp .validate_outer
	
.base_valid_ret:
	; Count and return base length
	mov rsi, r13
	xor eax, eax
	
.count_base:
	movzx ecx, byte [rsi]
	test cl, cl
	jz .count_done
	add eax, 1
	add rsi, 1
	jmp .count_base
	
.count_done:
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	ret
	
.base_invalid:
	xor eax, eax
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	ret
section .note.GNU-stack noalloc noexec nowrite