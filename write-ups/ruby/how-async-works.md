# How Async works

<!-- TOC -->

- [Background](#background)
    - [Fibers](#fibers)
    - [io-event](#io-event)
    - [timers](#timers)
- [Async](#async)
    - [How is the Fiber-scheduler implemented](#how-is-the-fiber-scheduler-implemented)
    - [Task](#task)
    - [Non-blocking reactor](#non-blocking-reactor)
- [Resources](#resources)

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

Composable asynchronous I/O framework for Ruby based on `io-event` and `timers`.

**General featuers**

- Scalable event-driven I/O for Ruby. Thousands of clients per process!
- Light weight fiber-based concurrency. No need for callbacks!
- Multi-thread/process containers for parallelism.
- Growing eco-system of event-driven components.

### How is the Fiber-scheduler implemented

How to make this piece of code execute concurrently instead of waiting for each request:

```ruby
topics.each do |topic|
  response = request(topic)
end
```

**Verbose implementation**

Start workers:

```ruby
waiting = {} # waiting list.

topics.each do |topic|
  Worker do
    io = connect
    io.write(topic)
    while response = io.read_nonblock
      if response == :wait_readable
        waiting[io] = Worker.current
        Worker.yield
      else
        break
      end
    end
  end
end
```

Event loop to wait for workers to finish:

```ruby
while waiting.any?
  ready = IO.select(waiting.keys)
  ready.each do |io|
    worker = waiting.delete(io)
    worker.resume
  end
end
```

**Clean implementation**

Phase 1:

```ruby
# Scheduler:
# - provides the interface for waiting on IO and other blocking operations, e.g: sleep.
# - hides the details of the event loop and the underlying operating system.
scheduler = Scheduler.new # waiting list.

topics.each do |topic|
  Worker do
    io = connect
    io.write(topic)
    while response = io.read_nonblock
      if response == :wait_readable
        # manages the task without the need for explicit yielding or waiting.
        scheduler.wait_readable(io)
      else
        break
      end
    end
  end
end

# The entire event loop is encapsulated here.
scheduler.run
```

Phase 2:

```ruby
# The thread local variable scheduler allows us to pass the scheduler as an implicit
# arguments to methods invoked on the same thread.
Thread.current.scheduler = Scheduler.new # waiting list.

topics.each do |topic|
  Fiber.schedule do
    io = connect
    io.write(topic)
    response = io.read
  end
end

Thread.current.scheduler.run
```

1. `io.read` calls internally the C function `rb_io_wait_readable(int f)`. If checks if a thread local
   scheduler is set, if it is, it defers to its implementation of `rb_io_wait_readable`. This allows you
   to have a custom scheduler without having to modify your code.

2. `Worker` is replaced with `Fiber.schedule`.

3. The real implementation has more details than this one, but this is essentailly it.

4. This is a proposal that was already merged into master for experimental stuff. It's available though
   by using the `async` gem.

5. Non-blocking IO is available by using the same IO libraries when used inside `Async` tasks.

### Task

The core abstraction of `async`:

- It's a Fiber-based mechanism for concurrency.
- Tasks execute synchronously from top-to bottom.

### Non-blocking reactor

It's at the core of `async`:

- It implements the event loop.
- Supports multiple blocking operations: IO, timers, queues, semaphores.
- Blocking operations yield control back to the reactor which schedules other tasks to continue
  their operations.

## Resources

Talks:

- [Async docs](https://socketry.github.io/async/index.html)
- [List of talks about Async](https://www.youtube.com/playlist?list=PLG-PicXncPwLlJDxW6n99GMsHf6Ol9TKV)
- [Scalable Concurrency for Ruby 3! - by Samuel Williams @ioquatix](https://www.youtube.com/watch?v=Y29SSOS4UOc)
- [Asynchronous Rails by Samuel Williams @ioquatix](https://www.youtube.com/watch?v=9tOMD491mFY)
- [Aync Ruby by Bruno Sutic](https://www.youtube.com/watch?v=LvfQTFNgYbI)