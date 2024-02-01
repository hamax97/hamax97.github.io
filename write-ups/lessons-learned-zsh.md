# Lessons Learned ZSH

## ZSH is too slow to load a new terminal

The first thing I did was to lazily load `nvm`:

From:
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

To:
```bash
export NVM_DIR="$HOME/.nvm"
# This is taking too long and makes opening a new terminal too slow.
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias nvm="unalias nvm; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; nvm $@"
```

Then I used `zprof` to profile the startup time. It looks like `compinit` was taking most of the startup time 70%, like 3.3 seconds.
I changed the following line in `~/.oh-my-zsh/oh-my-zsh.sh`:

From:
```bash
autoload -U compaudit compinit zrecompile
```

To:
```bash
autoload -Uz compaudit compinit zrecompile
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;
```

The snipped was extracted from [this gist](https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2308206). I only added `compaudit` and `zrecompile`
to the `autoload` line. The gist suggests to check compinit's cache only once a day.

Read the following articles:

- [Speeding up ZSH](https://medium.com/@dannysmith/little-thing-2-speeding-up-zsh-f1860390f92)
- [Speeding up my ZSH load time](https://carlosbecker.com/posts/speeding-up-zsh/?source=post_page-----f1860390f92--------------------------------)

