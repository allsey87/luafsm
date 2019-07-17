# A finite state machine based on Lua closures

## Description
This repository provides an implementation of a finite state machine based on [Lua closures](https://www.lua.org/pil/6.1.html). The module consists of a single file: [luafsm.lua](luafsm.lua), which when loaded returns a single table, containing a single function called `create`.

When provided with a description of a state machine, the `create` function will recursively build a closure-based state machine that can be executed. The description of a state machine is represented by a table that specifies the states and their arrangement. There are two types of states: basic states and super states.

Basic states are functions (or closures) which implement the behavior of the system (character, robot, etc). The first returned value of a basic state must be a boolean indicating whether or not the state has finished executing. If the state returns false, it will be reevaluated on the next control step. Otherwise, if the first returned value of a basic state is true, the second returned argument will be checked. If the second returned value has been provided, it is used as a key to look up the adjacent state to be transitioned to. If the second returned value is `nil`, the parent state exits.

Super states are tables that contain three fields: `entry`, `substates`, and `exit`. `entry` is a key (or a function that returns a key) that matches an entry in substate table. `substates` is a table that may contain basic states, super states, or both. `exit` is a key or a function that returns a key matching an adjacent state to be transitioned to. If it is a key, the transition is made once a substate has exited (i.e., returned `true, nil`). If it is a function, which evaluates to `false` the super state is reinitialized using the entry field. If it evaluates to true, the second returned value is checked. If the second returned value is not `nil` it is used as a key to transition to an adjacent state, otherwise the parent state exits.

### Basic Example
A basic example is provided in [basic_example.lua](basic_example.lua). It can be run by issuing the command, `lua basic_example.lua`.

```lua
-- load module
luafsm = require('luafsm')

-- define the state machine
hello_world_states = {
  entry = "print_hello",
  substates = {
    print_hello   = function() io.write("hello") return true, "print_space" end,
    print_space   = function() io.write(" ")     return true, "print_world" end,
    print_world   = function() io.write("world") return true, "print_newline" end,
    print_newline = function() io.write("\n")    return true, nil end,
  }
}

-- instantiate it
hello_world_fsm = luafsm.create(hello_world_states)

-- run the state machine until it has finished
while hello_world_fsm() == false do end
```

### Advanced Example
An advanced example is provided in [advanced_example.lua](advanced_example.lua). This example demonstrates the use of factories and functions to reduce code repetition.

## Insights

### Advantages
1. According to the Lua documentation, this code may execute faster when compared with table-based state machine implementations, since checking upvalues is cheaper than looking up entries in a table.
2. The code allows for quite a compact representation of a complex state machine

### Disadvantages
1. Harder to debug. Error reported by the Lua interpreter will point to the code doing the parsing even if the error is in your state machine description.
2. Adding and removing states is currently not supported (and may be difficult to implement)
