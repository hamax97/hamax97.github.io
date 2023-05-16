# Object-Oriented Design

The principles stated here are mostly a summary of what I found in the book:
Metz, Sandi. *Practical Object-Oriented Design: An Agile Primer using Ruby, 2nd Ed*.
Addison-Wesley Professional, July 2018; plus other sources in the Internet.

<!-- TOC -->

- [Object-Oriented Design](#object-oriented-design)
    - [Background](#background)
    - [Classes with a single responsibility](#classes-with-a-single-responsibility)
        - [How to know if a class/method is doing only one thing?](#how-to-know-if-a-classmethod-is-doing-only-one-thing)
        - [Tips for code that embraces change](#tips-for-code-that-embraces-change)
    - [Managing dependencies](#managing-dependencies)
        - [Tips for recognizing dependencies](#tips-for-recognizing-dependencies)
        - [Disadvantages of tight coupling](#disadvantages-of-tight-coupling)
        - [Tips for avoiding dependencies](#tips-for-avoiding-dependencies)
            - [Inject dependencies](#inject-dependencies)
            - [Isolate dependencies](#isolate-dependencies)
                - [Isolate instance creation](#isolate-instance-creation)
                - [Isolate vulnerable external messages](#isolate-vulnerable-external-messages)
            - [Remove argument-order dependencies](#remove-argument-order-dependencies)
                - [Explicityly define defaults](#explicityly-define-defaults)
                - [Isolate multiparameter initialization](#isolate-multiparameter-initialization)
        - [Managing dependency direction](#managing-dependency-direction)
    - [Creating flexible interfaces](#creating-flexible-interfaces)

<!-- /TOC -->

## Background

The objectives of OOD are:

- To make software easily **changeable** in the future.
- To reduce the cost of change.
- To make software **reusable**.
- To give joy to the software craftsmen.

Design doesn't matter if your application will never change.

OOD requires you to shift from thinking of the world as a collection of predefined procedure to modeling
the world as a series of messages that pass between objects.

OOD is about managing dependencies (between classes, between methods, ...). It's a set of coding techniques
that arrange dependencies such that objects easily change.

Design is the art of arranging code.

**Design principles** are different from **design patterns**.

There are Ruby gems that help you measure how well your code follows OOD principles:

- Bad measurements likely indicate your software is poorly designed.
- Good measurements, though, are not an indication that you're designing well. You might be applying well
  design principles to solve the wrong problems.

The foundation of an object-oriented system is the **message** (method).

Design is more the art of preserving changeability than it is the act of achieving perfection.

Your code should have the following qualities (TRUE):

- **Transparent**: The consequences of change should be obvious in the code that is changing and in
  distant code that relies upon it.
- **Reasonable**: The cost of any change should be proportional to the benefits the change achieves.
- **Usable**: Existing code should be usable in new and unexpected contexts.
- **Exemplary**: The code itself should encourage those who change it to perpetuate these qualities.

## Classes with a single responsibility

A class/method should do the smallest possible useful thing; that is, it should have a single responsiblity.

In my mind I used to think that having a class to do one small thing was bad design because I would
end up having lots of classes. But it seems like it's actually good.

A class that has more than one responsiblity is difficult to reuse.

### How to know if a class/method is doing only one thing?

- Try to describe your class in single sentence. If it includes **"and"** or **"or"**, it's likely that your
  class is doing more than one thing.

- When everything in a class is related to its central purpose, the class is said to be **highly cohesive**,
  or to have a single responsiblity.

- The idea is not to have a class that changes only for a very small, silly reason. The idea is to have
  a class that is **cohesive**.

### Tips for code that embraces change

- Depend on behavior, not data.

  - **Hide instance variables** (even from yourself) using accessor methods. Don't refer to instance
  variables directly.

  - **Hide data structures** behind methods. If your class uses a complicated data structure, don't access it
  directly in your methods, rather abstract away its complexities behind another method, maybe a class itself.

- Instead of adding a comment to a bit of code for exaplanation, extract that code to a method.
  The method name will serve as documentation.

- Enforce single responsiblity everywhere.

## Managing dependencies

An object depends on another object if, when one object changes, the other might be forced to change in turn.

The design challenge is to manage dependencies so that each class has the fewest possible.

A class should know just enough to do its job and not one thing more.

The more one class knows about another, the more **coupled** they are. The more tightly coupled two objects
are, the more they behave like a single entity.

### Tips for recognizing dependencies

An object has a dependency when it knows:

- The name of another class.
- The name of a message it intends to send to someone other than `self`.
- The arguments that a message requires.
- The order of those arguments, **positional** arguments.
- An object who knows another who knows another who knows something. This is called **message chaining**,
  a violation of the **"Law of Demeter"**.

Also, avoid over-coupling between your tests and your code. It will be frustrating when you refactor.

### Disadvantages of tight coupling

Let A and B be two tightly coupled classes:

- If you change class A changes, you might have to change class B.
- If you want to reuse class A, class B will be used as well.
- If you test class A, you'll be testing class B as well.

### Tips for avoiding dependencies

#### Inject dependencies

Don't depend on specific classes (class names) inside your object, that is, don't instantiate or
reference directly class names. Instead, receive as parameter an object that responds to the messages you want
to send, don't care about the class of the object. You can receive it through the constructor or the specific
message that uses it.

Don't do this:

```ruby
# DO NOT DO THIS ...
class GameEngine
  attr_reader: :arg1, :arg2 #...

  def initialize(engine_arg1, engine_arg2, arg1, arg2)
    # ...
    @arg1 = arg1
    @arg2 = arg2
  end

  def refresh
    new HumanPlayer(arg1, arg2).jump
  end
end
```

Do this instead:

```ruby
class GameEngine
  attr_reader: :player

  def initialize(player)
    @player = player
  end

  def refresh
    player.jump
  end
end

orc_player = OrcPlayer.new(arg1, arg2)
GameEngine.new(orc_player)
```

#### Isolate dependencies

If you are working on an existing application and you can't delete all unnecessary dependencies you
can **isolate them**.

##### Isolate instance creation

From this:

```ruby
class GameEngine
  attr_reader: :arg1, :arg2 #...

  def initialize(engine_arg1, engine_arg2, arg1, arg2)
    # ...
    @arg1 = arg1
    @arg2 = arg2
  end

  def refresh
    HumanPlayer.new(arg1, arg2).jump
  end
end
```

To this:

```ruby
class GameEngine
  attr_reader: :arg1, :arg2 #...

  def initialize(engine_arg1, engine_arg2, arg1, arg2)
    # ...
    @arg1 = arg1
    @arg2 = arg2
  end

  def refresh
    player.jump
  end

  def player
    @player ||= HumanPlayer.new(arg1, arg2)
  end
end
```

- You are still coupled to `HumanPlayer`, yet this code will be easier to change when allowed.

Or this:

```ruby
class GameEngine
  attr_reader: :player, :arg1, :arg2 #...

  def initialize(engine_arg1, engine_arg2, arg1, arg2)
    # ...
    @arg1 = arg1
    @arg2 = arg2
    @player ||= HumanPlayer.new(arg1, arg2)
  end

  def refresh
    player.jump
  end
end
```

- Note, though, that `HumanPlayer` will always be instantiated when `GameEngine` is instantiated.

##### Isolate vulnerable external messages

When your class contains multiple references to a message that is likely to change, wrap this message up,
isolate it so that if it changes it will be easier to update your class:

From this:

```ruby
class GameEngine
  # ...

  def refresh
    # complex logic ...
    player.jump
    # more complex logic ...
  end

  def trigger_event
    # complex logic ...
    player.jump
    # complex logic ...
  end
end
```

To this:

```ruby
class GameEngine
  # ...

  def refresh
    # complex logic ...
    player_jump
    # more complex logic ...
  end

  def trigger_event
    # complex logic ...
    player_jump
    # complex logic ...
  end

  def player_jump
    player.jump
  end
end
```

#### Remove argument-order dependencies

Prefer **keyword arguments** over **positional arguments**:

- You'll be able to pass arguments in any order.
- Keyword arguments serve as documentation in both ends of the message, in the sender's side
  and in the receiver's side.

It's better to depend on the name of the arguments than in the order they must be passed.

##### Explicityly define defaults

If you can define default values for your arguments, whether keyword or positional arguments.

You can even send messages (call methods) when defining defaults.

##### Isolate multiparameter initialization

In some situations you can't change the signature of the method you depend on.

The classes in your application should depend on code that you own; use a wrapping method to isolate
external dependencies.

Example:

You depend on this external class `GPUEnhancedEngine`.

```ruby
# External class; belongs to an external framework.
module GameEngine
  class GPUEnhancedEngine
    def initialize(positional_arg1, positional_arg2)
      # ...
    end
  end
end
```

Instead of calling `GameEngine::GPUEnhancedEngine.new(positional_arg1, positional_arg2)` in your classes,
wrap this in a wrapper method, like this:

```ruby
module GPUEnhancedEngineWrapper
  def self.engine(arg1:, arg2:)
    GameEngine::GPUEnhancedEngine.new(arg1, arg2)
  end
end

GPUEnhancedEngineWrapper.engine(arg1: 'some_value', arg2: 'some_other_value')
```

Why using a module?

- You have a separate object to which you can send the `engine` message.
- You convey the idea that you don't expect to have instances of this wrapper module.
- It's not meant to be `include`d in other classes.
- This works as a **factory**, an object whose sole purpose is to create other objects.

### Managing dependency direction

Dependencies always have a direction. The key to managing dependencies is to control their direction.

**Depend on things that change less often than you do.**

Reverse dependencies if it makes sense and you are following the guideline above.

## Creating flexible interfaces

Tips here are about methods within a class and how and what to expose to others.

Exposed methods comprise a class' **public interface**.