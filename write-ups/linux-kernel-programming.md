# Linux Kernel Programming

Resources, guides, tools, and lessons learned in my journey to become a Linux kernel developer.

## Development Environment

### Tools

#### ctags and cscope

Tools for efficient browsing in C codebases.

- ctags
  - Useful for navigating C codebases by jumping back and forth between declarations.
  - Offers autocompletion (aka omnicompletion) for function and variable names (cscope doesn’t.)
  - Doesn’t do as good as cscope for mostly unknown codebases.
  - Both can coexist.
  - Install with:

    ```bash
    sudo apt-get install exuberant-ctags
    ```
  - Generate tags:

    ```bash
    ctags -R
    ```
  - Keyboard shourtcuts inside nvim/vim:
    - **Ctrl + ]** Go to definition.
    - **Ctrl + t** Go back to the previous place.
    - **Ctrl + x Ctrl + ]** Try autocompleting from tags list.

- cscope
  - It requires more configuration than ctags for nvim. I skipped it for now and I'l use ctags only.

  - When I decide to use this I can follow these guides for using it:
    - [The Vim/Cscope tutorial](https://cscope.sourceforge.net/cscope_vim_tutorial.html).
    - [Tag Jumping in a Codebase Using ctags and cscope in Vim](https://www.embeddedts.com/blog/tag-jumping-in-a-codebase-using-ctags-and-cscope-in-vim/#setting-up-cscope)

  - Install with:

    ```bash
    sudo apt-get install cscope
    ```

TODOs:
- Continue with the book in Chp 1, Kernel Workspace Setup, Experimenting with the Raspberry Pi.


## Resources

- Linux Kernel Programming By Kaiwan N Billimoria, 2021.
  - [GitHub repository](https://github.com/PacktPublishing/Linux-Kernel-Programming).
  - [Known Errata (useful)](https://github.com/PacktPublishing/Linux-Kernel-Programming/tree/master#known-errata)
- [A Beginner’s Guide to Linux Kernel Development (LFD103)](https://training.linuxfoundation.org/training/a-beginners-guide-to-linux-kernel-development-lfd103/?code=2RERoFjNnwBaXL0xRiaC6B3rnABKjePmY4CD-PWFvYLom&state=Vnc2elpaSGJSdVhMdnE5cjJkZlFMU2Yyc3VBRn45QmNtU3hyUzVhVDV1TA%3D%3D)