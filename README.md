*This project has been created as part of the 42 curriculum by lbrusa.*

# libasm

## Description

**libasm** ("Assembly yourself!") is a 42 project whose goal is to become familiar with assembly language by re-implementing a few well-known C library functions in 64-bit x86 assembly and packaging them into a static library, `libasm.a`.

**Constraints from the subject:**

- 64-bit assembly, following the System V AMD64 calling convention
- Separate `.s` files (no inline ASM), assembled with `nasm`
- Intel syntax (not AT&T)
- The `-no-pie` compilation flag is forbidden, so the code must be position-independent
- Syscall errors must be handled and `errno` must be set (through `__errno_location` on Linux, `___error` on macOS)

**Mandatory functions:**

| Function | Behaves like |
|----------|--------------|
| `ft_strlen` | `man 3 strlen` |
| `ft_strcpy` | `man 3 strcpy` |
| `ft_strcmp` | `man 3 strcmp` |
| `ft_write` | `man 2 write` (sets `errno` on failure) |
| `ft_read` | `man 2 read` (sets `errno` on failure) |
| `ft_strdup` | `man 3 strdup` (calls `malloc`, sets `errno` to `ENOMEM` on failure) |

**Bonus functions**, using this linked-list structure:

```c
typedef struct s_list
{
	void          *data;
	struct s_list *next;
} t_list;
```

| Function | Description |
|----------|-------------|
| `ft_atoi_base` | Converts a string written in a given base to an `int`; returns 0 for an invalid base (fewer than 2 characters, duplicates, `+`, `-` or whitespace) |
| `ft_list_push_front` | Allocates a new node and puts it at the head of the list |
| `ft_list_size` | Returns the number of nodes in the list |
| `ft_list_sort` | Sorts the list in ascending order using a `cmp` function (bubble sort, swapping the `data` pointers) |
| `ft_list_remove_if` | Removes every node whose data makes `cmp(data, data_ref)` return 0, freeing the data with `free_fct` and the node with `free` |

**Target platform:** Linux x86-64, NASM with `-f elf64`, Intel syntax.

## Instructions

### Requirements

- A Linux x86-64 machine (or VM/container). The code uses Linux syscall numbers, `__errno_location` and the ELF64 format, so it does not build natively on macOS.
- `nasm`, `make`, `ar` and a C compiler (`gcc` or `cc`)

On Debian or Ubuntu:

```bash
sudo apt-get install nasm build-essential
```

### Build

```bash
make          # builds the mandatory part into libasm-x86-64/libasm.a
make bonus    # adds the bonus functions to the same library
make clean    # removes the object files
make fclean   # also removes the library and the test binary
make re       # fclean + all
```

### Test

`main.c` is a test program that calls every function (mandatory and bonus) and prints the expected and actual results, including `errno` checks for `ft_read`, `ft_write` and `ft_strdup`.

```bash
make test     # builds the bonus library, compiles main.c against it, then runs ./test
```

To link the library into your own program:

```bash
gcc your_main.c -L libasm-x86-64 -lasm -o your_program
```

The same `make bonus` and `make test` steps run on every push through the GitHub Actions workflow in `.github/workflows/build-and-test.yml`.

### Project layout

```
.
├── libasm-x86-64/     # one .s file per function (bonus files end in _bonus.s)
├── libasm.h           # prototypes of the mandatory functions
├── libasm_bonus.h     # t_list and prototypes of the bonus functions
├── main.c             # test program
├── makefile
├── annotate_elf.sh    # hex dump of an object file, labelled by ELF section
└── *.md               # study notes (see "Further notes" below)
```

## Resources

- [Computer Systems: A Programmer's Perspective (CS:APP)](https://csapp.cs.cmu.edu/), Bryant and O'Hallaron, Carnegie Mellon. Chapter 3 (machine-level representation of programs) is the source of several examples below.
- [Linux System Call Table for x86-64](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/)
- [NASM documentation](https://www.nasm.us/docs.php)
- [System V AMD64 ABI](https://gitlab.com/x86-psABIs/x86-64-ABI)
- Man pages: `strlen(3)`, `strcpy(3)`, `strcmp(3)`, `strdup(3)`, `read(2)`, `write(2)`, `errno(3)`

### Use of AI

I used AI assistants (chat assistants and the Cursor editor) as a study partner and reviewer:

- **Explanations:** asking about concepts while learning, such as the calling convention, stack alignment before `call`, PIE and the PLT, the ELF64 layout of an object file, LLVM bitcode, and the history of `ssize_t`. Several of the Markdown notes in this repository are edited versions of those conversations.
- **Review:** asking for feedback on my assembly code (register preservation, stack alignment, `errno` handling) and help debugging segmentation faults.
- **Documentation:** proofreading and formatting this README and the notes.

I wrote the assembly and the test program myself and checked every explanation against the resources above and by running the code.

## Further notes

Topic notes kept alongside this README:

| File | Topic |
|------|-------|
| [stack-frame.md](stack-frame.md) | The function prologue (`push rbp` / `mov rbp, rsp`) |
| [leaf-functions.md](leaf-functions.md) | When a prologue can be skipped; why `syscall` does not use the stack |
| [ssize_t.md](ssize_t.md) | Why `ssize_t` exists and which header defines it |
| [linking.md](linking.md) | Static vs dynamic libraries, and where libc lives on macOS |
| [some_commands.md](some_commands.md) | Inspecting an object file with `xxd`, `objdump`, `readelf`, `nm` |
| [readme-mac.md](readme-mac.md) | Disassembling on an Apple Silicon Mac (ARM64) |
| [bitcode.md](bitcode.md) | What the `.bc` file produced by `clang -save-temps` is |
| [bit.md](bit.md) | Where the word "bit" comes from |

The rest of this README is my personal study notes from the project.

## What is assembly?

The subject defines it as:

> An assembly (or assembler) language, often abbreviated asm, is a low-level programming language for a computer, or other programmable device, in which there is a very strong (but often not one-to-one) correspondence between the language and the architecture's machine code instructions. Each assembly language is specific to a particular computer architecture. In contrast, most high-level programming languages are generally portable across multiple architectures but require interpreting or compiling. Assembly language may also be called symbolic machine code.

## What is ELF64?

**ELF64** stands for **Executable and Linkable Format, 64-bit**. It's the standard binary file format used on Linux and other Unix-like systems for:

- **Executables** - Programs you run
- **Object files** (`.o`) - Compiled but not yet linked code
- **Shared libraries** (`.so`) - Dynamic libraries
- **Core dumps** - Memory snapshots for debugging

`nasm -f elf64` tells NASM to generate 64-bit ELF object files that can be linked with other object files and libraries on Linux x86-64.

**Other NASM output formats:**

- `elf32` - 32-bit ELF (for x86, not x86-64)
- `macho64` - macOS 64-bit format (not used in this project)
- `win64` - Windows 64-bit format (not used in this project)

In this project every `.s` file is assembled with `nasm -f elf64` into a `.o` file, and the objects are archived into the static library `libasm.a`.

## x86-64 Register Reference Table

Each 64-bit register and its 32-bit, 16-bit and 8-bit parts:

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

- **Callee-saved** registers (rbx, rbp, r12-r15) must be saved and restored by a function that uses them
- **Caller-saved** registers can be freely modified by a function, so the caller cannot expect them to survive a `call`
- **rsp** always points to the top of the stack
- **rip** is the instruction pointer (program counter)

## Calling conventions - what are they?

On x86-64 Linux (the System V AMD64 ABI), the **calling convention** defines:

1. **How arguments are passed to functions:**
   - First 6 integer/pointer args: `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`
   - Extra args go on the stack

2. **How return values come back:**
   - Integer and pointer results in `rax`

3. **Which registers you must preserve:**
   - If you use `rbx`, `rbp`, `r12-r15`, you must save/restore them
   - `rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8-r11` can be freely modified

4. **Stack alignment:**
   - The stack must be 16-byte aligned **before** a `call` instruction

**Example for `strlen(const char *s)`:**

- Argument `s` comes in `rdi`
- Return the length in `rax`
- No need to preserve registers if you don't use callee-saved ones

**Example for `strcmp(const char *s1, const char *s2)`:**

- First arg in `rdi`, second in `rsi`
- Return the comparison result in `eax` (it's an `int`)

If the assembly functions don't follow this, they won't work correctly with C code that calls them (like `main.c`).

## Creating a Static Library

The project builds a **static library** (`.a` archive) with the `ar` (archiver) command. The library contains the assembled objects and is copied into the executable at link time.

**Static Library (`.a`):**

- Code is embedded into the executable at link time
- Larger executable size
- No external dependencies at runtime

**Dynamic Library (`.so` on Linux, `.dylib` on macOS, `.dll` on Windows):**

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
- `r` = insert files into archive (replacing existing ones)
- `c` = create archive if it doesn't exist
- `s` = write an index (equivalent to running `ranlib`)

## What is the -no-pie Flag?

The `-no-pie` flag disables Position Independent Executable (PIE) generation. By default, modern compilers produce PIE binaries, which can be loaded at random memory addresses for security (ASLR).

With `-no-pie`, the code and data are loaded at fixed addresses. This makes some assembly easier to write (you can use absolute addresses and call libc functions directly), but it reduces security. The subject forbids it, so every call to a libc function goes through the PLT (see [PIE Compatibility](#pie-position-independent-executable-compatibility)).

## AT&T vs Intel Assembly Formats

In the book "Computer Systems: A Programmer's Perspective" they write:

> In our presentation, we show assembly code in ATT format (named after AT&T, the company that operated Bell Laboratories for many years), the default format for gcc, objdump, and the other tools we will consider. Other programming tools, including those from Microsoft as well as the documentation from Intel, show assembly code in Intel format. The two formats differ in a number of ways. As an example, gcc can generate code in Intel format for the sum function using the following command line:
>
> `gcc -Og -S -masm=intel mstore.c`
>
> The Intel and ATT formats differ in the following ways:
>
> - The Intel code omits the size designation suffixes. We see instruction push and mov instead of pushq and movq.
> - The Intel code omits the '%' character in front of register names, using rbx instead of %rbx.
> - The Intel code has a different way of describing locations in memory—for example, QWORD PTR [rbx] rather than (%rbx).
> - Instructions with multiple operands list them in the reverse order. This can be very confusing when switching between the two formats.

NASM uses Intel syntax. The key differences from AT&T:

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

- Intel: `mov qword [rax], 0` (size keyword before the bracket)
- AT&T: `movq $0, (%rax)` (suffix on the instruction: b/w/l/q)

**Example:**

```nasm
; Intel syntax (NASM)
mov rax, [rdi + 1]
cmp rax, 0
add rsi, 1
```

NASM only accepts Intel syntax, so there is nothing to switch. It is generally easier to read than AT&T.

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

Note: this C version checks for a NULL pointer (the `testq %rdi, %rdi` in the output below). The real `strlen`, and my `ft_strlen`, do not: passing NULL is undefined behavior and crashes.

Compile to assembly with:

```bash
gcc -Og -S strlen.c
```

`-Og` applies only optimizations that keep the generated code close to the source, which makes it easier to read than `-O2`.

Essential AT&T-style output:

```gas
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

Minimal NASM code for `strlen` (this is `libasm-x86-64/ft_strlen.s`):

```nasm
section .text
global ft_strlen

ft_strlen:
    xor rax, rax            ; Initialize counter 'rax' to 0

.loop:
    cmp byte [rdi + rax], 0 ; Compare the character at s[rax] with the null terminator
    je .end                 ; If it's the end of the string, jump to .end
    inc rax                 ; Otherwise, increment the counter
    jmp .loop               ; Repeat the loop

.end:
    ret                     ; Return the count in 'rax'
```

No NULL pointer check, matching the original `strlen` behavior.

## NASM vs GCC

NASM (Netwide Assembler) is a standalone assembler for x86 and x86-64 that uses Intel syntax. GCC hands its output to the GNU assembler (GAS), which defaults to AT&T syntax.

**Key differences:**

- NASM: explicit `section`/`global` declarations, strict syntax, its own macro language
- GAS: AT&T syntax by default (Intel with `.intel_syntax`), designed as the back end of GCC, emits debugging directives from the compiler

## cmp

`cmp` subtracts its second operand from the first, throws the result away, and sets **several flags** in the FLAGS register:

```nasm
cmp byte [rdi + rax], 0
```

This computes `[rdi + rax] - 0` and sets:

- **ZF** (Zero Flag) = 1 if the result is zero (operands are equal)
- **SF** (Sign Flag) = 1 if the result is negative
- **CF** (Carry Flag) = 1 if an unsigned borrow occurred
- **OF** (Overflow Flag) = 1 if a signed overflow occurred

Then `je` (jump if equal) checks the **ZF flag**:

- If ZF = 1, the byte equals 0, so jump to `.end`
- If ZF = 0, the byte is not 0, so continue to `inc rax`

Conditional jumps like `je`, `jg`, `jl`, etc. each check a different combination of these flags.

By contrast, `lea` does not alter any flags, since it is intended for address computations.

## strcpy

`ft_strcpy` uses `cl`. What is `cl`?

`cl` is an 8-bit (1 byte) register: the **lowest byte** of `rcx`.

x86-64 register hierarchy for `rcx`:

```text
rcx  [63:0]  - full 64-bit register
ecx  [31:0]  - lower 32 bits
cx   [15:0]  - lower 16 bits
cl   [7:0]   - lower 8 bits (byte) ← This is what ft_strcpy uses
ch   [15:8]  - second byte (bits 8-15)
```

Since `strcpy` copies one **byte** (character) at a time, an 8-bit register is the natural choice. `al` or `dl` would work as well. `bl` would also work, but `rbx` is callee-saved, so the function would have to save and restore it.

Writing to `cl` does **NOT** zero the upper bits of `rcx`. Only the lower 8 bits are modified:

**8-bit/16-bit registers** - upper bits unchanged:

```nasm
mov rcx, 0x123456789ABCDEF0
mov cl, 0x42              ; rcx = 0x123456789ABCDE42 (only lower 8 bits changed)
mov cx, 0x1234            ; rcx = 0x123456789ABC1234 (only lower 16 bits changed)
```

**32-bit registers** - upper 32 bits are zeroed:

```nasm
mov rcx, 0x123456789ABCDEF0
mov ecx, 0x42             ; rcx = 0x0000000000000042 (upper 32 bits zeroed!)
```

## Linking and Testing

To assemble and link a single function by hand:

```bash
# Compile C to assembly (AT&T style) to see what the compiler does
gcc -Og -S strlen.c

# Assemble the NASM version into an object file
nasm -f elf64 ft_strlen.s -o ft_strlen.o

# Compile main and link it with the object file
gcc main.c ft_strlen.o -o test_strlen
./test_strlen
```

## PIE (Position-Independent Executable) Compatibility

With PIE, the OS can load the program at a random address on every run (ASLR). Without it, the program always sits at the same fixed address, which makes memory-corruption exploits easier to write.

**Why PIE is safer:**

- Fixed addresses are predictable and easier to exploit
- PIE enables ASLR, randomizing addresses each run

**How to call external functions in PIE:**

```nasm
	; Get the memory address of the global `errno` variable from libc.
	; The 'wrt ..plt' syntax is essential for PIE compatibility.
	call __errno_location wrt ..plt
```

This calls through the Procedure Linkage Table (PLT), which the dynamic linker fills with the real address of the function at runtime. The same applies to `malloc` and `free`.

## Loading 1 Byte vs 8 Bytes

- `mov cl, [r15]` loads 1 byte (8 bits) into the lowest byte of `rcx`
- `mov rcx, [r15]` loads 8 bytes (64 bits) into the whole `rcx` register

The size of the move depends on the register:

- `cl` → 8 bits
- `cx` → 16 bits
- `ecx` → 32 bits
- `rcx` → 64 bits

## Reading Data from a Pointer

When the size can't be inferred from a register (for example when storing an immediate), you need a NASM size specifier:

- `byte [addr]` = 8 bits (1 byte)
- `word [addr]` = 16 bits (2 bytes)
- `dword [addr]` = 32 bits (4 bytes)
- `qword [addr]` = 64 bits (8 bytes)
- `tword [addr]` = 80 bits (10 bytes)
- `oword [addr]` = 128 bits (16 bytes)
- `yword [addr]` = 256 bits (32 bytes)
- `zword [addr]` = 512 bits (64 bytes)

Example from `ft_list_push_front`, filling a new `t_list` node:

```nasm
mov qword [rax], r12        ; new_node->data = data  (offset 0)
mov qword [rax + 8], rdx    ; new_node->next = old head  (offset 8)
```

## Operand Addressing Modes in NASM Intel Syntax

From the CS:APP book, here are the x86-64 operand addressing modes in NASM Intel syntax (translated from AT&T):

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
- The scale factor `s` must be 1, 2, 4, or 8

## Push and Pop Instructions in NASM Intel Syntax

From the CS:APP book, `push` and `pop` are the stack operations.

**AT&T syntax (from the book):**

```gas
pushq %rax          # push 8 bytes from rax onto stack
popq %rdx           # pop 8 bytes from stack into rdx
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

**Stack visualization** (addresses grow upward on the page, the stack grows downward):

```text
Initially                 After push rax            After pop rdx

|  ....  |                |  ....  |                |  ....  |
|  ....  | ← rsp (0x108)  |  ....  |                |  ....  | ← rsp (0x108)
                          | 0x123  | ← rsp (0x100)  | 0x123  |   (still in memory,
                                                                 but no longer in use)
```

**Key points:**

- `push rax` decrements `rsp` by 8 (the stack grows downward) and writes `rax` to `[rsp]`
- `pop rdx` reads `[rsp]` into `rdx` and increments `rsp` by 8
- NASM needs no size suffix: `push rax` is 64-bit because `rax` is
- AT&T uses `pushq`/`popq` to specify 64-bit

## Integer Arithmetic Operations in NASM Intel Syntax

Common x86-64 integer arithmetic and logical operations (from CS:APP Figure 3.10):

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
lea rax, [rdi + 8]      ; rax ← rdi + 8 (no memory access)
inc rax                 ; rax ← rax + 1
sub rax, rbx            ; rax ← rax - rbx
imul rax, rcx           ; rax ← rax * rcx
and rax, 0xfff          ; rax ← rax & 0xfff (keep the lower 12 bits)
sal rax, 3              ; rax ← rax << 3 (multiply by 8)
sar rax, 2              ; rax ← rax >> 2 (arithmetic right shift)
```

## Load Effective Address (LEA) Examples in NASM Intel Syntax

`lea` (load effective address) is useful for computing addresses and for simple arithmetic:

| NASM Intel Syntax | Result (in rax) |
|-------------------|-----------------|
| `lea rax, [rdx + 9]` | rax ← rdx + 9 |
| `lea rax, [rdx + rbx]` | rax ← rdx + rbx |
| `lea rax, [rdx + rbx * 4]` | rax ← rdx + rbx × 4 |
| `lea rax, [rbx * 8 + 2]` | rax ← rbx × 8 + 2 |

The scale can only be 1, 2, 4 or 8, so `[rdx + rbx * 3]` is not valid.

**Key advantage:** `lea` performs arithmetic without affecting CPU flags (unlike `add`, `sub`, etc.), which makes it handy for quick calculations.

## LEA in Real Code: Computing Polynomials

This example from CS:APP shows how a compiler uses `lea` for arithmetic:

**C code:**

```c
long scale(long x, long y, long z) {
    long t = x + 4 * y + 12 * z;
    return t;
}
```

**Arguments:**

- `rdi` = x (first argument)
- `rsi` = y (second argument)
- `rdx` = z (third argument)

**Assembly translation in NASM Intel syntax:**

```nasm
scale:
    lea rax, [rdi + rsi * 4]      ; rax = x + 4*y
    lea rdx, [rdx + rdx * 2]      ; rdx = z + 2*z = 3*z
    lea rax, [rax + rdx * 4]      ; rax = (x + 4*y) + 3*z*4 = x + 4*y + 12*z
    ret
```

1. First `lea`: computes `x + 4*y` using the base + scaled index addressing mode
2. Second `lea`: computes `3*z` as `z + z*2`
3. Third `lea`: adds the results: `(x + 4*y) + (3*z)*4 = x + 4*y + 12*z`

The compiler decomposes `12*z` into `(3*z)*4` because a scale of 12 is not allowed.

```nasm
lea rdx, [rdx + rdx * 2]
```

This does NOT dereference. It just computes the value `rdx + rdx*2` and stores it in `rdx`. No memory access happens.

## Little-Endian vs Big-Endian

**Endianness** describes how multi-byte values are stored in memory:

- **Little-Endian:** least significant byte first (at the lowest address)
- **Big-Endian:** most significant byte first (at the lowest address)

**x86-64 is little-endian.**

### Example: 64-bit hexadecimal value

Storing the 64-bit value `0x123456789ABCDEF0` in memory starting at address `0x1000`:

**Little-Endian (x86-64):**

```text
Address:  0x1000 0x1001 0x1002 0x1003 0x1004 0x1005 0x1006 0x1007
Value:    0xF0   0xDE   0xBC   0x9A   0x78   0x56   0x34   0x12
```

The lowest byte `0xF0` is at the lowest address, so the value looks "backwards" in a hex dump.

**Big-Endian:**

```text
Address:  0x1000 0x1001 0x1002 0x1003 0x1004 0x1005 0x1006 0x1007
Value:    0x12   0x34   0x56   0x78   0x9A   0xBC   0xDE   0xF0
```

The highest byte `0x12` is at the lowest address.

### NASM Assembly Example

```nasm
mov rax, 0x123456789ABCDEF0
mov qword [rdi], rax          ; store the 64-bit value at [rdi]
```

`mov` can't store a 64-bit immediate directly to memory, hence the detour through `rax`. If `rdi` points to `0x1000`:

- Byte at `[rdi + 0]` = `0xF0`
- Byte at `[rdi + 1]` = `0xDE`
- Byte at `[rdi + 2]` = `0xBC`
- Byte at `[rdi + 3]` = `0x9A`
- Byte at `[rdi + 4]` = `0x78`
- Byte at `[rdi + 5]` = `0x56`
- Byte at `[rdi + 6]` = `0x34`
- Byte at `[rdi + 7]` = `0x12`

So:

- In the register, the value is simply `0x123456789ABCDEF0`
- In memory, its bytes are stored in little-endian order

### Why This Matters

When you pick bytes out of a multi-byte value, you must know which byte is which:

```nasm
mov rax, 0x123456789ABCDEF0
mov byte [rdi], al       ; [rdi + 0] = 0xF0 (bits 0-7)
mov byte [rdi + 1], ah   ; [rdi + 1] = 0xDE (bits 8-15)

; ah only reaches bits 8-15; for the higher bytes, shift them down into al:
mov rax, 0x123456789ABCDEF0
mov byte [rdi], al              ; [rdi + 0] = 0xF0
shr rax, 8
mov byte [rdi + 1], al          ; [rdi + 1] = 0xDE
; ... etc
```

## The Meaning of 0xFFF

`0xfff` (4095 decimal, twelve 1-bits) shows up often in low-level code:

**1. Memory Alignment & Page Boundaries**

- Memory pages are usually 4 KB = 4096 = `0x1000` bytes, so `0xfff` is the page-offset mask
- `address & 0xfff` gives the offset within a page
- `address & ~0xfff` gives the page-aligned base address

**2. Hardware Register Masks**

- Masking the lower 12 bits is common in MMUs (page tables) and interrupt controllers

**3. Assembly Context**

```nasm
; Align stack to 16-byte boundary (clears the lower 4 bits)
and rsp, 0xfffffffffffffff0
; Check if address is page-aligned
test rdi, 0xfff
jz page_aligned
; Get page offset
mov rax, rdi
and rax, 0xfff
```

**4. Security and Reverse Engineering**

- ASLR randomizes addresses at page granularity, so the lower 12 bits of an address stay the same between runs. That is useful when debugging, and it is also why partial-overwrite exploits target them.

## My Last Function: `ft_list_remove_if`

This function can be tricky to understand at first. The key part is unlinking a node, which is different when the node is the head of the list. In C:

```c
if (prev)
    prev->next = current->next;
else
    *begin_list = current->next;
```

In my assembly, `rbx` is the current node and `r12` is the previous node (NULL at the start). `begin_list` was pushed last in the prologue, so it sits at `[rsp]`:

```nasm
    mov     rcx, qword [rbx + 8]; rcx = current_node->next

    test    r12, r12            ; Is prev_node (r12) NULL?
    jz      .remove_head        ; If prev is NULL, we are removing the head

    ; Removing a middle/tail node
    mov     qword [r12 + 8], rcx; prev_node->next = current_node->next
    jmp     .free_payload

.remove_head:
    mov     rax, qword [rsp]    ; Recover begin_list (t_list **) from our stack slot
    mov     qword [rax], rcx    ; *begin_list = current_node->next
```

After unlinking, the node's data is freed with `free_fct`, and `current->next` is saved in a scratch register before the node itself is freed with `free`. Reading `current->next` after `free(current)` would be a use-after-free.

### Alternative: a branchless version with `cmove`

When I compiled the C version with optimizations, the compiler avoided the branch with a conditional move. Here `rbp` is `prev` and `r12` holds `begin_list`:

```nasm
lea rax, [rbp + 8]         ; rax = address of prev->next (garbage if prev is NULL)
test rbp, rbp              ; is prev NULL?
cmove rax, r12             ; if prev is NULL, rax = begin_list (address of the head pointer)
mov rcx, qword [rbx + 8]   ; rcx = current->next
mov qword [rax], rcx       ; update whichever pointer rax points to
```

- When `prev != NULL`, `cmove` does nothing and `rax` keeps `&prev->next` from `lea`.
- When `prev == NULL`, `lea` computed `0 + 8 = 8`, which is a garbage address, but `cmove` replaces it with `begin_list` before anything is dereferenced.

Both cases end with `rax` holding the address of the pointer to update. `lea` never touches memory, so computing the garbage address is harmless.

## SET

The **`setcc`** instructions set a single **byte** to 0 or 1 based on the CPU flags.

```c
int comp(long a, long b) {
    return a < b;
}
```

```nasm
comp:
    cmp rdi, rsi           ; Compare a:b (sets condition flags)
    setl al                ; al = 1 if a < b, else 0
    movzx eax, al          ; Zero-extend al into eax
    ret
```

1. `cmp rdi, rsi` - compares the values and sets the CPU flags
2. `setl al` - if the "less than" condition holds, sets `al = 1`, else `al = 0`
3. `movzx eax, al` - zero-extends the byte to 32 bits (which also clears the upper half of `rax`)

**Common `set` instructions:**

- `sete` - Set if equal (ZF = 1)
- `setne` - Set if not equal (ZF = 0)
- `setl` - Set if less (signed)
- `setg` - Set if greater (signed)
- `setle` - Set if less or equal (signed)
- `setge` - Set if greater or equal (signed)
- `setz` - Set if zero (synonym of `sete`)
- `setnz` - Set if not zero (synonym of `setne`)

Each sets the destination byte to 1 if the condition is true, 0 if false.

## Calling functions

From CS:APP:

> Passing control from function P to function Q involves simply setting the program counter (PC) to the starting address of the code for Q. However, when it later comes time for Q to return, the processor must have some record of the code location where it should resume the execution of P. This information is recorded in x86-64 machines by invoking procedure Q with the instruction call Q. This instruction pushes an address A onto the stack and sets the PC to the beginning of Q. The pushed address A is referred to as the return address and is computed as the address of the instruction immediately following the call instruction. The counterpart instruction ret pops an address A off the stack and sets the PC to A.

## Quick Reference Notes

**ISA** - Instruction Set Architecture

**RIP** - Program counter (instruction pointer)

**gcc -Og -S main.c** - Compile to assembly with light, debug-friendly optimization

**x86 history:**

- 1978: 8086, the first 16-bit x86
- 1985: i386, the first 32-bit x86 (IA-32)
- 2003: AMD64 (x86-64), the 64-bit extension introduced by AMD with the Opteron and Athlon 64, later adopted by Intel

**Register convention:**

- **6 registers** for integer/pointer arguments: `rdi, rsi, rdx, rcx, r8, r9`
- **8 registers** for floating-point arguments: `xmm0-xmm7`

**Callee-saved registers** (must preserve): `rbx, rbp, r12-r15`
**Caller-saved registers** (can freely modify): `rax, rcx, rdx, rsi, rdi, r8-r11`

## strdup and malloc

`ft_strdup` calls `ft_strlen`, `malloc` and `ft_strcpy`, so it has to care about **stack alignment**. That means counting not only the registers you `push`, but also the **return address** that the `call` instruction places on the stack.

### The "Hidden" 8 Bytes

The `call` instruction does two things:

1. It pushes the address of the *next* instruction (the return address) onto the stack.
2. It jumps to the function.

So the moment execution enters `ft_strdup`, `rsp` has already moved down by **8 bytes**.

### The Math of the 16-Byte Rule

The System V ABI says: **"The stack must be 16-byte aligned *before* the `call` instruction is executed."**

Tracking `rsp` relative to 16 in `ft_strdup`:

1. **Before `ft_strdup` is called:** the stack is aligned (0 bytes offset).
2. **`call ft_strdup` happens:** the CPU pushes the return address, so the offset is **8 bytes**.
3. **`push r15`**: offset **16 bytes** (aligned).
4. **`push rbx`**: offset **24 bytes** (misaligned).
5. **`push r14`**: offset **32 bytes** (aligned), so it is safe to `call malloc`.

`r14` is not really needed in the function; it is pushed to restore the alignment. A `sub rsp, 8` would do the same job.

### What happens if you get it wrong?

If you call `malloc` (or any glibc function) with a misaligned stack, it may work most of the time. But as soon as the callee uses an SSE instruction that requires 16-byte-aligned stack memory (such as `movaps`), the program crashes with a segmentation fault (the CPU raises a general protection fault).

### `test rax, rax`

After `malloc`, `ft_strdup` checks for NULL with `test rax, rax`. This is a classic assembly idiom.

The `test` instruction performs a **bitwise AND** of its two operands but, unlike `and`, **does not store the result**. It only updates the flags.

With `test rax, rax`:

1. The CPU computes `rax & rax`, which is just `rax`.
2. It sets the **Zero Flag (ZF)** from that result:
   - **If `rax` is 0**, ZF is set to **1**.
   - **If `rax` is not 0**, ZF is set to **0**.

**Why `test` instead of `cmp rax, 0`?**

Both give the same result for this check, but `test rax, rax` encodes in 3 bytes versus 4 for `cmp rax, 0`, because it has no immediate operand. It is the idiom compilers emit.

Then:

- `je` (jump if equal) / `jz` (jump if zero) jumps if **ZF is 1**
- `jne` / `jnz` jumps if **ZF is 0**

```nasm
    test    rax, rax        ; ZF = 1 if rax is 0
    je      .malloc_error   ; jump if malloc returned NULL
```

You will sometimes see `or rax, rax` used for the same purpose. It also sets ZF without changing the value, but `test` is the standard way to ask "is this pointer NULL?".
