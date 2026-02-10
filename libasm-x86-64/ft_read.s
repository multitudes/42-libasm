section	.text
global	read  

extern __errno_location

; read(int rdi, void *rsi, size_t rdx)
; ------------------------------------------
; Behaves like the C read() function.
; Arguments are passed via registers by the caller.
; the args for read are already in the right registers:
;   rdi: file descriptor to read from
;   rsi: pointer to buffer where read data will be stored
;   rdx: number of bytes to read
; returns: number of bytes read (in rax) or -1 on error

; To link with C library functions like __errno_location in a PIE binary,
; we must declare them as external and specify that the call will be routed
; through the Procedure Linkage Table (PLT).

read:               
	mov	rax, 0                  ; syscall number for read
	syscall
    cmp rax, 0                  ; check return value
    jge .ret                    ; if rax >= 0, return it    

; --- Error Handling Path ---
; The syscall failed. rax contains a negative error code (e.g., -9 for EBADF).
.error:
    neg rax                     ; make it positive
    mov rdi, rax                ; Temporarily save the positive errno in rdi. We use rdi
                                ; because it's a "caller-saved" register that is not preserved
                                ; across the call to __errno_location. The call itself
                                ; will overwrite rax.

    ; Get the memory address of the global `errno` variable from libc.
    ; The 'wrt ..plt' syntax is essential for PIE compatibility.
    call __errno_location wrt ..plt
                                ; On return, rax now holds the address of errno.           
    mov [rax], edi              ; Store the positive error code (from edi, the lower 32 bits
                                ; of rdi) into the memory location pointed to by rax.
                                ; We use edi since errno is an int.
    mov rax, -1                 ; return -1
.ret:
	ret
