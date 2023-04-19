# How to use RVM - Ruby Version Manager

<!-- TOC -->

- [How to use RVM - Ruby Version Manager](#how-to-use-rvm---ruby-version-manager)
    - [Install a ruby version](#install-a-ruby-version)
    - [Create a gemset for a specific project or environment](#create-a-gemset-for-a-specific-project-or-environment)
    - [Use the gemset whenever you CD into the folder](#use-the-gemset-whenever-you-cd-into-the-folder)
    - [Get the GEM_HOME environment variable](#get-the-gem_home-environment-variable)
    - [Get the GET_PATH environment variable](#get-the-get_path-environment-variable)
    - [Migrate from .rvmrc to .ruby-version it's faster and recommended](#migrate-from-rvmrc-to-ruby-version-its-faster-and-recommended)
    - [Docs](#docs)

<!-- /TOC -->

## Install a ruby version

```bash
rvm install 3.2.0
```

## Create a gemset for a specific project (or environment)

```bash
rvm 3.2.0@project-name --create
```

Use gemset:

```bash
rvm use 3.2.0@project-name
```

## Use the gemset whenever you CD into the folder

1. Add the following to your `$HOME/.rvmrc`:

   ```bash
   export rvm_project_rvmrc=1
   ```

2. Create the files in your project root directory: `.ruby-version` and `.ruby-gemset`.

   Run:

   ```bash
   rvm --ruby-version use 3.2.0@project-name
   ```

   Gemsets are not supported by other tools, that's why rvm recommends to use separate file (.ruby-gemset).

3. Create `Gemfile`:

   ```
   gem install bundler
   bundler init
   ```

## Get the GEM_HOME environment variable

This variable points to the place where gems will be installed.

```bash
rvm gemdir
```

## Get the GET_PATH environment variable

This variable points to the place**s** where Ruby will look for gems.

```bash
echo $GEM_PATH
```

## Migrate from .rvmrc to .ruby-version (it's faster and recommended)

```bash
rvm rvmrc to ruby-version
```

## Docs

- Typical RVM project workflow: https://rvm.io/workflow/projects