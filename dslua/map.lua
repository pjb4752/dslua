local Array = require('lualibs.array')

local getmeta, setmeta = getmetatable, setmetatable
local typeof, rset, err = type, rawset, error
local apairs, mpairs = ipairs, pairs

local M = setmeta({ __type = 'map' }, {})

-- probably not that useful, but numeric keys are uncommon...
if _G['DSLUA_CHECK_MAP_KEYS'] then
  M.check_keys = function(target, index, value)
    if typeof(index) ~= 'number' then
      rset(target, index, value)
    else
      err('numeric index in map')
    end
  end
end

M.new = function(...)
  return M.from_array({ ... })
end
getmeta(M).__call = function(_, ...) return M.new(...) end

M.from_array = function(source)
  local obj = {}
  local key = nil
  for i, e in apairs(source) do
    if i % 2 ~= 0 then key = e
    else obj[key] = e
    end
  end
  return M.from_table(obj)
end

M.from_table = function(source)
  return setmeta(source, { __index = M, __newindex = M.check_keys })
end

M.is_map = function(obj)
  return typeof(obj) == 'table' and obj.__type == M.__type
end

M.get = function(map, key, default)
  return map[key] or default
end

M.insert = function(map, tuple)
  local key, value = unpack(tuple)
  map[key] = value
  return map
end

M.merge = function(map, other)
  for key, value in mpairs(other) do
    map[key] = value
  end
  return map
end

M.clone = function(map)
  local dup = M.new()
  return M.merge(dup, map)
end

M.keys = function(map)
  local keys = {}
  local index = 1
  for k, _ in mpairs(map) do
    keys[index] = k
    index = index + 1
  end
  return Array.from_table(keys)
end

M.values = function(map)
  local values = {}
  local index = 1
  for _, v in mpairs(map) do
    values[index] = v
    index = index + 1
  end
  return Array.from_table(values)
end

return M