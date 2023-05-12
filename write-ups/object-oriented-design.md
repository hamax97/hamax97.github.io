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
