# How to use rbenv

<!-- TOC -->
- [Install rbenv and its plugins](#install-rbenv-and-its-plugins)
- [Install Ruby version](#install-ruby-version)
- [Use gemsets](#use-gemsets)
  - [Gemset in custom directory](#gemset-in-custom-directory)
  - [Gemsets in default directory](#gemsets-in-default-directory)
<!-- /TOC -->

## Install rbenv and its plugins

Rbenv has the basic functionality but it requires plugins for all desired features:

- ruby-build: Installing Ruby versions.
- rbenv-gemset: Managing gemsets.
- ...

To have more control on it, install it using git:

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'eval "$(~/.rbenv/bin/rbenv init - zsh)"' >> ~/.zshrc
```

Restart shell.

Install plugins:

```bash
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
$ git clone https://github.com/jf/rbenv-gemset.git $HOME/.rbenv/plugins/rbenv-gemset
```

## Install Ruby version

List versions:

```bash
rbenv install --list
```

Install:

```bash
rbenv install 3.3.0
```

Set default Ruby version globally:

```bash
rbenv global 3.3.0
```

Set Ruby version for directoy:

```bash
rbenv local 3.3.0
```

## Use gemsets

### Gemset in custom directory

Create a gemset by specifying the directory where gems should be installed so that you can cleanup or test easily:

```bash
cd project-directoy

echo '.gems' > .rbenv-gemsets
```

When you run `bundle install` or `gem install`, the gems will be installed in `project-directory/.gems`.

To see where your gems are being installed, run:

```bash
gem env home
```

### Gemsets in default directory

Init a gemset:

```bash
rbenv gemset init [gemset-name]
```

Create gemset under specific Ruby version:

```bash
cd project-directory

rbenv gemset create [ruby-version] [gemset-name]
```

List existing gemsets:

```bash
rbenv gemset list
```

Delete gemset:

```bash
rbenv gemset delete [ruby-version] [gemset-name]
```
