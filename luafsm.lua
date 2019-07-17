-- create a table for the module
local luafsm = {}

-- define the create function
function luafsm.create(state)
   -- basic state
   if type(state) == "function" then
      return state
   -- super state
   elseif type(state) == "table" then
      local entry = state.entry
      local exit = state.exit
      local current = nil
      local substates = {}
      -- recursively construct substates
      for identifer, substate in pairs(state.substates) do
         substates[identifer] = luafsm.create(substate)
      end
      -- generate and return a super state function
      return function()
         if current == nil then
            if type(entry) == "function" then
               current = entry()
            else
               current = entry
            end
         end
         -- execute the current substate
         done, next = substates[current]()
         if done then
            -- done is true, the current substate has finished executing
            if next then
               current = next
               return false
            else
               -- no next state
               -- reset the current state to nil
               current = nil
               if exit then
                  -- exit was defined
                  if type(exit) == "table" then
                     return unpack(exit)
                  elseif type(exit) == "function" then
                     return exit()
                  else
                     return exit
                  end
               else
                  -- exit was not defined
                  return true
               end
            end
         else
            -- done is false, the current substate is still executing
            return false
         end
      end
   end
end

-- return the module
return luafsm;








