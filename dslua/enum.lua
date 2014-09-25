local setmeta = setmetatable
local mpairs, typeof = pairs, type

local M = setmeta({ __type = 'enum' }, {})

local function compose(fns)
  return function(init)
    local value = init
    for i = #fns, 1, -1 do
      value = fns[i](value)
    end
    return value
  end
end

function M.new(source)
  return setmeta({ source = source, links = {} }, { __index = M })
end

function M.all(enum)
  return M.into(enum, enum.source)
end

function M.into(enum, target)
  local reducer = compose(enum.links)
  local init = target.builder()

  return enum:reduce(reducer(target.adjoiner), init)
end

function M.p_any(enum, predicate)
  local reducer = compose(enum.links)
  local adjoiner = function(acc, e) return acc or predicate(e) end

  return enum:reduce(reducer(adjoiner), false)
end

function M.p_all(enum, predicate)
  local reducer = compose(enum.links)
  local adjoiner = function(acc, e) return acc and predicate(e) end

  return enum:reduce(reducer(adjoiner), false)
end

function M.p_cont(enum, value)
  return enum:p_any(function(e) return e == value end)
end

function M.p_none(enum, predicate)
  return not enum:p_any(predicate)
end

local function reduce_array(source, reducer, init)
  local result = init

  for i = 1, #source do
    result = reducer(result, source[i])
  end
  return result
end

local function reduce_map(source, reducer, init)
  local result = init

  for k, v in mpairs(source) do
    result = reducer(result, { k, v })
  end
  return result
end

function M.reduce(enum, reducer, init)
  local source = enum
  if enum.__type == 'enum' then
    source = source.source
  end

  if source.__type == 'array' then
    return reduce_array(source, reducer, init)
  elseif source.__type == 'map' then
    return reduce_map(source, reducer, init)
  elseif typeof(source) == 'table' then
    if t[1] then
      return reduce_array(source, reducer, init)
    else
      return reduce_map(source, reducer, init)
    end
  end
end

function M.map(enum, mapper)
  enum.links[#enum.links + 1] = function(step)
    return function(accumulator, element)
      return step(accumulator, mapper(element))
    end
  end
  return enum
end

function M.filter(enum, filterer)
  enum.links[#enum.links + 1] = function(step)
    return function(accumulator, element)
      if filterer(element) then
        return step(accumulator, element)
      end
      return accumulator
    end
  end
  return enum
end

function M.cat(enum)
  enum.links[#enum.links + 1] = function(step)
    return function(accumulator, element)
      return M.reduce(element, step, accumulator)
    end
  end
  return enum
end

function M.mapcat(enum, mapper)
  return enum:map(mapper):cat()
end

return M