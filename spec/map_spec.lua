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
      assert.are_not.equals(other, map)
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
end)
