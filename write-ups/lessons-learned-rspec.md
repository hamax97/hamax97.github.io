# Lessons learned RSpec

Many of the lessons learned here stated were copied directly from:
Marston, Myron and Ian Dees. *Efective Testing with RSpec 3*. Pragmatic Bookshelf, August 2017.

<!-- TOC -->

- [Lessons learned RSpec](#lessons-learned-rspec)
    - [Add RSpec to a project](#add-rspec-to-a-project)
    - [Main concepts](#main-concepts)
    - [Types of specs](#types-of-specs)
    - [Output colors](#output-colors)
    - [Filter backtraces to avoid huge backtraces](#filter-backtraces-to-avoid-huge-backtraces)
    - [Format output](#format-output)
    - [Show slowest examples](#show-slowest-examples)
    - [Run only what's needed](#run-only-whats-needed)
        - [Run failures only](#run-failures-only)
        - [Focusing specific examples](#focusing-specific-examples)
        - [Tag filtering](#tag-filtering)
    - [Mark work in progress](#mark-work-in-progress)
    - [Libraries](#libraries)
        - [rspec-core](#rspec-core)
    - [Drawbacks of instance variables in hooks - Use memoization](#drawbacks-of-instance-variables-in-hooks---use-memoization)
    - [context](#context)
    - [Use editor support to run specs with your keyboard](#use-editor-support-to-run-specs-with-your-keyboard)
    - [Run with Bundler in standalone mode](#run-with-bundler-in-standalone-mode)
    - [Mixins](#mixins)
    - [Matchers](#matchers)
        - [contain_exactly](#contain_exactly)
    - [Doubles](#doubles)
    - [Patterns and Practices](#patterns-and-practices)

<!-- /TOC -->

## Add RSpec to a project

1. Add `rspec` to your gems in `Gemfile` and install it.
2. Run:

   ```bash
   bundle exec rspec --init
   ```

   Use `bundle exec` to make sure you are using the right `rspec`.
## Main concepts

- **Example group**: Degined with `RSpec.describe`. Set of related tests.
- **Example**: defined with `it "..."`. Called `test case` in other frameworks.
- **Expectation**: lines that have `expect`. Called `assertions` in other frameworks.

- Words used interchangeably, but that have difference nuances:
  - A `test` validates that a bit of code is working properly.
  - A `spec` describes the desired behavior of a bit of code.
  - An `example` shows how a particular API is intended to be used.

- RSpec uses the term **test double** to refer to: mocks, stubs, fakes, spies. The difference is rooted
  in how you use them.
  - Martin Fowler agrees: [Test Double](https://martinfowler.com/bliki/TestDouble.html).

## Types of specs

- **Acceptance**: Does the whole system work?
  - Exercise all layers in the system.
  - Give an extremely important and valuable support when doing big refactorings.
  - Rely only in the product's external interface.
  - More difficult to write, more brittle, and slower.

- **Unit**: Do our objects do the right thing, are they convenient to work with?
  - Exercise only one layer in isolation at a time.
  - Focused and fast.
  - Isolated from third party code.
  - Very low level.
  - Help when refactoring objects or methods.
  - [Martin Fowler's definition](https://martinfowler.com/bliki/UnitTest.html).

- **Integration**: Does our code work against code we can’t change?
  - Allowed to access third party code in the spec.
  - Sit in between Acceptance and Unit specs.

- Useful resources:
  - [Xavier Shay's - How I test Rails applications](https://rhnh.net/2012/12/20/how-i-test-rails-applications/)

## Output colors

- Passing specs are `green`.
- Failing specs, and failure details, are `red`.
- Example descriptions and structural text are `black`.
- Extra details such as stack traces are `blue`.
- Pending specs are `yellow`.

- If the gem `coderay` is installed, the output with Ruby snippets will be color highlighted as
  in an editor.

## Filter backtraces to avoid huge backtraces

This helps removing gems' backtraces from your backtrace so that you can focus in your application
code when something fails.

RSpec hides its backtrace info by default.

Use the following config and add the gems as needed:

```ruby
config.filter_gems_from_backtrace 'rack', 'rack-test', 'sequel', 'sinatra'
```

To see the full backtrace use the flag `--backtrace` or `-b`.

## Format output

Use the flag `--format`:

- `--format documentation` or `-fd` shows groups and examples nested before the failure details.

## Show slowest examples

Use the flag `--profile`:

- `--profile <n>` where `<n>` is the number of examples that took the longest.

## Run only what's needed

### Run failures only

- To run last failure copy the last line of the failure output and run it as a command,
  which should look like:

  ```bash
  rspec ./spec/02/coffee_spec.rb:24
  ```

  Note it's using the specific line number where the expectation is. It can run non-failing examples.

- Run all failures. Use the flag `--only-failures`.

  Add a config to your spec file to specify where to store state about your tests:

  ```ruby
  RSpec.configure do |config|
    config.example_status_persistence_file_path = ​'spec/examples.txt'
  end
  ```

  Fix the code and run with this flag again.

- Run with the flag: `--next-failure`. Needs same setup as `--only-failures`.

### Focusing specific examples

1. As needed, add the `f` prefix to the API calls: `describe`, `context`, `it`. Ending up with:
   `fdescribe`, `fcontext`, `fit`.

2. Add a config:

   ```ruby
   RSpec.configure do |config|
     config.filter_run_when_matching(focus: true)
   end
   ```

3. Don't forget to remove this prefix.

### Tag filtering

Anytime you define a group or example (describe, context or it), you can pass a hash of tags known
as `metadata`. The hash can have arbitrary keys and values.

- Example: `fcontext` is shorthand for `context 'some context', focus: true do`.

- Example: if `--only-failures` wasn't implemented you could use:

  ```bash
  rspec --tag last_run_status:failed
  ```

## Mark work in progress

Use this whenever you want to list the behaviors your feature(s) will have, but don't want to
implement them yet:

- Don't add a block to the `it` API call:

  ```ruby
  it 'is an instance of Exception'
  ```

  When you run this spec, rspec will show `yellow` output, meaning `Not yet implemented`.

- Use `pending` if you wan't to see how the spec fails but don't want it marked as a failure.
  Maybe you have something in your mind and don't want to forget it:

  ```ruby
  it 'is an instace of StandardError' do
    pending 'Specific exception not implement yet'
    expect(my_object).to be_a StandardError
  end
  ```

  When you fix the issue, rspec will nicely let you know in the output.

- Use `skip` if you don't want the code in the block to run at all. Or prefix your example with `x`,
  so that it looks like `xit`.

## Libraries

### rspec-core

- The main parts of the API are: `describe`, `it`, `expect`. With these only, al ot of things can be done.
- Can be combined with any other testing library.

## Drawbacks of instance variables in hooks - Use memoization

- If you misspell the instance variable, Ruby will silently return nil instead of aborting with a
  failure right away. The result is typically a confusing error message about code that’s far away from the typo.

- To refactor your specs to use instance variables, you’ll have to go through the entire file and replace `var` with `@var`.

- When you initialize an instance variable in a before hook, you pay the cost of that setup time for all the
  examples in the group, even if some of them never use the instance variable. That’s inefficient and can
  be quite noticeable when setting up large or expensive objects.

  - You can use helper methods instead with memoization. The `RSpec.describe` block is Ruby class.
  - For handling the `nil` or `false` problem in memoization you can use the `let` helper method.

Taken from `Effective testing with RSpec 3`.

## context

It's just an alias for `describe`.

## Use editor support to run specs with your keyboard

- Vim: https://github.com/thoughtbot/vim-rspec
- VSCode: vscode-run-rspec-file

## Run with Bundler in standalone mode

Important performance improvement when running your specs:

TODO: https://learning.oreilly.com/library/view/effective-testing-with/9781680502770/f_0124.xhtml#sec.bundler

## Mixins

You can **mixin** modules inside an RSpec context, just like in regular Ruby code.

```ruby
require 'rack/test'

RSpec.describe 'The nicest description' do
  include Rack::Test::Methods

  ...
end
```

## Matchers

### contain_exactly

Doesn't regard order. Allows you change order in the collection returned by the API without failing your
tests. Use `eq([])` instead if order is important.

## Doubles

- RSpec has a feature called **verifying doubles**. This helps preventing **fragile mocks**, which is a
  problem where specs pass when they should fail because a method is not implemente, but the mock
  allows it to be used.

## Patterns and Practices

- Use the 3A's pattern: [Arrange/Act/Assert](https://xp123.com/articles/3a-arrange-act-assert/).

- [Better specs](https://www.betterspecs.org/).

- To avoind having test suites that force to bounce back and forth all the time between setup
  and examples, be pragmatic, share setup code only when necessary to increase mantainability and
  reduce noise.

- Use dependency injection and avoid hardcoding collaborating objects. This has multiple advantages:
  - Explicit dependencies: they’re documented right there in the signature of initialize.
  - Code that’s easier to reason about (no global state).
  - Libraries that are easier to drop into another project.
  - More testable code.

- Keep setup code and test code separate. Example: don't move test code to a `before` hook.
