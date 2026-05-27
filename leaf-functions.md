# Leaf Functions

ok so if I understand correctly in 86-64 assembly the processor always saves the address of the next instruction on the stack before calling a function. I don't need to use a prologue if I do not call a function or if I do not modify Callee saved registers

A:
You have understood it **100% correctly**. That is exactly how the architecture functions under the hood.

What you just described is actually a major concept in low-level systems programming called a **Leaf Function**.

---

## 1. The Call Mechanism

When your code executes `call ft_list_sort`, two distinct hardware events occur in a single CPU cycle:

1. The processor looks at the instruction pointer register (`rip`), which holds the address of the *very next* line of code in your program.
2. It automatically drops (pushes) that 8-byte pointer onto the stack where `rsp` is pointing. Only *then* does it jump into your function.

When your function hits its final `ret` opcode, the process reverses: the CPU pops that 8-byte address off the stack and jumps right back to your main routine.

---

## 2. When Can You Skip the Prologue entirely?

You are completely right. You can safely throw away the entire `push rbp`/`mov rbp, rsp` prologue and skip cleaning up the stack if your function meets these two conditions:

* **You do not modify any Callee-Saved registers** (`rbx`, `rbp`, `r12`-`r15`). If you can complete your entire algorithm using only caller-saved scratchpads (`rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8`-`r11`), you don't need to preserve anything.
* **You do not execute a `call` instruction yourself.** If your function is a "dead end" (a leaf) that just performs a calculation and returns, you don't need to worry about aligning the stack to 16 bytes for a child function.

---

## Examples side-by-side

Look at how much tighter your code becomes when it qualifies as a leaf function.

### A Non-Leaf Function (Requires Prologue / Preservation)

Because this function calls *another* function (`free`), it must protect registers and align the stack to 16 bytes.

```nasm
ft_custom_free:
    push    rbp
    mov     rbp, rsp
    push    rbx                 ; Save rbx because we want to use it
    sub     rsp, 8              ; Maintain 16-byte alignment before 'call'

    mov     rbx, rdi            ; Cache data pointer in rbx
    call    free wrt ..plt      ; We are CALLING something!

    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

```

### A Leaf Function (Zero Prologue, Naked Execution)

Because this function doesn't call anything and only uses scratch registers, you can treat it as a pure raw sequence:

```nasm
ft_is_negative:
    ; No push rbp, no mov rbp, rsp, no stack alignment!
    test    edi, edi            ; Check incoming int argument (rdi)
    js      .is_neg             ; Jump if sign flag is set (negative)
    
    xor     eax, eax            ; Return 0
    ret                         ; Instantly pops return address and exits!

.is_neg:
    mov     eax, 1              ; Return 1
    ret

```

By recognizing when a function is a leaf, you can save your CPU several memory operations per function invocation, making your assembly code incredibly lean and performant!

You are exactly right—system calls behave completely differently from normal function calls, and they **never require a prologue or stack alignment**.

When you write a function like `ft_write` or `ft_read` for your mandatory `libasm` assignments, you can jump straight into the logic, execute the system call, and exit immediately.

---

## Why System Calls Skip the Stack entirely

When your assembly code executes a normal user-space function call, it uses the stack via the `call` opcode:

```nasm
call    free               ; Drops a return address onto the stack

```

But when you invoke a system call, you do not use the `call` opcode. You use the **`syscall`** instruction:

```nasm
syscall                    ; Triggers a hardware context switch

```

The `syscall` opcode does not touch your stack pointer (`rsp`) at all. Instead, it triggers a hardware exception that switches the CPU from **User Mode** (Ring 3) to **Kernel Mode** (Ring 0).

Because the kernel runs in a completely separate security privilege layer, it explicitly refuses to trust or use your program's user-space stack. Instead, the CPU instantly swaps out your stack pointer for a protected, internal **Kernel Stack** before executing the system operation. Your function's stack remains entirely untouched.

---

## A Perfect Example: Your `ft_write` Function

Because a system call is inherently a "leaf" operation that handles its own memory space inside the kernel, your entire implementation of a function like `ft_write` requires absolutely zero boilerplate configuration:

```nasm
section .text
global ft_write
extern __errno_location

; ssize_t ft_write(int fd, const void *buf, size_t count);
ft_write:
    ; Incoming arguments are already perfectly placed by the caller:
    ; rdi = fd, rsi = buf, rdx = count
    
    mov     rax, 1              ; Write system call number on Linux x86_64 is 1
    syscall                     ; Jump straight into the Linux Kernel!
    
    ; System call exit handling
    test    rax, rax            ; Check the kernel's return value
    js      .handle_error       ; If negative, an error occurred!
    
    ret                         ; Clear return path (no stack to clean up)

.handle_error:
    neg     rax                 ; Convert negative error code (e.g., -9) to positive (9)
    mov     rdi, rax            ; Save error code into rdi
    call    __errno_location wrt ..plt ; Get the address of errno
    mov     qword [rax], rdi    ; Set errno = error code
    mov     rax, -1             ; Return -1 per standard POSIX spec
    ret

```
