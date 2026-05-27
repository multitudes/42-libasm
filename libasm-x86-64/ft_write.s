section	.text
global	ft_write  

; ft_write(int rdi, void *rsi, size_t rdx)
; ------------------------------------------
; Behaves like the C write() function.
; Arguments are passed via registers by the caller.
; the args for ft_write are already in the right registers:
;   rdi: file descriptor to write to
;   rsi: pointer to buffer where data to write is stored
;   rdx: number of bytes to write
; returns: number of bytes written (in rax) or -1 on error

; To link with C library functions like __errno_location in a PIE binary,
; we must declare them as external and specify that the call will be routed
; through the Procedure Linkage Table (PLT).
extern __errno_location

ft_write:               
	mov	rax, 1                  ; syscall number for write
	syscall
    cmp rax, 0                  ; check return value
    jge .ret                    ; if rax >= 0, return it    

; --- Error Handling Path ---
; The syscall failed. rax contains a negative error code (e.g., -9 for EBADF).
.error:
    neg rax                     ; make it positive
    mov rdi, rax                ; Temporarily save the positive errno in rdi.

; Get the memory address of the global `errno` variable from libc.
; The 'wrt ..plt' syntax is essential for PIE compatibility.

    call __errno_location wrt ..plt ; On return, rax holds the address of errno.           
    mov [rax], edi                  ; Store the positive error code (from edi, the lower 32 bits
                                    ; of rdi) into the memory location pointed to by rax.
                                    ; We use edi since errno is an int.
    mov rax, -1                     ; return -1
.ret:
	ret