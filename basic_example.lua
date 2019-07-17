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

-- run it until it has finished
while hello_world_fsm() == false do end
