-- create a table for the module
local luafsm = {}

-- define the create function
function luafsm.create(state)
   -- simple state
   if type(state) == "function" then
      return state
   -- super state
   elseif type(state) == "table" then
      local substates = {}
      local current = nil
      local entry = nil
      local exit = nil
      -- recursively construct substates
      for identifer, substate in pairs(state.substates) do
         substates[identifer] = luafsm.create(substate)
      end
      -- set the entry state
      entry = state.entry
      current = state.entry
      if state.exit then
         exit = state.exit
      else
         -- default exit function
         exit = function() return true end
      end
      -- generate a super state function
      return function()
         --print("current = " .. current)
         done, next = substates[current]()
         if done then
            if next then
               current = next
               return false
            else
               current = entry
               return exit()
            end
         else
            return false
         end
      end
   end
end

-- return the module
return luafsm;








