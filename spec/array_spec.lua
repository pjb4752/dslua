local Array = require('dslua.array')

describe('An Array', function()
  local array = nil

  before_each(function()
    array = Array.new(10, 20, 30)
  end)

  describe('pushing an element', function()
    it('adds the element onto the end of the array', function()
      array:push(40)
      assert.are.equals(4, #array)
      assert.are.equals(40, array:last())
    end)
  end)

  describe('popping an element', function()
    it('removes and returns the last array element', function()
      local value = array:pop()
      assert.are.equals(2, #array)
      assert.are.equals(30, value)
    end)
  end)

  describe('pushing another array', function()
    it('appends the new elements onto the original', function()
      array:push_all(Array.new(40, 50))
      assert.are.equals(5, #array)
      assert.are.equals(40, array[4])
      assert.are.equals(50, array[5])
    end)
  end)

  describe('creating a clone', function()
    it('copies the array', function()
      local other = array:clone()
      assert.are.same(array, other)
      assert.are_not.equals(array, other)
    end)
  end)

  describe('pouring elements into another collection', function()
    it('copies the elements', function()
      local other = array:enum():into(Array.new())
      assert.are.same(array, other)
    end)
  end)

  describe('testing if an element is present', function()
    context('when the element is present', function()
      it('returns true', function()
        local result = array:enum():p_cont(10)
        assert.is_true(result)
      end)
    end)

    context('when the element is not present', function()
      it('returns false', function()
        local result = array:enum():p_cont(40)
        assert.is_false(result)
      end)
    end)
  end)

  describe('searching for an element', function()
    context('when the element is present', function()
      it('returns the element', function()
        local result = array:enum():find(20)
        assert.are.equals(20, result)
      end)
    end)

    context('when the element is not present', function()
      it('returns nil', function()
        local result = array:enum():find(40)
        assert.are.equal(nil, result)
      end)
    end)
  end)

  describe('testing if any element satisfies a predicate', function()
    context('when an element satisfies the predicate', function()
      it('returns true', function()
        local pred = function(e) return e > 10 end
        local result = array:enum():p_any(pred)
        assert.is_true(result)
      end)
    end)

    context('when no element satifies the predicate', function()
      it('returns false', function()
        local pred = function(e) return e > 100 end
        local result = array:enum():p_any(pred)
        assert.is_false(result)
      end)
    end)
  end)

  describe('testing if all elements satisfy a predicate', function()
    context('when all elements satisfy the predicate', function()
      it('returns true', function()
        local pred = function(e) return e < 50 end
        local result = array:enum():p_all(pred)
        assert.is_true(result)
      end)
    end)

    context('when one element fails to satisfy the predicate', function()
      it('returns false', function()
        local pred = function(e) return e < 30 end
        local result = array:enum():p_all(pred)
        assert.is_false(result)
      end)
    end)
  end)

  describe('testing when no elements satisfy a predicate', function()
    context('when no elements satisfy the predicate', function()
      it('returns true', function()
        local pred = function(e) return e < 0 end
        local result = array:enum():p_none(pred)
        assert.is_true(result)
      end)
    end)

    context('when an element satisfies the predicate', function()
      it('returns false', function()
        local pred = function(e) return e < 15 end
        local result = array:enum():p_none(pred)
        assert.is_false(result)
      end)
    end)
  end)

  describe('finding the index of an element', function()
    context('when the element exists', function()
      it('returns the first matching index', function()
        array:push(20)
        local result = array:index_of(20)
        assert.are.equal(2, result)
      end)
    end)

    context('when the element does not exist', function()
      it('returns nil', function()
        local result = array:index_of(4000)
        assert.are.equal(nil, result)
      end)
    end)
  end)

  describe('reducing the elements', function()
    it('returns the result of the reduction', function()
      local reducer = function(acc, e) return acc + e end
      local result = array:enum():reduce(reducer, 0)
      assert.are.equal(60, result)
    end)
  end)

  describe('mapping the elements', function()
    it('returns the mapped values', function()
      local mapper = function(e) return e + 5 end
      local result = array:enum():map(mapper):all()
      assert.are.same({ 15, 25, 35 }, result)
    end)
  end)

  describe('filtering the elements', function()
    it('returns elements that pass the filter', function()
      local filterer = function(e) return e > 10 end
      local result = array:enum():filter(filterer):all()
      assert.are.same({ 20, 30 }, result)
    end)
  end)

  describe('catting elements', function()
    it('returns a flattened set of elements', function()
      local nested1 = Array.new(4, 5, 6)
      local nested2 = Array.new(7, 8, 9)
      local result = Array.new(nested1, nested2):enum():cat():all()
      assert.are.same({ 4, 5, 6, 7, 8, 9 }, result)
    end)
  end)

  describe('mapcatting elements', function()
    it('returns a mapped set of elements, flattened', function()
      local mapper = function(e) return { e * 10, e * 100 } end
      local result = array:enum():mapcat(mapper):all()
      assert.are.same({ 100, 1000, 200, 2000, 300, 3000 }, result)
    end)
  end)
end)
