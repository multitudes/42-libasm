# Inspecting an object file

Commands to build an object file and look at it as hex, as disassembly, and as symbols, followed by a byte-by-byte walkthrough of `ft_strlen.o`. Run these on Linux: `readelf` and the ELF format are Linux-specific.

## Commands

```bash
# build objects (use `make bonus` if you need the bonus .o files)
make

# hex dump the object file
xxd -g 1 -c 16 libasm-x86-64/ft_strlen.o | less

# disassemble (Intel syntax)
objdump -d -M intel libasm-x86-64/ft_strlen.o | less

# list symbols
nm -C libasm-x86-64/ft_strlen.o
# or
readelf -sW libasm-x86-64/ft_strlen.o

# list sections with their file offsets
readelf -S libasm-x86-64/ft_strlen.o
objdump -h libasm-x86-64/ft_strlen.o
```

To inspect an object inside the archive:

```bash
# list archive members
ar t libasm-x86-64/libasm.a

# extract a single member, then inspect it
ar x libasm-x86-64/libasm.a ft_strlen.o
xxd -g 1 -c 16 ft_strlen.o | less
```

## Why do the offsets in `xxd` and `objdump` differ?

`objdump -d` prints addresses relative to the start of the section. For a relocatable `.o` file the section address is 0, because the linker only assigns final addresses later. `xxd` shows raw **file offsets**. The `.text` bytes are stored after the ELF header and the section header table, so they start at a higher file offset (here `0x180`) even though the disassembly starts at `0x0`.

Mapping rule:

```text
file_offset = sh_offset + (address - sh_addr)
```

For this object `sh_addr` is 0, so disassembly address `0x0` is file offset `sh_offset` = `0x180`.

## Section headers

```text
$ readelf -S libasm-x86-64/ft_strlen.o
There are 5 section headers, starting at offset 0x40:

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .text             PROGBITS         0000000000000000  00000180
       000000000000000f  0000000000000000  AX       0     0     16
  [ 2] .shstrtab         STRTAB           0000000000000000  00000190
       0000000000000021  0000000000000000           0     0     1
  [ 3] .symtab           SYMTAB           0000000000000000  000001c0
       0000000000000090  0000000000000018           4     5     8
  [ 4] .strtab           STRTAB           0000000000000000  00000250
       0000000000000042  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), l (large), p (processor specific)
```

**Columns:**

- **`[Nr]`**: section index in the section header table (0-based).
- **Name:** section name (e.g. `.text`, `.symtab`, `.strtab`).
- **Type:** section type (`PROGBITS` = program-defined data or code; `STRTAB` = string table; `SYMTAB` = symbol table; `NOBITS` = `.bss`-like, occupies no bytes in the file).
- **Address (`sh_addr`)**: the section's virtual address at runtime. For relocatable `.o` files this is `0x0` because the linker assigns final addresses later.
- **Offset (`sh_offset`)**: byte offset in the file where the section's data starts (what `xxd` shows).
- **Size (`sh_size`)**: length in bytes of the section data.
- **EntSize (`sh_entsize`)**: size of each entry if the section holds fixed-size entries (e.g. symbol table entries); `0` otherwise.
- **Flags:** `A` = alloc (occupies memory at runtime), `W` = writable, `X` = executable, `S` = strings, etc.
- **Link:** index of a related section. For `SYMTAB`, it points to the string table holding the symbol names (4 = `.strtab`).
- **Info:** section-specific extra info. For `SYMTAB` it is the index of the first global symbol (5).
- **Align:** required alignment (a power of two).

**The `.text` line decoded:**

- `Type = PROGBITS`: contains code bytes.
- `Address = 0x0`: relocatable object, no final address yet.
- `Offset = 0x180`: file offset where the code begins, which is why `xxd` shows the instructions at `0x180`.
- `Size = 0x0f`: 15 bytes of code.
- `Flags = AX`: allocated in memory and executable, as expected for code.
- `Align = 16`: placed at a 16-byte boundary when linked.

## Symbols

```bash
nm -C libasm-x86-64/ft_strlen.o
readelf -s libasm-x86-64/ft_strlen.o
```

The `.symtab` section holds 6 entries of 24 bytes each (0x90 = 144 = 6 × 24):

- **Num 0:** the mandatory empty entry.
- **Num 1:** `FILE` type, local: the source file name `libasm-x86-64/ft_strlen.s`.
- **Num 2:** `SECTION` type, local: refers to `.text` (Ndx = 1).
- **Num 3–4:** `ft_strlen.loop` and `ft_strlen.end`: local labels (Bind = LOCAL, Type = NOTYPE) at offsets `0x3` and `0xe` in `.text`. NASM prefixes local `.labels` with the name of the previous global label.
- **Num 5:** `ft_strlen`: the public function (Bind = GLOBAL, Type = NOTYPE) at offset `0x0` in `.text`.

**Why `ft_strlen.end` is at offset `0xe` (14):**

```text
   0:   48 31 c0                xor    rax,rax                         (3 bytes)
   3:   80 3c 07 00             cmp    BYTE PTR [rdi+rax*1],0x0        (4 bytes)
   7:   74 05                   je     e <ft_strlen.end>               (2 bytes)
   9:   48 ff c0                inc    rax                             (3 bytes)
   c:   eb f5                   jmp    3 <ft_strlen.loop>              (2 bytes)
   e:   c3                      ret                                    (1 byte) ← ft_strlen.end
```

3 + 4 + 2 + 3 + 2 = 14 bytes (`0x0e`), so the label lands on byte 14.

## Annotated hex dump

`annotate_elf.sh` (in the repository root) prints the `xxd` dump with a label for the section each line belongs to. The boundaries are hard-coded for `ft_strlen.o`, so it is only accurate for this file.

```bash
./annotate_elf.sh libasm-x86-64/ft_strlen.o
```

```text
00000000: 7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00  .ELF............ [ELF HEADER]
00000010: 01 00 3e 00 01 00 00 00 00 00 00 00 00 00 00 00  ..>............. [ELF HEADER]
00000020: 00 00 00 00 00 00 00 00 40 00 00 00 00 00 00 00  ........@....... [ELF HEADER]
00000030: 00 00 00 00 40 00 00 00 00 00 40 00 05 00 02 00  ....@.....@..... [ELF HEADER]
00000040: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
00000050: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
00000060: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
00000070: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
00000080: 01 00 00 00 01 00 00 00 06 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
00000090: 00 00 00 00 00 00 00 00 80 01 00 00 00 00 00 00  ................ [SECTION HEADERS]
000000a0: 0f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
000000b0: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
000000c0: 07 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
000000d0: 00 00 00 00 00 00 00 00 90 01 00 00 00 00 00 00  ................ [SECTION HEADERS]
000000e0: 21 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  !............... [SECTION HEADERS]
000000f0: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
00000100: 11 00 00 00 02 00 00 00 00 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
00000110: 00 00 00 00 00 00 00 00 c0 01 00 00 00 00 00 00  ................ [SECTION HEADERS]
00000120: 90 00 00 00 00 00 00 00 04 00 00 00 05 00 00 00  ................ [SECTION HEADERS]
00000130: 08 00 00 00 00 00 00 00 18 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
00000140: 19 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
00000150: 00 00 00 00 00 00 00 00 50 02 00 00 00 00 00 00  ........P....... [SECTION HEADERS]
00000160: 42 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  B............... [SECTION HEADERS]
00000170: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [SECTION HEADERS]
00000180: 48 31 c0 80 3c 07 00 74 05 48 ff c0 eb f5 c3 00  H1..<..t.H...... [.text CODE]
00000190: 00 2e 74 65 78 74 00 2e 73 68 73 74 72 74 61 62  ..text..shstrtab [.shstrtab]
000001a0: 00 2e 73 79 6d 74 61 62 00 2e 73 74 72 74 61 62  ..symtab..strtab [.shstrtab]
000001b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [.symtab]
000001c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [.symtab]
000001d0: 00 00 00 00 00 00 00 00 01 00 00 00 04 00 f1 ff  ................ [.symtab]
000001e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [.symtab]
000001f0: 00 00 00 00 03 00 01 00 00 00 00 00 00 00 00 00  ................ [.symtab]
00000200: 00 00 00 00 00 00 00 00 25 00 00 00 00 00 01 00  ........%....... [.symtab]
00000210: 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [.symtab]
00000220: 34 00 00 00 00 00 01 00 0e 00 00 00 00 00 00 00  4............... [.symtab]
00000230: 00 00 00 00 00 00 00 00 1b 00 00 00 10 00 01 00  ................ [.symtab]
00000240: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ [.symtab]
00000250: 00 6c 69 62 61 73 6d 2d 78 38 36 2d 36 34 2f 66  .libasm-x86-64/f [.strtab]
00000260: 74 5f 73 74 72 6c 65 6e 2e 73 00 66 74 5f 73 74  t_strlen.s.ft_st [.strtab]
00000270: 72 6c 65 6e 00 66 74 5f 73 74 72 6c 65 6e 2e 6c  rlen.ft_strlen.l [.strtab]
00000280: 6f 6f 70 00 66 74 5f 73 74 72 6c 65 6e 2e 65 6e  oop.ft_strlen.en [.strtab]
00000290: 64 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  d............... [.strtab]
```

The script labels whole lines, so a few are approximate. Line `0x1b0` is really the last byte of `.shstrtab` (at `0x1b0`) followed by alignment padding; `.symtab` starts at `0x1c0`. The zero bytes after the `ret` at `0x18f` and after `.strtab` (from `0x292`) are also padding.

**Overview:**

1. **ELF header** (`0x00`–`0x3f`)
2. **Section header table** (`0x40`–`0x17f`): 5 entries of 64 bytes
3. **`.text`** (`0x180`–`0x18e`): the 15 bytes of code
4. **`.shstrtab`** (`0x190`–`0x1b0`): section names
5. **`.symtab`** (`0x1c0`–`0x24f`): 6 symbol entries of 24 bytes
6. **`.strtab`** (`0x250`–`0x291`): symbol names

## The ELF header

The ELF header is 64 bytes: the first 4 lines of the dump. All multi-byte fields are **little-endian**, so `3e 00` is read as the 16-bit value `0x003e`.

### Line 1 (`0x00`–`0x0f`): `e_ident`, the file's "ID card"

`7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00`

| Bytes | Value | Name | Description |
| --- | --- | --- | --- |
| **0–3** | `7f 45 4c 46` | **Magic** | `0x7f` followed by `ELF`. |
| **4** | `02` | **Class** | `01` = 32-bit; `02` = **64-bit**. |
| **5** | `01` | **Data** | `01` = **little-endian**; `02` = big-endian. |
| **6** | `01` | **Version** | Always `01` for the current ELF version. |
| **7** | `00` | **OS/ABI** | `00` = **System V** (used by Linux and others). |
| **8** | `00` | **ABI Version** | Usually `00`. |
| **9–15** | `00...` | **Padding** | Reserved, unused. |

Before looking at anything else, the loader and linker use these bytes to check that the file is 64-bit (byte 4) and how to read every multi-byte integer that follows (byte 5).

### Line 2 (`0x10`–`0x1f`): type and target

`01 00 3e 00 01 00 00 00 00 00 00 00 00 00 00 00`

- **`01 00` (`e_type`):** `0x0001` = `ET_REL`, a relocatable object file (it needs linking).
- **`3e 00` (`e_machine`):** `0x003e` = AMD x86-64.
- **`01 00 00 00` (`e_version`):** ELF version 1.
- **Last 8 bytes (`e_entry`):** the entry point, where an executable starts running. It is `0` because a `.o` file has no entry point.

### Line 3 (`0x20`–`0x2f`): table offsets

`00 00 00 00 00 00 00 00 40 00 00 00 00 00 00 00`

- **First 8 bytes (`e_phoff`):** offset of the **program header table** = `0`. Program headers describe how to load an executable into memory; a `.o` file has none.
- **Last 8 bytes (`e_shoff`):** offset of the **section header table** = `0x40` (64). The section headers start right after the 64-byte ELF header.

### Line 4 (`0x30`–`0x3f`): sizes and counts

`00 00 00 00 40 00 00 00 00 00 40 00 05 00 02 00`

- **`00 00 00 00` (`e_flags`):** processor-specific flags, 0 on x86-64.
- **`40 00` (`e_ehsize`):** size of this ELF header = 64 bytes.
- **`00 00` (`e_phentsize`):** size of a program header entry = 0 (none).
- **`00 00` (`e_phnum`):** number of program headers = 0.
- **`40 00` (`e_shentsize`):** size of a section header entry = 64 bytes.
- **`05 00` (`e_shnum`):** number of sections = 5 (NULL, `.text`, `.shstrtab`, `.symtab`, `.strtab`).
- **`02 00` (`e_shstrndx`):** index of the section that holds the section names = 2 (`.shstrtab`).

Many fields are 8 bytes wide to fit 64-bit addresses and offsets. Since this object is tiny, most of those bytes are `00`: it looks like padding, but it is a series of 64-bit integers with small values.

## `.shstrtab`: section names

**`.shstrtab`** stands for **S**ection **H**eader **Str**ing **Tab**le.

Section headers are fixed-size binary structures. They don't contain the section names directly. Instead, each header has a `sh_name` field: an **index** into `.shstrtab`.

At offset `0x190`:

```text
00 2e 74 65 78 74 00 2e 73 68 73 74 72 74 61 62 00 ...
\0  .  t  e  x  t \0  .  s  h  s  t  r  t  a  b \0 ...
```

1. The first byte is a null byte (index 0 = empty name).
2. Index 1 starts `.text`, followed by a null byte.
3. Index 7 starts `.shstrtab`, and so on.

To print the name of section 1, `readelf` reads its `sh_name` (1), goes to `.shstrtab`, and reads from index 1 until the next null byte: `.text`.

### `.shstrtab` vs `.strtab`

The file has **two** string tables:

* **`.shstrtab`**: names of the **sections** (e.g. `.text`, `.symtab`).
* **`.strtab`**: names of the **symbols** in the code (e.g. `ft_strlen`, `ft_strlen.loop`).

They are separate so that tools like `strip` can remove the symbol table and its names without breaking the section table.

## The section header table

If the ELF header is the ID card, the section header table is the **map**: for each section, where it starts in the file, how big it is, and what it is for. Each entry is **64 bytes** (4 lines in the dump), and there are 5 entries.

### Entry 0: the NULL section (`0x40`–`0x7f`)

All zeros. Every ELF section table starts with a NULL entry, so that index 0 can mean "no section".

### Entry 1: `.text` (`0x80`–`0xbf`)

- **`01 00 00 00` (`sh_name`)**: index 1 in `.shstrtab` = `.text`.
- **`01 00 00 00` (`sh_type`)**: `SHT_PROGBITS`, data defined by the program (the code).
- **`06 00 00 00 ...` (`sh_flags`)**: `SHF_ALLOC` (2) + `SHF_EXECINSTR` (4): load it into memory and allow execution.
- **`80 01 00 00 ...` (`sh_offset`)**: `0x180`, exactly where `48 31 c0` (`xor rax, rax`) appears in the dump.
- **`0f 00 00 00 ...` (`sh_size`)**: 15 bytes.
- **`10 00 ...` (`sh_addralign`)**: 16.

### Entry 2: `.shstrtab` (`0xc0`–`0xff`)

- **`07 00 00 00` (`sh_name`)**: index 7 = `.shstrtab` (it names itself).
- **`03 00 00 00` (`sh_type`)**: `SHT_STRTAB`, a string table.
- **`90 01 00 00 ...` (`sh_offset`)**: `0x190`.
- **`21 00 ...` (`sh_size`)**: 33 bytes.

### Entry 3: `.symtab` (`0x100`–`0x13f`)

- **`11 00 00 00` (`sh_name`)**: index `0x11` = `.symtab`.
- **`02 00 00 00` (`sh_type`)**: `SHT_SYMTAB`, a symbol table.
- **`c0 01 00 00 ...` (`sh_offset`)**: `0x1c0`.
- **`90 00 ...` (`sh_size`)**: 144 bytes.
- **`04 00 00 00` (`sh_link`)** and **`05 00 00 00` (`sh_info`)**: names are in section 4 (`.strtab`); the first global symbol is number 5.
- **`18 00 ...` (`sh_entsize`)**: 24 bytes per symbol entry.

### Entry 4: `.strtab` (`0x140`–`0x17f`)

- **`19 00 00 00` (`sh_name`)**: index `0x19` = `.strtab`.
- **`03 00 00 00` (`sh_type`)**: `SHT_STRTAB`.
- **`50 02 00 00 ...` (`sh_offset`)**: `0x250`, near the end of the file, where `libasm-x86-64/ft_strlen.s` and `ft_strlen` are stored.
- **`42 00 ...` (`sh_size`)**: 66 bytes.

### Summary

| Section Index | Name (via `sh_name`) | File Offset | Size |
| --- | --- | --- | --- |
| 0 | [NULL] | 0x0 | 0 |
| 1 | .text | **0x180** | 15 bytes |
| 2 | .shstrtab | **0x190** | 33 bytes |
| 3 | .symtab | **0x1C0** | 144 bytes |
| 4 | .strtab | **0x250** | 66 bytes |

The section header table works like a table of contents: the section data could be stored in any order, and as long as the offsets in this table were updated, tools would still find everything.

### Reading one symbol entry

Symbol 5 (`ft_strlen`) starts at `0x1c0 + 5 × 24 = 0x238`:

```text
00000230: .. .. .. .. .. .. .. .. 1b 00 00 00 10 00 01 00
00000240: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
```

- **`1b 00 00 00` (`st_name`)**: index `0x1b` in `.strtab` = `ft_strlen`.
- **`10` (`st_info`)**: binding GLOBAL (high 4 bits = 1), type NOTYPE (low 4 bits = 0).
- **`00` (`st_other`)**: default visibility.
- **`01 00` (`st_shndx`)**: defined in section 1 (`.text`).
- **8 bytes (`st_value`)**: offset `0` in `.text`.
- **8 bytes (`st_size`)**: `0` (NASM doesn't record a size unless you declare one).

Symbol 4 at `0x220` is `ft_strlen.end`: name index `0x34`, local, value `0x0e`.

## ELF on Linux vs Mach-O on macOS

This object file is **ELF64**, the standard format on Linux and the BSDs. Assembling the same code on a Mac changes the file format, the symbol names, and possibly the whole instruction set.

### 1. The file format: Mach-O vs ELF

macOS doesn't use ELF; it uses **Mach-O** (Mach Object).

* **Magic bytes:** instead of `7f 45 4c 46`, a 64-bit Mach-O file starts with `cf fa ed fe` (the value `0xfeedfacf`, stored little-endian).
* **Structure:** instead of a section header table, Mach-O is organized around **load commands**, which describe segments (containing sections) and how to map them into memory.

### 2. The architecture: Intel vs Apple Silicon

#### Intel Mac (x86-64)

Same instruction set as Linux x86-64, but a different ABI in the details:

* **Underscore prefix:** C symbols get a leading underscore, so the assembly label must be `_ft_strlen`, or the linker won't find it.
* **Syscalls:** macOS syscall numbers differ from Linux (and have `0x2000000` added), and errors are reported through the carry flag instead of a negative return value.
* **errno:** the function is `___error` instead of `__errno_location`.

#### Apple Silicon Mac (ARM64)

A completely different instruction set. Every instruction is exactly 4 bytes (x86-64 instructions are 1 to 15 bytes).

* **Instructions:** `xor rax, rax` becomes `mov x0, #0`.
* **Registers:** instead of `rax`, `rdi`, `rsi`, you use `x0`, `x1`, `x2`, etc.
* **Format:** still Mach-O, with the CPU type set to ARM64.

### 3. Comparison Table

| Feature | Linux (this file) | Intel Mac | Apple Silicon Mac |
| --- | --- | --- | --- |
| **Format** | ELF64 | Mach-O 64 | Mach-O 64 |
| **Magic** | `7f 45 4c 46` | `cf fa ed fe` | `cf fa ed fe` |
| **Architecture** | x86-64 | x86-64 | **AArch64 (ARM64)** |
| **Symbol naming** | `ft_strlen` | `_ft_strlen` | `_ft_strlen` |
| **Syscall instruction** | `syscall` | `syscall` | `svc #0x80` |

### 4. Other Unix systems

* **FreeBSD/OpenBSD:** also **ELF**. The format is the same, but syscall numbers and the error convention differ from Linux, so the syscall wrappers still need changes.
* **Solaris/illumos:** also ELF.

### For the libasm project

This project targets Linux x86-64 only. Supporting macOS as well would need a separate version: `macho64` output, underscore-prefixed symbols, macOS syscall numbers, and `___error`. On Apple Silicon it would need a full ARM64 rewrite.
