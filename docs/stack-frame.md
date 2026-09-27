# The Stack Frame

Many of my functions (for example `ft_atoi_base`) start with:

```nasm
push rbp
mov  rbp, rsp
```

This two-line sequence is the **function prologue**. It sets up a **stack frame** (also called an activation record) for the function.

To see why it is used, it helps to picture the stack when one function calls another.

---

## The Concept of the Stack Frame

A running program uses a region of memory called the **stack** to keep track of local variables, some function arguments, and where to return to when a function finishes.

Each function call gets its own slice of this memory, called a **frame**.

* **`rsp` (Stack Pointer):** points to the *top* of the stack. The stack grows downward in memory, and `rsp` changes with every `push`, `pop`, `call` and `ret`.
* **`rbp` (Base Pointer / Frame Pointer):** meant to stay fixed while the function runs. It points to a fixed reference point at the *base* of the function's frame.

---

## Step-by-Step: What Those Two Lines Do

Imagine function A calls `ft_atoi_base`.

### 1. `push rbp`

Before `ft_atoi_base` can use `rbp` as its own reference point, it has to respect the caller, which was probably using `rbp` for its own frame. `rbp` is callee-saved.

* **What it does:** saves the caller's `rbp` value on the stack.
* **Why:** so that right before returning (`ret`), the function can `pop rbp` and give the caller back its register exactly as it was.

### 2. `mov rbp, rsp`

* **What it does:** copies the current value of `rsp` into `rbp`.
* **Why:** at this moment `rsp` sits at the boundary where the caller's frame ends and the new frame begins. Copying it to `rbp` creates a stable anchor for the whole function.

---

## Why do we need a fixed anchor (`rbp`)?

If you only use `rsp`, things get tricky. Say you push three values inside the function: `rsp` has now moved by 24 bytes, so the offset from `rsp` to any given stack slot depends on where you are in the code.

With `rbp` set up, offsets are constant:

* Local variables are always at a fixed negative offset from `rbp` (e.g. `[rbp - 8]`, `[rbp - 16]`).
* The return address is at `[rbp + 8]`, and arguments passed on the stack (the 7th and beyond) start at `[rbp + 16]`.

No matter how often `rsp` moves during the function, these references stay valid. Debuggers also rely on the chain of saved `rbp` values to print a backtrace.

---

## Modern Context: Is it mandatory?

No. Optimizing compilers often skip it (*frame pointer omission*): they track exactly how far `rsp` has moved, address everything relative to `rsp`, and free up `rbp` as one more general-purpose register.

For hand-written assembly and for debugging, the classic `push rbp` / `mov rbp, rsp` prologue is still a simple, reliable way to keep stack accesses readable. It also helps with alignment: after the return address (8 bytes) and `push rbp` (8 bytes), `rsp` is 16-byte aligned again. Leaf functions can skip it entirely (see [leaf-functions.md](leaf-functions.md)).
