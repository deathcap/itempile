'use strict';
const deepEqual = require('deep-equal');
const cloneObject = require('clone');

class ItemPile {
  constructor(item, count, tags) {
    this.item = (typeof(item) === 'string' ? ItemPile.itemFromString(item) : item);
    this.count = count !== undefined ? count : 1;
    this.tags = tags !== undefined ? tags : {};
  }

  clone() {
    return new ItemPile(this.item, this.count, cloneObject(this.tags, false));
  }

  // maximum size items should pile
  static get maxPileSize() {
    return 64;
  }

  // convert item<->string; change these to use non-string items
  static itemFromString(s) {
    if (s instanceof ItemPile) return s;
    return (!s ? '' : s);
  }

  static itemToString(item) {
    return ''+item;
  }

  hasTags() {
    return Object.keys(this.tags).length !== 0;    // not "{}"
  }

  matchesType(itemPile) {
    return this.item === itemPile.item;
  }

  matchesTypeAndCount(itemPile) {
    return this.item === itemPile.item && this.count === itemPile.count;
  }

  matchesTypeAndTags(itemPile) {
    return this.item === itemPile.item && deepEqual(this.tags, itemPile.tags, {strict:true});
  }

  matchesAll(itemPile) {
    return this.matchesTypeAndCount(itemPile) && deepEqual(this.tags, itemPile.tags, {strict:true});
  }

  // can this pile be merged with another?
  canPileWith(itemPile) {
    if (itemPile.item !== this.item) return false;
    if (itemPile.count === 0 || this.count === 0) return true; // (special case: can always merge with 0-size pile of same item, regardless of tags - for placeholder slots)
    if (itemPile.hasTags() || this.hasTags()) return false; // any tag data makes unpileable
    return true;
  }

  // combine two piles if possible, altering both this and argument pile
  // returns count of items that didn't fit
  mergePile(itemPile) {
    if (!this.canPileWith(itemPile)) return false;
    itemPile.count = this.increase(itemPile.count);
    return itemPile.count;
  }

  // increase count by argument, returning number of items that didn't fit
  increase(n) {
    const a = this.tryAdding(n);
    const newCount = a[0];
    const excessCount = a[1];
    this.count = newCount;
    return excessCount;
  }

  // decrease count by argument, returning number of items removed
  decrease(n) {
    const a = this.trySubtracting(n);
    const removedCount = a[0];
    const remainingCount= a[1];
    this.count = remainingCount;
    return removedCount;
  }

  // try combining count of items up to max pile size, returns [newCount, excessCount]
  tryAdding(n) {
    // special case: infinite incoming count sets pile to infinite, even though >maxPileSize
    // TODO: option to disable infinite piles? might want to add only up to 64 etc. (ref GH-2)
    if (n === Infinity) return [Infinity, 0];

    const sum = this.count + n;
    if (sum > ItemPile.maxPileSize && this.count !== Infinity) { // (special case: infinite destination piles never overflow)
      return [ItemPile.maxPileSize, sum - ItemPile.maxPileSize]; // overflowing pile
    } else {
      return [sum, 0]; // added everything they wanted
    }
  }

  // try removing a finite count of items, returns [removedCount, remainingCount]
  trySubtracting(n) {
    const difference = this.count - n;
    if (difference < 0) {
      return [this.count, n - this.count]; // didn't have enough
    } else {
      return [n, this.count - n];  // had enough, some remain
    }
  }

  // remove count of argument items, returning new pile of those items which were split off
  splitPile(n) {
    if (n === 0) return false;
    if (n < 0) {
      // negative count = all but n
      n = this.count + n;
    } else if (n < 1) {
      // fraction = fraction
      n = Math.ceil(this.count * n);
    }

    if (n > this.count) return false;
    if (n !== Infinity) this.count -= n; // (subtract, but avoid Infinity - Infinity = NaN)

    return new ItemPile(this.item, n, cloneObject(this.tags, false));
  }

  toString() {
    if (this.hasTags()) {
      return `${this.count}:${this.item} ${JSON.stringify(this.tags)}`;
    } else {
      return `${this.count}:${this.item}`;
    }
  }

  static fromString(s) {
    const a = s.match(/^([^:]+):([^ ]+) ?(.*)/); // assumptions: positive integral count, item name no spaces
    if (!a) return undefined;
    const countStr = a[1];
    const itemStr = a[2];
    const tagsStr = a[3];
    let count;
    if (countStr === 'Infinity') {
      count = Infinity;
    } else {
      count = parseInt(countStr, 10);
    }
    const item = ItemPile.itemFromString(itemStr);
    let tags;
    if (tagsStr && tagsStr.length) {
      tags = JSON.parse(tagsStr);
    } else {
      tags = {};
    }

    return new ItemPile(item, count, tags);
  }

  static fromArray(a) {
    const item = a[0];
    const count = a[1];
    const tags = a[2];
    return new ItemPile(item, count, tags);
  }

  static fromArrayIfArray(a) {
    if (Array.isArray(a)) {
      return ItemPile.fromArray(a);
    } else {
      return a;
    }
  }
}

module.exports = ItemPile;

