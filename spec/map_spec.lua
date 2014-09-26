local Array = require('dslua.array')
local Map = require('dslua.map')

describe('A Map', function()
  local map = nil

  before_each(function()
    map = Map.new('foo', 10, 'bar', 20, 'baz', 30)
  end)

  describe('getting a value by key', function()
    context('when the key exists', function()
      it('returns the value', function()
        local value = map:get('foo', 90)
        assert.are.equals(10, value)
      end)
    end)

    context('when the key is missing', function()
      it('returns the default value', function()
        local value = map:get('hihi', 4000)
        assert.are.equals(4000, value)
      end)
    end)
  end)

  describe('inserting a new key-value pair', function()
    it('assigns the value to the key', function()
      map:insert({ 'quux', 50 })
      assert.are.equals(50, map.quux)
    end)
  end)

  describe('merging in another map', function()
    it('combines the maps, overwriting old keys with the new', function()
      map:merge(Map.new('quux', 100, 'foo', 75))
      assert.are.equals(100, map.quux)
      assert.are.equals(75, map.foo)
    end)
  end)

  describe('creating a clone', function()
    it('copies the map', function()
      local other = map:clone()
      assert.are.same(map, other)
      assert.are_not.equals(map, other)
    end)
  end)

  describe('retrieving only keys', function()
    it('returns an array of keys', function()
      local keys = map:keys()
      table.sort(keys)
      assert.are.same({ 'bar', 'baz', 'foo' }, keys)
    end)
  end)

  describe('retrieving only values', function()
    it('returns an array of values', function()
      local values = map:values()
      table.sort(values)
      assert.are.same({ 10, 20, 30}, values)
    end)
  end)

  describe('pouring elements into another collection', function()
    it('copies the elements', function()
      local other = map:enum():into(Map.new())
      assert.are.same(map, other)
    end)
  end)

  describe('testing if an element is present', function()
    context('when the element is present', function()
      it('returns true', function()
        local result = map:enum():p_cont({ 'foo', 10 })
        assert.is_true(result)
      end)
    end)

    context('when the element is not present', function()
      it('returns false', function()
        local result = map:enum():p_cont({ 'foo', 20 })
        assert.is_false(result)
      end)
    end)
  end)

  describe('searching for an element', function()
    context('when the element is found', function()
      it('returns the element', function()
        local result = map:enum():find({ 'foo', 10 })
        assert.are.same({ 'foo', 10 }, result)
      end)
    end)

    context('when the element is not found', function()
      it('returns nil', function()
        local result = map:enum():find({ 'foo', 20 })
        assert.are.equal(nil, result)
      end)
    end)
  end)

  describe('testing if any element satisfies a predicate', function()
    context('when an element satisfies the predicate', function()
      it('returns true', function()
        local pred = function(e) return e[2] > 10 end
        local result = map:enum():p_any(pred)
        assert.is_true(result)
      end)
    end)

    context('when no element satisfies the predicate', function()
      it('returns false', function()
        local pred = function(e) return e[2] > 100 end
        local result = map:enum():p_any(pred)
        assert.is_false(result)
      end)
    end)
  end)

  describe('testing if all elements satisfy a predicate', function()
    context('when all elements satisfy the predicate', function()
      it('returns true', function()
        local pred = function(e) return e[2] < 50 end
        local result = map:enum():p_all(pred)
        assert.is_true(result)
      end)
    end)

    context('when on element fails to satisfy the predicate', function()
      it('returns false', function()
        local pred = function(e) return e[2] < 30 end
        local result = map:enum():p_all(pred)
        assert.is_false(result)
      end)
    end)
  end)

  describe('testing when no elements satisfy a predicate', function()
    context('when no elements satisfy the predicate', function()
      it('returns true', function()
        local pred = function(e) return e[2] < 0 end
        local result = map:enum():p_none(pred)
        assert.is_true(result)
      end)
    end)

    context('when an element satisfies the predicate', function()
      it('returns false', function()
        local pred = function(e) return e[2] < 15 end
        local result = map:enum():p_none(pred)
        assert.is_false(result)
      end)
    end)
  end)

  describe('reducing the elements', function()
    it('returns the result of the reduction', function()
      local reducer = function(acc, e) return acc + e[2] end
      local result = map:enum():reduce(reducer, 0)
      assert.are.equal(60, result)
    end)
  end)

  describe('mapping the elements', function()
    it('returns the mapped values', function()
      local mapper = function(e) return { e[1], e[2] + 5 } end
      local result = map:enum():map(mapper):all()
      assert.are.same({ foo = 15, bar = 25, baz = 35 }, result)
    end)
  end)

  describe('filtering the elements', function()
    it('returns elements that pass the filter', function()
      local filterer = function(e) return e[2] > 10 end
      local result = map:enum():filter(filterer):all()
      assert.are.same({ bar = 20, baz = 30 }, result)
    end)
  end)

  describe('catting elements', function()
    it('returns a flattened set of elements', function()
      local result = Map.new('foo', 10):enum():cat():into(Array.new())
      assert.are.same({ 'foo', 10 }, result)
    end)
  end)

  describe('mapcatting elements', function()
    it('returns a mapped set of elements, flattened', function()
      local mapper = function(e) return { e[1], e[2] * 10, e[2] * 100 } end
      local result = Map.new('foo', 10):enum():mapcat(mapper):into(Array.new())
      assert.are.same({ 'foo', 100, 1000 }, result)
    end)
  end)
end)
