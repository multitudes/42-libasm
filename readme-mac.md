# Disassembling on a Mac (Apple Silicon)

My Mac has an M1 chip, which is ARM64 (AArch64), not x86-64. These notes cover how to look at machine code there, and how it compares with the x86-64 code of this project.

## Tools

1. **`otool -tV`** - Apple's disassembler (comes with the Xcode Command Line Tools)

```bash
otool -tV your_binary
```

2. **`objdump -d`** - also included in the Xcode Command Line Tools (it is LLVM's `objdump`)

```bash
objdump -d your_binary
```

3. **`lldb`** - Apple's debugger, which can also disassemble

```bash
lldb your_binary
(lldb) disassemble -n function_name
```

## Reading ARM64 output

Compiling the `multstore` example from CS:APP and running `objdump -d` on the object file gives:

```text
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
```

This is ARM64 assembly, the M1's native architecture. It is completely different from the x86-64 assembly written in this project.

**Line by line:**

```text
0:  a9be4ff4   stp x20, x19, [sp, #-0x20]!   ; Save x20, x19 on the stack (pre-decrement sp by 0x20)
4:  a9017bfd   stp x29, x30, [sp, #0x10]     ; Save frame pointer & link register (return address)
8:  910043fd   add x29, sp, #0x10            ; Set up frame pointer
c:  aa0203f3   mov x19, x2                   ; Save dest pointer (3rd arg) in x19
10: 94000000   bl  0x10                      ; Call mult2(x, y), result in x0
14: f9000260   str x0, [x19]                 ; Store result: *dest = t
18: a9417bfd   ldp x29, x30, [sp, #0x10]     ; Restore frame pointer & link register
1c: a8c24ff4   ldp x20, x19, [sp], #0x20     ; Restore x20, x19 (post-increment sp)
20: d65f03c0   ret                           ; Return to the address in x30
```

The `bl 0x10` looks like it jumps to itself because this is an unlinked object file: the offset is 0 until the linker fills in the real address of `mult2`.

**Key differences from x86-64:**

- **Registers:** `x0-x30` instead of `rax, rdi, rsi, rdx...`
- **Arguments:** first 8 args in `x0-x7` (vs `rdi, rsi, rdx, rcx, r8, r9` in x86-64)
- **Return value:** in `x0` (vs `rax`)
- **Return address:** `bl` (branch with link) stores it in register `x30` instead of pushing it on the stack like x86's `call`
- **Instructions:** `stp/ldp` (store/load pair) instead of `push/pop`

## Machine code

`a9be4ff4` is the **machine code**: the binary instruction, written in hexadecimal, that the CPU actually executes.

- **Left column** (`a9be4ff4`): the raw bytes, as stored in memory
- **Right column** (`stp x20, x19, [sp, #-0x20]!`): the human-readable instruction

The CPU doesn't understand "stp". It only understands the bit pattern `10101001101111100100111111110100` (which is `a9be4ff4` in hex).

**How ARM64 encodes this instruction:**

```text
a9be4ff4 (hex) = 1010 1001 1011 1110 0100 1111 1111 0100 (binary)

Broken down:
- Bits [31-22]: 1010100110 = STP, 64-bit registers, pre-index form
- Bits [21-15]: 1111100    = imm7 = -4, scaled by 8 bytes = -32 = -0x20
- Bits [14-10]: 10011      = Rt2 = x19 (second register)
- Bits [9-5]:   11111      = Rn  = sp  (base address)
- Bits [4-0]:   10100      = Rt  = x20 (first register)
```

Every ARM64 instruction is exactly 4 bytes. x86-64 instructions vary from 1 to 15 bytes:

```text
55              push rbp         ; 55 is the machine code
48 89 e5        mov rbp, rsp     ; 48 89 e5 is the machine code
```

The assembler (NASM for this project) translates human-readable assembly into machine code. A disassembler does the reverse: machine code into assembly.

To see the x86-64 disassembly of this project, build it on a Linux x86-64 machine (or VM/container) and run `objdump -d -M intel` on the object files (see [some_commands.md](some_commands.md)).
