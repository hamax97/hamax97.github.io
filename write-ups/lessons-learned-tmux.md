# Lessons learned when installing and using Tmux

<!-- TOC -->

- [Sessions, Windows, Panes](#sessions-windows-panes)
    - [Session](#session)
    - [Window](#window)
    - [Pane](#pane)
- [Commands](#commands)
- [My custom keybindings](#my-custom-keybindings)
- [Troubleshooting](#troubleshooting)
    - [-bit colors not working](#-bit-colors-not-working)
    - [Strange characters appearing when starting tmux - 0;10;1c](#strange-characters-appearing-when-starting-tmux---0101c)
- [Resources](#resources)

<!-- /TOC -->

## Sessions, Windows, Panes

### Session

- Sessions are the topmost layer in tmux.
- A collection of one or more windows managed as a single unit.
- You're tipically attached to one single session.
- Each session has a single active window.

### Window

- Container to one or more panes.
- Think of them as tabs in browsers.
- Each window has a currently active pane.
- Allows you to switch between panes.

### Pane

- It's a split in a window.
- Represents an individual termianl session.
- There will only be one active pane at a time.

## Commands

To enter commands you need to use the **prefix**. It's what you type before you enter the actual command.

The default prefix is: `Ctrl + b`

## My custom keybindings

- Navigate between panels: `Ctrl + h|j|k|l`
- Previous/next window: `Shift + Alt + M|L`
- In copy mode:
  - Select: `v`
  - Rectangle select: `Ctrl + v`
  - Yank: `y`

## Troubleshooting

### 24-bit colors not working

**Problem**

You should see a smoth gradient when running this script:

```bash
curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh >24-bit-color.sh
bash 24-bit-color.sh
```

If you can clearly see the separation between different colors, it means it's not working.

Also, I had an issue with oh-my-zsh. The autocompletion suggestion was not appearing in gray but in solid
white, making it confusing.

I was using the version 3.0 installed by the package manager in Ubuntu 20.04 with Windows Terminal.

**Solution**

I manually compiled version 3.3a and added these lines to the very beginning of my `~/.config/tmux/tmux.conf`:

```
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",$TERM:RGB"
```

### Strange characters appearing when starting tmux - 0;10;1c

**Problem**

https://github.com/microsoft/WSL/issues/5931#issuecomment-1296783606

**Solution**

Add the following to `~/.config/tmux/tmux.conf`, make sure it's after the plugin `tmux-sensible`:

```
set -sg escape-time 1
```

## Resources

- [Tmux set up by Dreams of Code](https://www.youtube.com/watch?v=DzNmUNvnB04).