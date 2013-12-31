# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

deepEqual = require 'deep-equal'
clone = require 'clone'

module.exports = 
class ItemPile

  constructor: (item, count, tags) ->
    @item = if typeof(item) == 'string' then ItemPile.itemFromString(item) else item
    @count = count ? 1
    @tags = tags ? {}

  clone: () ->
    return new ItemPile(@item, @count, clone(@tags, false))

  # maximum size items should pile to
  @maxPileSize = 64

  # convert item<->string; change these to use non-string items
  @itemFromString: (s) ->
    if s instanceof ItemPile then return s
    if !s then '' else s

  @itemToString: (item) ->
    ''+item

  hasTags: () ->
    Object.keys(@tags).length != 0    # not "{}"

  matchesType: (itemPile) ->
    @item == itemPile.item

  matchesTypeAndCount: (itemPile) ->
    @item == itemPile.item && @count == itemPile.count

  matchesTypeAndTags: (itemPile) ->
    @item == itemPile.item && deepEqual(@tags, itemPile.tags, {strict:true})

  matchesAll: (itemPile) ->
    @matchesTypeAndCount(itemPile) && deepEqual(@tags, itemPile.tags, {strict:true})

  # can this pile be merged with another?
  canPileWith: (itemPile) ->
    return false if itemPile.item != @item
    return true if itemPile.count == 0 or @count == 0 # (special case: can always merge with 0-size pile of same item, regardless of tags - for placeholder slots)
    return false if itemPile.hasTags() or @hasTags() # any tag data makes unpileable
    true

  # combine two piles if possible, altering both this and argument pile
  # returns count of items that didn't fit
  mergePile: (itemPile) ->
    return false if not @canPileWith(itemPile)
    itemPile.count = @increase(itemPile.count)

  # increase count by argument, returning number of items that didn't fit
  increase: (n) ->
    [newCount, excessCount] = @tryAdding(n)
    @count = newCount
    return excessCount

  # decrease count by argument, returning number of items removed
  decrease: (n) ->
    [removedCount, remainingCount] = @trySubtracting(n)
    @count = remainingCount
    return removedCount

  # try combining count of items up to max pile size, returns [newCount, excessCount]
  tryAdding: (n) ->
    sum = @count + n
    if sum > ItemPile.maxPileSize and @count != Infinity # (special case: infinite piles never overflow)
      return [ItemPile.maxPileSize, sum - ItemPile.maxPileSize] # overflowing pile
    else
      return [sum, 0] # added everything they wanted

  # try removing count of items, returns [removedCount, remainingCount]
  trySubtracting: (n) ->
    difference = @count - n
    if difference < 0
      return [@count, n - @count] # didn't have enough
    else
      return [n, @count - n]  # had enough, some remain

  # remove count of argument items, returning new pile of those items which were split off
  splitPile: (n) ->
    if n < 0 
      # negative count = all but n
      n = @count + n
    else if n < 1
      # fraction = fraction
      n = Math.ceil(@count * n)

    return false if n > @count
    @count -= n       unless n == Infinity # (subtract, but avoid Infinity - Infinity = NaN)

    return new ItemPile(@item, n, clone(@tags, false))

  toString: () ->
    if @hasTags()
      "#{@count}:#{@item} #{JSON.stringify @tags}"
    else
      "#{@count}:#{@item}"

  @fromString: (s) ->
    a = s.match(/^([^:]+):([^ ]+) ?(.*)/) # assumptions: positive integral count, item name no spaces
    return undefined if not a
    [_, countStr, itemStr, tagsStr] = a
    count = parseInt(countStr, 10)
    item = ItemPile.itemFromString(itemStr)
    if tagsStr && tagsStr.length
      tags = JSON.parse(tagsStr)
    else
      tags = {}

    return new ItemPile(item, count, tags)


