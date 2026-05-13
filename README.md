# Learning Assembly: libasm Project

These are my personal notes for the 42 school libasm project.

**Target Platform:** Linux x86-64 (Intel 64-bit architecture)  
**Assembler:** NASM (Netwide Assembler) with `-f elf64` flag  
**Syntax:** Intel assembly syntax

## What is assembly
From the school's subject I quote the definition:
> An assembly (or assembler) language, often abbreviated asm, is a low-level programming language for a computer, or other programmable device, in which there is a very strong (but often not one-to-one) correspondence between the language and the architecture’s machine code instructions. Each assembly language is specific to a particular computer architecture. In contrast, most high-level programming languages are generally portable across multiple architectures but require interpreting or compiling. Assembly language may also be called symbolic machine code.

## What is ELF64?

**ELF64** stands for **Executable and Linkable Format, 64-bit**. It's the standard binary file format used on Linux and other Unix-like systems for:

- **Executables** - Programs you run
- **Object files** (`.o`) - Compiled but not yet linked code
- **Shared libraries** (`.so`) - Dynamic libraries
- **Core dumps** - Memory snapshots for debugging

When you use `nasm -f elf64`, you're telling NASM to generate 64-bit object files in ELF format that can be linked with other object files and libraries on Linux x86-64 systems.

**Other formats:**

- `elf32` - 32-bit ELF (for x86, not x86-64)
- `macho64` - macOS 64-bit format (not used in this project)
- `win64` - Windows 64-bit format (not used in this project)

For this project, all `.s` assembly files are assembled with `nasm -f elf64` to produce `.o` object files, which are then archived into a static library (`.a`) or linked into an executable.

## Calling conventions - what are they?

On 64-bit x86-64 (which I am targeting with `-f elf64`), the **calling convention** defines:

1. **How arguments are passed to functions:**
   - First 6 integer/pointer args: `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`
   - Extra args go on the stack

2. **How return values come back:**
   - Integer results in `rax`

3. **Which registers you must preserve:**
   - If you use `rbx`, `rbp`, `r12-r15`, you must save/restore them
   - `rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8-r11` can be freely modified

4. **Stack alignment:**
   - The stack must be 16-byte aligned **before** a `call` instruction

**Example for `strlen(const char *s)`:**

- Argument `s` comes in `rdi`
- Return the length in `rax`
- No need to preserve registers if you don't use them

**Example for `strcmp(const char *s1, const char *s2)`:**

- First arg in `rdi`, second in `rsi`
- Return comparison result in `rax`

If the assembly functions don't follow this, they won't work correctly with C code that calls them (like your main.c).

## Creating a Static Library

I am building a **static library** (`.a` archive) using the `ar` (archiver) command. This library contains my assembly implementations and is linked into my executable at compile time.
All x86-64 assembly code is written in Intel syntax, specifically for the `nasm` assembler.

**Static Library (`.a`):**

- Code is embedded into the executable at link time
- Larger executable size
- No external dependencies at runtime

**Dynamic Library (`.so` on Linux, `.dll` on Windows):**

- Code remains separate, loaded at runtime
- Smaller executable size
- Requires the library to be present on the target system

**Makefile Example:**

```makefile
$(NAME): $(OBJS)
	ar rcs $@ $^
```

The `ar rcs` command:

- `ar` = archiver tool
- `r` = insert files into archive
- `c` = create archive if it doesn't exist
- `s` = write an index (equivalent to running `ranlib`)

I will rewrite the following C functions in assembly:

- strlen (man 3 strlen)
- my_strcpy (man 3 my_strcpy)
- strcmp (man 3 strcmp)
- write (man 2 write)
- read (man 2 read)
- strdup (man 3 strdup, I will call malloc)

 I will use this struct for the linked list functions:

```c
typedef struct s_list {
	void *data;
	struct s_list *next;
} t_list;
```
And as bonus:

- ft_atoi_base - converts an integer to different bases
- ft_list_push_front
- ft_list_size 
- ft_list_sort 
- ft_list_remove_if - remove a node if a compare function says the node is same

Error handling:

- Check for errors during syscalls and handle them properly
- Set the variable `errno` as needed
- Call the external `__errno_location` (or `___error` on some systems)

## What is the --no-pie Flag?

The `--no-pie` compilation flag disables Position Independent Executable (PIE) generation. By default, modern compilers produce PIE binaries, which can be loaded at random memory addresses for security (ASLR).

If you use `--no-pie`, the binary is not position-independent, meaning its code and data are loaded at fixed addresses. This can make certain assembly code easier to write, especially when using absolute addresses, but it reduces security and is not allowed in many coding standards.

## ATT vs Intel Assembly Formats

In the book "Computer Systems: A Programmer's Perspective" they write:
> In our presentation, we show assembly code in ATT format (named after AT&T, the company that operated Bell Laboratories for many years), the default format for gcc, objdump, and the other tools we will consider.  
Other programming tools, including those from Microsoft as well as the documentation from Intel, show assembly code in Intel format. The two formats differ in a number of ways. As an example, gcc can generate code in Intel format for the sum function using the following command line:
```bash
gcc -Og -S -masm=intel mstore.c
```
> The Intel and ATT formats differ in the following ways:

>- The Intel code omits the size designation suffixes. We see instruction push and mov instead of pushq and movq.
>- The Intel code omits the ‘%’ character in front of register names, using rbx instead of %rbx.
>- The Intel code has a different way of describing locations in memory—for example, QWORD PTR [rbx] rather than (%rbx).
>- Instructions with multiple operands list them in the reverse order. This can be very confusing when switching between the two formats.

Intel syntax is an assembly language notation style used in NASM. Here are the key differences from AT&T syntax:

**Operand Order:**

- Intel: `mov destination, source`
- AT&T: `mov source, destination`

**Register Prefix:**

- Intel: `rax` (no prefix)
- AT&T: `%rax` (% prefix)

**Immediate Values:**

- Intel: `mov rax, 5` (no prefix)
- AT&T: `mov $5, %rax` ($ prefix)

**Memory Addressing:**

- Intel: `mov rax, [rbx + 8]` (brackets for memory)
- AT&T: `mov 8(%rbx), %rax` (parentheses, offset first)

**Size Directives:**

- Intel: `mov qword [rax], 0` (size keyword before bracket)
- AT&T: `movq $0, (%rax)` (suffix on instruction: b/w/l/q)

**Instruction Suffixes:**

- Intel: No suffix needed; size is explicit
- AT&T: `movq`, `movl`, `movw`, `movb` (q/l/w/b = quad/long/word/byte)

**Example:**

```nasm
; Intel syntax (NASM default)
mov rax, [rdi + 1]
cmp rax, 0
add rsi, 1
```

Since you're using NASM with `-f elf64`, you're already writing Intel syntax by default. This is generally clearer and easier to read than AT&T.Since you're using NASM with `-f elf64`, you're already writing Intel syntax by default. This is generally clearer and easier to read than AT&T.

## Starting with my version of strlen

Example C implementation:

```c
#include <stddef.h>

size_t strlen(const char *s) {
	size_t len = 0;
	while (s && s[len]) {
		len++;
	}
	return len;
}
```

Note: Like the original `strlen`, this does not check for NULL pointers and will fail with invalid input.

Compile with:
```bash
gcc -Og -S strlen.c
```

The `-Og` option disables optimizations for easier reading.

Essential ATT-style assembly:

```assembly
.text          # Executable code section
.globl strlen  # Function visible to linker
strlen:
	xor  %eax, %eax         # Clear counter
	jmp .L2
.L4:
	addq $1, %rax           # Increment counter
.L2:
	testq %rdi, %rdi        # Check pointer for NULL
	je .L1                  # If NULL, return
	cmpb $0, (%rdi,%rax)    # Compare byte at s[len]
	jne .L4                 # Loop if not zero
.L1:
	ret
```

## NASM Style

Minimal NASM-compatible code for `strlen`:

```nasm
section .text
global strlen
strlen:
	xor rax, rax            ; Initialize counter
.loop:
	cmp byte [rdi + rax], 0 ; Compare character at s[rax]
	je .end                 ; If null terminator, end
	inc rax                 ; Increment counter
	jmp .loop               ; Repeat
.end:
	ret                     ; Return count in rax
```
Note: No NULL pointer check, matching the original `strlen` behavior.

## NASM vs GCC

NASM (Netwide Assembler) is a standalone assembler for x86 and x86-64 architectures, using Intel syntax. GCC uses the GNU assembler (GAS), which defaults to AT&T syntax.

**Key differences:**

- NASM: explicit section/global declarations, strict syntax
- GCC/GAS: AT&T syntax, more high-level features and debugging info

## cmp

It sets **multiple flags** in the FLAGS register:

```assembly
cmp byte [rdi + rax], 0
```

This does: `[rdi + rax] - 0` and sets:

- **ZF** (Zero Flag) = 1 if result is zero (operands are equal)
- **SF** (Sign Flag) = 1 if result is negative
- **CF** (Carry Flag) = 1 if unsigned underflow
- **OF** (Overflow Flag) = 1 if signed overflow

Then `je` (jump if equal) checks the **ZF flag**:

- If ZF = 1 → the byte equals 0 → jump to `.end`
- If ZF = 0 → the byte is not 0 → continue to `inc rax`

So `cmp` sets multiple CPU flags based on the arithmetic result, and then conditional jumps like `je`, `jg`, `jl`, etc. check different combinations of these flags.

The leaq instruction does not alter any condition codes, since it is intended
to be used in address computations.

## strcpy

Here you will see `cl`. what is cl?

`cl` is an 8-bit (1 byte) register. It's the **lower byte** of the `rcx` register.

x86-64 register hierarchy for `rcx`:

```nasm
rcx  [63:0]  - full 64-bit register
ecx  [31:0]  - lower 32 bits
cx   [15:0]  - lower 16 bits
cl   [7:0]   - lower 8 bits (byte) ← This is what you're using
ch   [15:8]  - second byte (bits 8-15)
```

Since `strcpy` copies one **byte** (character) at a time, using `cl` is correct and efficient. You could also use:

- `byte [rsi]` with temporary register
- Other 8-bit registers like `al`, `bl`, `dl`

Writing to `cl` does **NOT** zero the upper bits of `rcx`. Only the lower 8 bits are modified.

Here's the x86-64 behavior:

**8-bit/16-bit registers** - upper bits unchanged:

```asm
mov rcx, 0x123456789ABCDEF0
mov cl, 0x42              ; rcx = 0x123456789ABCDE42 (only lower 8 bits changed)
mov cx, 0x1234            ; rcx = 0x123456789ABC1234 (only lower 16 bits changed)
```

**32-bit registers** - upper 32 bits are zeroed:

```asm
mov rcx, 0x123456789ABCDEF0
mov ecx, 0x42             ; rcx = 0x0000000000000042 (upper 32 bits zeroed!)
```

## Linking and Testing

To compile and link your assembly code:

```bash
# Compile C to assembly (ATT style)
gcc -Og -S strlen.c

# Compile main and link object file
gcc main.c strlen.o -o test_strlen

# For NASM style
nasm -f elf64 strlen.s -o strlen.o

gcc main.c strlen.o -o test_strlen
./test_strlen
```

## PIE (Position-Independent Executable) Compatibility

PIE-compatible code is much safer. Without PIE (`--no-pie`), your program loads at a fixed address, making it easier for attackers to exploit vulnerabilities. With PIE, the OS can randomize your program's memory location (ASLR), making attacks much harder.

**Why PIE is safer:**

- Fixed addresses are predictable and easier to exploit
- PIE enables ASLR, randomizing addresses each run

**How to call external functions in PIE:**

```nasm
	; Get the memory address of the global `errno` variable from libc.
	; The 'wrt ..plt' syntax is essential for PIE compatibility.
	call __errno_location wrt ..plt
```
This uses the Procedure Linkage Table (PLT) to resolve the address at runtime.

## Loading 1 Byte vs 8 Bytes

- `mov cl, [r15]` loads 1 byte (8 bits) into the lower part of `rcx`
- `mov rcx, [r15]` loads 8 bytes (64 bits) into the entire `rcx` register

The size of the move depends on the register:

- `cl` → 8 bits
- `cx` → 16 bits
- `ecx` → 32 bits
- `rcx` → 64 bits

## Reading Data from a Pointer

NASM size specifiers:

- `byte [addr]` = 8 bits (1 byte)
- `word [addr]` = 16 bits (2 bytes)
- `dword [addr]` = 32 bits (4 bytes)
- `qword [addr]` = 64 bits (8 bytes)
- `tword [addr]` = 80 bits (10 bytes)
- `oword [addr]` = 128 bits (16 bytes)
- `yword [addr]` = 256 bits (32 bytes)
- `zword [addr]` = 512 bits (64 bytes)

Example:

```nasm
mov qword [rax], rbp    ; store 64-bit data pointer
mov qword 8[rax], rdx   ; store 64-bit next pointer
```

The progression is: `byte` → `word` → `dword` → `qword` → `tword` → `oword` → `yword` → `zword`. 

## Operand Addressing Modes in NASM Intel Syntax

From the "Computer Systems" book, here are the x86-64 operand addressing modes in NASM Intel syntax (translated from AT&T):

| Type | NASM Intel Form | Example | Description |
|------|-----------------|---------|-------------|
| Immediate | `Imm` | `mov rax, 100` | Constant value (AT&T: `$Imm`) |
| Register | `reg` | `mov rax, rbx` | Register value |
| Memory (Absolute) | `[Imm]` | `mov rax, [0x600000]` | Constant address (AT&T: `Imm`) |
| Memory (Indirect) | `[reg]` | `mov rax, [rdi]` | Register as address (AT&T: `(reg)`) |
| Memory (Base + Displacement) | `[reg + Imm]` | `mov rax, [rbp + 8]` | Register plus offset (AT&T: `Imm(reg)`) |
| Memory (Indexed) | `[reg1 + reg2]` | `mov rax, [rbx + rcx]` | Two registers (AT&T: `(reg1, reg2)`) |
| Memory (Base + Indexed) | `[reg1 + Imm + reg2]` | `mov rax, [rbp + 8 + rcx]` | Displacement + two regs (AT&T: `Imm(reg1, reg2)`) |
| Memory (Scaled Index) | `[reg * s]` | `mov rax, [rcx * 8]` | Scaled register (AT&T: `(,reg,s)`) |
| Memory (Disp + Scaled) | `[Imm + reg * s]` | `mov rax, [8 + rcx * 4]` | Displacement + scaled (AT&T: `Imm(,reg,s)`) |
| Memory (Base + Scaled) | `[reg1 + reg2 * s]` | `mov rax, [rbp + rcx * 4]` | Base + scaled (AT&T: `(reg1, reg2, s)`) |
| Memory (Full) | `[reg1 + Imm + reg2 * s]` | `mov rax, [rbp + 8 + rcx * 4]` | All components (AT&T: `Imm(reg1, reg2, s)`) |

**Key differences from AT&T:**

- NASM uses `[...]` for memory (AT&T uses parentheses)
- No `$` prefix on immediates, no `%` on registers
- Operators within brackets: `+` for addition, `*` for scaling
- Scaling factor `s` must be 1, 2, 4, or 8

## Push and Pop Instructions in NASM Intel Syntax

From the "Computer Systems" book, `push` and `pop` are stack operations. Both work identically in NASM Intel syntax:

**AT&T syntax (from the book):**
```asm
pushq %rax          ; push 8 bytes from rax onto stack
popq %rdx           ; pop 8 bytes from stack into rdx
```

**NASM Intel syntax:**
```nasm
push rax            ; push 8 bytes from rax onto stack
pop rdx             ; pop 8 bytes from stack into rdx
```

**How it works (from the book's Figure 3.8):**

| Register | Initially | After `push rax` | After `pop rdx` |
|----------|-----------|------------------|-----------------|
| `rax` | 0x123 | 0x123 | 0x123 |
| `rdx` | 0 | 0 | 0x123 |
| `rsp` | 0x108 | 0x100 | 0x108 |

**Stack visualization:**
```
Step 1: Initially              Step 2: After push rax        Step 3: After pop rdx
--------                       --------                       --------
| .... |                       | ....  |                       | ....  |
| .... |                       | ....  |                       | ....  |
| .... | ← rsp (0x108)         | ....  |                       | ....  | ← rsp (0x108)
         Stack top             | 0x123 | ← rsp (0x100)         | 0x123 | 
  Stack top                     Stack top                      Stack top
```

**Key points:**

- `push rax` decrements `rsp` by 8 (stack grows downward) and writes `rax` to `[rsp]`
- `pop rdx` reads from `[rsp]` into `rdx` and increments `rsp` by 8
- In NASM Intel syntax, no size suffix needed (size determined by register: `push rax` is 64-bit)
- AT&T uses `pushq`/`popq` to specify 64-bit; NASM infers from the operand

## Integer Arithmetic Operations in NASM Intel Syntax

Common x86-64 integer arithmetic and logical operations (from the CS:APP book Figure 3.10):

| Instruction | NASM Syntax | Effect | Description |
|-------------|------------|--------|-------------|
| **lea** | `lea D, [S]` | D ← &S | Load effective address |
| **inc** | `inc D` | D ← D + 1 | Increment |
| **dec** | `dec D` | D ← D - 1 | Decrement |
| **neg** | `neg D` | D ← -D | Negate |
| **not** | `not D` | D ← ~D | Bitwise complement |
| **add** | `add D, S` | D ← D + S | Add |
| **sub** | `sub D, S` | D ← D - S | Subtract |
| **imul** | `imul D, S` | D ← D * S | Signed multiply |
| **xor** | `xor D, S` | D ← D ^ S | Exclusive-or |
| **or** | `or D, S` | D ← D \| S | Bitwise or |
| **and** | `and D, S` | D ← D & S | Bitwise and |
| **sal** | `sal D, k` | D ← D << k | Left shift (arithmetic) |
| **shl** | `shl D, k` | D ← D << k | Left shift (same as sal) |
| **sar** | `sar D, k` | D ← D >>A k | Arithmetic right shift |
| **shr** | `shr D, k` | D ← D >>L k | Logical right shift |

**Examples:**
```nasm
lea rax, [rdi + 8]      ; rax gets the address of rdi + 8
inc rax                 ; rax ← rax + 1
sub rax, rbx            ; rax ← rax - rbx
imul rax, rcx           ; rax ← rax * rcx
and rax, 0xfff          ; rax ← rax & 0xfff (mask lower 12 bits)
sal rax, 3              ; rax ← rax << 3 (multiply by 8)
sar rax, 2              ; rax ← rax >> 2 (arithmetic right shift)
```

## Load Effective Address (LEA) Examples in NASM Intel Syntax

The `lea` (load effective address) instruction is powerful for computing addresses and simple arithmetic:

| NASM Intel Syntax | Result (in rax) |
|-------------------|-----------------|
| `lea rax, [rdx + 9]` | rax ← rdx + 9 |
| `lea rax, [rdx + rbx]` | rax ← rdx + rbx |
| `lea rax, [rdx + rbx * 3]` | rax ← rdx + rbx × 3 |
| `lea rax, [rbx * 8 + 2]` | rax ← rbx × 8 + 2 |

**Key advantage:** `lea` performs arithmetic without affecting CPU flags (unlike `add`, `sub`, etc.), making it useful for quick calculations.

## LEA in Real Code: Computing Polynomials

Here's a great example from CS:APP showing how a compiler uses `lea` for arithmetic:

**C code:**
```c
long scale(long x, long y, long z) {
    long t = x + 4 * y + 12 * z;
    return t;
}
```

**Calling convention (x86-64):**
- `rdi` = x (first argument)
- `rsi` = y (second argument)
- `rdx` = z (third argument)

**Assembly translation in NASM Intel syntax:**
```nasm
scale:
    lea rax, [rdi + rsi * 4]      ; rax = x + 4*y (first part)
    lea rdx, [rdx + rdx * 2]      ; rdx = z + 2*z = 3*z
    lea rax, [rax + rdx * 4]      ; rax = (x + 4*y) + 3*z*4 = x + 4*y + 12*z
    ret
```

1. First `lea`: Computes `x + 4*y` using the base+scaled index addressing mode
2. Second `lea`: Computes `3*z` by computing `z + z*2` 
3. Third `lea`: Adds the results: `(x + 4*y) + (3*z)*4 = x + 4*y + 12*z`

The compiler cleverly decomposes `12*z` into `(3*z)*4` to fit within the addressing mode's capabilities. `lea` is ideal here because it performs multiple arithmetic operations (addition and multiplication by powers of 2) in a single instruction without modifying flags.

```nasm
lea rdx, [rdx + rdx * 2]
```

This does NOT dereference. It just computes the address rdx + rdx*2 and stores that address value in rdx. No memory access happens.

## Little-Endian vs Big-Endian

**Endianness** describes how multi-byte values are stored in memory:

- **Little-Endian:** Least significant byte first (low-order bytes at lower addresses)
- **Big-Endian:** Most significant byte first (high-order bytes at lower addresses)

**x86-64 is little-endian**, which is why it's important to understand for assembly programming.

### Example: 64-bit hexadecimal value

Let's store the 64-bit value `0x123456789ABCDEF0` in memory starting at address `0x1000`:

**Little-Endian (x86-64):**
```
Address:  0x1000 0x1001 0x1002 0x1003 0x1004 0x1005 0x1006 0x1007
Value:    0xF0   0xDE   0xBC   0x9A   0x78   0x56   0x34   0x12
```

The 64-bit value is stored **backwards** (LSB first). The lowest byte `0xF0` is at the lowest address.

**Big-Endian:**
```
Address:  0x1000 0x1001 0x1002 0x1003 0x1004 0x1005 0x1006 0x1007
Value:    0x12   0x34   0x56   0x78   0x9A   0xBC   0xDE   0xF0
```

The 64-bit value is stored **forwards** (MSB first). The highest byte `0x12` is at the lowest address.

### NASM Assembly Example

```nasm
mov qword [rax], 0x123456789ABCDEF0   ; Store the 64-bit value in memory at [rax]
```

If `rax` points to address `0x1000` (on x86-64 little-endian):

- Byte at `[rax + 0]` = `0xF0`
- Byte at `[rax + 1]` = `0xDE`
- Byte at `[rax + 2]` = `0xBC`
- Byte at `[rax + 3]` = `0x9A`
- Byte at `[rax + 4]` = `0x78`
- Byte at `[rax + 5]` = `0x56`
- Byte at `[rax + 6]` = `0x34`
- Byte at `[rax + 7]` = `0x12`

So:

- In register: the value is unchanged, it's 0x123456789ABCDEF0  
- When extracted as bytes: you get the little-endian byte order.
- When written to memory: those bytes are stored in little-endian order.

### Why This Matters

When manipulating multi-byte values in assembly (especially in struct fields), you must account for endianness:

```nasm
mov rax, 0x123456789ABCDEF0
mov byte [rdi], al       ; [rdi + 0] = 0xF0
mov byte [rdi + 1], ah   ; [rdi + 1] = 0xDE

; better:
mov rax, 0x123456789ABCDEF0
mov byte [rdi], al              ; [rdi + 0] = 0xF0
shr rax, 8
mov byte [rdi + 1], al          ; [rdi + 1] = 0xDE
; ... etc
```

## The Meaning of 0xFFF

`0xfff` (4095 decimal) is significant in low-level programming:

**1. Memory Alignment & Page Boundaries**

- Used as a page size mask for 4KB pages
- `address & 0xfff` gives offset within a page
- `address & ~0xfff` gives page-aligned base address

**2. Buffer Overflow & Exploitation**

- Return addresses, stack canaries, heap metadata, shellcode addresses

**3. Hardware Register Masks**

- Masks out lower 12 bits, common in MMUs and interrupt controllers

**4. Assembly Context**

```assembly
; Align stack to 16-byte boundary
and rsp, 0xfffffffffffffff0
; Check if address is page-aligned
test rdi, 0xfff
jz page_aligned
; Get page offset
mov rax, rdi
and rax, 0xfff
```

**5. Exploitation Techniques**

- ASLR bypass, heap manipulation, format string attacks

**6. Security Research**

- Memory corruption, fuzzing, reverse engineering

`0xfff` is a natural boundary in computer systems, often used for alignment and security analysis.

## My Last Function: `list_remove_if`

This function can be tricky to understand at first. Here is the relevant assembly, compiled from C and adapted for NASM:

```nasm
lea rax, [rbp + 8]         ; rax = address of prev->next (if prev is not NULL)
test rbp, rbp              ; test if prev is NULL
cmove rax, r12             ; if prev is NULL, rax = r12 (address of *begin_list)
mov rcx, qword [rbx + 8]   ; rcx = current->next
mov qword [rax], rcx       ; update pointer
```

This matches the C logic:

```c
if (prev)
    prev->next = current->next;
else
    *begin_list = current->next;
```

Before removing a node, I check if there is a previous node. If not, the node to remove is the head of the list. In assembly, I first calculate the address for `prev->next` and store it in `rax`. If `prev` is NULL, this would be a garbage address, but the conditional move (`cmove`) updates `rax` to the correct address (`*begin_list`). I then update the pointer to skip the node being removed.

### Case 1: `rbp != NULL` (removing a middle or end node)

```nasm
lea rax, [rbp + 8]      ; rax = address of prev->next
test rbp, rbp           ; rbp is NOT NULL
cmove rax, r12          ; does NOT execute (condition false)
mov qword [rax], rcx    ; prev->next = current->next
```

### Case 2: `rbp == NULL` (removing the first node)

```nasm
lea rax, [rbp + 8]      ; rax = 0 + 8 = 8 (garbage address)
test rbp, rbp           ; rbp IS NULL (zero flag set)
cmove rax, r12          ; executes! rax = r12 = &(*begin_list)
mov qword [rax], rcx    ; *begin_list = current->next
```

- When `rbp != NULL`, `rax` keeps the correct address from `lea`.
- When `rbp == NULL`, `cmove` overwrites `rax` with the correct address (`r12`).

The initial `lea` result (8) when `rbp` is NULL is garbage, but it is immediately replaced by `cmove` with the proper value. This way, both cases end up with `rax` containing the right address to update, and I avoid any segfaults or undefined behavior.

## SET

The **`set` instruction** sets a single **byte** to 0 or 1 based on CPU condition flags.

```c
int comp(data_t a, data_t b) {
    // ...compare a and b...
    // return 1 if a < b, else 0
}
```

```nasm
comp:
    cmp rdi, rsi           ; Compare a:b (sets condition flags)
    setl al                ; Set al to 0 or 1 (1 if a < b)
    movzx eax, al          ; Zero-extend al to 32-bit eax
    ret
```

1. `cmp rdi, rsi` - Compares the values and sets CPU flags
2. `setl al` - Checks the flags: if "less than" condition is true, sets `al = 1`, else `al = 0`
3. `movzx eax, al` - Zero-extends the byte result to 32 bits (clears upper bytes)

**Common `set` instructions (synonyms):**

- `sete` - Set if equal (ZF = 1)
- `setne` - Set if not equal (ZF = 0)
- `setl` - Set if less (signed) 
- `setg` - Set if greater (signed)
- `setle` - Set if less or equal
- `setge` - Set if greater or equal
- `setz` - Set if zero (same as `sete`)
- `setnz` - Set if not zero (same as `setne`)

Each sets the destination byte to 1 if the condition is true, 0 if false.

## Calling functions

Passing control from function P to function Q involves simply setting the program
counter (PC) to the starting address of the code for Q. However, when it later
comes time for Q to return, the processor must have some record of the code
location where it should resume the execution of P. This information is recorded
in x86-64 machines by invoking procedure Q with the instruction call Q. This
instruction pushes an address A onto the stack and sets the PC to the beginning
of Q. The pushed address A is referred to as the return address and is computed
as the address of the instruction immediately following the call instruction. The
counterpart instruction ret pops an address A off the stack and sets the PC to A.

## x86-64 Register Reference Table

Complete register breakdown showing 64-bit, 32-bit, 16-bit, and 8-bit portions:

| 64-bit | 32-bit | 16-bit | 8-bit Low | 8-bit High | Purpose | Calling Convention |
|--------|--------|--------|-----------|------------|---------|-------------------|
| **rax** | eax | ax | al | ah | Return value, accumulator | Caller-saved |
| **rbx** | ebx | bx | bl | bh | Base register | **Callee-saved** |
| **rcx** | ecx | cx | cl | ch | 4th argument, counter | Caller-saved |
| **rdx** | edx | dx | dl | dh | 3rd argument, data | Caller-saved |
| **rsi** | esi | si | sil | - | 2nd argument, source index | Caller-saved |
| **rdi** | edi | di | dil | - | 1st argument, destination index | Caller-saved |
| **rbp** | ebp | bp | bpl | - | Frame/base pointer | **Callee-saved** |
| **rsp** | esp | sp | spl | - | Stack pointer | **Special** |
| **r8** | r8d | r8w | r8b | - | 5th argument | Caller-saved |
| **r9** | r9d | r9w | r9b | - | 6th argument | Caller-saved |
| **r10** | r10d | r10w | r10b | - | General purpose | Caller-saved |
| **r11** | r11d | r11w | r11b | - | General purpose | Caller-saved |
| **r12** | r12d | r12w | r12b | - | General purpose | **Callee-saved** |
| **r13** | r13d | r13w | r13b | - | General purpose | **Callee-saved** |
| **r14** | r14d | r14w | r14b | - | General purpose | **Callee-saved** |
| **r15** | r15d | r15w | r15b | - | General purpose | **Callee-saved** |

**Notes:**
- **Callee-saved** registers (rbx, rbp, r12-r15) must be preserved if used
- **Caller-saved** registers can be freely modified
- **rsp** always points to the stack top
- **rip** is the instruction pointer (program counter)

## Quick Reference Notes

**ISA** - Instruction Set Architecture

**RIP** - Program counter (instruction pointer)

**gcc -Og -S main.c** - Compile to assembly with minimal optimization

**x86-64 / AMD64:**
- 64-bit (2002): Core i7, AVX 256-bit
- 32-bit (1985): i386
- First 16-bit: 8086 (1978)

**Register Convention:**
- **6 registers** for integer/pointer arguments: `rdi, rsi, rdx, rcx, r8, r9`
- **6 float registers** for floating-point: `xmm0-xmm5`

**Callee-saved registers** (must preserve): `rbx, rbp, r12-r15`  
**Caller-saved registers** (can freely modify): `rax, rcx, rdx, rsi, rdi, r8-r11`

**Stack:**
- Stack pointer: `rsp`
- **Fast** but **general temp storage**
- `rbx` is for base addressing

**Register roles:**
- `r8-r9`: 5th-6th arguments
- `r10-r11`: Caller-saved, general temp
- `r12-r15`: Callee-saved, general temp

## Resources

[Computer Systems: A Programmer's Perspective - Carnegie Mellon](https://csapp.cs.cmu.edu/)  
