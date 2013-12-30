# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

test = require 'tape'
ItemPile = require './'

test 'create default', (t) ->
  a = new ItemPile('dirt')
  t.equal a.item, 'dirt'
  t.equal a.count, 1
  t.deepEqual a.tags, {}
  t.end()

test 'create illegal zero-count pile', (t) ->
  try
    a = new ItemPile('dirt', 0)
  catch error
    caughtError = error
  console.log caughtError
  t.equal(caughtError != undefined, true)
  t.end()

test 'create illegal undefined item', (t) ->
  try
    a = new ItemPile(undefined, 0)
  catch error
    caughtError = error
  console.log caughtError
  t.equal(caughtError != undefined, true)
  t.end()

test 'immutable count', (t) ->
  'use strict'    # to throw exception on setting read-only property

  a = new ItemPile('dirt', 1)
  t.equal(a.count, 1)

  try
    a.count = 2
  catch error
    caughtError = error
  console.log caughtError
  t.equal(caughtError != undefined, true)
  t.equal(a.count, 1)

  t.end()

test 'immutable item', (t) ->
  'use strict'

  a = new ItemPile('sand', 1)

  try
    a.item = 'glass'
  catch error
    caughtError = error
  console.log caughtError
  t.equal(caughtError != undefined, true)
  t.equal(a.item, 'sand')

  t.end()

test 'immutable tags', (t) ->
  'use strict'

  a = new ItemPile('tool', 1, {damage:0})

  try
    a.tags = {damage:1}
  catch error
    caughtError = error
  console.log caughtError
  t.equal(caughtError != undefined, true)
  t.deepEqual(a.tags, {damage:0})

  t.end()

test 'immutable tags deep', (t) ->
  'use strict'

  a = new ItemPile('tool', 1, {modifiers:{lastsLonger:1}})

  try
    a.tags.modifiers.lastsLonger = 2
  catch error
    caughtError = error
  t.equal(caughtError != undefined, true)
  console.log caughtError
  t.deepEqual(a.tags, {modifiers:{lastsLonger:1}})

  t.end()




test 'empty tags', (t) ->
  a = new ItemPile('dirt', 1, {})
  t.deepEqual a.tags, {}
  t.end()

test 'increased', (t) ->
  a = new ItemPile('dirt', 1)
  [a2, excess] = a.increased(10)
  t.equal a2.count, 11
  t.equal excess, 0

  [a3, excess] = a2.increased(100)
  t.equal a3.count, 64
  t.equal excess, 47 
  t.end()

test 'merge simple', (t) ->
  a = new ItemPile('dirt', 10)
  b = new ItemPile('dirt', 20)
  
  [a2, b2] = a.mergedPile(b)

  t.equal(a2.item, a.item)
  t.equal(a2.count, 30)
  t.equal(b2 == undefined, true)  # empty pile
  t.end()


test 'merge big', (t) ->
  a = new ItemPile('dirt', 1)
  b = new ItemPile('dirt', 80)

  [a2, b2] = a.mergedPile(b)

  t.equal(a2.item, b2.item)
  t.equal(a2.count + b2.count, 80 + 1)
  t.equal(a2.count, 64)
  t.equal(b2.count, 17)

  t.end()

test 'split', (t) ->
  a = new ItemPile('dirt', 64)
  [a2, b] = a.splitPile(16)

  t.equal(a2.count, 48)
  t.equal(b.count, 16)
  t.equal(a2.item, b.item)
  t.equal(a2.tags, b.tags)
  t.end()

test 'split all', (t) ->
  a = new ItemPile('dirt', 10)
  [a2, b] = a.splitPile(10)

  t.equal(a2 == undefined, true)
  t.equal(b.item, a.item)
  t.equal(b.count, 10)
  t.equal(b.count, a.count)

  t.end()

test 'split bad', (t) ->
  a = new ItemPile('dirt', 10)
  [a2, b] = a.splitPile(1000)
  
  t.equal(b == undefined, true)
  t.equal(a2.count, a.count)  # unchanged
  t.end()

test 'split neg', (t) ->
  a = new ItemPile('dirt', 10)
  [a2, b] = a.splitPile(-1)

  t.equal(a2.count, 1)
  t.equal(b.count, 9)

  t.end()

test 'split fract half', (t) ->
  a = new ItemPile('gold', 10)
  [a2, b] = a.splitPile(0.5)

  t.equal(a2.count, 5)
  t.equal(b.count, 5)
  t.end()

test 'split fract uneven', (t) ->
  a = new ItemPile('gold', 11)
  [a2, b] = a.splitPile(0.5)

  t.equal(a2.count, 5)
  t.equal(b.count, 6)
  t.end()

test 'matches', (t) ->
  a = new ItemPile('dirt', 3)
  b = new ItemPile('dirt', 4)
  
  t.equal(a.matchesType(b), true)
  t.equal(a.matchesTypeAndCount(b), false)
  t.equal(a.matchesAll(b), false)

  c = new ItemPile('dirt', 4)
  t.equal(b.matchesType(c), true)
  t.equal(b.matchesTypeAndCount(c), true)
  t.equal(b.matchesAll(c), true)

  t.equal(c.matchesType(b), true)
  t.equal(c.matchesTypeAndCount(b), true)
  t.equal(c.matchesAll(b), true)

  d = new ItemPile('magic', 1, {foo:-7})
  e = new ItemPile('magic', 1, {foo:54})
  f = new ItemPile('magic', 1, {foo:-7})
  g = new ItemPile('magic', 2, {foo:-7})
  t.equal(d.matchesType(d), true)
  t.equal(d.matchesTypeAndCount(e), true)
  t.equal(d.matchesAll(e), false)
  t.equal(d.matchesAll(f), true)
  t.equal(g.matchesTypeAndTags(d), true)

  t.end()

test 'toString', (t) ->
  a = new ItemPile('dirt', 42)
  console.log a.toString()
  t.equal(a+'', '42:dirt')

  b = new ItemPile('magic', 1, {foo:-7})
  console.log b.toString()
  t.equal(b+'', '1:magic {"foo":-7}')
  t.end()

test 'fromString', (t) ->
  a = ItemPile.fromString('24:dirt')
  console.log(a)
  t.equal(a.count, 24)
  t.equal(a.item, 'dirt')
  t.equal(a.hasTags(), false)
  t.end()

test 'fromString/toString roundtrip', (t) ->
  strings = [
    '24:dirt'
    '48:dirt'
    '1000:dirt'
    '1:foo {"tag":1}'
    '2:hmm {"foo":[],"bar":2}'
    ]
  for s in strings
    b = ItemPile.fromString(s)
    outStr = b+''
    t.equal(s, outStr)
    console.log("=",s, outStr)
  t.end()

test 'itemFromString', (t) ->
  a = ItemPile.itemFromString('foo')
  t.equals(a, 'foo')

  b = ItemPile.itemFromString(undefined)
  t.equal(b == undefined, true)

  c = ItemPile.itemToString('bar')
  t.equals(c, 'bar')

  d = ItemPile.itemToString(ItemPile.itemFromString(null))
  t.equals(d, 'undefined')
  t.end()

test 'infinite', (t) ->
  a = new ItemPile('magic', Infinity)
  [a2, removedCount] = a.decreased(1)
  t.equal(a2.count, Infinity)
  [a3, removedCount] = a.decreased(1000000)
  t.equal(a3.count, Infinity)
  [a4, excessCount] = a.increased(1000000000)
  t.equal(a4.count, Infinity)
  t.end()

