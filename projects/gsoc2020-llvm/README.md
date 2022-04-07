## Latency Hiding of Host to Device Memory Transfers

This initiated as part of a contribution to the [LLVM Project](https://llvm.org/) under the
[Google Summer of Code 2020](https://summerofcode.withgoogle.com/).

Given the increasing number of use cases for massively parallel devices (GPUs), solving the problems they bring have
become an important research field. One of the main problems that needs to be solved is the long time (latency) that it
takes to move data from the computer’s main memory to the device’s memory. Therefore, using the LLVM compiler
infrastructure, the proposed solution consists of adding a new functionality to the current OpenMP interprocedural
optimization pass, OpenMPOpt, such that the OpenMP runtime calls that involve host to device memory transfers are split
into “issue” and “wait” functions. The “issue” function will contain the code necessary to transfer the data from the
host to the device in an asynchronous manner, returning a handle in which the “wait” function will wait for completion.
The “issue” and “wait” functions will be moved upwards and downwards respectively, until it is illegal to do so.
Doing this, the instructions between the “issue” and the “wait” can be executed, while separately doing the data
transfer to the device, hence, reducing the time the process is blocked waiting for the transfer to finish.

This prototype project focuses on analyzing and splitting the runtime call `__tgt_target_data_begin_mapper`. Therefore,
following there are descriptions and links to the [Merged Code](#Merged Code), [Pending for Review](#Pending for Review),
[Work in Progress](#Work in Progress), and [TODOs](#TODOs).

### Merged Code
Split the runtime call `__tgt_target_data_begin_mapper` into its `issue` and `wait` counterparts.
[Commit](https://github.com/llvm/llvm-project/commit/496f8e5b369f091def93482578232da8c6e77a7a).

Moving the `wait` version of `__tgt_target_data_begin_mapper` down as much as possible.
[Commit](https://github.com/llvm/llvm-project/commit/bd2fa1819b9dc1a863a4b5a8abc540598f56c8f2).

Getting the values stored in the offload arrays passed to `__tgt_target_data_begin_mapper`.
[Commit](https://github.com/llvm/llvm-project/commit/8931add6170508704007f1a410993e6aec879c01).

Regression test that checks if the runtime function `__tgt_target_data_begin_mapper` is actually split and moved
correctly.
[Commit](https://github.com/llvm/llvm-project/commit/6f0d99d2b9b3b8ae96dd91c8988cc067b9c9afb9).

### Pending for Review
Grouping the setup instructions (`issue`) for the runtime call `__tgt_target_data_begin_mapper`.
[Phabricator review](https://reviews.llvm.org/D86474).

Unit-testing infrastructure for the optimization pass `OpenMPOpt`.
[Phabricator review](https://reviews.llvm.org/D83316).

### Work in Progress
Moving up the `issue` version of `__tgt_target_data_begin_mapper`. That is, after having grouped the set up instructions
of the runtime call, try to move it up as much as possible over instructions that are guaranteed will not modify the
memory regions being offloaded.

### TODOs
- [ ] Find a solution for the problem with the Alias Analysis Manager. Currently it always returns that a call to any
function may modify one of the offloaded memory regions even if the offloaded region has the `noalias` modifier.

- [ ] Moving down the `wait` version of `__tgt_target_data_begin_mapper`, but now inspecting more complex
Control Flow Graphs. Right now it only analyzes the basic block where the runtime call is located.

- [ ] Moving up the `issue` version of `__tgt_target_data_begin_mapper`, but now inspecting more complex
Control Flow Graphs. Right now it only analyzes the basic block where the runtime call is located.
