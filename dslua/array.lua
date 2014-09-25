local Enum = require('dslua.enum')

local getmeta, setmeta = getmetatable, setmetatable
local typeof, rset, err = type, rawset, error
local apairs = ipairs

local M = setmeta({ __type = 'array' }, {})

if _G['DSLUA_CHECK_ARRAY_INDICES'] then
  M.check_indices = function(target, index, value)
    if typeof(index) == 'number' then
      rset(target, index, value)
    else
      err('non-numeric index in array access')
    end
  end
end

function M.new(...)
  return M.from_table({ ... })
end
getmeta(M).__call = function(t, ...) return M.new(...) end
M.builder = M.new

function M.from_table(source)
  return setmeta(source, { __index = M, __newindex = M.check_indices })
end

function M.p_array(obj)
  return typeof(obj) == 'table' and obj.__type == M.__type
end

function M.enum(array)
  return Enum.new(array)
end

function M.first(array)
  return array[1]
end

function M.last(array)
  return array[table.getn(array)]
end
M.peek = M.last

function M.push(array, element)
  local index = table.getn(array) + 1
  array[index] = element
  return array
end
M.append = M.push
M.adjoiner = M.push

function M.pop(array)
  local last_index = table.getn(array)
  local last = array[last_index]
  array[last_index] = nil
  return last
end

function M.push_all(array, other)
  local index = table.getn(array)
  for i, v in apairs(other) do
    array[index + i] = v
  end
  return array
end
M.append_all = M.push_all

function M.clone(array)
  -- FIXME unpacking large tables (>8000 elements)
  return M(unpack(array))
end

function M.index_of(array, value)
  local index = 1
  local reducer = function(acc, e)
    if acc then return acc end
    if e == value then
      return index
    else
      index = index + 1
    end
  end

  return Enum.new(array):reduce(reducer, nil)
end

return M
