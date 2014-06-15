# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

test = require 'tape'
ItemPile = require './'

test 'create default', (t) ->
  a = new ItemPile('dirt')
  t.equal a.item, 'dirt'
  t.equal a.count, 1
  t.deepEqual a.tags, {}
  t.end()

test 'empty tags default', (t) ->
  a = new ItemPile('dirt', 1)
  t.deepEqual a.tags, {}
  t.end()

test 'clone', (t) ->
  a = new ItemPile('tool', 1, {damage:0})
  t.equal a.item, 'tool'
  t.equal a.count, 1
  t.deepEqual a.tags, {damage:0}

  b = a.clone()
  t.equal a.item, 'tool'
  t.equal a.count, 1
  t.deepEqual a.tags, {damage:0}

  b.tags.damage += 1

  t.deepEqual b.tags, {damage:1}
  t.deepEqual a.tags, {damage:0}

  t.end()

test 'increase', (t) ->
  a = new ItemPile('dirt', 1)
  excess = a.increase(10)
  t.equal a.count, 11
  t.equal excess, 0

  excess = a.increase(100)
  t.equal a.count, 64
  t.equal excess, 47
  t.end()

test 'increase infinity', (t) ->
  a = new ItemPile('money', 1)
  excess = a.increase(Infinity)
  t.equal a.count, Infinity
  t.end()

test 'merge simple', (t) ->
  a = new ItemPile('dirt', 10)
  b = new ItemPile('dirt', 20)

  excess = a.mergePile(b)

  t.equal(a.item, b.item)
  t.equal(a.count + b.count, 10 + 20)
  t.equal(excess, 0)
  t.equal(a.count, 30)
  t.equal(b.count, 0)
  t.end()


test 'merge big', (t) ->
  a = new ItemPile('dirt', 1)
  b = new ItemPile('dirt', 80)

  excess = a.mergePile(b)

  t.equal(a.item, b.item)
  t.equal(a.count + b.count, 80 + 1)
  t.equal(excess, b.count)
  t.equal(a.count, 64)
  t.equal(b.count, 17)

  t.end()

test 'merge 0-size', (t) ->
  a = new ItemPile('pick', 0)
  b = new ItemPile('pick', 1, {damage:0})

  excess = a.mergePile(b)

  t.equal(excess, 0)
  t.equal(a.count, 1)
  t.end()

test 'split', (t) ->
  a = new ItemPile('dirt', 64)
  b = a.splitPile(16)

  t.equal(a.count, 48)
  t.equal(b.count, 16)
  t.equal(a.item, b.item)
  t.deepEqual(a.tags, b.tags)  # (not equal() since is cloned, different object)
  t.end()

test 'split clone', (t) ->
  a = new ItemPile('tool', 3, {damage:0})
  t.equal a.item, 'tool'
  t.equal a.count, 3
  t.deepEqual a.tags, {damage:0}

  b = a.splitPile(1)
  t.equal b.item, 'tool'
  t.equal b.count, 1
  t.equal a.count, 2
  t.deepEqual a.tags, {damage:0}
  t.deepEqual b.tags, {damage:0}

  b.tags.damage += 1

  t.deepEqual b.tags, {damage:1}
  t.deepEqual a.tags, {damage:0}

  t.end()


test 'split bad', (t) ->
  a = new ItemPile('dirt', 10)
  b = a.splitPile(1000)

  t.equal(b, false)
  t.equal(a.count, 10)  # unchanged
  t.end()

test 'split neg', (t) ->
  a = new ItemPile('dirt', 10)
  b = a.splitPile(-1)

  t.equal(a.count, 1)
  t.equal(b.count, 9)

  t.end()

test 'split fract half', (t) ->
  a = new ItemPile('gold', 10)
  b = a.splitPile(0.5)

  t.equal(a.count, 5)
  t.equal(b.count, 5)
  t.end()

test 'split fract uneven', (t) ->
  a = new ItemPile('gold', 11)
  b = a.splitPile(0.5)

  t.equal(a.count, 5)
  t.equal(b.count, 6)
  t.end()

test 'split zero', (t) ->
  a = new ItemPile('diamond', 20)

  b = a.splitPile(0)
  t.equal(b, false)
  t.end()

test 'split infinitive', (t) ->
  a = new ItemPile('diamond', Infinity)

  b = a.splitPile(1)
  t.equal(b.count, 1)
  t.equal(a.count, Infinity)

  c = a.splitPile(10)
  t.equal(c.count, 10)
  t.equal(a.count, Infinity)

  d = a.splitPile(-7)   # all but N of Infinity is still Infinity..
  t.equal(d.count, Infinity)
  t.equal(a.count, Infinity)

  e = a.splitPile(0.5)
  t.equal(e.count, Infinity)
  t.equal(a.count, Infinity)

  f = a.splitPile(0)  # not 0 * Infinity -> NaN
  t.equal(f, false)

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

test 'fromArray', (t) ->
  a = ItemPile.fromArray(['dirt', 42])
  t.equal(a.count, 42)
  t.equal(a.item, 'dirt')
  t.equal(a.hasTags(), false)

  b = ItemPile.fromArray(['dirt'])
  t.equal(b.count, 1)
  t.equal(b.item, 'dirt')
  t.equal(b.hasTags(), false)

  c = ItemPile.fromArray(['pick', 1, {damage:0}])
  t.equal(c.count, 1)
  t.equal(c.item, 'pick')
  t.equal(c.hasTags(), true)
  t.deepEqual(c.tags, {damage:0})

  t.end()

test 'fromArrayIfArray', (t) ->
  a = new ItemPile('dirt', 42)
  b = ItemPile.fromArrayIfArray(a)
  t.equal(a.matchesAll(b), true)
  t.equal(b.matchesAll(a), true)
  t.equal(a.count, 42)
  t.equal(b.count, 42)
  t.equal(a.item, 'dirt')
  t.equal(b.item, 'dirt')
  t.equal(a, b)
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
    '0:dirt'
    '1:foo {"tag":1}'
    '2:hmm {"foo":[],"bar":2}'
    'Infinity:gold'
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
  t.equal(b, '')

  c = ItemPile.itemToString('bar')
  t.equals(c, 'bar')

  d = ItemPile.itemToString(ItemPile.itemFromString(null))
  t.equals(d, '')
  t.end()

test 'infinite', (t) ->
  a = new ItemPile('magic', Infinity)
  a.decrease(1)
  t.equal(a.count, Infinity)
  a.decrease(1000000)
  t.equal(a.count, Infinity)
  a.increase(1000000000)
  t.equal(a.count, Infinity)
  t.end()

test 'clone', (t) ->
  a = new ItemPile('junk', 10)
  b = a.clone()

  b.decrease(1)
  t.equal(b.count, 9)
  t.equal(a.count, 10)

  t.end()
