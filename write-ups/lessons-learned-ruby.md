# Lessons learned using Ruby

<!-- TOC -->

- [Lessons learned using Ruby](#lessons-learned-using-ruby)
    - [Complex regular expressions](#complex-regular-expressions)
    - [Exceptions](#exceptions)
    - [Docker](#docker)

<!-- /TOC -->

## Complex regular expressions

Use regex literals with the `x` option:

```ruby
%r{
    <regex_part_1> # you can add comments
    <regex_part_2> # and end of lines
}x
```

## Exceptions

- `rescue` without a class will capture `StandardError` and its children.

  - It won't capture Ruby internal errors, which is fine most of the time.

- `raise` with no current exception in `$!` will raise a `RuntimeError` (which is a child of `StandardError`).

Docs: https://docs.ruby-lang.org/en/master/Exception.html

## Docker

Create a container to test things:

```bash
docker run --rm -it -h myruby --name myruby ruby:3.2.0 /bin/bash
```
