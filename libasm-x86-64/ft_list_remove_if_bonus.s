section	.text
global	ft_list_remove_if    

extern free

; void list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(), void (*free_fct)(void *))
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

section .text
global  ft_list_remove_if    

extern free

ft_list_remove_if:

    test    rdi, rdi            ; Is t_list **begin_list NULL?
    jz      .quick_ret
    test    rdx, rdx            ; Is cmp function pointer NULL?
    jz      .quick_ret
    test    rcx, rcx            ; Is free_fct pointer NULL?
    jz      .quick_ret
    
    ; Frame Prologue 
    push    rbp
    mov     rbp, rsp

    ; Preserve Callee-Saved Registers
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rdi                 ; 16-byte alignment and rdi is saved on stack at [rsp]

    mov     r13, rsi            ; r13 = data_ref
    mov     r14, rdx            ; r14 = cmp function pointer
    mov     r15, rcx            ; r15 = free_fct pointer

    mov     rbx, qword [rdi]    ; rbx = current_node (*begin_list)
    xor     r12, r12            ; r12 = prev_node (initialized to NULL)
    
.inner_loop:
    test    rbx, rbx            ; Is current_node (rbx) NULL?
    jz      .full_exit          ; we finished traversing the list

    ; Call the Comparison Function: cmp(current->data, data_ref)
    mov     rdi, qword [rbx]    ; rdi = current_node->data
    mov     rsi, r13            ; rsi = data_ref
    call    r14                 ; call cmp
    
    test    eax, eax            ; 
    jne     .dont_remove        ; If return value is not zero, skip deletion

    ; remove node
    mov     rcx, qword [rbx + 8]; rcx = current_node->next
    
    test    r12, r12            ; Is prev_node (r12) NULL?
    jz      .remove_head        ; If prev is NULL, we are removing the head 

    ; Removing a middle/tail node
    mov     qword [r12 + 8], rcx; prev_node->next = current_node->next
    jmp     .free_payload

.remove_head:
    mov     rax, qword [rsp]    ; Recover begin_list (t_list **) from our stack slot
    mov     qword [rax], rcx    ; *begin_list = current_node->next

.free_payload:
    mov     rdi, qword [rbx]    ; rdi = current_node->data
    call    r15                 ; call free_fct(current->data)

    mov     rdi, rbx            ; rdi = current_node
    call    free wrt ..plt      ; free(current_node)

    ; The next node can't be kept in a scratch register: free may overwrite it.
    ; Reload it from the link updated above instead.
    test    r12, r12            ; Did we remove the head?
    jz      .next_from_head
    mov     rbx, qword [r12 + 8]; current_node = prev_node->next
    jmp     .inner_loop

.next_from_head:
    mov     rax, qword [rsp]    ; rax = begin_list
    mov     rbx, qword [rax]    ; current_node = *begin_list
    jmp     .inner_loop

.dont_remove:
    mov     r12, rbx            ; prev_node = current_node
    mov     rbx, qword [rbx + 8]; current_node = current_node->next
    jmp     .inner_loop
    
.full_exit:
    pop     rdi                 ; Clean our local storage / alignment slot
    pop     r15                 ; Restore all saved registers
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp

.quick_ret:
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
