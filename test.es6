'use strict';
const test = require('tape');
const ItemPile = require('./');

test('create default', t => {
  const a = new ItemPile('dirt');
  t.equal(a.item, 'dirt');
  t.equal(a.count, 1);
  t.deepEqual(a.tags, {});
  t.end();
});

test('empty tags default', t => {
  const a = new ItemPile('dirt', 1);
  t.deepEqual(a.tags, {});
  t.end();
});

test('clone', t => {
  const a = new ItemPile('tool', 1, {damage:0});
  t.equal(a.item, 'tool');
  t.equal(a.count, 1);
  t.deepEqual(a.tags, {damage:0});

  const b = a.clone();
  t.equal(a.item, 'tool');
  t.equal(a.count, 1);
  t.deepEqual(a.tags, {damage:0});

  b.tags.damage += 1;

  t.deepEqual(b.tags, {damage:1});
  t.deepEqual(a.tags, {damage:0});

  t.end();
});

test('increase', t => {
  const a = new ItemPile('dirt', 1);
  const excess = a.increase(10);
  t.equal(a.count, 11);
  t.equal(excess, 0);

  const excess2 = a.increase(100);
  t.equal(a.count, 64);
  t.equal(excess2, 47);
  t.end();
});

test('increase infinity', t => {
  const a = new ItemPile('money', 1);
  const excess = a.increase(Infinity);
  t.equal(a.count, Infinity);
  t.end();
});

test('merge simple', t => {
  const a = new ItemPile('dirt', 10);
  const b = new ItemPile('dirt', 20);

  const excess = a.mergePile(b);

  t.equal(a.item, b.item);
  t.equal(a.count + b.count, 10 + 20);
  t.equal(excess, 0);
  t.equal(a.count, 30);
  t.equal(b.count, 0);
  t.end();
});

test('merge big', t => {
  const a = new ItemPile('dirt', 1);
  const b = new ItemPile('dirt', 80);

  const excess = a.mergePile(b);

  t.equal(a.item, b.item);
  t.equal(a.count + b.count, 80 + 1);
  t.equal(excess, b.count);
  t.equal(a.count, 64);
  t.equal(b.count, 17);

  t.end();
});

test('merge 0-size', t => {
  const a = new ItemPile('pick', 0);
  const b = new ItemPile('pick', 1, {damage:0});

  const excess = a.mergePile(b);

  t.equal(excess, 0);
  t.equal(a.count, 1);
  t.end();
});

test('split', t => {
  const a = new ItemPile('dirt', 64);
  const b = a.splitPile(16);

  t.equal(a.count, 48);
  t.equal(b.count, 16);
  t.equal(a.item, b.item);
  t.deepEqual(a.tags, b.tags);   // (not equal() since is cloned, different object)
  t.end();
});

test('split clone', t => {
  const a = new ItemPile('tool', 3, {damage:0});
  t.equal(a.item, 'tool');
  t.equal(a.count, 3);
  t.deepEqual(a.tags, {damage:0});

  const b = a.splitPile(1);
  t.equal(b.item, 'tool');
  t.equal(b.count, 1);
  t.equal(a.count, 2);
  t.deepEqual(a.tags, {damage:0});
  t.deepEqual(b.tags, {damage:0});

  b.tags.damage += 1;

  t.deepEqual(b.tags, {damage:1});
  t.deepEqual(a.tags, {damage:0});

  t.end();
});


test('split bad', t => {
  const a = new ItemPile('dirt', 10);
  const b = a.splitPile(1000);

  t.equal(b, false);
  t.equal(a.count, 10);  // unchanged
  t.end();
});

test('split neg', t => {
  const a = new ItemPile('dirt', 10);
  const b = a.splitPile(-1);

  t.equal(a.count, 1);
  t.equal(b.count, 9);

  t.end();
});

test('split fract half', t => {
  const a = new ItemPile('gold', 10);
  const b = a.splitPile(0.5);

  t.equal(a.count, 5);
  t.equal(b.count, 5);
  t.end();
});

test('split fract uneven', t => {
  const a = new ItemPile('gold', 11);
  const b = a.splitPile(0.5);

  t.equal(a.count, 5);
  t.equal(b.count, 6);
  t.end();
});

test('split zero', t => {
  const a = new ItemPile('diamond', 20);

  const b = a.splitPile(0);
  t.equal(b, false);
  t.end();
});

test('split infinitive', t => {
  const a = new ItemPile('diamond', Infinity);

  const b = a.splitPile(1);
  t.equal(b.count, 1);
  t.equal(a.count, Infinity);

  const c = a.splitPile(10);
  t.equal(c.count, 10);
  t.equal(a.count, Infinity);

  const d = a.splitPile(-7);   // all but N of Infinity is still Infinity..
  t.equal(d.count, Infinity);
  t.equal(a.count, Infinity);

  const e = a.splitPile(0.5);
  t.equal(e.count, Infinity);
  t.equal(a.count, Infinity);

  const f = a.splitPile(0);  // not 0 * Infinity -> NaN
  t.equal(f, false);

  t.end();
});

test('matches', t => {
  const a = new ItemPile('dirt', 3);
  const b = new ItemPile('dirt', 4);

  t.equal(a.matchesType(b), true);
  t.equal(a.matchesTypeAndCount(b), false);
  t.equal(a.matchesAll(b), false);

  const c = new ItemPile('dirt', 4);
  t.equal(b.matchesType(c), true);
  t.equal(b.matchesTypeAndCount(c), true);
  t.equal(b.matchesAll(c), true);

  t.equal(c.matchesType(b), true);
  t.equal(c.matchesTypeAndCount(b), true);
  t.equal(c.matchesAll(b), true);

  const d = new ItemPile('magic', 1, {foo:-7});
  const e = new ItemPile('magic', 1, {foo:54});
  const f = new ItemPile('magic', 1, {foo:-7});
  const g = new ItemPile('magic', 2, {foo:-7});
  t.equal(d.matchesType(d), true);
  t.equal(d.matchesTypeAndCount(e), true);
  t.equal(d.matchesAll(e), false);
  t.equal(d.matchesAll(f), true);
  t.equal(g.matchesTypeAndTags(d), true);

  t.end();
});

test('toString', t => {
  const a = new ItemPile('dirt', 42);
  console.log(a.toString());
  t.equal(a+'', '42:dirt');

  const b = new ItemPile('magic', 1, {foo:-7});
  console.log(b.toString());
  t.equal(b+'', '1:magic {"foo":-7}');
  t.end();
});

test('fromArray', t => {
  const a = ItemPile.fromArray(['dirt', 42]);
  t.equal(a.count, 42);
  t.equal(a.item, 'dirt');
  t.equal(a.hasTags(), false);

  const b = ItemPile.fromArray(['dirt']);
  t.equal(b.count, 1);
  t.equal(b.item, 'dirt');
  t.equal(b.hasTags(), false);

  const c = ItemPile.fromArray(['pick', 1, {damage:0}]);
  t.equal(c.count, 1);
  t.equal(c.item, 'pick');
  t.equal(c.hasTags(), true);
  t.deepEqual(c.tags, {damage:0});

  t.end();
});

test('fromArrayIfArray', t => {
  const a = new ItemPile('dirt', 42);
  const b = ItemPile.fromArrayIfArray(a);
  t.equal(a.matchesAll(b), true);
  t.equal(b.matchesAll(a), true);
  t.equal(a.count, 42);
  t.equal(b.count, 42);
  t.equal(a.item, 'dirt');
  t.equal(b.item, 'dirt');
  t.equal(a, b);
  t.end();
});

test('fromString', t => {
  const a = ItemPile.fromString('24:dirt');
  console.log(a);
  t.equal(a.count, 24);
  t.equal(a.item, 'dirt');
  t.equal(a.hasTags(), false);
  t.end();
});

test('fromString/toString roundtrip', t => {
  const strings = [
    '24:dirt',
    '48:dirt',
    '1000:dirt',
    '0:dirt',
    '1:foo {"tag":1}',
    '2:hmm {"foo":[],"bar":2}',
    'Infinity:gold',
    ];

  for (let i = 0; i < strings.length; i += 1) {
    const s = strings[i];
    const b = ItemPile.fromString(s);
    const outStr = b+'';
    t.equal(s, outStr);
    console.log("=",s, outStr);
  }
  t.end();
});

test('itemFromString', t => {
  const a = ItemPile.itemFromString('foo');
  t.equals(a, 'foo');

  const b = ItemPile.itemFromString(undefined);
  t.equal(b, '');

  const c = ItemPile.itemToString('bar');
  t.equals(c, 'bar');

  const d = ItemPile.itemToString(ItemPile.itemFromString(null));
  t.equals(d, '');
  t.end();
});

test('infinite', t => {
  const a = new ItemPile('magic', Infinity);
  a.decrease(1);
  t.equal(a.count, Infinity);
  a.decrease(1000000);
  t.equal(a.count, Infinity);
  a.increase(1000000000);
  t.equal(a.count, Infinity);
  t.end();
});

test('clone', t => {
  const a = new ItemPile('junk', 10);
  const b = a.clone();

  b.decrease(1);
  t.equal(b.count, 9);
  t.equal(a.count, 10);

  t.end();
});
