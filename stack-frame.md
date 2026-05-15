This specific two-line sequence is called the **function prologue**. It sets up what is known as a **stack frame** (or activation record) for your function.

To understand why it is used, it helps to visualize how the stack works when one function calls another.

---

## The Concept of the Stack Frame

When a program is running, it uses a region of memory called the **stack** to keep track of local variables, function arguments, and where to return to when a function finishes.

Each function gets its own dedicated slice of this memory, called a **frame**.

* **`rsp` (Stack Pointer):** This register points to the very *top* of the stack. Because the stack grows downward in memory as you push data onto it, `rsp` is constantly changing every time you `push`, `pop`, or call a function.
* **`rbp` (Base Pointer / Frame Pointer):** This register is meant to stay totally stationary during the function's execution. It points to a fixed reference point at the *base* of your function's stack frame.

---

## Step-by-Step: What Those Two Lines Do

Imagine Function A calls your function, `ft_atoi_base`.

### 1. `push rbp`

Before your function can start using the `rbp` register as its own fixed reference point, it has to respect the caller function. The caller was likely using `rbp` for its own stack frame.

* **What it does:** This saves the caller's `rbp` value safely onto the stack.
* **Why:** So that right before your function returns (`ret`), you can pop it back out, restoring the caller's environment exactly how they left it.

### 2. `mov rbp, rsp`

* **What it does:** This copies the current value of `rsp` into `rbp`.
* **Why:** Because `rsp` is currently at the boundary where the caller's frame ends and *your* function's frame begins. By copying it to `rbp`, you lock down a stable "anchor" or basecamp for `ft_atoi_base`.

---

## Why do we need a fixed anchor (`rbp`)?

If you don't use `rbp` and only rely on `rsp`, things get tricky. Imagine you push three items onto the stack inside your function. `rsp` has now moved by 24 bytes. If you want to access a local variable or a specific saved register on the stack, the offset from `rsp` changes depending on where you are in your function.

By setting up `rbp`, you create a constant reference point:

* Local variables will *always* be at a fixed negative offset from `rbp` (e.g., `[rbp - 8]`, `[rbp - 16]`).
* Arguments or previous frame data will *always* be at a fixed positive offset (e.g., `[rbp + 16]`).

No matter how many times `rsp` moves up and down during your code, your references to variables remain completely stable.

---

## Modern Context: Is it strictly mandatory?

In modern x86_64 assembly and optimized C compilers, you will often see functions skip this step entirely (a technique called *Frame Pointer Omission*). Because modern compilers are incredibly good at tracking exactly how much `rsp` moves, they can just use `rsp` directly to save a tiny bit of performance and free up `rbp` to be used as a general-purpose register.

However, for educational environments like **42 Berlin**, debugging, and writing clean, manual assembly, setting up the stack frame using `push rbp` and `mov rbp, rsp` is the standard, reliable way to guarantee your stack memory doesn't get corrupted.