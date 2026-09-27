# Linking: where do `printf` and `malloc` come from?

My question: when I call `printf` or `malloc`, are there thousands of individual `.o` files on my Mac, one per function?

**No.** A separate `.o` file for every function (`printf.o`, `malloc.o`, `strlen.o`) would mean millions of tiny files and slow linking. Instead, object code is bundled into **libraries**.

This note is about macOS, where I was experimenting. The project itself targets Linux, where the equivalents are `libc.so.6` (glibc) and `.a` / `.so` files.

---

## 1. The C library on macOS

The standard C functions (declared in headers like `<stdlib.h>`, `<stdio.h>`, `<string.h>`) are compiled ahead of time by Apple and shipped in a dynamic library. On macOS, libc is part of **`libSystem.dylib`**, which every program links against automatically. `/usr/lib/libc.dylib` historically existed as a name for it.

> **Mac-specific twist:** since macOS 11 (Big Sur), the system libraries are no longer stored as separate `.dylib` files on disk. They are combined into one large prebuilt file, the **dyld shared cache**. The linker still behaves as if the libraries were there (it reads small `.tbd` stub files from the SDK), and at runtime the dynamic loader maps the code from the cache.

---

## 2. Static vs Dynamic Linking

For the 42 `libasm` project you build a **static library** (`libasm.a`). It's worth understanding how it differs from the way `printf` is linked.

### Dynamic Linking (how `printf` works)

When the linker sees a call to `printf`, it does not copy `printf`'s machine code into your executable.

Instead, it leaves a **placeholder** in your binary that says: "when this program starts, look up `printf` in the system's C library."

* **Result:** your executable stays small.
* **Bonus:** if Apple fixes a bug in `printf` or makes it faster, your program benefits without being recompiled.

### Static Linking (how `libasm.a` works)

For the project you use the `ar` (archive) command to bundle the assembled objects (`ft_strlen.o`, `ft_strcpy.o`, ...) into `libasm.a`. A `.a` file is a simple archive of `.o` files plus an index of the symbols they define, similar in spirit to a `.zip` file without compression.

When a program is linked against `libasm.a`, the linker copies the machine code of the objects it actually needs directly into the final executable.

---

## Summary

| Component | What it is | Where it lives | Purpose |
| --- | --- | --- | --- |
| **Headers** (`.h`) | Plain-text declarations | In the SDK, e.g. `/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include` | Tell the *compiler* that `printf` exists and what arguments it takes |
| **Libraries** (`.dylib` / shared cache) | Precompiled machine code | The dyld shared cache | Contain the actual instructions for `printf`, which the *dynamic loader* maps into your program at runtime |

---

## Aside: the memory hierarchy

Why registers matter so much in assembly: they are by far the fastest storage. Rough, typical figures:

| Memory type | Location | Latency | Typical size | Technology |
| --- | --- | --- | --- | --- |
| Registers | Inside the CPU core | < 1 ns (within a clock cycle) | A few KB in total | Flip-flops (transistors) |
| CPU cache (L1/L2/L3) | On the CPU chip, next to the cores | ~1 to 15 ns | Up to tens of MB | SRAM (static RAM) |
| System RAM | Connected via the memory bus | ~60 to 100 ns | GB (e.g. 8–64 GB) | DRAM (dynamic RAM) |
| SSD | Connected via PCIe | ~50,000+ ns | Hundreds of GB to TB | NAND flash |
