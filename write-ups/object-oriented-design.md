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
        - [Defining interfaces](#defining-interfaces)
            - [Public interfaces](#public-interfaces)
            - [Private interfaces](#private-interfaces)
        - [Designing the public interface](#designing-the-public-interface)
            - [Using sequence diagrams](#using-sequence-diagrams)
            - [Ask for "what" instead of telling "how"](#ask-for-what-instead-of-telling-how)
            - [Seek context independence](#seek-context-independence)
        - [Rules of thumb for interfaces](#rules-of-thumb-for-interfaces)
            - [Create explicit interfaces](#create-explicit-interfaces)
            - [Honor the public interfaces of others](#honor-the-public-interfaces-of-others)
            - [Minimize context](#minimize-context)
        - [The Law of Demeter](#the-law-of-demeter)
            - [Definition](#definition)
    - [Reduce costs with Duck Typing](#reduce-costs-with-duck-typing)
        - [Plymorphism backgroung](#plymorphism-backgroung)
        - [Recognizing hidden Ducks](#recognizing-hidden-ducks)
        - [Documenting Duck types](#documenting-duck-types)
        - [Be pragmmatic](#be-pragmmatic)
    - [Acquiring behavior through inheritance](#acquiring-behavior-through-inheritance)
        - [Where/when to use inheritance?](#wherewhen-to-use-inheritance)
    - [Sharing role behavior with modules](#sharing-role-behavior-with-modules)
        - [Example](#example)

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

Objects should manage themselves; they should contain their own behavior. If your interest is in object B,
you should not be forced to know about object A if your only use of it is to find things out about B.

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

### Defining interfaces

#### Public interfaces

The face it presents to the world:

- Reveal its primary responsiblity.
- Are expected to be invoked by others.
- Will not change on a whim.
- Are safe for others to depend on.
- Are thoroughly documented in the tests.

**Public methods should read like a description of responsibilities**. Remember the "single responsiblity principle"?

#### Private interfaces

Non-public methods. They:

- Handle implementation details.
- Are not expected to be sent by other objects.
- Can change for any reason whatsoever.
- Are unsage for others to depend on.
- May not even be referenced in the tests.

### Designing the public interface

When you start an application from scratch domain objects are easy to find, but **they are not at the
design center of your application**. Instead, they are a trap for the unwary. If you fixate on domain
object, you will tend to coerce behavior into them. Design experts **notice** domain objects without
concentrating on them; they **focus not on these objects but on the messages that pass between them**.
These messages are the guides that lead you to discover other objects, ones that are just as necessary
but far less obvious.

The **transition from class-based design to message-based design is a turning point in your design career**.
The message-based perspective yields more flexible applications than does the class-based perspective.
Changing the fundamental design question from “I know I need this class, what should it do?” to “I need to
send this message, who should respond to it?” is the first step in that direction.

You don't send messages because you have objects, you have objects because you send messages.

#### Using sequence diagrams

It's a perfect, low-cost way to experiment with objects **and** messages:

- Objects are represented in boxes.
- Each object has a vertical line.
- Messages are represented with arrows. The tip of the arrow points to the receiver. This arrow is
  labeled with the message name.
- When an object is busy processing a message, it is *active* and its vertical line becomes a rectangle
  until it's not busy anymore.

The cost of finding missing objects and messages is very low.

Sequence diagrams are experimental and you can discard them. They are a starting point for your
design.

#### Ask for "what" instead of telling "how"

Instead of driving the behavior of a class through methods in its public interface, implement a single
public method in this receiver class that drives this behavior:

- The public interface will be drastically reduced.
- You'll know less about the receiver class.
- The likelyhood of change in the sender class is reduced given that the receiver class changes.

Trust other objects to do their job, don't try to know **how** they are doing it.

#### Seek context independence

For an object to behave properly it needs a context (dependencies). Try to reduce this context as much as
possible and to know as less as possible from its dependencies. The key is differentiating **what** from **how**.

### Rules of thumb for interfaces

#### Create explicit interfaces

Methods in the **public** interface should:

- Be explicitly identified as such.
- Be more about **what** than **how**.
- Have names that, insofar as you can anticipate, will not change.
- Prefer keyword arguments.

Indicate which methods are more or less stable using:

- `public`, `private` and `protected`.
- You can also use a naming convention for private methods, something like: `_method_name`.

#### Honor the public interfaces of others

Try very hard to **not use** another class' private methods.

A dependency on a private method of an external framework is a form of technical debt. Avoid these
dependencies.

If you **must** depend on a private interface isolate this dependency.

#### Minimize context

Construct public interfaces with an eye toward minimizing the context they require from others.

Keep the what versus how distinction in mind; create public methods that allow senders to get
what they want without knowing how your class implements its behavior.

### The Law of Demeter

Set of coding rules that results in loosely coupled objects.

You will benefit from knowing about responsiblities, dependencies, and interfaces before reading this.

#### Definition

An object should not "reach through" its collaborators to access **their** collaborators' data, methods,
or collaborators.

It prohibits routing a message to a third object via a second object of a different type:

- "only talk to your immediate neighbors"
- "use only one dot"

Example violations: ??

```ruby
player.world.house.door
hash.keys.sort.join(',')
```

- These are colloquially referred to as **train wrecks**.

For a deeper understanding read [this blog](https://blog.testdouble.com/posts/2022-06-15-law-of-demeter).

## Reduce costs with Duck Typing

Duck types are public interaces that are not tied to any specific class.

Users of an object need not, and should not, be concerned about its class.

It's not what an object **is** that matters, it's what it **does**.

The ability to tolerate ambiguity about the class of an object is the hallmark of a confident
designer. Once you begin to treat your objects as if they are defined by their behavior rather
than by their class, you enter into a new realm of expressive flexible design.

### Plymorphism (backgroung)

The ability of many different objects to respond to the same message. Senders of the message need not
care about the class of the receiver; receivers supply their own specific version of the behavior.

### Recognizing hidden Ducks

- Case statements that switch on a class.
- `kind_of?` and `is_a?`
- `responds_to?`

### Documenting Duck types

The abstracness of the duck types makes them less obvious in the code. Therefore, write docs for them.
There are no better docs than tests, so write tests for your duck types.

### Be pragmmatic

There are use cases where using `case` or `kind_of` or ..., is valid. For example, when you depend on
a Ruby class like `Array`. Ruby classes are unlikely to change, so depending on them directly can be
considered safe.

## Acquiring behavior through inheritance

**Inheritance** is, at its core, a mechanism for **automatic message delegation**. It defines a forwarding
path for not-understood messages. You define an inheritance relationship between two objects, and the
forwarding happens automatically. There are different types of inheritance:

- In ***class*ical inheritance** these relationships are defined by creating subclasses. The **class**
  prefix in classical refers to the **superclass/subclass** mechanism.
  - There is **multiple inheritance** and **single inheritance**. Ruby provides **single inheritance**.
- JavaScript has **prototypical inheritance**.
- Also, Ruby has **modules**.

### Where/when to use inheritance?

- Use of classical inheritance is always optional; every problem that is solves can be solved another way.
  You have to ponder the costs.
  - You can share **role behavior** with `module`s.

- Only use inheritance for shallow trees.

- When you have highly related classes that share common behavior but differ along some dimension.

- The objects you are modeling must truly have a generalization-specialization relationship.

- Creating a hierarchy has costs; the best way to minimize these costs is to maximize your chance of
  **getting the abstraction right** before allowing subclasses to depend on it:
  - You'll face the trade-off of duplicating code in two classes or going ahead and create an abstraction
    for those two classes:
    - If you duplicate code it'll be costly to change if you have to update it frequently.
    - If you create the abstraction you might have problems if a new specialized class arrives with
      a new requirement and you are forced to somehow change your already created abstraction and its dependants.
  - The best way to create an abstract superclass is by pushing code **up** from concrete subclasses bit by bit,
    instead of moving all behavior to the superclass and pushing down specific behaviors. It's safer this way.
    You'll avoid having concrete behavior (useful only in one subclass) in the superclass.
  - Identifying the correct abstraction is easier if you have access to at least three existing concrete
    classes.

- Use the **template method pattern**. In parent classes (maybe abstract) extract steps of behavior as methods,
  then let sublcasses implement specifc behavior in those methods.
  - Raise clear error when there's no implementation defined in a subclass:

    ```ruby
    def some_method
      raise NotImplementedError, "#{self.class} must implement some_method"
    end
    ```

- **Decouple superclasses and subclasses**:
  - Forcing a sublcass to know how to interact with its abstract superclass creates a dependency.
  - Avoid calling `super` from your subclasses, it's like saying the subclass knows the algorithm in
    the parent class and **depents** on this knowledge.
  - Other programmers might forget to call `super`.
  - Rather, send **hook** messages from superclasses. For example, note the hook methods
    `post_initialize` and `local_behavior`:

    ```ruby
    class SuperClass
      def initialize(**args)
        # ...
        post_initalize(args)
      end

      def post_initialize(args)
        # empty
      end

      def some_behavior
        # some cool behavior and then ...
        local_behavior
      end

      def local_behavior
        # empty or default implementation
      end
    end

    class SubClass < SuperClass
      def post_initialize(args)
        # some cool specific behavior with args that belongs here
      end

      def local_behavior
        # some specific behavior that belongs here
      end

      # now I don't know that much about SuperClass
    end
    ```

## Sharing role behavior with modules

Use of classical inheritance is always optional; every problem that is solves can be solved another way.

Some problems require sharing behavior among objects that seem unrelated, the relationship that
unites them is a **role**, the role the objects play.

There exists a relationship between the objects that play the role and object for whom they play the role.
It's not as vissible, but it exists, therefore dependencies are created, and must be properly managed.

Ruby provides a way to define a named group of methods independent of any class which can be **mixed-in**
in any object. These mixins are called **modules**.

**Modules** provide a way to add the same set of code to objects of different classes:
- The methods defined in the module become available via **automatic delegation**.

Be careful, an object that defines a small set of methods still can respond to a lot of messages:

- Those it implements.
- Those implemented in all objects above it in the hierarchy.
- Those implemented in any module that has been added to it.
- Those implemented in all modules added to any object above it in the hierarchy.

### Example

```ruby
module Restorable
  def restore
    restorer.heal(self)
    local_restoration_behavior
  end

  def restorer
    @restorer ||= MagicalRestorer.new
  end

  def local_restoration_behavior
    raise NotImplementedError
  end
end

class Goblin
  include Restorable

  def local_restoration_behavior
    jump.and scream
  end

  # ...
end

bolg = Goblin.new

# battle begins ...

bolg.restore
```