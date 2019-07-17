luafsm = require('luafsm')

-- example use of a factory to generate states
function new_char_printer(char, transition)
   return function()
      io.write(char)
      return true, transition
   end
end

-- example use of a function to generate superstates
function printer(str, transition)
   state = {}
   state.substates = {}
   for index = 1, #str do
      if index < #str then
         state.substates[index] =
            new_char_printer(str:sub(index, index), index + 1)
      else
         state.substates[index] =
            new_char_printer(str:sub(index, index))
      end 
   end
   state.entry = 1
   state.exit = function() return true, transition end
   return state
end

-- define a hello world printing state machine
print_hello_world = {
   entry = "print_hello",
   substates = {
      print_hello = printer("hello", "print_space"),
      print_space = function()
         io.write(" ") 
         return true, "print_world"
      end,
      print_world = {
         entry = "print_w",
         substates = {
            print_w = new_char_printer("w", "print_o"),
            print_o = new_char_printer("o", "print_r"),
            print_r = new_char_printer("r", "print_l"),
            print_l = new_char_printer("l", "print_d"),
            print_d = new_char_printer("d"),
         },
         exit = function()
            return true, "print_exclamation_mark"
         end,
      },
      print_exclamation_mark = function()
         print("!")
         return true
      end,
   },
   exit = function() return true end,
}

-- create an instance of the state machine
fsm = luafsm.create(print_hello_world)

-- run the state machine until it finishes
while fsm() == false do end

