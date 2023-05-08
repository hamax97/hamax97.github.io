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
        - [rspec-expectations](#rspec-expectations)
    - [Drawbacks of instance variables in hooks - Use memoization - let](#drawbacks-of-instance-variables-in-hooks---use-memoization---let)
    - [Example groups/examples: Aliases for better wording](#example-groupsexamples-aliases-for-better-wording)
        - [Custom aliases with custom behavior](#custom-aliases-with-custom-behavior)
    - [Use editor support to run specs with your keyboard](#use-editor-support-to-run-specs-with-your-keyboard)
    - [Use Spring to run tests - Performance improvement](#use-spring-to-run-tests---performance-improvement)
    - [Sharing code](#sharing-code)
        - [Mixins](#mixins)
        - [Shared example groups and shared examples](#shared-example-groups-and-shared-examples)
        - [include, prepend, extend](#include-prepend-extend)
    - [Matchers](#matchers)
        - [contain_exactly](#contain_exactly)
    - [Doubles](#doubles)
        - [Usage mode](#usage-mode)
        - [Origin](#origin)
            - [Verifying doubles](#verifying-doubles)
        - [Recommendations](#recommendations)
    - [Patterns and Practices](#patterns-and-practices)
        - [General](#general)
        - [Acceptance/Integration/Unit specs](#acceptanceintegrationunit-specs)
        - [Acceptance/Integration specs: setup test db before each suite](#acceptanceintegration-specs-setup-test-db-before-each-suite)
        - [Acceptance/Integration specs: solve order dependency issues - around hook - isolating specs](#acceptanceintegration-specs-solve-order-dependency-issues---around-hook---isolating-specs)
            - [Run spec files separately](#run-spec-files-separately)
    - [Hooks](#hooks)
        - [Order of execution](#order-of-execution)
    - [RSpec.configure](#rspecconfigure)
        - [Recommendations](#recommendations)
    - [Auto generated example descriptions](#auto-generated-example-descriptions)

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

- The main parts of the API are: `describe`, `it`, `expect`. With these only, a lot of things can be done.
- Can be combined with any other testing library.

### rspec-expectations

Allows you to clearly specify what a **subject** is expected to be.

This library can be used in isolation from `rspec-core` and together with anything you want.

How it works:

```ruby
expect(<subject>).to <matcher>, 'custom failure message'
```

- `<subject>` an instance of a Ruby class.
- `<matcher>` a matcher object
- `expect` wraps the `<subject>` in a friendly adapter that allows you to call `to`, `to_not` or `not_to`.

## Drawbacks of instance variables in hooks - Use memoization - let

- If you misspell the instance variable, Ruby will silently return nil instead of aborting with a
  failure right away. The result is typically a confusing error message about code that’s far away from the typo.

- To refactor your specs to use instance variables, you’ll have to go through the entire file and replace `var` with `@var`.

- When you initialize an instance variable in a before hook, you pay the cost of that setup time for all the
  examples in the group, even if some of them never use the instance variable. That’s inefficient and can
  be quite noticeable when setting up large or expensive objects.

  - You can use helper methods instead with memoization. The `RSpec.describe` block is a Ruby class.
  - For handling the `nil` or `false` problem in memoization you can use the `let` helper method.
  - `let` caches the value if the same example uses it multiple times, but not across examples.

## Example groups/examples: Aliases for better wording

- `context` is an alias for describe.
- `it` has multiple aliases:
  - `specify`: useful for describing deprecations in your specs. In the output of the spec it shows
    something like: `should <matcher> <arguments>`, without the need to give a description when declaring
    the example, as with `it`.
  - `example`: useful for data specific specs.
- `subject` is an alias for `let(:subject)`
- `is_expected` is an alias for `expect(subject)`.
- `should` is an alias for `expect(subject).to`.
- `should_not` is an alias for `expect(subject).to_not` or `expect(subject).not_to`.

  ```ruby
  subject { SomeClass.new }
  it { is_expected.to include(:some_attribute) }
  it { should_not include(:something_else) }
  ```

See [Auto generated example descriptions](#auto-generated-example-descriptions).

- You can use them in any way you want. The idea is **getting the words right**, which is crucial for BDD.

### Custom aliases with custom behavior

You might want to start the debugger right after the example finishes, but before resources are cleaned up.

Add this to your rspec config:

```ruby
RSpec.configure do |config|
  config.alias_example_group_to :debug_describe, pry: true
  config.alias_example_to :debug_it, pry: true

  config.after(:example, pry: true) do |ex|
    require 'pry'
    biding.pry
  end
end
```

- `pry: true` is the metadata that will be attached to the example group or example you declare using
  the alias `debug_describe` or `debug_it`.
- The `after` hook is added to all examples containing the `pry: true` metadata.

Now you can use the aliases:

```ruby
debug_describe CustomClass, 'when accessing db' do
  # ...
end

# ...
debug_it 'when calculating taxes' do
  # ...
  # pry will be started here.
end
# ...
```

## Use editor support to run specs with your keyboard

- Vim: https://github.com/thoughtbot/vim-rspec
- VSCode: vscode-run-rspec-file

## Use Spring to run tests - Performance improvement

This will be specially useful for big projects or projects with Rails which take too long to load.

Add this gem to the `:development` and `:test` groups:

```ruby
gem "spring-commands-rspec", "~> 1.0"
```

In the file `config/environments/test.rb`, make sure to have:

```ruby
config.cache_classes = false
config.action_view.cache_template_loading = true
```

Create the stub:

```bash
bundle exec spring binstub rspec
```

Execute the tests:

```bash
bin/rspec
```

To pick up changes:

```bash
bin/spring stop
```

## Sharing code
### Mixins

You can **mixin** modules inside an RSpec context, just like in regular Ruby code.

```ruby
require 'rack/test'

RSpec.describe 'The nicest description' do
  include Rack::Test::Methods

  ...
end
```

If you want to include a module in **all** example groups:

```ruby
RSpec.config do |config|
  config.include Rack::Test::Methods
end
```

### Shared example groups and shared examples

Shared example groups and shared examples exist **only** to be shared, that is, to be included from
other specs.

These are useful if you want to reuse hooks, examples, or let declarations, which are not shareable
using mixins.

It's a good practice to save your shared specs code under `specs/support` with a meaningful name.

You can use:

- `shared_examples`, `include_examples`, and `it_behaves_like`.
  - `include_examples` vs `it_behaves_like`:
    - `include_examples` is like copy and pasting the code. If you include twice the same (with different arguments)
      you'll have conflicts.
    - `it_behaves_like` creates a context and includes everything inside that context. If you include
      twice the same you won't have conflicts. Prefer this if unsure.

- `shared_context` and `include_context`.

Like this:

```ruby
RSpec.shared_context 'Some Context' do
# ...
end

RSpec.describe 'Some feature' do
  include_context 'Some Context'
end
```

Or to include it in all example groups:

```ruby
RSpec.config do |config|
  config.include_context 'Some Context'
end
```

Or sharing examples only:

```ruby
# specs/support/bird_behavior.rb
RSpec.shared_examples 'Bird' do |bird_class|
  let(:bird) { bird_class.new }

  it 'flies' do
    expect(bird.fly).to be_flying
  end
end

# specs/eagle_spec.rb
require_relative '../app/eagle'
require_relative 'support/bird_behavior'

RSpec.describe 'Eagle' do
  it_behaves_like 'Bird', Eagle

  # or ...

  it_behaves_like 'Bird' do
    let(:tempfile) { Tempfile.new('/tmp/bird.tmp/') }
    let(:bird) { SomeSpecialBird.new(tempfile.path) }

    # Remove the let declaration in the shared code if you use this.
  end
end
```

### include, prepend, extend

Use modules in your rspec config:

```ruby
RSpec.configure do |config|
  # Brings methods into each example
  config.include ExtraExampleMethods

  # Brings methods into each example,
  # overriding methods with the same name
  # (rarely used)
  config.prepend ImportantExampleMethods

  # Brings methods into each group (alongside let/describe/etc.)
  # Useful for adding to RSpec's domain-specific language
  config.extend ExtraGroupMethods
end
```

## Matchers

Belong to `rspec-expectations` library.

Types:
- **Primitive** matchers for basic data types like strings, numbers, and so on.
- **Higher-order** matchers that can take other matchers as input, then (among other uses) apply them across collections
- **Block** matchers for checking properties of code, including blocks, exceptions, and side effects

Matchers use underneath the Ruby operator `===`, triple equals.

A matcher define a **category** and checks, using `===`, if the value given belongs to that
category. To express this Ruby does the following:

```ruby
# Does <value> belong to this <category>?
# <category> === <value>

a_value_between(1730, 1740) === 1731
```

Another example:

```ruby
expect([1, 2, 3]).to start_with((0..2))
```

- The invocation to `to` will do: `start_with((0..2)) === [1, 2, 3]`
- The invocation to `start_with((0..2))` will return a **matcher** object.
- The call to the matcher's object method `===` with `[1, 2, 3]` as argument will do: `(0..2) === [1]`.
  - To verify that `(0..2)` responds to the message `===`, run: `(0..2).respond_to? '==='`.
- Like this you can compose matchers, instead of `(0..2)`, you pass the matcher, it will then be
  will invoked, and lastly its `===` method.

### contain_exactly

Doesn't regard order. Allows you to change order in the collection returned by the API without failing your
tests. Use `eq([])` instead if order is important.

## Doubles

There are a couple of ways to think about test doubles:

- **Usage mode**.
- **Origin**: how you created it.

Every test double will have both a **usage mode** and an **origin**.

Create them using `double()`.

### Usage mode

- **Stub**: Returns canned responses, avoiding any meaningful computation or I/O.
  - Best for simulating *query* methods (no side effect).
  - Args given are ignored.
  - `allow(<double object>).to receive().and_return()`

- **Mock**: Expects specific messages; raises an error if if doesn't receive them at the end of the example.
  - Useful to deal with *command* methods (have side effect).
  - `expect(<double object>).to receive()`

- **Null Object**: A benign test module that can stand in for any object; returns itself in response to any
  message.
  - Useful when your double receives many messages and spelling all of them out is not easy.
  - `double.as_null_object`.
  - Also known as **black hole**.

- **Spy**: Records the messages it receives, so that you can check them later.
  - Created with `spy`.
  - Allows you to use `have_received` instead of `received`, which allows you to move expectations
    to the end of the example, making them more readable, complying with the Act/Arrage/Assert pattern.

- **Fake**: Takes a working implementation but uses some shortcut that makes it not suitable
  for production. For example: an in memory test db, or a network api call that simulates
  some behavior.

### Origin

Indicate what its underlying Ruby class is:

- **Pure double**: Its behavior comes entirely from the test framework.

- **Partial dobule**: An existing Ruby object that takes on some test double behavior; its interface
  is a mixture of real and fake implementations.
  - Useful when it's not easy to test injecting dependencies.
  - Use `allow` or `expect` in a regular Ruby oject to override the behavior of specific messages.
  - After each example the object is restablished.
  - Using partial doubles is a **code smell** that might lead to you to bad design decissions.

- **Verifying double**: Totally fake like a pure double, but contrains its interface based on a real object
  like a partial double.
  - It's safer because verifies that the double matches the API it's standing for.
  - Use instead of `double`:
    - `instance_double('<class name>')`
    - `class_double('<class name>')`
    - `object_double('<class name>')`
    - Each of these has a `..._spy` variant.
  - Will verify the double only if the class is loaded, if it's not loaded it will behave as a non-verifying double.
    - Use the constant that points to the class instead of a string. This way you'll be forced to require the
      file that contains the constant; or
    - Use the option configuration option `verify_doubled_constant_names` set to `true`. Make sure to have this
      in a support file under `spec/support` so that you load it on demand. Otherwise, you'll not be able
      to use verifying doubles without previously having loaded the corresponding class. This will be useful when
      you give the name of the constant as a string, instead of passing the constant directly. You can then use
      the flag: `--require support/support_config.rb`.

- **Stubbed constant**: A Ruby constant -such as a class or module name- which you create, remove, or
  replace in a single test.
  - Use `stub_const('SomeModule::SomeConst', <some_value>)`.
  - This will:
    - Define a new constant.
    - Replace an existing constant.
    - Replace an entire module or class (which are constants).
    - Avoid loading an expensive class.
  - Use `hide_const('SomeConst')` to hide the constant.
    - Useful, for example, when you want to make sure some piece of code doesn't uses a module
      or class or some other constant.

#### Verifying doubles

- RSpec has a feature called **verifying doubles**. This helps preventing **fragile mocks**, which is a
  problem where specs pass when they should fail because a method is not implemented, but the mock
  allows it to be used.

### Recommendations

- To avoid brittle specs, use test doubles to decouple them from validation rules, configuration, and
  other ever-changing specifics of your application.

- Don't use `expect` when `allow` is sufficient.

- **Code smell**: If you find yourself stubbing messages of the subject under test, it's a hint that your
  subject has more than one responsibility, and it's likely better to split it up into two objects.

- Use the config option `verify_partial_doubles` set to true.

- **Mock only objects you own**: Mocking third-party objects is risky. Your specs might pass when they
  should fail or the other way around. To avoid this:
  - Rely on your acceptance specs.
  - Use a **high-fidelity** fake of the API, if it's possible.
    - There are gems that provide them for you.
    - The **VCR** gem helps building high-fidelity fakes for HTTP APIs that don't provide them.
  - Write your own wrapper around the API and use a double instead of your wrapper.

## Patterns and Practices

### General

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

- Test in random order to find order dependencies. Use `config.order = :random` in `spec_helper.rb`.
  - To repeat an specific order use the flag `--seed` with the value reported in the previous output.
  - With the `--bisect` flag rspec will run your specs in groups and try to find where the dependency is.

- Avoid the Mystery Guest problem: The test reader is not able to see the cause and effect between fixture
  and verification logic because part of it is done outside the Test Method.
  Read [this post](https://thoughtbot.com/blog/mystery-guest).
  - Don't overuse hooks to avoid repetition. It might become a mess.

- Use clear custom failure messages when the default failure message is not enough. They should be
  enough to understand what went wrong so that you can start fixing it right away instead of adding
  `puts` all over the place.
  - If the custom message is used repeatedly, you can create a custom matcher.

- Avoid overspecification: favor loose matchers:
  Using a loose matcher makes your specs less brittle; it prevents incidental details from causing an
  unexpected failure.

- Never check for a bare exception raise:
  Always include some kind of detail—either a specific custom error class or a snippet from the
  message—that is unique to the specific raise statement you are testing.

### Acceptance/Integration/Unit specs

- Have a separate folder for each of them under `spec/`.
  - `spec/acceptance`.
  - `spec/integration`.
  - `spec/unit`.

### Acceptance/Integration specs: setup test db before each suite

For integration and acceptance tests you'll need to setup your test db:

- Add the code to set it up in `spec/support/db.rb`. Or the like. You can use hooks to run code before
  the suite starts. It should look like:

  ```ruby
  RSpec.configure do |c|
    c.before(:suite) do # before suite.
      Sequel.extension :migration
      Sequel::Migrator.run(DB, 'db/migrations')
      DB[:expenses].truncate
    end
  end
  ```

- Load this code from your acceptance or integration specs using `require_relative`.
- Make sure to make the `DB` object (or whatever you have) available in both the support file
  and the specs file. For example, you can use `require_relative`.

### Acceptance/Integration specs: solve order dependency issues - around hook - isolating specs

Make sure you leave the shared resources you use in a clean state after each spec.

For example a database. Sorround in **transaction**s specs that issue queries to a database, so that
the changed items can be **rolledback**. To implement this you can use the `around` hook:

1. In your support file in `spec/support/db.rb` you can add the `around` hook to examples that are
   tagged with something you define, in this case: `:db`.

   ```ruby
   RSpec.configure do |c|
     # ...

     c.around(:example, :db) do |example|
       # Can run things before.
       DB.transaction(rollback: :always) { example.run }
       # Can run things after.
     end
   end
   ```

   `around` hooks run after any `before` context hooks, but before any `before` example hooks, and similarly
   after any `after` example hooks but before any `after` context hooks.

   The example parameter given to the block should be used to call `run` on it, or `call`, which would
   allow you to treat example as a `Proc`.

2. You need then to do two things:

   1. Include the support file in your specs files using `require_relative`. More on how to avoid this later.
   2. Tag the example groups with `:db`, or whatever tag you chose.

3. To avoid requiring always your support file in your specs, you can ask RSpec to do it for you when
   it finds an spec file that contains an example group or example tagged with `:db`, or your chosen tag:

   In the `spec/spec_helper.rb` file:

   ```ruby
   RSpec.config do |config|
     # ...
     config.when_first_matching_example_defined(:db) do
       require_relative 'support/db'
     end
     # ...
   end
   ```

#### Run spec files separately

```bash
(for f in `find spec -iname '*_spec.rb'`; do
​  echo "$f:"
  bundle exec rspec $f -fp || exit 1
​done)
```

## Hooks

- Only use **config hooks** for things that aren’t essential for understanding how your specs work.
  The bits of logic that isolate each example—such as database transactions or environment
  sandboxing—are prime candidates.

- `:suite` hooks are only allowed to be defined in the config section of your specs.
  - Perhaps in `spec_helper.rb`; or
  - in the `support/` folder.

### Order of execution

- `before` hooks run from the outside in.
  - Scope modifiers: `:context`, `:example`.
- `after` hooks run from the inside out.
  - Scope modifiers: `:context`, `:example`.
- `around` hooks:
  - The code **before** the `example.run` will execute from the outside in. Runs before all `before` hooks
    associated to an example.
  - The code **after** the `example.run` will run from the inside out. Runs after all `after` hooks
    associated to an example.
  - Scope modifiers: `:example`.

## RSpec.configure

All configurations provided by rspec are available here.

The command line flags don't provide all the configuration options available, only those that are
most likely to be used and changed.

rspec will combine all the `RSpec.configure` blocks you have in your code base.

### Recommendations

- Put the setup code in `spec/spec_helper.rb` and load it by adding `--require spec_helper` to your
  `.rspec` file.
- Be careful with what you load in your `spec/spec_helper.rb`.
  - Specs that take only a few milliseconds can become multisecond.
- Use `when_first_matching_example_defined` to load things that are required for specific specs; or
- you can `require` the libraries you need in the specific spec files you need them.

## Auto generated example descriptions

Use them sparingly. One use-case is when the description generated by rspec is almost exactly
to what you would've wrote.

You can use `it`, `specify`, `subject`, `is_expected.to`, `is_expected.not_to`.

Examples:

Instead of this:
```ruby
RSpec.describe CookieRecipe, '#ingredients' do
  it 'should include :butter, :milk and :eggs' do
    expect(CookieRecipe.new.ingredients).to include(:butter, :milk, :eggs)
  end

  it 'should not include :fish_oil' do
    expect(CookieRecipe.new.ingredients).not_to include(:fish_oil)
  end
end
```

This:
```ruby
RSpec.describe CookieRecipe, '#ingredients' do
  specify do
    expect(CookieRecipe.new.ingredients).to include(:butter, :milk, :eggs)
  end

  specify do
    expect(CookieRecipe.new.ingredients).not_to include(:fish_oil)
  end
end

# Would generate same description for the examples.
```

Or this:

```ruby
RSpec.describe CookieRecipe, '#ingredients' do
  subject { CookieRecipe.new.ingredients }
  it { is_expected.to include(:butter, :milk, :eggs) }
  it { is_expected.not_to include(:fish_oil) }
end

RSpec.describe CookieRecipe, '#ingredients' do
  subject { CookieRecipe.new.ingredients }
  it { should include(:butter, :milk, :eggs) }
  it { should_not include(:fish_oil) }
end

# Would generate the same description for the examples.
```

- `subject` is an alias for `let(:subject)`.
- `subject(:some_symbol)` is an alias for `let(:some_symbol)`.
- `specify` is an alias for `it`.
- `is_expected` is an alias for `expect(subject)`.
- `should` and `should_not` are aliases for `expect(subject).to` and `expect(subject).not_to`.