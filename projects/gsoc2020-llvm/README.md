## Latency Hiding of Host to Device Memory Transfers

This initiated as part of a contribution to the [LLVM Project](https://llvm.org/) under the
[Google Summer of Code 2020](https://summerofcode.withgoogle.com/). For a more detailed description of the initial
proposal read [here](https://summerofcode.withgoogle.com/projects/#5908473784565760).

### Merged Code
Regression test that checks if the runtime function is actually split and moved correctly.
* [Initial test commit](https://github.com/llvm/llvm-project/commit/6f0d99d2b9b3b8ae96dd91c8988cc067b9c9afb9).

Split the runtime call `__tgt_target_data_begin_mapper` into its `issue` and `wait` counterparts.
* [Commit](https://github.com/llvm/llvm-project/commit/496f8e5b369f091def93482578232da8c6e77a7a).

Moving the `wait` down.
* [Commit](https://github.com/llvm/llvm-project/commit/bd2fa1819b9dc1a863a4b5a8abc540598f56c8f2).

### Pending for Review Code
Getting the values stored in the offload arrays passed to `__tgt_target_data_begin_mapper`.
* [Review](https://reviews.llvm.org/D86300).

Grouping the setup instructions (`issue`) for the runtime call `__tgt_target_data_begin_mapper`.
* [Review](https://reviews.llvm.org/D86474).

Unit-testing infrastructure for `OpenMPOpt`.
* [Review](https://reviews.llvm.org/D83316).

### TODOs
* Find a solution for the problem with the Alias Analysis Manager. Currently it always returns that a call to any
function may modify one of the offloaded memory regions even if it has the `noalias` modifier.

* Moving the `wait` down but now inspecting more complex Control Flow Graphs. Right now it only analyzes the basic block
where the runtime call is located.

* Moving the `issue` up:
    * Initially it can be moved only analyzing the basic block where the runtime call is.
    * A further step would be analyzing moving it upwards across complex Control Flow Graphs.