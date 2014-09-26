local Array = require('dslua.array')
local Map = require('dslua.map')

-- Arrays --
local numbers = Array.from_table({ 1, 2, 3, 4, 5 })

local mapper = function(e) return e * 2 end
local filterer = function(e) return e > 5 end

local result1 = numbers:enum():map(mapper):filter(filterer):into(Array.new())

-- 6, 8, 10
for i, e in ipairs(result1) do
  print(e)
end

local mapcatter = function(e) return Array.from_table({ e, e * 2, e * 3 }) end

local result2 = numbers:enum():mapcat(mapcatter):all()

-- 1, 2, 3, 2, 4, 6, 3, 6, 9, 4, 8, 12, 5, 10, 15
for i, e in ipairs(result2) do
  print(e)
end

local result3 = numbers:enum():p_none(function(e) return e == 7 end)

-- true
print(result3)

-- Maps --
local ages = Map.new('Mary', 20, 'Bob', 24, 'Mike', 18, 'Jane', 22)

local maxage = function(acc, e) return e[2] > acc[2] and e or acc end

local result4 = ages:enum():reduce(maxage, { 'Nobody', 0 })

-- Bob is the oldest at 24 years
print(string.format('%s is the oldest at %d years', result4[1], result4[2]))

local result5 = ages:enum():p_any(function(e) return e[2] > 30 end)

-- false
print(result5)
