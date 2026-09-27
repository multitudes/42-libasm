# main.bc

Running `cc -save-temps main.c` on my Mac leaves a `main.bc` file next to the source. It is **LLVM Bitcode**.

On macOS, `cc` is Apple's **Clang**, which is built on the **LLVM** compiler infrastructure (the name originally stood for "Low Level Virtual Machine").

A traditional compiler translates C directly into assembly for one specific CPU. Clang goes through an intermediate step instead.

---

## The Compilation Pipeline with Bitcode

With `-save-temps`, Clang keeps the output of every stage:

1. **`main.c`** (your source code) → *preprocessor*
2. **`main.i`** (preprocessed C code) → *Clang frontend*
3. **`main.bc`** (LLVM Bitcode) → *LLVM optimizer and code generator*
4. **`main.s`** (target assembly) → *assembler*
5. **`main.o`** (machine code object file) → *linker*
6. **`a.out`** (final executable)

---

## What exactly *is* Bitcode?

Bitcode is a hardware-independent **Intermediate Representation (IR)** of your program, stored in a dense binary format. The IR itself is a low-level, strongly typed language that looks like a cross between C and assembly, with an unlimited number of virtual registers.

Because `main.bc` is binary, a text editor can't show it. Clang can convert it to the human-readable text form of LLVM IR (a `.ll` file):

```bash
clang -S -emit-llvm main.bc -o main.ll
```

This tells Clang: take this bitcode file, stop at the assembly stage (`-S`), but write LLVM IR (`-emit-llvm`) instead of CPU assembly, into `main.ll`.

The standalone LLVM tool for the same job is `llvm-dis main.bc`, but Apple does not ship it with Xcode (`xcrun --find llvm-dis` fails). It comes with a full LLVM install, for example `brew install llvm`.

A minimal `main` looks like this in `main.ll`:

```llvm
define i32 @main() {
  %1 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  ret i32 0
}
```

---

## Why does LLVM use an IR?

### 1. The M × N Problem (Compiler Efficiency)

Imagine you support 5 programming languages (C, C++, Swift, Rust, Objective-C) and 4 CPU architectures (x86-64, ARM64, PowerPC, WebAssembly). Without a shared IR, you would need 20 separate compilers (5 × 4).

With LLVM, each language frontend only has to translate into **LLVM IR**, and each backend only has to translate **LLVM IR** into one CPU architecture: 5 + 4 pieces instead of 5 × 4. When a new CPU appears (like Apple's M1), only *one* new backend is needed for every language to support it.

### 2. Recompiling without the source (historical)

For a few years, Apple let (and for watchOS and tvOS, required) developers upload iOS, watchOS and tvOS apps to the App Store as bitcode instead of final machine code, so Apple could recompile them for new chips without the developer resubmitting. macOS apps never used this. Apple deprecated bitcode submissions in Xcode 14 (2022), so today `.bc` files mostly matter as a compiler intermediate like the one above.

---

## What to look for next

Open `main.ll` in your editor. You will see how your C code's variables, loops, and function calls were stripped down into a strongly typed IR with unlimited registers, before the compiler turns it into real hardware assembly in `main.s`.
