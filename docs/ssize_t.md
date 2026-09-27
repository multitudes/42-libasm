# Why ssize_t?

## The error

I wanted to study how compilation works, so I ran `cc -save-temps main.c` on my Mac and got:

```text
./libasm.h:9:1: error: unknown type name 'ssize_t'; did you mean 'size_t'?
    9 | ssize_t ft_write(int fd, const void *buf, size_t count);
      | ^~~~~~~
      | size_t
```

The compiler doesn't know what `ssize_t` is.

`size_t` is part of standard C: it is defined in `<stddef.h>`, and `<stdlib.h>`, `<stdio.h>` and `<string.h>` provide it too. `ssize_t` (signed size) is **not** standard C. It is a POSIX type. On Linux, common headers often pull it in indirectly, so the code happens to compile. On macOS the headers are stricter.

The fix is to include the POSIX header that defines it, in `libasm.h`:

```c
#include <sys/types.h>
// or
#include <unistd.h>
```

`libasm.h` now includes `<unistd.h>`, so the project compiles on both systems.

## History

If C was created to build the Unix operating system, why isn't the return type of a system call part of the language?

The history is right: Dennis Ritchie created C at Bell Labs to rewrite Unix.

The short answer: **when C and Unix were created in the early 1970s, `ssize_t` didn't exist, because the problem it solves didn't exist yet.**

---

## 1. Early Unix was tiny, and `int` was enough

C was designed on the PDP-11, a 16-bit machine.

* An `int` was 16 bits.
* A single `read()` or `write()` call only moved small amounts of data.
* So the original `read()` and `write()` simply took and returned an `int`.

An `int` can be positive (number of bytes transferred) or `-1` (error). There was no need for a special type.

---

## 2. Bigger machines and the "unsigned" problem

As computers moved to 32-bit (and later 64-bit) architectures, programs could handle much more memory.

C gained `unsigned` types, and ANSI C (1989) standardized `size_t` as the type for object sizes. It is unsigned, since you can't have a negative number of bytes.

That created a dilemma for `read` and `write`:

* If they return an **unsigned** `size_t`, how do they return `-1` for an error? In unsigned arithmetic `-1` becomes the largest possible value (`4,294,967,295` with 32 bits), which breaks error checking.
* If they return a plain signed `int`, the result may be too small to hold the byte count on machines where `size_t` is bigger than `int`.

POSIX standardized `ssize_t` to solve this: a signed type with the same width as `size_t`. It can hold `-1` for errors and byte counts up to `SSIZE_MAX`, half of what `size_t` can express. That is why POSIX leaves the result implementation-defined if you ask `read` or `write` for more than `SSIZE_MAX` bytes.

---

## 3. Language vs Operating System

This is the philosophical reason. C became bigger than Unix: it is used to program microcontrollers, Windows PCs, and embedded systems that have nothing to do with Unix.

To keep C universal, the **language standard** was separated from the **operating system standard**:

* **The C language (ISO C):** defines what makes sense on *every* platform: loops, arithmetic, pointers, `int`, `char`, `size_t`. It has only minimal I/O (`FILE *` streams) and knows nothing about file descriptors or system calls.
* **The operating system interface (POSIX):** defines how Unix-like systems (Linux, macOS, the BSDs) expose system services. `ssize_t` belongs here because it is tied to OS-level I/O calls and their error convention.

A programmer writing C for a microwave or a traffic light shouldn't have to care about Unix-style file I/O that their device doesn't have.

So `ssize_t` lives in POSIX headers like `<sys/types.h>` and `<unistd.h>` (Unix standard header), not in the core language. C stays a lightweight, universal skeleton, and the OS provides the specific muscles.
