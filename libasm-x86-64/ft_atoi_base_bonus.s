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
	push rbp			; save stack frame of previous function
	mov rbp, rsp		; set up new stack frame for this function
	push rbx			; preserves the callee-saved registers 
	push r12			; according to the System V AMD64 ABI .. 
	push r13
	push r14
	push r15
	
	mov r12, rdi			; save the pointer to the input string
	mov r13, rsi			; save the pointer to the base string
	xor r14d, r14d			; sign (0 = positive, 1 = negative)
	
	call .validate_base
	test eax, eax			; if validate_base returns 0, the base is invalid
	jz .return_zero
	
	mov r15d, eax			; Save the base length	
	mov rsi, r12			; this will be my working pointer
	
.skip_whitespace:
	movzx eax, byte [rsi]
	cmp al, ' '
	je .increment_rsi
	cmp al, 9				; tab
	je .increment_rsi
	cmp al, 10				; newline
	je .increment_rsi
	cmp al, 11				; vertical tab
	je .increment_rsi
	cmp al, 12				; form feed
	je .increment_rsi
	cmp al, 13				; carriage return
	je .increment_rsi
	jmp .check_sign
	
.increment_rsi:
	add rsi, 1
	jmp .skip_whitespace
	
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
	
.parse_number:
	xor eax, eax			; initialize eax - it will now contain the result
	
.parse_loop:
	movzx ecx, byte [rsi]	; Load the current character into new scratch pad
	test cl, cl				; if null terminator, end of string reached
	jz .parse_end			; stop parsing
	
	; Find current character in base
	mov rdx, r13			; rdx will be the current position in base string
	xor r8d, r8d			; init current index counter for base string
	
.find_in_base:
	movzx ebx, byte [rdx]
	test bl, bl
	jz .parse_end			; end of base string - char is not in base - stop parsing
	
	cmp bl, cl				; cl is the lower byte of ecx which contains the current character from input string
	je .digit_found
	
	add rdx, 1
	add r8d, 1
	jmp .find_in_base
	
.digit_found:
	; result = result * base + digit_value
	imul eax, r15d			; eax = result * base
	add eax, r8d			; eax += digit_value
	add rsi, 1
	jmp .parse_loop
	
.parse_end:
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
	push rsi
	push rdi
	
	; Check if base has at least 2 characters
	movzx eax, byte [r13]
	test al, al
	jz .base_invalid
	movzx eax, byte [r13 + 1]
    test al, al
    jz .base_invalid

    xor eax, eax            ; eax will track the length of the base
    mov rsi, r13            ; rsi = working pointer for base string
	
.validate_characters_in_base:
	movzx ecx, byte [rsi]   ; Load current char into ecx (saving eax for counter)
    test cl, cl             ; Is it the null terminator?
    jz .count_done          ; eax already holds the exact count. 

	; Check for invalid characters: +, -, whitespace
	cmp cl, '+'
	je .base_invalid
	cmp cl, '-'
	je .base_invalid
	cmp cl, ' '
	je .base_invalid
	cmp cl, 9				; tab
	je .base_invalid
	cmp cl, 10				; newline
	je .base_invalid
	cmp cl, 11				; vertical tab
	je .base_invalid
	cmp cl, 12				; form feed
	je .base_invalid
	cmp cl, 13				; carriage return
	je .base_invalid
	
	; Check for duplicates: compare with all previous characters
	mov rdx, r13			; rdx = start of base
	
.check_duplicates:
	cmp rdx, rsi			; if we reached the same pointer/char in base no duplicates..
	je .no_duplicate		
	
	movzx ebx, byte [rdx]
	cmp cl, bl
	je .base_invalid		; found duplicate
	
	add rdx, 1
	jmp .check_duplicates
	
.no_duplicate:
	add eax, 1				; increment base length counter
	add rsi, 1				; move to next char in base
	jmp .validate_characters_in_base
	
.count_done:
	pop rdi
	pop rsi
	pop rbx
	ret
	
.base_invalid:
	xor eax, eax
	pop rdi
	pop rsi
	pop rbx
	ret
