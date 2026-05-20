# why ssize_t

I have a c file... I want to study how the compilation works. 
I do cc -save-temps main.c
and I get the following error:
```bash
./libasm.h:9:1: error: unknown type
      name 'ssize_t'; did you mean 'size_t'?
    9 | ssize_t ft_write(int fd, const void *buf, size_t count);
      | ^~~~~~~
      | size_t
```

Look closely at your libasm.h:

```c
ssize_t ft_write(int fd, const void *buf, size_t count);
```

The compiler complains that it doesn’t know what ssize_t is.

Unlike size_t (which is built into standard C via headers like <stdlib.h> or <stddef.h>), ssize_t (signed size) is a POSIX-specific extension. On Linux, sometimes <stdlib.h> or other common headers implicitly pull in ssize_t. On macOS, it is strictly isolated.

To fix this error on your Mac, you simply need to include the header that actually defines ssize_t inside your libasm.h:

```c
#include <sys/types.h>
// or
#include <unistd.h>
```

## history

I don't understand if C languages has been created to build unix operating system, why the return type of a system call could not be included in the language?

That is a spectacular historical question. You are 100% correct about the history: Dennis Ritchie created the C language at Bell Labs specifically to rewrite the Unix operating system.

So, why didn't he just build `ssize_t` directly into the C language from day one?

The short answer is: **When C and Unix were created in the early 1970s, `ssize_t` didn't exist yet, because the problems it solves didn't exist yet.**

Here is how the evolution of hardware and the separation of powers split C and Unix apart.

---

## 1. Early Unix was tiny, and `int` was enough

When C was designed for the PDP-11 computer in 1972, it was a 16-bit architecture.

* An `int` was 16 bits.
* The maximum amount of data you could read or write in a single system call was a few kilobytes.
* Therefore, the original `read()` and `write()` system calls in early Unix didn't use `ssize_t` or `size_t`. They just used regular `int`.

An `int` can be positive (number of bytes read) or negative (`-1` for an error). It worked perfectly. There was absolutely no need for a special type.

---

## 2. The 32-bit Explosion and the "Unsigned" Problem

By the late 1970s and 1980s, computers moved to 32-bit architectures. Suddenly, programs could handle massive amounts of memory.

C introduced `unsigned int` (and later `size_t`) so programmers could represent strictly positive numbers up to 4 gigabytes. This was perfect for counting bytes, because you can't read a negative number of bytes.

However, this created a massive dilemma for system calls like `read` and `write`:

* If `write()` returns an **unsigned** `size_t`, it can represent huge file transfers. But how does it return `-1` to signal an error? (In unsigned math, `-1` becomes the largest possible positive number, `4,294,967,295`, which ruins error checking).
* If `write()` returns a **signed** `int`, it can easily return `-1` for errors, but it cuts your maximum transferable data size exactly in half because one bit is stolen to represent the +/- sign.

To solve this, the IEEE POSIX committee later invented `ssize_t`—a signed type guaranteed to be the exact same bit-size as `size_t`.

---

## 3. The Separation of Church and State (Language vs. OS)

This is the philosophical reason. As C grew, it became bigger than Unix. It started being used to program microcontrollers, Windows PCs, and embedded systems that had *nothing* to do with Unix.

To keep C universal, the creators intentionally separated the **C Language Standard** from the **Operating System Standard**.

* **The C Language (ISO C):** Defines only what is universally true for *every* computer on earth (loops, math, pointers, `int`, `char`, `size_t`). It deliberately knows nothing about files, hard drives, or internet sockets.
* **The Operating System (POSIX):** Defines how a specific family of operating systems (Unix, Linux, macOS) talks to hardware. `ssize_t` belongs here because it specifically handles OS-level file I/O operations and error codes.

If the C language forced `ssize_t` into its core compiler, a developer trying to program a microwave or a basic traffic light using C would be forced to carry around overhead for Unix-style file systems that their device doesn't even possess.

By keeping `ssize_t` inside `<unistd.h>` (Unix Standard Headers) instead of the compiler itself, C remains the lightweight, universal skeleton, while the OS provides the specific muscles.