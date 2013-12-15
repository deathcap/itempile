// Generated by CoffeeScript 1.6.3
(function() {
  var ItemPile, test;

  test = require('tape');

  ItemPile = require('./');

  test('create default', function(t) {
    var a;
    a = new ItemPile('dirt');
    t.equal(a.item, 'dirt');
    t.equal(a.count, 1);
    t.deepEqual(a.tags, {});
    return t.end();
  });

  test('empty tags', function(t) {
    var a;
    a = new ItemPile('dirt', 1, {});
    t.deepEqual(a.tags, {});
    return t.end();
  });

  test('increase', function(t) {
    var a, excess;
    a = new ItemPile('dirt', 1);
    excess = a.increase(10);
    t.equal(a.count, 11);
    t.equal(excess, 0);
    excess = a.increase(100);
    t.equal(a.count, 64);
    t.equal(excess, 47);
    return t.end();
  });

  test('merge', function(t) {
    var a, b, excess;
    a = new ItemPile('dirt', 1);
    b = new ItemPile('dirt', 80);
    excess = a.mergePile(b);
    t.equal(a.item, b.item);
    t.equal(a.count + b.count, 80 + 1);
    t.equal(excess, b.count);
    t.equal(a.count, 64);
    t.equal(b.count, 17);
    return t.end();
  });

  test('split', function(t) {
    var a, b;
    a = new ItemPile('dirt', 64);
    b = a.splitPile(32);
    t.equal(a.count, 32);
    t.equal(b.count, 32);
    t.equal(a.item, b.item);
    t.equal(a.tags, b.tags);
    return t.end();
  });

  test('split bad', function(t) {
    var a, b;
    a = new ItemPile('dirt', 10);
    b = a.splitPile(1000);
    t.equal(b, false);
    t.equal(a.count, 10);
    return t.end();
  });

  test('matches', function(t) {
    var a, b, c, d, e, f, g;
    a = new ItemPile('dirt', 3);
    b = new ItemPile('dirt', 4);
    t.equal(a.matchesType(b), true);
    t.equal(a.matchesTypeAndCount(b), false);
    t.equal(a.matchesAll(b), false);
    c = new ItemPile('dirt', 4);
    t.equal(b.matchesType(c), true);
    t.equal(b.matchesTypeAndCount(c), true);
    t.equal(b.matchesAll(c), true);
    t.equal(c.matchesType(b), true);
    t.equal(c.matchesTypeAndCount(b), true);
    t.equal(c.matchesAll(b), true);
    d = new ItemPile('magic', 1, {
      foo: -7
    });
    e = new ItemPile('magic', 1, {
      foo: 54
    });
    f = new ItemPile('magic', 1, {
      foo: -7
    });
    g = new ItemPile('magic', 2, {
      foo: -7
    });
    t.equal(d.matchesType(d), true);
    t.equal(d.matchesTypeAndCount(e), true);
    t.equal(d.matchesAll(e), false);
    t.equal(d.matchesAll(f), true);
    t.equal(g.matchesTypeAndTags(d), true);
    return t.end();
  });

  test('toString', function(t) {
    var a, b;
    a = new ItemPile('dirt', 42);
    console.log(a.toString());
    t.equal(a + '', '42:dirt');
    b = new ItemPile('magic', 1, {
      foo: -7
    });
    console.log(b.toString());
    t.equal(b + '', '1:magic {"foo":-7}');
    return t.end();
  });

  test('fromString', function(t) {
    var a;
    a = ItemPile.fromString('24:dirt');
    console.log(a);
    t.equal(a.count, 24);
    t.equal(a.item, 'dirt');
    t.equal(a.hasTags(), false);
    return t.end();
  });

  test('fromString/toString roundtrip', function(t) {
    var b, outStr, s, strings, _i, _len;
    strings = ['24:dirt', '48:dirt', '1000:dirt', '0:dirt', '1:foo {"tag":1}', '2:hmm {"foo":[],"bar":2}'];
    for (_i = 0, _len = strings.length; _i < _len; _i++) {
      s = strings[_i];
      b = ItemPile.fromString(s);
      outStr = b + '';
      t.equal(s, outStr);
      console.log("=", s, outStr);
    }
    return t.end();
  });

  test('itemFromString', function(t) {
    var a, b, c, d;
    a = ItemPile.itemFromString('foo');
    t.equals(a, 'foo');
    b = ItemPile.itemFromString(void 0);
    t.equal(b, '');
    c = ItemPile.itemToString('bar');
    t.equals(c, 'bar');
    d = ItemPile.itemToString(ItemPile.itemFromString(null));
    t.equals(d, '');
    return t.end();
  });

  test('infinite', function(t) {
    var a;
    a = new ItemPile('magic', Infinity);
    a.decrease(1);
    t.equal(a.count, Infinity);
    a.decrease(1000000);
    t.equal(a.count, Infinity);
    a.increase(1000000000);
    t.equal(a.count, Infinity);
    return t.end();
  });

}).call(this);
