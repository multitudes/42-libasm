# Leaf Functions

My question: in x86-64 assembly the processor always saves the address of the next instruction on the stack when calling a function. So I don't need a prologue if I don't call another function and don't modify callee-saved registers?

Yes, that is how the architecture works. A function that calls nothing else is called a **leaf function**.

---

## 1. The Call Mechanism

When your code executes `call ft_list_sort`, the single `call` instruction does two things:

1. It pushes the return address (the address of the instruction right after the `call`) onto the stack, where `rsp` points. That is 8 bytes.
2. It jumps to the start of the called function.

When the function reaches `ret`, the process reverses: the CPU pops that 8-byte address off the stack and jumps back to the caller.

---

## 2. When Can You Skip the Prologue?

You can leave out the `push rbp` / `mov rbp, rsp` prologue, and any stack cleanup, if your function meets both conditions:

* **You do not modify any callee-saved registers** (`rbx`, `rbp`, `r12`-`r15`). If the whole algorithm fits in the caller-saved registers (`rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8`-`r11`), there is nothing to preserve.
* **You do not execute a `call` yourself.** A leaf function just computes and returns, so there is no child call that needs a 16-byte aligned stack.

`ft_strlen`, `ft_strcpy` and `ft_list_size` in this project are leaf functions.

---

## Examples side-by-side

### A Non-Leaf Function (Requires Prologue / Preservation)

This function calls *another* function (`free`), so it must protect the registers it relies on and align the stack to 16 bytes:

```nasm
ft_custom_free:
    push    rbp                 ; rsp offset: 8 (return address) + 8 = 16
    mov     rbp, rsp
    push    rbx                 ; Save rbx because we want to use it (offset 24)
    sub     rsp, 8              ; Restore 16-byte alignment before 'call' (offset 32)

    mov     rbx, rdi            ; Cache data pointer in rbx
    call    free wrt ..plt      ; We are CALLING something!

    add     rsp, 8
    pop     rbx
    pop     rbp
    ret
```

### A Leaf Function (No Prologue)

This function calls nothing and only uses scratch registers, so it needs no setup at all:

```nasm
ft_is_negative:
    ; No push rbp, no mov rbp, rsp, no stack alignment!
    test    edi, edi            ; Check the incoming int argument (edi)
    js      .is_neg             ; Jump if the sign flag is set (negative)

    xor     eax, eax            ; Return 0
    ret                         ; Pops the return address and goes back

.is_neg:
    mov     eax, 1              ; Return 1
    ret
```

Recognizing leaf functions saves a few memory operations per call and keeps the code short.

---

## System Calls Don't Use the Stack

System calls behave differently from normal function calls. The `syscall` instruction itself needs **no prologue and no stack alignment**.

A normal user-space function call goes through the stack:

```nasm
call    free               ; Pushes a return address onto the stack
```

A system call uses the **`syscall`** instruction instead:

```nasm
syscall                    ; Switches the CPU into the kernel
```

`syscall` does not push anything on your stack. It saves the return address in `rcx` and the flags in `r11` (which is why those two registers are clobbered by every syscall), then switches the CPU from **user mode** (ring 3) to **kernel mode** (ring 0).

The kernel does not trust or use your program's stack: it switches to its own kernel stack before doing any work. Your stack stays untouched.

---

## Example: `ft_write`

The success path of `ft_write` is a pure leaf: the arguments are already in the registers the kernel expects, so it can go straight to `syscall`.

The error path is **not** a leaf, because it calls `__errno_location`. That call has to follow the normal rules: keep the error code somewhere a callee can't clobber, and align the stack.

```nasm
section .text
global ft_write
extern __errno_location

; ssize_t ft_write(int fd, const void *buf, size_t count);
ft_write:
    ; Arguments are already in place: rdi = fd, rsi = buf, rdx = count
    mov     rax, 1              ; Linux x86-64 syscall number for write
    syscall

    test    rax, rax            ; The kernel returns -errno on failure
    js      .handle_error
    ret                         ; Success: rax = bytes written

.handle_error:
    neg     rax                 ; e.g. -9 becomes 9 (EBADF)
    push    rax                 ; Save the error code on the stack. This also
                                ; realigns rsp to 16 bytes for the call.
    call    __errno_location wrt ..plt ; rax = address of errno
    pop     rcx                 ; Get the error code back
    mov     dword [rax], ecx    ; errno = error code (errno is a 4-byte int)
    mov     rax, -1             ; Return -1, like write(2)
    ret
```

Two details matter here:

* `rdi` is caller-saved, so `__errno_location` is allowed to overwrite it. Keeping the error code in `rdi` across the call happens to work with glibc, but the ABI doesn't guarantee it. Pushing it on the stack (or using a callee-saved register) is safe.
* On entry `rsp` is 8 bytes off from 16-byte alignment because of the return address. The single `push` brings it back to alignment before the `call`.
