# Lessons learned RSpec

<!-- TOC -->

- [Lessons learned RSpec](#lessons-learned-rspec)
    - [Output colors](#output-colors)
    - [Libraries](#libraries)
        - [rspec-core](#rspec-core)

<!-- /TOC -->

## Output colors

- Passing specs are `green`.
- Failing specs, and failure details, are `red`.
- Example descriptions and structural text are `black`.
- Extra details such as stack traces are `blue`.
- Pending specs are `yellow`.

## Libraries

### rspec-core

The main parts of the API are: `describe`, `it`, `expect`. With these only, al ot of things can be done.
