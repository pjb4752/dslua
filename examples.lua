local ar = require('dslua.array')
local en = require('dslua.enum')

-- Arrays --
local numbers = ar.from_table({1, 2, 3, 4, 5, 6})

local mapper = function(e) return e * 2 end
local filterer = function(e) return e > 7 end

local result = numbers:enum():map(mapper):filter(filterer):into(ar.new())

for i, e in ipairs(result) do
  print(string.format('element at %d is %d', i, e))
end

local mapcatter = function(e) return ar.from_table({ e, e * 2, e * 3 }) end

local result2 = numbers:enum():mapcat(mapcatter):all()

for i, e in ipairs(result2) do
  print(string.format('element at %d is %d', i, e))
end

local result3 = numbers:enum():p_none(function(e) return e == 7 end)

print(result3)

-- Maps --

-- add something
