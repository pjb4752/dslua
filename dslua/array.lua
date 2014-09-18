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

M.new = function(...)
  return M.from_table({ ... })
end
getmeta(M).__call = function(t, ...) return M.new(...) end

M.from_table = function(source)
  return setmeta(source, { __index = M, __newindex = M.check_indices })
end

M.is_array = function(obj)
  return typeof(obj) == 'table' and obj.__type == M.__type
end

M.first = function(array)
  return array[1]
end

M.last = function(array)
  return array[table.getn(array)]
end
M.peek = M.last

M.push = function(array, element)
  local index = table.getn(array) + 1
  array[index] = element
  return array
end
M.append = M.push

M.pop = function(array)
  local last_index = table.getn(array)
  local last = array[last_index]
  array[last_index] = nil
  return last
end

M.push_all = function(array, other)
  local index = table.getn(array)
  for i, v in apairs(other) do
    array[index + i] = v
  end
  return array
end
M.append_all = M.push_all

M.clone = function(array)
  -- FIXME unpacking large tables (>8000 elements)
  return M(unpack(array))
end

return M
