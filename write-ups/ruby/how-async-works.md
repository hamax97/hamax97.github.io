# How Async works

<!-- TOC -->

- [Background](#background)
    - [Fibers](#fibers)
    - [io-event](#io-event)
    - [timers](#timers)
- [Async](#async)

<!-- /TOC -->

## Background

### Fibers

Ruby mechanism that allows you to pause/resume a block of code. Also called a **coroutine**.

Characteristics:

- **Cooperatively multitasked:** The responsibility for yielding control rests with the individual
  fibers and not with the operating system (as opposite to `Thread`s.)
- Can explicitly yield control.
- `Fiber.yield` yields control from inside the fiber.
- `fiber_object.resume` starts execution, or resumes execution where the last `Fiber.yield` appeared.
- Fibers are objects. You can pass them around, or store them in variables.
- Fibers can only be resumed in the thread that created them.
- Fibers can transfer control to other fibers using `transfer`.
- In Ruby 3.0, Fibers can be configured to yield control automatically when its operations are blocked.
- In Ruby 3.0, Fibers can be **non-blocking**, that is, when a fiber would otherwise block because of I/O,
  or block waiting on another process, it automatically cedes control to a **fiber scheduler**, which
  chooses another fiber to wake up and controls resuming the original fiber when it has whatever it needs
  to proceed.
  - What if a Fiber doesn't give control back to the fiber scheduler?

### io-event

Provides low level cross-platform primitives for constructing event loops, with support for `select`,
`kqueue`, `epoll` and `io_uring`.

An **event loop** is a semi-infinite loop, polling and blocking on the OS until some in a set of
file descriptors are ready.

[GitHub link](https://github.com/socketry/io-event).

### timers

Collections of one-shot and periodic timers, intended for use with event loops such as `async`.

[GitHub link](https://github.com/socketry/timers).

## Async

TODO: continue here: https://socketry.github.io/async/index.html