# itempile

A data structure for groups of identical objects, up to a maximum number. 
Useful for games. (This module was previously known as "itemstack".)

[![Build Status](https://travis-ci.org/deathcap/itempile.png)](https://travis-ci.org/deathcap/itempile)

Can be used standalone but most useful with [inventory](https://github.com/deathcap/inventory).

Requires a ES6-compatible environment (at least partially), tested on Node v4.2.4

## Creating

An item pile can be created simply with an item name and count, for example:

    var ItemPile = require('itempile');

    var x = new ItemPile('dirt', 10);

represents a quantity of 10 dirt. The item type can be an any comparable object
(singleton); these examples use strings. The quantity can be omitted to use a default of "1".

## Merging 

Piles of the same type can be merged:

    var a = new ItemPile('dirt', 10);
    var b = new ItemPile('dirt', 20);

    a.mergePile(b);

results in `a` increasing to 30 and `b` to 0. `mergePile` returns `false` if the piles differ
in type and cannot be merged, otherwise the number of items that did not fit (excess above
the maximum pile size):

    var a = new ItemPile('dirt', 1);
    var b = new ItemPile('dirt', 80);

    a.mergePile(b);

increases the count of `a` to 64, the default `ItemPile.maxStackSize` limit, and decreases `b` to 17.
The sum of the two pile counts remains invariant, the quantity has just shifted between the two. 

## Splitting

Want to take items from a pile? Split the pile, specifying the number of items you want:

    var a = new ItemPile('dirt', 64)
    var b = a.splitPile(16)

`b` is a new pile with 16 dirt, `a` is lowered to the remaining 48 dirt. For convenience you can alternatively pass a
decimal fraction (such as 0.5, splits the pile in half), or a negative integer (-1 to take all but one).

## Other operations

Merging/splitting are the most important but several other methods are provided,
see the unit tests for further examples.

## Advanced piles

You can create piles of infinite size:

    new ItemPile('diamond', Infinity)

and they behave as you expect, sinking unlimited items when merging and sourcing unlimited items when splitting.

Extra data can be attached to a pile, using the "tags" parameter:

    new ItemPile('pick', 1, {damage:0})


## License

MIT

