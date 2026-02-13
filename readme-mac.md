Yes! macOS has several built-in and available disassemblers for M1 (ARM64):

**Built-in tools:**
1. **`otool -tV`** - Apple's disassembler (comes with Xcode Command Line Tools)
   ```bash
   otool -tV your_binary
   ```

2. **`objdump -d`** - GNU disassembler (if you have it via Homebrew)
   ```bash
   objdump -d your_binary
   ```

3. **`lldb`** - Apple's debugger with disassembly
   ```bash
   lldb your_binary
   (lldb) disassemble -n function_name
   ```

ok right now i am paying on my mac. 
so when i get this 
0000000000000000 <ltmp0>:
       0: a9be4ff4      stp     x20, x19, [sp, #-0x20]!
       4: a9017bfd      stp     x29, x30, [sp, #0x10]
       8: 910043fd      add     x29, sp, #0x10
       c: aa0203f3      mov     x19, x2
      10: 94000000      bl      0x10 <ltmp0+0x10>
      14: f9000260      str     x0, [x19]
      18: a9417bfd      ldp     x29, x30, [sp, #0x10]
      1c: a8c24ff4      ldp     x20, x19, [sp], #0x20
      20: d65f03c0      ret

      That's ARM64 (AArch64) assembly - your M1 Mac's native architecture! This is completely different from the x86-64 assembly you're writing in your libasm project.

**Breaking down this ARM64 code:**

```
0: a9be4ff4    stp x20, x19, [sp, #-0x20]!   ; Save x19, x20 to stack (pre-decrement sp by 0x20)
4: a9017bfd    stp x29, x30, [sp, #0x10]     ; Save frame pointer & link register
8: 910043fd    add x29, sp, #0x10            ; Set up frame pointer
c: aa0203f3    mov x19, x2                   ; Save dest pointer (3rd arg) to x19
10: 94000000   bl  0x10                      ; Call mult2(x, y) - result in x0
14: f9000260   str x0, [x19]                 ; Store result: *dest = t
18: a9417bfd   ldp x29, x30, [sp, #0x10]     ; Restore frame pointer & link register
1c: a8c24ff4   ldp x20, x19, [sp], #0x20     ; Restore x19, x20 (post-increment sp)
20: d65f03c0   ret                           ; Return
```

**Key differences from x86-64:**
- **Registers:** `x0-x30` instead of `rax, rdi, rsi, rdx...`
- **Arguments:** First 8 args in `x0-x7` (vs `rdi, rsi, rdx, rcx...` in x86-64)
- **Return:** Result in `x0` (vs `rax`)
- **Instructions:** `stp/ldp` (store/load pair), `bl` (branch-link) vs x86's `push/pop`, `call`

Your **libasm project uses x86-64**, so this ARM64 output won't help you directly - you'd need to run your x86-64 code on an Intel machine or Linux VM to see the actual x86-64 disassembly.

`a9be4ff4` is the **machine code** (binary instruction encoded in hexadecimal) that the CPU actually executes.

**The breakdown:**
- **Left column** (`a9be4ff4`): Raw bytes - what's stored in memory
- **Right column** (`stp x20, x19, [sp, #-0x20]!`): Human-readable assembly instruction

The CPU doesn't understand "stp" - it only understands the binary pattern `10101001101111100100111111110100` (which is `a9be4ff4` in hex).

**How ARM64 encodes this instruction:**
```
a9be4ff4 (hex) = 1010 1001 1011 1110 0100 1111 1111 0100 (binary)

Broken down:
- Bits [31-22]: 1010100110 = STP opcode (store pair)
- Bits [21-15]: 1111100 = immediate offset encoded
- Bits [14-10]: 01001 = register x19 (source 1)
- Bits [9-5]:   11111 = register sp (base address)
- Bits [4-0]:   10100 = register x20 (source 2)
```

**Same concept in x86-64:**
```
55              push rbp         ; 55 is the machine code
48 89 e5        mov rbp, rsp     ; 48 89 e5 is the machine code
```

The assembler (NASM for your x86-64 code) translates human-readable assembly → machine code. The disassembler does the reverse: machine code → assembly.