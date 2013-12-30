# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

deepEqual = require 'deep-equal'
deepFreeze = require 'deep-freeze'

module.exports = 
class ItemPile

  constructor: (item, count, tags) ->
    item = if typeof(item) == 'string' then ItemPile.itemFromString(item) else item
    throw "itempile illegal item: #{item} is undefined #{count} #{tags}, must be defined" if not item?
    count = count ? 1
    throw "itempile illegal count: #{count} for item #{item} #{tags}, must be >0" if count <= 0
    tags = tags ? {}

    deepFreeze(tags)  # prevent altering all nested values (note: item, count already "frozen", not "objects")

    # define read-only properties
    Object.defineProperties this,
      item:
        value: item
        writable: false
        enumerable: true
      count:
        value: count
        writable: false
        enumerable: true
      tags:
        value: tags
        writable: false
        enumerable: true

    Object.freeze(this) # TODO: necessary? doesn't hurt

  # maximum size items should pile to
  @maxPileSize = 64

  # convert item<->string; change these to use non-string items
  @itemFromString: (s) ->
    return undefined if not s
    return s if s instanceof ItemPile
    return s

  @itemToString: (item) ->
    ''+item

  hasTags: () ->
    Object.keys(@tags).length != 0    # not "{}"

  matchesType: (itemPile) ->
    itemPile? && @item == itemPile.item

  matchesTypeAndCount: (itemPile) ->
    itemPile? && @item == itemPile.item && @count == itemPile.count

  matchesTypeAndTags: (itemPile) ->
    itemPile? && @item == itemPile.item && deepEqual(@tags, itemPile.tags, {strict:true})

  matchesAll: (itemPile) ->
    itemPile? && @matchesTypeAndCount(itemPile) && deepEqual(@tags, itemPile.tags, {strict:true})

  # can this pile be merged with another?
  canPileWith: (itemPile) ->
    return false if not itemPile?
    return false if itemPile.item != @item
    return false if itemPile.hasTags() or @hasTags() # any tag data makes unpileable
    true

  # combine two piles if possible, returning new [our increased pile, their decreased pile]
  mergedPile: (itemPile) ->
    return false if not @canPileWith(itemPile)

    [ourNew, excessCount] = @increased(itemPile.count)
    if excessCount == 0
      theirNew = undefined  # there's nothing left
    else
      theirNew = new ItemPile(itemPile.item, excessCount, itemPile.tags)

    return [ourNew, theirNew]

  # increase count by argument, returning [new pile, excess count that didn't fit]
  increased: (n) ->
    [newCount, excessCount] = @tryAdding(n)
    newPile = new ItemPile(@item, newCount, @tags)

    return [newPile, excessCount]

  # decrease count by argument, returning [new pile, count of items removed]
  decreased: (n) ->
    [removedCount, remainingCount] = @trySubtracting(n)

    if remainingCount == 0
      newPile = undefined   # they took everything!
    else
      newPile = new ItemPile(@item, remainingCount, @tags)

    return [newPile, removedCount]

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

  # remove count of argument items, returning [our updated pile, new pile of those items which were split off]
  splitPile: (n) ->
    if n < 0 
      # negative count = all but n
      n = @count + n
    else if n < 1
      # fraction = fraction
      n = Math.ceil(@count * n)

    if n > @count
      # tried to take too much, do nothing
      return [this, undefined]

    if @count - n == 0
      ourNew = undefined
    else
      ourNew = new ItemPile(@item, @count - n, @tags)

    if n == 0
      theirNew = undefined
    else
      theirNew = new ItemPile(@item, n, @tags)

    return [ourNew, theirNew]

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


