
(function() {
'use strict';

function F2(fun)
{
  function wrapper(a) { return function(b) { return fun(a,b); }; }
  wrapper.arity = 2;
  wrapper.func = fun;
  return wrapper;
}

function F3(fun)
{
  function wrapper(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  }
  wrapper.arity = 3;
  wrapper.func = fun;
  return wrapper;
}

function F4(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  }
  wrapper.arity = 4;
  wrapper.func = fun;
  return wrapper;
}

function F5(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  }
  wrapper.arity = 5;
  wrapper.func = fun;
  return wrapper;
}

function F6(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  }
  wrapper.arity = 6;
  wrapper.func = fun;
  return wrapper;
}

function F7(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  }
  wrapper.arity = 7;
  wrapper.func = fun;
  return wrapper;
}

function F8(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  }
  wrapper.arity = 8;
  wrapper.func = fun;
  return wrapper;
}

function F9(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  }
  wrapper.arity = 9;
  wrapper.func = fun;
  return wrapper;
}

function A2(fun, a, b)
{
  return fun.arity === 2
    ? fun.func(a, b)
    : fun(a)(b);
}
function A3(fun, a, b, c)
{
  return fun.arity === 3
    ? fun.func(a, b, c)
    : fun(a)(b)(c);
}
function A4(fun, a, b, c, d)
{
  return fun.arity === 4
    ? fun.func(a, b, c, d)
    : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e)
{
  return fun.arity === 5
    ? fun.func(a, b, c, d, e)
    : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f)
{
  return fun.arity === 6
    ? fun.func(a, b, c, d, e, f)
    : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g)
{
  return fun.arity === 7
    ? fun.func(a, b, c, d, e, f, g)
    : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h)
{
  return fun.arity === 8
    ? fun.func(a, b, c, d, e, f, g, h)
    : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i)
{
  return fun.arity === 9
    ? fun.func(a, b, c, d, e, f, g, h, i)
    : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

//import Native.List //

var _elm_lang$core$Native_Array = function() {

// A RRB-Tree has two distinct data types.
// Leaf -> "height"  is always 0
//         "table"   is an array of elements
// Node -> "height"  is always greater than 0
//         "table"   is an array of child nodes
//         "lengths" is an array of accumulated lengths of the child nodes

// M is the maximal table size. 32 seems fast. E is the allowed increase
// of search steps when concatting to find an index. Lower values will
// decrease balancing, but will increase search steps.
var M = 32;
var E = 2;

// An empty array.
var empty = {
	ctor: '_Array',
	height: 0,
	table: []
};


function get(i, array)
{
	if (i < 0 || i >= length(array))
	{
		throw new Error(
			'Index ' + i + ' is out of range. Check the length of ' +
			'your array first or use getMaybe or getWithDefault.');
	}
	return unsafeGet(i, array);
}


function unsafeGet(i, array)
{
	for (var x = array.height; x > 0; x--)
	{
		var slot = i >> (x * 5);
		while (array.lengths[slot] <= i)
		{
			slot++;
		}
		if (slot > 0)
		{
			i -= array.lengths[slot - 1];
		}
		array = array.table[slot];
	}
	return array.table[i];
}


// Sets the value at the index i. Only the nodes leading to i will get
// copied and updated.
function set(i, item, array)
{
	if (i < 0 || length(array) <= i)
	{
		return array;
	}
	return unsafeSet(i, item, array);
}


function unsafeSet(i, item, array)
{
	array = nodeCopy(array);

	if (array.height === 0)
	{
		array.table[i] = item;
	}
	else
	{
		var slot = getSlot(i, array);
		if (slot > 0)
		{
			i -= array.lengths[slot - 1];
		}
		array.table[slot] = unsafeSet(i, item, array.table[slot]);
	}
	return array;
}


function initialize(len, f)
{
	if (len <= 0)
	{
		return empty;
	}
	var h = Math.floor( Math.log(len) / Math.log(M) );
	return initialize_(f, h, 0, len);
}

function initialize_(f, h, from, to)
{
	if (h === 0)
	{
		var table = new Array((to - from) % (M + 1));
		for (var i = 0; i < table.length; i++)
		{
		  table[i] = f(from + i);
		}
		return {
			ctor: '_Array',
			height: 0,
			table: table
		};
	}

	var step = Math.pow(M, h);
	var table = new Array(Math.ceil((to - from) / step));
	var lengths = new Array(table.length);
	for (var i = 0; i < table.length; i++)
	{
		table[i] = initialize_(f, h - 1, from + (i * step), Math.min(from + ((i + 1) * step), to));
		lengths[i] = length(table[i]) + (i > 0 ? lengths[i-1] : 0);
	}
	return {
		ctor: '_Array',
		height: h,
		table: table,
		lengths: lengths
	};
}

function fromList(list)
{
	if (list.ctor === '[]')
	{
		return empty;
	}

	// Allocate M sized blocks (table) and write list elements to it.
	var table = new Array(M);
	var nodes = [];
	var i = 0;

	while (list.ctor !== '[]')
	{
		table[i] = list._0;
		list = list._1;
		i++;

		// table is full, so we can push a leaf containing it into the
		// next node.
		if (i === M)
		{
			var leaf = {
				ctor: '_Array',
				height: 0,
				table: table
			};
			fromListPush(leaf, nodes);
			table = new Array(M);
			i = 0;
		}
	}

	// Maybe there is something left on the table.
	if (i > 0)
	{
		var leaf = {
			ctor: '_Array',
			height: 0,
			table: table.splice(0, i)
		};
		fromListPush(leaf, nodes);
	}

	// Go through all of the nodes and eventually push them into higher nodes.
	for (var h = 0; h < nodes.length - 1; h++)
	{
		if (nodes[h].table.length > 0)
		{
			fromListPush(nodes[h], nodes);
		}
	}

	var head = nodes[nodes.length - 1];
	if (head.height > 0 && head.table.length === 1)
	{
		return head.table[0];
	}
	else
	{
		return head;
	}
}

// Push a node into a higher node as a child.
function fromListPush(toPush, nodes)
{
	var h = toPush.height;

	// Maybe the node on this height does not exist.
	if (nodes.length === h)
	{
		var node = {
			ctor: '_Array',
			height: h + 1,
			table: [],
			lengths: []
		};
		nodes.push(node);
	}

	nodes[h].table.push(toPush);
	var len = length(toPush);
	if (nodes[h].lengths.length > 0)
	{
		len += nodes[h].lengths[nodes[h].lengths.length - 1];
	}
	nodes[h].lengths.push(len);

	if (nodes[h].table.length === M)
	{
		fromListPush(nodes[h], nodes);
		nodes[h] = {
			ctor: '_Array',
			height: h + 1,
			table: [],
			lengths: []
		};
	}
}

// Pushes an item via push_ to the bottom right of a tree.
function push(item, a)
{
	var pushed = push_(item, a);
	if (pushed !== null)
	{
		return pushed;
	}

	var newTree = create(item, a.height);
	return siblise(a, newTree);
}

// Recursively tries to push an item to the bottom-right most
// tree possible. If there is no space left for the item,
// null will be returned.
function push_(item, a)
{
	// Handle resursion stop at leaf level.
	if (a.height === 0)
	{
		if (a.table.length < M)
		{
			var newA = {
				ctor: '_Array',
				height: 0,
				table: a.table.slice()
			};
			newA.table.push(item);
			return newA;
		}
		else
		{
		  return null;
		}
	}

	// Recursively push
	var pushed = push_(item, botRight(a));

	// There was space in the bottom right tree, so the slot will
	// be updated.
	if (pushed !== null)
	{
		var newA = nodeCopy(a);
		newA.table[newA.table.length - 1] = pushed;
		newA.lengths[newA.lengths.length - 1]++;
		return newA;
	}

	// When there was no space left, check if there is space left
	// for a new slot with a tree which contains only the item
	// at the bottom.
	if (a.table.length < M)
	{
		var newSlot = create(item, a.height - 1);
		var newA = nodeCopy(a);
		newA.table.push(newSlot);
		newA.lengths.push(newA.lengths[newA.lengths.length - 1] + length(newSlot));
		return newA;
	}
	else
	{
		return null;
	}
}

// Converts an array into a list of elements.
function toList(a)
{
	return toList_(_elm_lang$core$Native_List.Nil, a);
}

function toList_(list, a)
{
	for (var i = a.table.length - 1; i >= 0; i--)
	{
		list =
			a.height === 0
				? _elm_lang$core$Native_List.Cons(a.table[i], list)
				: toList_(list, a.table[i]);
	}
	return list;
}

// Maps a function over the elements of an array.
function map(f, a)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: new Array(a.table.length)
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths;
	}
	for (var i = 0; i < a.table.length; i++)
	{
		newA.table[i] =
			a.height === 0
				? f(a.table[i])
				: map(f, a.table[i]);
	}
	return newA;
}

// Maps a function over the elements with their index as first argument.
function indexedMap(f, a)
{
	return indexedMap_(f, a, 0);
}

function indexedMap_(f, a, from)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: new Array(a.table.length)
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths;
	}
	for (var i = 0; i < a.table.length; i++)
	{
		newA.table[i] =
			a.height === 0
				? A2(f, from + i, a.table[i])
				: indexedMap_(f, a.table[i], i == 0 ? from : from + a.lengths[i - 1]);
	}
	return newA;
}

function foldl(f, b, a)
{
	if (a.height === 0)
	{
		for (var i = 0; i < a.table.length; i++)
		{
			b = A2(f, a.table[i], b);
		}
	}
	else
	{
		for (var i = 0; i < a.table.length; i++)
		{
			b = foldl(f, b, a.table[i]);
		}
	}
	return b;
}

function foldr(f, b, a)
{
	if (a.height === 0)
	{
		for (var i = a.table.length; i--; )
		{
			b = A2(f, a.table[i], b);
		}
	}
	else
	{
		for (var i = a.table.length; i--; )
		{
			b = foldr(f, b, a.table[i]);
		}
	}
	return b;
}

// TODO: currently, it slices the right, then the left. This can be
// optimized.
function slice(from, to, a)
{
	if (from < 0)
	{
		from += length(a);
	}
	if (to < 0)
	{
		to += length(a);
	}
	return sliceLeft(from, sliceRight(to, a));
}

function sliceRight(to, a)
{
	if (to === length(a))
	{
		return a;
	}

	// Handle leaf level.
	if (a.height === 0)
	{
		var newA = { ctor:'_Array', height:0 };
		newA.table = a.table.slice(0, to);
		return newA;
	}

	// Slice the right recursively.
	var right = getSlot(to, a);
	var sliced = sliceRight(to - (right > 0 ? a.lengths[right - 1] : 0), a.table[right]);

	// Maybe the a node is not even needed, as sliced contains the whole slice.
	if (right === 0)
	{
		return sliced;
	}

	// Create new node.
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice(0, right),
		lengths: a.lengths.slice(0, right)
	};
	if (sliced.table.length > 0)
	{
		newA.table[right] = sliced;
		newA.lengths[right] = length(sliced) + (right > 0 ? newA.lengths[right - 1] : 0);
	}
	return newA;
}

function sliceLeft(from, a)
{
	if (from === 0)
	{
		return a;
	}

	// Handle leaf level.
	if (a.height === 0)
	{
		var newA = { ctor:'_Array', height:0 };
		newA.table = a.table.slice(from, a.table.length + 1);
		return newA;
	}

	// Slice the left recursively.
	var left = getSlot(from, a);
	var sliced = sliceLeft(from - (left > 0 ? a.lengths[left - 1] : 0), a.table[left]);

	// Maybe the a node is not even needed, as sliced contains the whole slice.
	if (left === a.table.length - 1)
	{
		return sliced;
	}

	// Create new node.
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice(left, a.table.length + 1),
		lengths: new Array(a.table.length - left)
	};
	newA.table[0] = sliced;
	var len = 0;
	for (var i = 0; i < newA.table.length; i++)
	{
		len += length(newA.table[i]);
		newA.lengths[i] = len;
	}

	return newA;
}

// Appends two trees.
function append(a,b)
{
	if (a.table.length === 0)
	{
		return b;
	}
	if (b.table.length === 0)
	{
		return a;
	}

	var c = append_(a, b);

	// Check if both nodes can be crunshed together.
	if (c[0].table.length + c[1].table.length <= M)
	{
		if (c[0].table.length === 0)
		{
			return c[1];
		}
		if (c[1].table.length === 0)
		{
			return c[0];
		}

		// Adjust .table and .lengths
		c[0].table = c[0].table.concat(c[1].table);
		if (c[0].height > 0)
		{
			var len = length(c[0]);
			for (var i = 0; i < c[1].lengths.length; i++)
			{
				c[1].lengths[i] += len;
			}
			c[0].lengths = c[0].lengths.concat(c[1].lengths);
		}

		return c[0];
	}

	if (c[0].height > 0)
	{
		var toRemove = calcToRemove(a, b);
		if (toRemove > E)
		{
			c = shuffle(c[0], c[1], toRemove);
		}
	}

	return siblise(c[0], c[1]);
}

// Returns an array of two nodes; right and left. One node _may_ be empty.
function append_(a, b)
{
	if (a.height === 0 && b.height === 0)
	{
		return [a, b];
	}

	if (a.height !== 1 || b.height !== 1)
	{
		if (a.height === b.height)
		{
			a = nodeCopy(a);
			b = nodeCopy(b);
			var appended = append_(botRight(a), botLeft(b));

			insertRight(a, appended[1]);
			insertLeft(b, appended[0]);
		}
		else if (a.height > b.height)
		{
			a = nodeCopy(a);
			var appended = append_(botRight(a), b);

			insertRight(a, appended[0]);
			b = parentise(appended[1], appended[1].height + 1);
		}
		else
		{
			b = nodeCopy(b);
			var appended = append_(a, botLeft(b));

			var left = appended[0].table.length === 0 ? 0 : 1;
			var right = left === 0 ? 1 : 0;
			insertLeft(b, appended[left]);
			a = parentise(appended[right], appended[right].height + 1);
		}
	}

	// Check if balancing is needed and return based on that.
	if (a.table.length === 0 || b.table.length === 0)
	{
		return [a, b];
	}

	var toRemove = calcToRemove(a, b);
	if (toRemove <= E)
	{
		return [a, b];
	}
	return shuffle(a, b, toRemove);
}

// Helperfunctions for append_. Replaces a child node at the side of the parent.
function insertRight(parent, node)
{
	var index = parent.table.length - 1;
	parent.table[index] = node;
	parent.lengths[index] = length(node);
	parent.lengths[index] += index > 0 ? parent.lengths[index - 1] : 0;
}

function insertLeft(parent, node)
{
	if (node.table.length > 0)
	{
		parent.table[0] = node;
		parent.lengths[0] = length(node);

		var len = length(parent.table[0]);
		for (var i = 1; i < parent.lengths.length; i++)
		{
			len += length(parent.table[i]);
			parent.lengths[i] = len;
		}
	}
	else
	{
		parent.table.shift();
		for (var i = 1; i < parent.lengths.length; i++)
		{
			parent.lengths[i] = parent.lengths[i] - parent.lengths[0];
		}
		parent.lengths.shift();
	}
}

// Returns the extra search steps for E. Refer to the paper.
function calcToRemove(a, b)
{
	var subLengths = 0;
	for (var i = 0; i < a.table.length; i++)
	{
		subLengths += a.table[i].table.length;
	}
	for (var i = 0; i < b.table.length; i++)
	{
		subLengths += b.table[i].table.length;
	}

	var toRemove = a.table.length + b.table.length;
	return toRemove - (Math.floor((subLengths - 1) / M) + 1);
}

// get2, set2 and saveSlot are helpers for accessing elements over two arrays.
function get2(a, b, index)
{
	return index < a.length
		? a[index]
		: b[index - a.length];
}

function set2(a, b, index, value)
{
	if (index < a.length)
	{
		a[index] = value;
	}
	else
	{
		b[index - a.length] = value;
	}
}

function saveSlot(a, b, index, slot)
{
	set2(a.table, b.table, index, slot);

	var l = (index === 0 || index === a.lengths.length)
		? 0
		: get2(a.lengths, a.lengths, index - 1);

	set2(a.lengths, b.lengths, index, l + length(slot));
}

// Creates a node or leaf with a given length at their arrays for perfomance.
// Is only used by shuffle.
function createNode(h, length)
{
	if (length < 0)
	{
		length = 0;
	}
	var a = {
		ctor: '_Array',
		height: h,
		table: new Array(length)
	};
	if (h > 0)
	{
		a.lengths = new Array(length);
	}
	return a;
}

// Returns an array of two balanced nodes.
function shuffle(a, b, toRemove)
{
	var newA = createNode(a.height, Math.min(M, a.table.length + b.table.length - toRemove));
	var newB = createNode(a.height, newA.table.length - (a.table.length + b.table.length - toRemove));

	// Skip the slots with size M. More precise: copy the slot references
	// to the new node
	var read = 0;
	while (get2(a.table, b.table, read).table.length % M === 0)
	{
		set2(newA.table, newB.table, read, get2(a.table, b.table, read));
		set2(newA.lengths, newB.lengths, read, get2(a.lengths, b.lengths, read));
		read++;
	}

	// Pulling items from left to right, caching in a slot before writing
	// it into the new nodes.
	var write = read;
	var slot = new createNode(a.height - 1, 0);
	var from = 0;

	// If the current slot is still containing data, then there will be at
	// least one more write, so we do not break this loop yet.
	while (read - write - (slot.table.length > 0 ? 1 : 0) < toRemove)
	{
		// Find out the max possible items for copying.
		var source = get2(a.table, b.table, read);
		var to = Math.min(M - slot.table.length, source.table.length);

		// Copy and adjust size table.
		slot.table = slot.table.concat(source.table.slice(from, to));
		if (slot.height > 0)
		{
			var len = slot.lengths.length;
			for (var i = len; i < len + to - from; i++)
			{
				slot.lengths[i] = length(slot.table[i]);
				slot.lengths[i] += (i > 0 ? slot.lengths[i - 1] : 0);
			}
		}

		from += to;

		// Only proceed to next slots[i] if the current one was
		// fully copied.
		if (source.table.length <= to)
		{
			read++; from = 0;
		}

		// Only create a new slot if the current one is filled up.
		if (slot.table.length === M)
		{
			saveSlot(newA, newB, write, slot);
			slot = createNode(a.height - 1, 0);
			write++;
		}
	}

	// Cleanup after the loop. Copy the last slot into the new nodes.
	if (slot.table.length > 0)
	{
		saveSlot(newA, newB, write, slot);
		write++;
	}

	// Shift the untouched slots to the left
	while (read < a.table.length + b.table.length )
	{
		saveSlot(newA, newB, write, get2(a.table, b.table, read));
		read++;
		write++;
	}

	return [newA, newB];
}

// Navigation functions
function botRight(a)
{
	return a.table[a.table.length - 1];
}
function botLeft(a)
{
	return a.table[0];
}

// Copies a node for updating. Note that you should not use this if
// only updating only one of "table" or "lengths" for performance reasons.
function nodeCopy(a)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice()
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths.slice();
	}
	return newA;
}

// Returns how many items are in the tree.
function length(array)
{
	if (array.height === 0)
	{
		return array.table.length;
	}
	else
	{
		return array.lengths[array.lengths.length - 1];
	}
}

// Calculates in which slot of "table" the item probably is, then
// find the exact slot via forward searching in  "lengths". Returns the index.
function getSlot(i, a)
{
	var slot = i >> (5 * a.height);
	while (a.lengths[slot] <= i)
	{
		slot++;
	}
	return slot;
}

// Recursively creates a tree with a given height containing
// only the given item.
function create(item, h)
{
	if (h === 0)
	{
		return {
			ctor: '_Array',
			height: 0,
			table: [item]
		};
	}
	return {
		ctor: '_Array',
		height: h,
		table: [create(item, h - 1)],
		lengths: [1]
	};
}

// Recursively creates a tree that contains the given tree.
function parentise(tree, h)
{
	if (h === tree.height)
	{
		return tree;
	}

	return {
		ctor: '_Array',
		height: h,
		table: [parentise(tree, h - 1)],
		lengths: [length(tree)]
	};
}

// Emphasizes blood brotherhood beneath two trees.
function siblise(a, b)
{
	return {
		ctor: '_Array',
		height: a.height + 1,
		table: [a, b],
		lengths: [length(a), length(a) + length(b)]
	};
}

function toJSArray(a)
{
	var jsArray = new Array(length(a));
	toJSArray_(jsArray, 0, a);
	return jsArray;
}

function toJSArray_(jsArray, i, a)
{
	for (var t = 0; t < a.table.length; t++)
	{
		if (a.height === 0)
		{
			jsArray[i + t] = a.table[t];
		}
		else
		{
			var inc = t === 0 ? 0 : a.lengths[t - 1];
			toJSArray_(jsArray, i + inc, a.table[t]);
		}
	}
}

function fromJSArray(jsArray)
{
	if (jsArray.length === 0)
	{
		return empty;
	}
	var h = Math.floor(Math.log(jsArray.length) / Math.log(M));
	return fromJSArray_(jsArray, h, 0, jsArray.length);
}

function fromJSArray_(jsArray, h, from, to)
{
	if (h === 0)
	{
		return {
			ctor: '_Array',
			height: 0,
			table: jsArray.slice(from, to)
		};
	}

	var step = Math.pow(M, h);
	var table = new Array(Math.ceil((to - from) / step));
	var lengths = new Array(table.length);
	for (var i = 0; i < table.length; i++)
	{
		table[i] = fromJSArray_(jsArray, h - 1, from + (i * step), Math.min(from + ((i + 1) * step), to));
		lengths[i] = length(table[i]) + (i > 0 ? lengths[i - 1] : 0);
	}
	return {
		ctor: '_Array',
		height: h,
		table: table,
		lengths: lengths
	};
}

return {
	empty: empty,
	fromList: fromList,
	toList: toList,
	initialize: F2(initialize),
	append: F2(append),
	push: F2(push),
	slice: F3(slice),
	get: F2(get),
	set: F3(set),
	map: F2(map),
	indexedMap: F2(indexedMap),
	foldl: F3(foldl),
	foldr: F3(foldr),
	length: length,

	toJSArray: toJSArray,
	fromJSArray: fromJSArray
};

}();
//import Native.Utils //

var _elm_lang$core$Native_Basics = function() {

function div(a, b)
{
	return (a / b) | 0;
}
function rem(a, b)
{
	return a % b;
}
function mod(a, b)
{
	if (b === 0)
	{
		throw new Error('Cannot perform mod 0. Division by zero error.');
	}
	var r = a % b;
	var m = a === 0 ? 0 : (b > 0 ? (a >= 0 ? r : r + b) : -mod(-a, -b));

	return m === b ? 0 : m;
}
function logBase(base, n)
{
	return Math.log(n) / Math.log(base);
}
function negate(n)
{
	return -n;
}
function abs(n)
{
	return n < 0 ? -n : n;
}

function min(a, b)
{
	return _elm_lang$core$Native_Utils.cmp(a, b) < 0 ? a : b;
}
function max(a, b)
{
	return _elm_lang$core$Native_Utils.cmp(a, b) > 0 ? a : b;
}
function clamp(lo, hi, n)
{
	return _elm_lang$core$Native_Utils.cmp(n, lo) < 0
		? lo
		: _elm_lang$core$Native_Utils.cmp(n, hi) > 0
			? hi
			: n;
}

var ord = ['LT', 'EQ', 'GT'];

function compare(x, y)
{
	return { ctor: ord[_elm_lang$core$Native_Utils.cmp(x, y) + 1] };
}

function xor(a, b)
{
	return a !== b;
}
function not(b)
{
	return !b;
}
function isInfinite(n)
{
	return n === Infinity || n === -Infinity;
}

function truncate(n)
{
	return n | 0;
}

function degrees(d)
{
	return d * Math.PI / 180;
}
function turns(t)
{
	return 2 * Math.PI * t;
}
function fromPolar(point)
{
	var r = point._0;
	var t = point._1;
	return _elm_lang$core$Native_Utils.Tuple2(r * Math.cos(t), r * Math.sin(t));
}
function toPolar(point)
{
	var x = point._0;
	var y = point._1;
	return _elm_lang$core$Native_Utils.Tuple2(Math.sqrt(x * x + y * y), Math.atan2(y, x));
}

return {
	div: F2(div),
	rem: F2(rem),
	mod: F2(mod),

	pi: Math.PI,
	e: Math.E,
	cos: Math.cos,
	sin: Math.sin,
	tan: Math.tan,
	acos: Math.acos,
	asin: Math.asin,
	atan: Math.atan,
	atan2: F2(Math.atan2),

	degrees: degrees,
	turns: turns,
	fromPolar: fromPolar,
	toPolar: toPolar,

	sqrt: Math.sqrt,
	logBase: F2(logBase),
	negate: negate,
	abs: abs,
	min: F2(min),
	max: F2(max),
	clamp: F3(clamp),
	compare: F2(compare),

	xor: F2(xor),
	not: not,

	truncate: truncate,
	ceiling: Math.ceil,
	floor: Math.floor,
	round: Math.round,
	toFloat: function(x) { return x; },
	isNaN: isNaN,
	isInfinite: isInfinite
};

}();
//import //

var _elm_lang$core$Native_Utils = function() {

// COMPARISONS

function eq(x, y)
{
	var stack = [];
	var isEqual = eqHelp(x, y, 0, stack);
	var pair;
	while (isEqual && (pair = stack.pop()))
	{
		isEqual = eqHelp(pair.x, pair.y, 0, stack);
	}
	return isEqual;
}


function eqHelp(x, y, depth, stack)
{
	if (depth > 100)
	{
		stack.push({ x: x, y: y });
		return true;
	}

	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object')
	{
		if (typeof x === 'function')
		{
			throw new Error(
				'Trying to use `(==)` on functions. There is no way to know if functions are "the same" in the Elm sense.'
				+ ' Read more about this at http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#=='
				+ ' which describes why it is this way and what the better version will look like.'
			);
		}
		return false;
	}

	if (x === null || y === null)
	{
		return false
	}

	if (x instanceof Date)
	{
		return x.getTime() === y.getTime();
	}

	if (!('ctor' in x))
	{
		for (var key in x)
		{
			if (!eqHelp(x[key], y[key], depth + 1, stack))
			{
				return false;
			}
		}
		return true;
	}

	// convert Dicts and Sets to lists
	if (x.ctor === 'RBNode_elm_builtin' || x.ctor === 'RBEmpty_elm_builtin')
	{
		x = _elm_lang$core$Dict$toList(x);
		y = _elm_lang$core$Dict$toList(y);
	}
	if (x.ctor === 'Set_elm_builtin')
	{
		x = _elm_lang$core$Set$toList(x);
		y = _elm_lang$core$Set$toList(y);
	}

	// check if lists are equal without recursion
	if (x.ctor === '::')
	{
		var a = x;
		var b = y;
		while (a.ctor === '::' && b.ctor === '::')
		{
			if (!eqHelp(a._0, b._0, depth + 1, stack))
			{
				return false;
			}
			a = a._1;
			b = b._1;
		}
		return a.ctor === b.ctor;
	}

	// check if Arrays are equal
	if (x.ctor === '_Array')
	{
		var xs = _elm_lang$core$Native_Array.toJSArray(x);
		var ys = _elm_lang$core$Native_Array.toJSArray(y);
		if (xs.length !== ys.length)
		{
			return false;
		}
		for (var i = 0; i < xs.length; i++)
		{
			if (!eqHelp(xs[i], ys[i], depth + 1, stack))
			{
				return false;
			}
		}
		return true;
	}

	if (!eqHelp(x.ctor, y.ctor, depth + 1, stack))
	{
		return false;
	}

	for (var key in x)
	{
		if (!eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

var LT = -1, EQ = 0, GT = 1;

function cmp(x, y)
{
	if (typeof x !== 'object')
	{
		return x === y ? EQ : x < y ? LT : GT;
	}

	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? EQ : a < b ? LT : GT;
	}

	if (x.ctor === '::' || x.ctor === '[]')
	{
		while (x.ctor === '::' && y.ctor === '::')
		{
			var ord = cmp(x._0, y._0);
			if (ord !== EQ)
			{
				return ord;
			}
			x = x._1;
			y = y._1;
		}
		return x.ctor === y.ctor ? EQ : x.ctor === '[]' ? LT : GT;
	}

	if (x.ctor.slice(0, 6) === '_Tuple')
	{
		var ord;
		var n = x.ctor.slice(6) - 0;
		var err = 'cannot compare tuples with more than 6 elements.';
		if (n === 0) return EQ;
		if (n >= 1) { ord = cmp(x._0, y._0); if (ord !== EQ) return ord;
		if (n >= 2) { ord = cmp(x._1, y._1); if (ord !== EQ) return ord;
		if (n >= 3) { ord = cmp(x._2, y._2); if (ord !== EQ) return ord;
		if (n >= 4) { ord = cmp(x._3, y._3); if (ord !== EQ) return ord;
		if (n >= 5) { ord = cmp(x._4, y._4); if (ord !== EQ) return ord;
		if (n >= 6) { ord = cmp(x._5, y._5); if (ord !== EQ) return ord;
		if (n >= 7) throw new Error('Comparison error: ' + err); } } } } } }
		return EQ;
	}

	throw new Error(
		'Comparison error: comparison is only defined on ints, '
		+ 'floats, times, chars, strings, lists of comparable values, '
		+ 'and tuples of comparable values.'
	);
}


// COMMON VALUES

var Tuple0 = {
	ctor: '_Tuple0'
};

function Tuple2(x, y)
{
	return {
		ctor: '_Tuple2',
		_0: x,
		_1: y
	};
}

function chr(c)
{
	return new String(c);
}


// GUID

var count = 0;
function guid(_)
{
	return count++;
}


// RECORDS

function update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


//// LIST STUFF ////

var Nil = { ctor: '[]' };

function Cons(hd, tl)
{
	return {
		ctor: '::',
		_0: hd,
		_1: tl
	};
}

function append(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (xs.ctor === '[]')
	{
		return ys;
	}
	var root = Cons(xs._0, Nil);
	var curr = root;
	xs = xs._1;
	while (xs.ctor !== '[]')
	{
		curr._1 = Cons(xs._0, Nil);
		xs = xs._1;
		curr = curr._1;
	}
	curr._1 = ys;
	return root;
}


// CRASHES

function crash(moduleName, region)
{
	return function(message) {
		throw new Error(
			'Ran into a `Debug.crash` in module `' + moduleName + '` ' + regionToString(region) + '\n'
			+ 'The message provided by the code author is:\n\n    '
			+ message
		);
	};
}

function crashCase(moduleName, region, value)
{
	return function(message) {
		throw new Error(
			'Ran into a `Debug.crash` in module `' + moduleName + '`\n\n'
			+ 'This was caused by the `case` expression ' + regionToString(region) + '.\n'
			+ 'One of the branches ended with a crash and the following value got through:\n\n    ' + toString(value) + '\n\n'
			+ 'The message provided by the code author is:\n\n    '
			+ message
		);
	};
}

function regionToString(region)
{
	if (region.start.line == region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'between lines ' + region.start.line + ' and ' + region.end.line;
}


// TO STRING

function toString(v)
{
	var type = typeof v;
	if (type === 'function')
	{
		return '<function>';
	}

	if (type === 'boolean')
	{
		return v ? 'True' : 'False';
	}

	if (type === 'number')
	{
		return v + '';
	}

	if (v instanceof String)
	{
		return '\'' + addSlashes(v, true) + '\'';
	}

	if (type === 'string')
	{
		return '"' + addSlashes(v, false) + '"';
	}

	if (v === null)
	{
		return 'null';
	}

	if (type === 'object' && 'ctor' in v)
	{
		var ctorStarter = v.ctor.substring(0, 5);

		if (ctorStarter === '_Tupl')
		{
			var output = [];
			for (var k in v)
			{
				if (k === 'ctor') continue;
				output.push(toString(v[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (ctorStarter === '_Task')
		{
			return '<task>'
		}

		if (v.ctor === '_Array')
		{
			var list = _elm_lang$core$Array$toList(v);
			return 'Array.fromList ' + toString(list);
		}

		if (v.ctor === '<decoder>')
		{
			return '<decoder>';
		}

		if (v.ctor === '_Process')
		{
			return '<process:' + v.id + '>';
		}

		if (v.ctor === '::')
		{
			var output = '[' + toString(v._0);
			v = v._1;
			while (v.ctor === '::')
			{
				output += ',' + toString(v._0);
				v = v._1;
			}
			return output + ']';
		}

		if (v.ctor === '[]')
		{
			return '[]';
		}

		if (v.ctor === 'Set_elm_builtin')
		{
			return 'Set.fromList ' + toString(_elm_lang$core$Set$toList(v));
		}

		if (v.ctor === 'RBNode_elm_builtin' || v.ctor === 'RBEmpty_elm_builtin')
		{
			return 'Dict.fromList ' + toString(_elm_lang$core$Dict$toList(v));
		}

		var output = '';
		for (var i in v)
		{
			if (i === 'ctor') continue;
			var str = toString(v[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return v.ctor + output;
	}

	if (type === 'object')
	{
		if (v instanceof Date)
		{
			return '<' + v.toString() + '>';
		}

		if (v.elm_web_socket)
		{
			return '<websocket>';
		}

		var output = [];
		for (var k in v)
		{
			output.push(k + ' = ' + toString(v[k]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return '<internal structure>';
}

function addSlashes(str, isChar)
{
	var s = str.replace(/\\/g, '\\\\')
			  .replace(/\n/g, '\\n')
			  .replace(/\t/g, '\\t')
			  .replace(/\r/g, '\\r')
			  .replace(/\v/g, '\\v')
			  .replace(/\0/g, '\\0');
	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}


return {
	eq: eq,
	cmp: cmp,
	Tuple0: Tuple0,
	Tuple2: Tuple2,
	chr: chr,
	update: update,
	guid: guid,

	append: F2(append),

	crash: crash,
	crashCase: crashCase,

	toString: toString
};

}();
var _elm_lang$core$Basics$never = function (_p0) {
	never:
	while (true) {
		var _p1 = _p0;
		var _v1 = _p1._0;
		_p0 = _v1;
		continue never;
	}
};
var _elm_lang$core$Basics$uncurry = F2(
	function (f, _p2) {
		var _p3 = _p2;
		return A2(f, _p3._0, _p3._1);
	});
var _elm_lang$core$Basics$curry = F3(
	function (f, a, b) {
		return f(
			{ctor: '_Tuple2', _0: a, _1: b});
	});
var _elm_lang$core$Basics$flip = F3(
	function (f, b, a) {
		return A2(f, a, b);
	});
var _elm_lang$core$Basics$always = F2(
	function (a, _p4) {
		return a;
	});
var _elm_lang$core$Basics$identity = function (x) {
	return x;
};
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<|'] = F2(
	function (f, x) {
		return f(x);
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['|>'] = F2(
	function (x, f) {
		return f(x);
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>>'] = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<<'] = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['++'] = _elm_lang$core$Native_Utils.append;
var _elm_lang$core$Basics$toString = _elm_lang$core$Native_Utils.toString;
var _elm_lang$core$Basics$isInfinite = _elm_lang$core$Native_Basics.isInfinite;
var _elm_lang$core$Basics$isNaN = _elm_lang$core$Native_Basics.isNaN;
var _elm_lang$core$Basics$toFloat = _elm_lang$core$Native_Basics.toFloat;
var _elm_lang$core$Basics$ceiling = _elm_lang$core$Native_Basics.ceiling;
var _elm_lang$core$Basics$floor = _elm_lang$core$Native_Basics.floor;
var _elm_lang$core$Basics$truncate = _elm_lang$core$Native_Basics.truncate;
var _elm_lang$core$Basics$round = _elm_lang$core$Native_Basics.round;
var _elm_lang$core$Basics$not = _elm_lang$core$Native_Basics.not;
var _elm_lang$core$Basics$xor = _elm_lang$core$Native_Basics.xor;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['||'] = _elm_lang$core$Native_Basics.or;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['&&'] = _elm_lang$core$Native_Basics.and;
var _elm_lang$core$Basics$max = _elm_lang$core$Native_Basics.max;
var _elm_lang$core$Basics$min = _elm_lang$core$Native_Basics.min;
var _elm_lang$core$Basics$compare = _elm_lang$core$Native_Basics.compare;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>='] = _elm_lang$core$Native_Basics.ge;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<='] = _elm_lang$core$Native_Basics.le;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>'] = _elm_lang$core$Native_Basics.gt;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<'] = _elm_lang$core$Native_Basics.lt;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['/='] = _elm_lang$core$Native_Basics.neq;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['=='] = _elm_lang$core$Native_Basics.eq;
var _elm_lang$core$Basics$e = _elm_lang$core$Native_Basics.e;
var _elm_lang$core$Basics$pi = _elm_lang$core$Native_Basics.pi;
var _elm_lang$core$Basics$clamp = _elm_lang$core$Native_Basics.clamp;
var _elm_lang$core$Basics$logBase = _elm_lang$core$Native_Basics.logBase;
var _elm_lang$core$Basics$abs = _elm_lang$core$Native_Basics.abs;
var _elm_lang$core$Basics$negate = _elm_lang$core$Native_Basics.negate;
var _elm_lang$core$Basics$sqrt = _elm_lang$core$Native_Basics.sqrt;
var _elm_lang$core$Basics$atan2 = _elm_lang$core$Native_Basics.atan2;
var _elm_lang$core$Basics$atan = _elm_lang$core$Native_Basics.atan;
var _elm_lang$core$Basics$asin = _elm_lang$core$Native_Basics.asin;
var _elm_lang$core$Basics$acos = _elm_lang$core$Native_Basics.acos;
var _elm_lang$core$Basics$tan = _elm_lang$core$Native_Basics.tan;
var _elm_lang$core$Basics$sin = _elm_lang$core$Native_Basics.sin;
var _elm_lang$core$Basics$cos = _elm_lang$core$Native_Basics.cos;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['^'] = _elm_lang$core$Native_Basics.exp;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['%'] = _elm_lang$core$Native_Basics.mod;
var _elm_lang$core$Basics$rem = _elm_lang$core$Native_Basics.rem;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['//'] = _elm_lang$core$Native_Basics.div;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['/'] = _elm_lang$core$Native_Basics.floatDiv;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['*'] = _elm_lang$core$Native_Basics.mul;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['-'] = _elm_lang$core$Native_Basics.sub;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['+'] = _elm_lang$core$Native_Basics.add;
var _elm_lang$core$Basics$toPolar = _elm_lang$core$Native_Basics.toPolar;
var _elm_lang$core$Basics$fromPolar = _elm_lang$core$Native_Basics.fromPolar;
var _elm_lang$core$Basics$turns = _elm_lang$core$Native_Basics.turns;
var _elm_lang$core$Basics$degrees = _elm_lang$core$Native_Basics.degrees;
var _elm_lang$core$Basics$radians = function (t) {
	return t;
};
var _elm_lang$core$Basics$GT = {ctor: 'GT'};
var _elm_lang$core$Basics$EQ = {ctor: 'EQ'};
var _elm_lang$core$Basics$LT = {ctor: 'LT'};
var _elm_lang$core$Basics$JustOneMore = function (a) {
	return {ctor: 'JustOneMore', _0: a};
};

var _elm_lang$core$Maybe$withDefault = F2(
	function ($default, maybe) {
		var _p0 = maybe;
		if (_p0.ctor === 'Just') {
			return _p0._0;
		} else {
			return $default;
		}
	});
var _elm_lang$core$Maybe$Nothing = {ctor: 'Nothing'};
var _elm_lang$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		var _p1 = maybeValue;
		if (_p1.ctor === 'Just') {
			return callback(_p1._0);
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$Just = function (a) {
	return {ctor: 'Just', _0: a};
};
var _elm_lang$core$Maybe$map = F2(
	function (f, maybe) {
		var _p2 = maybe;
		if (_p2.ctor === 'Just') {
			return _elm_lang$core$Maybe$Just(
				f(_p2._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map2 = F3(
	function (func, ma, mb) {
		var _p3 = {ctor: '_Tuple2', _0: ma, _1: mb};
		if (((_p3.ctor === '_Tuple2') && (_p3._0.ctor === 'Just')) && (_p3._1.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A2(func, _p3._0._0, _p3._1._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map3 = F4(
	function (func, ma, mb, mc) {
		var _p4 = {ctor: '_Tuple3', _0: ma, _1: mb, _2: mc};
		if ((((_p4.ctor === '_Tuple3') && (_p4._0.ctor === 'Just')) && (_p4._1.ctor === 'Just')) && (_p4._2.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A3(func, _p4._0._0, _p4._1._0, _p4._2._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map4 = F5(
	function (func, ma, mb, mc, md) {
		var _p5 = {ctor: '_Tuple4', _0: ma, _1: mb, _2: mc, _3: md};
		if (((((_p5.ctor === '_Tuple4') && (_p5._0.ctor === 'Just')) && (_p5._1.ctor === 'Just')) && (_p5._2.ctor === 'Just')) && (_p5._3.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A4(func, _p5._0._0, _p5._1._0, _p5._2._0, _p5._3._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map5 = F6(
	function (func, ma, mb, mc, md, me) {
		var _p6 = {ctor: '_Tuple5', _0: ma, _1: mb, _2: mc, _3: md, _4: me};
		if ((((((_p6.ctor === '_Tuple5') && (_p6._0.ctor === 'Just')) && (_p6._1.ctor === 'Just')) && (_p6._2.ctor === 'Just')) && (_p6._3.ctor === 'Just')) && (_p6._4.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A5(func, _p6._0._0, _p6._1._0, _p6._2._0, _p6._3._0, _p6._4._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});

//import Native.Utils //

var _elm_lang$core$Native_List = function() {

var Nil = { ctor: '[]' };

function Cons(hd, tl)
{
	return { ctor: '::', _0: hd, _1: tl };
}

function fromArray(arr)
{
	var out = Nil;
	for (var i = arr.length; i--; )
	{
		out = Cons(arr[i], out);
	}
	return out;
}

function toArray(xs)
{
	var out = [];
	while (xs.ctor !== '[]')
	{
		out.push(xs._0);
		xs = xs._1;
	}
	return out;
}

function foldr(f, b, xs)
{
	var arr = toArray(xs);
	var acc = b;
	for (var i = arr.length; i--; )
	{
		acc = A2(f, arr[i], acc);
	}
	return acc;
}

function map2(f, xs, ys)
{
	var arr = [];
	while (xs.ctor !== '[]' && ys.ctor !== '[]')
	{
		arr.push(A2(f, xs._0, ys._0));
		xs = xs._1;
		ys = ys._1;
	}
	return fromArray(arr);
}

function map3(f, xs, ys, zs)
{
	var arr = [];
	while (xs.ctor !== '[]' && ys.ctor !== '[]' && zs.ctor !== '[]')
	{
		arr.push(A3(f, xs._0, ys._0, zs._0));
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function map4(f, ws, xs, ys, zs)
{
	var arr = [];
	while (   ws.ctor !== '[]'
		   && xs.ctor !== '[]'
		   && ys.ctor !== '[]'
		   && zs.ctor !== '[]')
	{
		arr.push(A4(f, ws._0, xs._0, ys._0, zs._0));
		ws = ws._1;
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function map5(f, vs, ws, xs, ys, zs)
{
	var arr = [];
	while (   vs.ctor !== '[]'
		   && ws.ctor !== '[]'
		   && xs.ctor !== '[]'
		   && ys.ctor !== '[]'
		   && zs.ctor !== '[]')
	{
		arr.push(A5(f, vs._0, ws._0, xs._0, ys._0, zs._0));
		vs = vs._1;
		ws = ws._1;
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function sortBy(f, xs)
{
	return fromArray(toArray(xs).sort(function(a, b) {
		return _elm_lang$core$Native_Utils.cmp(f(a), f(b));
	}));
}

function sortWith(f, xs)
{
	return fromArray(toArray(xs).sort(function(a, b) {
		var ord = f(a)(b).ctor;
		return ord === 'EQ' ? 0 : ord === 'LT' ? -1 : 1;
	}));
}

return {
	Nil: Nil,
	Cons: Cons,
	cons: F2(Cons),
	toArray: toArray,
	fromArray: fromArray,

	foldr: F3(foldr),

	map2: F3(map2),
	map3: F4(map3),
	map4: F5(map4),
	map5: F6(map5),
	sortBy: F2(sortBy),
	sortWith: F2(sortWith)
};

}();
var _elm_lang$core$List$sortWith = _elm_lang$core$Native_List.sortWith;
var _elm_lang$core$List$sortBy = _elm_lang$core$Native_List.sortBy;
var _elm_lang$core$List$sort = function (xs) {
	return A2(_elm_lang$core$List$sortBy, _elm_lang$core$Basics$identity, xs);
};
var _elm_lang$core$List$singleton = function (value) {
	return {
		ctor: '::',
		_0: value,
		_1: {ctor: '[]'}
	};
};
var _elm_lang$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return list;
			} else {
				var _p0 = list;
				if (_p0.ctor === '[]') {
					return list;
				} else {
					var _v1 = n - 1,
						_v2 = _p0._1;
					n = _v1;
					list = _v2;
					continue drop;
				}
			}
		}
	});
var _elm_lang$core$List$map5 = _elm_lang$core$Native_List.map5;
var _elm_lang$core$List$map4 = _elm_lang$core$Native_List.map4;
var _elm_lang$core$List$map3 = _elm_lang$core$Native_List.map3;
var _elm_lang$core$List$map2 = _elm_lang$core$Native_List.map2;
var _elm_lang$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			var _p1 = list;
			if (_p1.ctor === '[]') {
				return false;
			} else {
				if (isOkay(_p1._0)) {
					return true;
				} else {
					var _v4 = isOkay,
						_v5 = _p1._1;
					isOkay = _v4;
					list = _v5;
					continue any;
				}
			}
		}
	});
var _elm_lang$core$List$all = F2(
	function (isOkay, list) {
		return !A2(
			_elm_lang$core$List$any,
			function (_p2) {
				return !isOkay(_p2);
			},
			list);
	});
var _elm_lang$core$List$foldr = _elm_lang$core$Native_List.foldr;
var _elm_lang$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			var _p3 = list;
			if (_p3.ctor === '[]') {
				return acc;
			} else {
				var _v7 = func,
					_v8 = A2(func, _p3._0, acc),
					_v9 = _p3._1;
				func = _v7;
				acc = _v8;
				list = _v9;
				continue foldl;
			}
		}
	});
var _elm_lang$core$List$length = function (xs) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (_p4, i) {
				return i + 1;
			}),
		0,
		xs);
};
var _elm_lang$core$List$sum = function (numbers) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return x + y;
			}),
		0,
		numbers);
};
var _elm_lang$core$List$product = function (numbers) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return x * y;
			}),
		1,
		numbers);
};
var _elm_lang$core$List$maximum = function (list) {
	var _p5 = list;
	if (_p5.ctor === '::') {
		return _elm_lang$core$Maybe$Just(
			A3(_elm_lang$core$List$foldl, _elm_lang$core$Basics$max, _p5._0, _p5._1));
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$minimum = function (list) {
	var _p6 = list;
	if (_p6.ctor === '::') {
		return _elm_lang$core$Maybe$Just(
			A3(_elm_lang$core$List$foldl, _elm_lang$core$Basics$min, _p6._0, _p6._1));
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$member = F2(
	function (x, xs) {
		return A2(
			_elm_lang$core$List$any,
			function (a) {
				return _elm_lang$core$Native_Utils.eq(a, x);
			},
			xs);
	});
var _elm_lang$core$List$isEmpty = function (xs) {
	var _p7 = xs;
	if (_p7.ctor === '[]') {
		return true;
	} else {
		return false;
	}
};
var _elm_lang$core$List$tail = function (list) {
	var _p8 = list;
	if (_p8.ctor === '::') {
		return _elm_lang$core$Maybe$Just(_p8._1);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$head = function (list) {
	var _p9 = list;
	if (_p9.ctor === '::') {
		return _elm_lang$core$Maybe$Just(_p9._0);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List_ops = _elm_lang$core$List_ops || {};
_elm_lang$core$List_ops['::'] = _elm_lang$core$Native_List.cons;
var _elm_lang$core$List$map = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$foldr,
			F2(
				function (x, acc) {
					return {
						ctor: '::',
						_0: f(x),
						_1: acc
					};
				}),
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$filter = F2(
	function (pred, xs) {
		var conditionalCons = F2(
			function (front, back) {
				return pred(front) ? {ctor: '::', _0: front, _1: back} : back;
			});
		return A3(
			_elm_lang$core$List$foldr,
			conditionalCons,
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _p10 = f(mx);
		if (_p10.ctor === 'Just') {
			return {ctor: '::', _0: _p10._0, _1: xs};
		} else {
			return xs;
		}
	});
var _elm_lang$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$foldr,
			_elm_lang$core$List$maybeCons(f),
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$reverse = function (list) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return {ctor: '::', _0: x, _1: y};
			}),
		{ctor: '[]'},
		list);
};
var _elm_lang$core$List$scanl = F3(
	function (f, b, xs) {
		var scan1 = F2(
			function (x, accAcc) {
				var _p11 = accAcc;
				if (_p11.ctor === '::') {
					return {
						ctor: '::',
						_0: A2(f, x, _p11._0),
						_1: accAcc
					};
				} else {
					return {ctor: '[]'};
				}
			});
		return _elm_lang$core$List$reverse(
			A3(
				_elm_lang$core$List$foldl,
				scan1,
				{
					ctor: '::',
					_0: b,
					_1: {ctor: '[]'}
				},
				xs));
	});
var _elm_lang$core$List$append = F2(
	function (xs, ys) {
		var _p12 = ys;
		if (_p12.ctor === '[]') {
			return xs;
		} else {
			return A3(
				_elm_lang$core$List$foldr,
				F2(
					function (x, y) {
						return {ctor: '::', _0: x, _1: y};
					}),
				ys,
				xs);
		}
	});
var _elm_lang$core$List$concat = function (lists) {
	return A3(
		_elm_lang$core$List$foldr,
		_elm_lang$core$List$append,
		{ctor: '[]'},
		lists);
};
var _elm_lang$core$List$concatMap = F2(
	function (f, list) {
		return _elm_lang$core$List$concat(
			A2(_elm_lang$core$List$map, f, list));
	});
var _elm_lang$core$List$partition = F2(
	function (pred, list) {
		var step = F2(
			function (x, _p13) {
				var _p14 = _p13;
				var _p16 = _p14._0;
				var _p15 = _p14._1;
				return pred(x) ? {
					ctor: '_Tuple2',
					_0: {ctor: '::', _0: x, _1: _p16},
					_1: _p15
				} : {
					ctor: '_Tuple2',
					_0: _p16,
					_1: {ctor: '::', _0: x, _1: _p15}
				};
			});
		return A3(
			_elm_lang$core$List$foldr,
			step,
			{
				ctor: '_Tuple2',
				_0: {ctor: '[]'},
				_1: {ctor: '[]'}
			},
			list);
	});
var _elm_lang$core$List$unzip = function (pairs) {
	var step = F2(
		function (_p18, _p17) {
			var _p19 = _p18;
			var _p20 = _p17;
			return {
				ctor: '_Tuple2',
				_0: {ctor: '::', _0: _p19._0, _1: _p20._0},
				_1: {ctor: '::', _0: _p19._1, _1: _p20._1}
			};
		});
	return A3(
		_elm_lang$core$List$foldr,
		step,
		{
			ctor: '_Tuple2',
			_0: {ctor: '[]'},
			_1: {ctor: '[]'}
		},
		pairs);
};
var _elm_lang$core$List$intersperse = F2(
	function (sep, xs) {
		var _p21 = xs;
		if (_p21.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			var step = F2(
				function (x, rest) {
					return {
						ctor: '::',
						_0: sep,
						_1: {ctor: '::', _0: x, _1: rest}
					};
				});
			var spersed = A3(
				_elm_lang$core$List$foldr,
				step,
				{ctor: '[]'},
				_p21._1);
			return {ctor: '::', _0: _p21._0, _1: spersed};
		}
	});
var _elm_lang$core$List$takeReverse = F3(
	function (n, list, taken) {
		takeReverse:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return taken;
			} else {
				var _p22 = list;
				if (_p22.ctor === '[]') {
					return taken;
				} else {
					var _v23 = n - 1,
						_v24 = _p22._1,
						_v25 = {ctor: '::', _0: _p22._0, _1: taken};
					n = _v23;
					list = _v24;
					taken = _v25;
					continue takeReverse;
				}
			}
		}
	});
var _elm_lang$core$List$takeTailRec = F2(
	function (n, list) {
		return _elm_lang$core$List$reverse(
			A3(
				_elm_lang$core$List$takeReverse,
				n,
				list,
				{ctor: '[]'}));
	});
var _elm_lang$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
			return {ctor: '[]'};
		} else {
			var _p23 = {ctor: '_Tuple2', _0: n, _1: list};
			_v26_5:
			do {
				_v26_1:
				do {
					if (_p23.ctor === '_Tuple2') {
						if (_p23._1.ctor === '[]') {
							return list;
						} else {
							if (_p23._1._1.ctor === '::') {
								switch (_p23._0) {
									case 1:
										break _v26_1;
									case 2:
										return {
											ctor: '::',
											_0: _p23._1._0,
											_1: {
												ctor: '::',
												_0: _p23._1._1._0,
												_1: {ctor: '[]'}
											}
										};
									case 3:
										if (_p23._1._1._1.ctor === '::') {
											return {
												ctor: '::',
												_0: _p23._1._0,
												_1: {
													ctor: '::',
													_0: _p23._1._1._0,
													_1: {
														ctor: '::',
														_0: _p23._1._1._1._0,
														_1: {ctor: '[]'}
													}
												}
											};
										} else {
											break _v26_5;
										}
									default:
										if ((_p23._1._1._1.ctor === '::') && (_p23._1._1._1._1.ctor === '::')) {
											var _p28 = _p23._1._1._1._0;
											var _p27 = _p23._1._1._0;
											var _p26 = _p23._1._0;
											var _p25 = _p23._1._1._1._1._0;
											var _p24 = _p23._1._1._1._1._1;
											return (_elm_lang$core$Native_Utils.cmp(ctr, 1000) > 0) ? {
												ctor: '::',
												_0: _p26,
												_1: {
													ctor: '::',
													_0: _p27,
													_1: {
														ctor: '::',
														_0: _p28,
														_1: {
															ctor: '::',
															_0: _p25,
															_1: A2(_elm_lang$core$List$takeTailRec, n - 4, _p24)
														}
													}
												}
											} : {
												ctor: '::',
												_0: _p26,
												_1: {
													ctor: '::',
													_0: _p27,
													_1: {
														ctor: '::',
														_0: _p28,
														_1: {
															ctor: '::',
															_0: _p25,
															_1: A3(_elm_lang$core$List$takeFast, ctr + 1, n - 4, _p24)
														}
													}
												}
											};
										} else {
											break _v26_5;
										}
								}
							} else {
								if (_p23._0 === 1) {
									break _v26_1;
								} else {
									break _v26_5;
								}
							}
						}
					} else {
						break _v26_5;
					}
				} while(false);
				return {
					ctor: '::',
					_0: _p23._1._0,
					_1: {ctor: '[]'}
				};
			} while(false);
			return list;
		}
	});
var _elm_lang$core$List$take = F2(
	function (n, list) {
		return A3(_elm_lang$core$List$takeFast, 0, n, list);
	});
var _elm_lang$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return result;
			} else {
				var _v27 = {ctor: '::', _0: value, _1: result},
					_v28 = n - 1,
					_v29 = value;
				result = _v27;
				n = _v28;
				value = _v29;
				continue repeatHelp;
			}
		}
	});
var _elm_lang$core$List$repeat = F2(
	function (n, value) {
		return A3(
			_elm_lang$core$List$repeatHelp,
			{ctor: '[]'},
			n,
			value);
	});
var _elm_lang$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(lo, hi) < 1) {
				var _v30 = lo,
					_v31 = hi - 1,
					_v32 = {ctor: '::', _0: hi, _1: list};
				lo = _v30;
				hi = _v31;
				list = _v32;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var _elm_lang$core$List$range = F2(
	function (lo, hi) {
		return A3(
			_elm_lang$core$List$rangeHelp,
			lo,
			hi,
			{ctor: '[]'});
	});
var _elm_lang$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$map2,
			f,
			A2(
				_elm_lang$core$List$range,
				0,
				_elm_lang$core$List$length(xs) - 1),
			xs);
	});

var _elm_lang$core$Array$append = _elm_lang$core$Native_Array.append;
var _elm_lang$core$Array$length = _elm_lang$core$Native_Array.length;
var _elm_lang$core$Array$isEmpty = function (array) {
	return _elm_lang$core$Native_Utils.eq(
		_elm_lang$core$Array$length(array),
		0);
};
var _elm_lang$core$Array$slice = _elm_lang$core$Native_Array.slice;
var _elm_lang$core$Array$set = _elm_lang$core$Native_Array.set;
var _elm_lang$core$Array$get = F2(
	function (i, array) {
		return ((_elm_lang$core$Native_Utils.cmp(0, i) < 1) && (_elm_lang$core$Native_Utils.cmp(
			i,
			_elm_lang$core$Native_Array.length(array)) < 0)) ? _elm_lang$core$Maybe$Just(
			A2(_elm_lang$core$Native_Array.get, i, array)) : _elm_lang$core$Maybe$Nothing;
	});
var _elm_lang$core$Array$push = _elm_lang$core$Native_Array.push;
var _elm_lang$core$Array$empty = _elm_lang$core$Native_Array.empty;
var _elm_lang$core$Array$filter = F2(
	function (isOkay, arr) {
		var update = F2(
			function (x, xs) {
				return isOkay(x) ? A2(_elm_lang$core$Native_Array.push, x, xs) : xs;
			});
		return A3(_elm_lang$core$Native_Array.foldl, update, _elm_lang$core$Native_Array.empty, arr);
	});
var _elm_lang$core$Array$foldr = _elm_lang$core$Native_Array.foldr;
var _elm_lang$core$Array$foldl = _elm_lang$core$Native_Array.foldl;
var _elm_lang$core$Array$indexedMap = _elm_lang$core$Native_Array.indexedMap;
var _elm_lang$core$Array$map = _elm_lang$core$Native_Array.map;
var _elm_lang$core$Array$toIndexedList = function (array) {
	return A3(
		_elm_lang$core$List$map2,
		F2(
			function (v0, v1) {
				return {ctor: '_Tuple2', _0: v0, _1: v1};
			}),
		A2(
			_elm_lang$core$List$range,
			0,
			_elm_lang$core$Native_Array.length(array) - 1),
		_elm_lang$core$Native_Array.toList(array));
};
var _elm_lang$core$Array$toList = _elm_lang$core$Native_Array.toList;
var _elm_lang$core$Array$fromList = _elm_lang$core$Native_Array.fromList;
var _elm_lang$core$Array$initialize = _elm_lang$core$Native_Array.initialize;
var _elm_lang$core$Array$repeat = F2(
	function (n, e) {
		return A2(
			_elm_lang$core$Array$initialize,
			n,
			_elm_lang$core$Basics$always(e));
	});
var _elm_lang$core$Array$Array = {ctor: 'Array'};

//import Native.Utils //

var _elm_lang$core$Native_Debug = function() {

function log(tag, value)
{
	var msg = tag + ': ' + _elm_lang$core$Native_Utils.toString(value);
	var process = process || {};
	if (process.stdout)
	{
		process.stdout.write(msg);
	}
	else
	{
		console.log(msg);
	}
	return value;
}

function crash(message)
{
	throw new Error(message);
}

return {
	crash: crash,
	log: F2(log)
};

}();
//import Maybe, Native.List, Native.Utils, Result //

var _elm_lang$core$Native_String = function() {

function isEmpty(str)
{
	return str.length === 0;
}
function cons(chr, str)
{
	return chr + str;
}
function uncons(str)
{
	var hd = str[0];
	if (hd)
	{
		return _elm_lang$core$Maybe$Just(_elm_lang$core$Native_Utils.Tuple2(_elm_lang$core$Native_Utils.chr(hd), str.slice(1)));
	}
	return _elm_lang$core$Maybe$Nothing;
}
function append(a, b)
{
	return a + b;
}
function concat(strs)
{
	return _elm_lang$core$Native_List.toArray(strs).join('');
}
function length(str)
{
	return str.length;
}
function map(f, str)
{
	var out = str.split('');
	for (var i = out.length; i--; )
	{
		out[i] = f(_elm_lang$core$Native_Utils.chr(out[i]));
	}
	return out.join('');
}
function filter(pred, str)
{
	return str.split('').map(_elm_lang$core$Native_Utils.chr).filter(pred).join('');
}
function reverse(str)
{
	return str.split('').reverse().join('');
}
function foldl(f, b, str)
{
	var len = str.length;
	for (var i = 0; i < len; ++i)
	{
		b = A2(f, _elm_lang$core$Native_Utils.chr(str[i]), b);
	}
	return b;
}
function foldr(f, b, str)
{
	for (var i = str.length; i--; )
	{
		b = A2(f, _elm_lang$core$Native_Utils.chr(str[i]), b);
	}
	return b;
}
function split(sep, str)
{
	return _elm_lang$core$Native_List.fromArray(str.split(sep));
}
function join(sep, strs)
{
	return _elm_lang$core$Native_List.toArray(strs).join(sep);
}
function repeat(n, str)
{
	var result = '';
	while (n > 0)
	{
		if (n & 1)
		{
			result += str;
		}
		n >>= 1, str += str;
	}
	return result;
}
function slice(start, end, str)
{
	return str.slice(start, end);
}
function left(n, str)
{
	return n < 1 ? '' : str.slice(0, n);
}
function right(n, str)
{
	return n < 1 ? '' : str.slice(-n);
}
function dropLeft(n, str)
{
	return n < 1 ? str : str.slice(n);
}
function dropRight(n, str)
{
	return n < 1 ? str : str.slice(0, -n);
}
function pad(n, chr, str)
{
	var half = (n - str.length) / 2;
	return repeat(Math.ceil(half), chr) + str + repeat(half | 0, chr);
}
function padRight(n, chr, str)
{
	return str + repeat(n - str.length, chr);
}
function padLeft(n, chr, str)
{
	return repeat(n - str.length, chr) + str;
}

function trim(str)
{
	return str.trim();
}
function trimLeft(str)
{
	return str.replace(/^\s+/, '');
}
function trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function words(str)
{
	return _elm_lang$core$Native_List.fromArray(str.trim().split(/\s+/g));
}
function lines(str)
{
	return _elm_lang$core$Native_List.fromArray(str.split(/\r\n|\r|\n/g));
}

function toUpper(str)
{
	return str.toUpperCase();
}
function toLower(str)
{
	return str.toLowerCase();
}

function any(pred, str)
{
	for (var i = str.length; i--; )
	{
		if (pred(_elm_lang$core$Native_Utils.chr(str[i])))
		{
			return true;
		}
	}
	return false;
}
function all(pred, str)
{
	for (var i = str.length; i--; )
	{
		if (!pred(_elm_lang$core$Native_Utils.chr(str[i])))
		{
			return false;
		}
	}
	return true;
}

function contains(sub, str)
{
	return str.indexOf(sub) > -1;
}
function startsWith(sub, str)
{
	return str.indexOf(sub) === 0;
}
function endsWith(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
}
function indexes(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _elm_lang$core$Native_List.Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _elm_lang$core$Native_List.fromArray(is);
}


function toInt(s)
{
	var len = s.length;

	// if empty
	if (len === 0)
	{
		return intErr(s);
	}

	// if hex
	var c = s[0];
	if (c === '0' && s[1] === 'x')
	{
		for (var i = 2; i < len; ++i)
		{
			var c = s[i];
			if (('0' <= c && c <= '9') || ('A' <= c && c <= 'F') || ('a' <= c && c <= 'f'))
			{
				continue;
			}
			return intErr(s);
		}
		return _elm_lang$core$Result$Ok(parseInt(s, 16));
	}

	// is decimal
	if (c > '9' || (c < '0' && c !== '-' && c !== '+'))
	{
		return intErr(s);
	}
	for (var i = 1; i < len; ++i)
	{
		var c = s[i];
		if (c < '0' || '9' < c)
		{
			return intErr(s);
		}
	}

	return _elm_lang$core$Result$Ok(parseInt(s, 10));
}

function intErr(s)
{
	return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int");
}


function toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return floatErr(s);
	}
	var n = +s;
	// faster isNaN check
	return n === n ? _elm_lang$core$Result$Ok(n) : floatErr(s);
}

function floatErr(s)
{
	return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float");
}


function toList(str)
{
	return _elm_lang$core$Native_List.fromArray(str.split('').map(_elm_lang$core$Native_Utils.chr));
}
function fromList(chars)
{
	return _elm_lang$core$Native_List.toArray(chars).join('');
}

return {
	isEmpty: isEmpty,
	cons: F2(cons),
	uncons: uncons,
	append: F2(append),
	concat: concat,
	length: length,
	map: F2(map),
	filter: F2(filter),
	reverse: reverse,
	foldl: F3(foldl),
	foldr: F3(foldr),

	split: F2(split),
	join: F2(join),
	repeat: F2(repeat),

	slice: F3(slice),
	left: F2(left),
	right: F2(right),
	dropLeft: F2(dropLeft),
	dropRight: F2(dropRight),

	pad: F3(pad),
	padLeft: F3(padLeft),
	padRight: F3(padRight),

	trim: trim,
	trimLeft: trimLeft,
	trimRight: trimRight,

	words: words,
	lines: lines,

	toUpper: toUpper,
	toLower: toLower,

	any: F2(any),
	all: F2(all),

	contains: F2(contains),
	startsWith: F2(startsWith),
	endsWith: F2(endsWith),
	indexes: F2(indexes),

	toInt: toInt,
	toFloat: toFloat,
	toList: toList,
	fromList: fromList
};

}();

//import Native.Utils //

var _elm_lang$core$Native_Char = function() {

return {
	fromCode: function(c) { return _elm_lang$core$Native_Utils.chr(String.fromCharCode(c)); },
	toCode: function(c) { return c.charCodeAt(0); },
	toUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toUpperCase()); },
	toLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLowerCase()); },
	toLocaleUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleUpperCase()); },
	toLocaleLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleLowerCase()); }
};

}();
var _elm_lang$core$Char$fromCode = _elm_lang$core$Native_Char.fromCode;
var _elm_lang$core$Char$toCode = _elm_lang$core$Native_Char.toCode;
var _elm_lang$core$Char$toLocaleLower = _elm_lang$core$Native_Char.toLocaleLower;
var _elm_lang$core$Char$toLocaleUpper = _elm_lang$core$Native_Char.toLocaleUpper;
var _elm_lang$core$Char$toLower = _elm_lang$core$Native_Char.toLower;
var _elm_lang$core$Char$toUpper = _elm_lang$core$Native_Char.toUpper;
var _elm_lang$core$Char$isBetween = F3(
	function (low, high, $char) {
		var code = _elm_lang$core$Char$toCode($char);
		return (_elm_lang$core$Native_Utils.cmp(
			code,
			_elm_lang$core$Char$toCode(low)) > -1) && (_elm_lang$core$Native_Utils.cmp(
			code,
			_elm_lang$core$Char$toCode(high)) < 1);
	});
var _elm_lang$core$Char$isUpper = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('A'),
	_elm_lang$core$Native_Utils.chr('Z'));
var _elm_lang$core$Char$isLower = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('a'),
	_elm_lang$core$Native_Utils.chr('z'));
var _elm_lang$core$Char$isDigit = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('0'),
	_elm_lang$core$Native_Utils.chr('9'));
var _elm_lang$core$Char$isOctDigit = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('0'),
	_elm_lang$core$Native_Utils.chr('7'));
var _elm_lang$core$Char$isHexDigit = function ($char) {
	return _elm_lang$core$Char$isDigit($char) || (A3(
		_elm_lang$core$Char$isBetween,
		_elm_lang$core$Native_Utils.chr('a'),
		_elm_lang$core$Native_Utils.chr('f'),
		$char) || A3(
		_elm_lang$core$Char$isBetween,
		_elm_lang$core$Native_Utils.chr('A'),
		_elm_lang$core$Native_Utils.chr('F'),
		$char));
};

var _elm_lang$core$Result$toMaybe = function (result) {
	var _p0 = result;
	if (_p0.ctor === 'Ok') {
		return _elm_lang$core$Maybe$Just(_p0._0);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$Result$withDefault = F2(
	function (def, result) {
		var _p1 = result;
		if (_p1.ctor === 'Ok') {
			return _p1._0;
		} else {
			return def;
		}
	});
var _elm_lang$core$Result$Err = function (a) {
	return {ctor: 'Err', _0: a};
};
var _elm_lang$core$Result$andThen = F2(
	function (callback, result) {
		var _p2 = result;
		if (_p2.ctor === 'Ok') {
			return callback(_p2._0);
		} else {
			return _elm_lang$core$Result$Err(_p2._0);
		}
	});
var _elm_lang$core$Result$Ok = function (a) {
	return {ctor: 'Ok', _0: a};
};
var _elm_lang$core$Result$map = F2(
	function (func, ra) {
		var _p3 = ra;
		if (_p3.ctor === 'Ok') {
			return _elm_lang$core$Result$Ok(
				func(_p3._0));
		} else {
			return _elm_lang$core$Result$Err(_p3._0);
		}
	});
var _elm_lang$core$Result$map2 = F3(
	function (func, ra, rb) {
		var _p4 = {ctor: '_Tuple2', _0: ra, _1: rb};
		if (_p4._0.ctor === 'Ok') {
			if (_p4._1.ctor === 'Ok') {
				return _elm_lang$core$Result$Ok(
					A2(func, _p4._0._0, _p4._1._0));
			} else {
				return _elm_lang$core$Result$Err(_p4._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p4._0._0);
		}
	});
var _elm_lang$core$Result$map3 = F4(
	function (func, ra, rb, rc) {
		var _p5 = {ctor: '_Tuple3', _0: ra, _1: rb, _2: rc};
		if (_p5._0.ctor === 'Ok') {
			if (_p5._1.ctor === 'Ok') {
				if (_p5._2.ctor === 'Ok') {
					return _elm_lang$core$Result$Ok(
						A3(func, _p5._0._0, _p5._1._0, _p5._2._0));
				} else {
					return _elm_lang$core$Result$Err(_p5._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p5._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p5._0._0);
		}
	});
var _elm_lang$core$Result$map4 = F5(
	function (func, ra, rb, rc, rd) {
		var _p6 = {ctor: '_Tuple4', _0: ra, _1: rb, _2: rc, _3: rd};
		if (_p6._0.ctor === 'Ok') {
			if (_p6._1.ctor === 'Ok') {
				if (_p6._2.ctor === 'Ok') {
					if (_p6._3.ctor === 'Ok') {
						return _elm_lang$core$Result$Ok(
							A4(func, _p6._0._0, _p6._1._0, _p6._2._0, _p6._3._0));
					} else {
						return _elm_lang$core$Result$Err(_p6._3._0);
					}
				} else {
					return _elm_lang$core$Result$Err(_p6._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p6._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p6._0._0);
		}
	});
var _elm_lang$core$Result$map5 = F6(
	function (func, ra, rb, rc, rd, re) {
		var _p7 = {ctor: '_Tuple5', _0: ra, _1: rb, _2: rc, _3: rd, _4: re};
		if (_p7._0.ctor === 'Ok') {
			if (_p7._1.ctor === 'Ok') {
				if (_p7._2.ctor === 'Ok') {
					if (_p7._3.ctor === 'Ok') {
						if (_p7._4.ctor === 'Ok') {
							return _elm_lang$core$Result$Ok(
								A5(func, _p7._0._0, _p7._1._0, _p7._2._0, _p7._3._0, _p7._4._0));
						} else {
							return _elm_lang$core$Result$Err(_p7._4._0);
						}
					} else {
						return _elm_lang$core$Result$Err(_p7._3._0);
					}
				} else {
					return _elm_lang$core$Result$Err(_p7._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p7._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p7._0._0);
		}
	});
var _elm_lang$core$Result$mapError = F2(
	function (f, result) {
		var _p8 = result;
		if (_p8.ctor === 'Ok') {
			return _elm_lang$core$Result$Ok(_p8._0);
		} else {
			return _elm_lang$core$Result$Err(
				f(_p8._0));
		}
	});
var _elm_lang$core$Result$fromMaybe = F2(
	function (err, maybe) {
		var _p9 = maybe;
		if (_p9.ctor === 'Just') {
			return _elm_lang$core$Result$Ok(_p9._0);
		} else {
			return _elm_lang$core$Result$Err(err);
		}
	});

var _elm_lang$core$String$fromList = _elm_lang$core$Native_String.fromList;
var _elm_lang$core$String$toList = _elm_lang$core$Native_String.toList;
var _elm_lang$core$String$toFloat = _elm_lang$core$Native_String.toFloat;
var _elm_lang$core$String$toInt = _elm_lang$core$Native_String.toInt;
var _elm_lang$core$String$indices = _elm_lang$core$Native_String.indexes;
var _elm_lang$core$String$indexes = _elm_lang$core$Native_String.indexes;
var _elm_lang$core$String$endsWith = _elm_lang$core$Native_String.endsWith;
var _elm_lang$core$String$startsWith = _elm_lang$core$Native_String.startsWith;
var _elm_lang$core$String$contains = _elm_lang$core$Native_String.contains;
var _elm_lang$core$String$all = _elm_lang$core$Native_String.all;
var _elm_lang$core$String$any = _elm_lang$core$Native_String.any;
var _elm_lang$core$String$toLower = _elm_lang$core$Native_String.toLower;
var _elm_lang$core$String$toUpper = _elm_lang$core$Native_String.toUpper;
var _elm_lang$core$String$lines = _elm_lang$core$Native_String.lines;
var _elm_lang$core$String$words = _elm_lang$core$Native_String.words;
var _elm_lang$core$String$trimRight = _elm_lang$core$Native_String.trimRight;
var _elm_lang$core$String$trimLeft = _elm_lang$core$Native_String.trimLeft;
var _elm_lang$core$String$trim = _elm_lang$core$Native_String.trim;
var _elm_lang$core$String$padRight = _elm_lang$core$Native_String.padRight;
var _elm_lang$core$String$padLeft = _elm_lang$core$Native_String.padLeft;
var _elm_lang$core$String$pad = _elm_lang$core$Native_String.pad;
var _elm_lang$core$String$dropRight = _elm_lang$core$Native_String.dropRight;
var _elm_lang$core$String$dropLeft = _elm_lang$core$Native_String.dropLeft;
var _elm_lang$core$String$right = _elm_lang$core$Native_String.right;
var _elm_lang$core$String$left = _elm_lang$core$Native_String.left;
var _elm_lang$core$String$slice = _elm_lang$core$Native_String.slice;
var _elm_lang$core$String$repeat = _elm_lang$core$Native_String.repeat;
var _elm_lang$core$String$join = _elm_lang$core$Native_String.join;
var _elm_lang$core$String$split = _elm_lang$core$Native_String.split;
var _elm_lang$core$String$foldr = _elm_lang$core$Native_String.foldr;
var _elm_lang$core$String$foldl = _elm_lang$core$Native_String.foldl;
var _elm_lang$core$String$reverse = _elm_lang$core$Native_String.reverse;
var _elm_lang$core$String$filter = _elm_lang$core$Native_String.filter;
var _elm_lang$core$String$map = _elm_lang$core$Native_String.map;
var _elm_lang$core$String$length = _elm_lang$core$Native_String.length;
var _elm_lang$core$String$concat = _elm_lang$core$Native_String.concat;
var _elm_lang$core$String$append = _elm_lang$core$Native_String.append;
var _elm_lang$core$String$uncons = _elm_lang$core$Native_String.uncons;
var _elm_lang$core$String$cons = _elm_lang$core$Native_String.cons;
var _elm_lang$core$String$fromChar = function ($char) {
	return A2(_elm_lang$core$String$cons, $char, '');
};
var _elm_lang$core$String$isEmpty = _elm_lang$core$Native_String.isEmpty;

var _elm_lang$core$Dict$foldr = F3(
	function (f, acc, t) {
		foldr:
		while (true) {
			var _p0 = t;
			if (_p0.ctor === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var _v1 = f,
					_v2 = A3(
					f,
					_p0._1,
					_p0._2,
					A3(_elm_lang$core$Dict$foldr, f, acc, _p0._4)),
					_v3 = _p0._3;
				f = _v1;
				acc = _v2;
				t = _v3;
				continue foldr;
			}
		}
	});
var _elm_lang$core$Dict$keys = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return {ctor: '::', _0: key, _1: keyList};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$values = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return {ctor: '::', _0: value, _1: valueList};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$toList = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: key, _1: value},
					_1: list
				};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$foldl = F3(
	function (f, acc, dict) {
		foldl:
		while (true) {
			var _p1 = dict;
			if (_p1.ctor === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var _v5 = f,
					_v6 = A3(
					f,
					_p1._1,
					_p1._2,
					A3(_elm_lang$core$Dict$foldl, f, acc, _p1._3)),
					_v7 = _p1._4;
				f = _v5;
				acc = _v6;
				dict = _v7;
				continue foldl;
			}
		}
	});
var _elm_lang$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _p2) {
				stepState:
				while (true) {
					var _p3 = _p2;
					var _p9 = _p3._1;
					var _p8 = _p3._0;
					var _p4 = _p8;
					if (_p4.ctor === '[]') {
						return {
							ctor: '_Tuple2',
							_0: _p8,
							_1: A3(rightStep, rKey, rValue, _p9)
						};
					} else {
						var _p7 = _p4._1;
						var _p6 = _p4._0._1;
						var _p5 = _p4._0._0;
						if (_elm_lang$core$Native_Utils.cmp(_p5, rKey) < 0) {
							var _v10 = rKey,
								_v11 = rValue,
								_v12 = {
								ctor: '_Tuple2',
								_0: _p7,
								_1: A3(leftStep, _p5, _p6, _p9)
							};
							rKey = _v10;
							rValue = _v11;
							_p2 = _v12;
							continue stepState;
						} else {
							if (_elm_lang$core$Native_Utils.cmp(_p5, rKey) > 0) {
								return {
									ctor: '_Tuple2',
									_0: _p8,
									_1: A3(rightStep, rKey, rValue, _p9)
								};
							} else {
								return {
									ctor: '_Tuple2',
									_0: _p7,
									_1: A4(bothStep, _p5, _p6, rValue, _p9)
								};
							}
						}
					}
				}
			});
		var _p10 = A3(
			_elm_lang$core$Dict$foldl,
			stepState,
			{
				ctor: '_Tuple2',
				_0: _elm_lang$core$Dict$toList(leftDict),
				_1: initialResult
			},
			rightDict);
		var leftovers = _p10._0;
		var intermediateResult = _p10._1;
		return A3(
			_elm_lang$core$List$foldl,
			F2(
				function (_p11, result) {
					var _p12 = _p11;
					return A3(leftStep, _p12._0, _p12._1, result);
				}),
			intermediateResult,
			leftovers);
	});
var _elm_lang$core$Dict$reportRemBug = F4(
	function (msg, c, lgot, rgot) {
		return _elm_lang$core$Native_Debug.crash(
			_elm_lang$core$String$concat(
				{
					ctor: '::',
					_0: 'Internal red-black tree invariant violated, expected ',
					_1: {
						ctor: '::',
						_0: msg,
						_1: {
							ctor: '::',
							_0: ' and got ',
							_1: {
								ctor: '::',
								_0: _elm_lang$core$Basics$toString(c),
								_1: {
									ctor: '::',
									_0: '/',
									_1: {
										ctor: '::',
										_0: lgot,
										_1: {
											ctor: '::',
											_0: '/',
											_1: {
												ctor: '::',
												_0: rgot,
												_1: {
													ctor: '::',
													_0: '\nPlease report this bug to <https://github.com/elm-lang/core/issues>',
													_1: {ctor: '[]'}
												}
											}
										}
									}
								}
							}
						}
					}
				}));
	});
var _elm_lang$core$Dict$isBBlack = function (dict) {
	var _p13 = dict;
	_v14_2:
	do {
		if (_p13.ctor === 'RBNode_elm_builtin') {
			if (_p13._0.ctor === 'BBlack') {
				return true;
			} else {
				break _v14_2;
			}
		} else {
			if (_p13._0.ctor === 'LBBlack') {
				return true;
			} else {
				break _v14_2;
			}
		}
	} while(false);
	return false;
};
var _elm_lang$core$Dict$sizeHelp = F2(
	function (n, dict) {
		sizeHelp:
		while (true) {
			var _p14 = dict;
			if (_p14.ctor === 'RBEmpty_elm_builtin') {
				return n;
			} else {
				var _v16 = A2(_elm_lang$core$Dict$sizeHelp, n + 1, _p14._4),
					_v17 = _p14._3;
				n = _v16;
				dict = _v17;
				continue sizeHelp;
			}
		}
	});
var _elm_lang$core$Dict$size = function (dict) {
	return A2(_elm_lang$core$Dict$sizeHelp, 0, dict);
};
var _elm_lang$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			var _p15 = dict;
			if (_p15.ctor === 'RBEmpty_elm_builtin') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				var _p16 = A2(_elm_lang$core$Basics$compare, targetKey, _p15._1);
				switch (_p16.ctor) {
					case 'LT':
						var _v20 = targetKey,
							_v21 = _p15._3;
						targetKey = _v20;
						dict = _v21;
						continue get;
					case 'EQ':
						return _elm_lang$core$Maybe$Just(_p15._2);
					default:
						var _v22 = targetKey,
							_v23 = _p15._4;
						targetKey = _v22;
						dict = _v23;
						continue get;
				}
			}
		}
	});
var _elm_lang$core$Dict$member = F2(
	function (key, dict) {
		var _p17 = A2(_elm_lang$core$Dict$get, key, dict);
		if (_p17.ctor === 'Just') {
			return true;
		} else {
			return false;
		}
	});
var _elm_lang$core$Dict$maxWithDefault = F3(
	function (k, v, r) {
		maxWithDefault:
		while (true) {
			var _p18 = r;
			if (_p18.ctor === 'RBEmpty_elm_builtin') {
				return {ctor: '_Tuple2', _0: k, _1: v};
			} else {
				var _v26 = _p18._1,
					_v27 = _p18._2,
					_v28 = _p18._4;
				k = _v26;
				v = _v27;
				r = _v28;
				continue maxWithDefault;
			}
		}
	});
var _elm_lang$core$Dict$NBlack = {ctor: 'NBlack'};
var _elm_lang$core$Dict$BBlack = {ctor: 'BBlack'};
var _elm_lang$core$Dict$Black = {ctor: 'Black'};
var _elm_lang$core$Dict$blackish = function (t) {
	var _p19 = t;
	if (_p19.ctor === 'RBNode_elm_builtin') {
		var _p20 = _p19._0;
		return _elm_lang$core$Native_Utils.eq(_p20, _elm_lang$core$Dict$Black) || _elm_lang$core$Native_Utils.eq(_p20, _elm_lang$core$Dict$BBlack);
	} else {
		return true;
	}
};
var _elm_lang$core$Dict$Red = {ctor: 'Red'};
var _elm_lang$core$Dict$moreBlack = function (color) {
	var _p21 = color;
	switch (_p21.ctor) {
		case 'Black':
			return _elm_lang$core$Dict$BBlack;
		case 'Red':
			return _elm_lang$core$Dict$Black;
		case 'NBlack':
			return _elm_lang$core$Dict$Red;
		default:
			return _elm_lang$core$Native_Debug.crash('Can\'t make a double black node more black!');
	}
};
var _elm_lang$core$Dict$lessBlack = function (color) {
	var _p22 = color;
	switch (_p22.ctor) {
		case 'BBlack':
			return _elm_lang$core$Dict$Black;
		case 'Black':
			return _elm_lang$core$Dict$Red;
		case 'Red':
			return _elm_lang$core$Dict$NBlack;
		default:
			return _elm_lang$core$Native_Debug.crash('Can\'t make a negative black node less black!');
	}
};
var _elm_lang$core$Dict$LBBlack = {ctor: 'LBBlack'};
var _elm_lang$core$Dict$LBlack = {ctor: 'LBlack'};
var _elm_lang$core$Dict$RBEmpty_elm_builtin = function (a) {
	return {ctor: 'RBEmpty_elm_builtin', _0: a};
};
var _elm_lang$core$Dict$empty = _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
var _elm_lang$core$Dict$isEmpty = function (dict) {
	return _elm_lang$core$Native_Utils.eq(dict, _elm_lang$core$Dict$empty);
};
var _elm_lang$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {ctor: 'RBNode_elm_builtin', _0: a, _1: b, _2: c, _3: d, _4: e};
	});
var _elm_lang$core$Dict$ensureBlackRoot = function (dict) {
	var _p23 = dict;
	if ((_p23.ctor === 'RBNode_elm_builtin') && (_p23._0.ctor === 'Red')) {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p23._1, _p23._2, _p23._3, _p23._4);
	} else {
		return dict;
	}
};
var _elm_lang$core$Dict$lessBlackTree = function (dict) {
	var _p24 = dict;
	if (_p24.ctor === 'RBNode_elm_builtin') {
		return A5(
			_elm_lang$core$Dict$RBNode_elm_builtin,
			_elm_lang$core$Dict$lessBlack(_p24._0),
			_p24._1,
			_p24._2,
			_p24._3,
			_p24._4);
	} else {
		return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
	}
};
var _elm_lang$core$Dict$balancedTree = function (col) {
	return function (xk) {
		return function (xv) {
			return function (yk) {
				return function (yv) {
					return function (zk) {
						return function (zv) {
							return function (a) {
								return function (b) {
									return function (c) {
										return function (d) {
											return A5(
												_elm_lang$core$Dict$RBNode_elm_builtin,
												_elm_lang$core$Dict$lessBlack(col),
												yk,
												yv,
												A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, xk, xv, a, b),
												A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, zk, zv, c, d));
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var _elm_lang$core$Dict$blacken = function (t) {
	var _p25 = t;
	if (_p25.ctor === 'RBEmpty_elm_builtin') {
		return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
	} else {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p25._1, _p25._2, _p25._3, _p25._4);
	}
};
var _elm_lang$core$Dict$redden = function (t) {
	var _p26 = t;
	if (_p26.ctor === 'RBEmpty_elm_builtin') {
		return _elm_lang$core$Native_Debug.crash('can\'t make a Leaf red');
	} else {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Red, _p26._1, _p26._2, _p26._3, _p26._4);
	}
};
var _elm_lang$core$Dict$balanceHelp = function (tree) {
	var _p27 = tree;
	_v36_6:
	do {
		_v36_5:
		do {
			_v36_4:
			do {
				_v36_3:
				do {
					_v36_2:
					do {
						_v36_1:
						do {
							_v36_0:
							do {
								if (_p27.ctor === 'RBNode_elm_builtin') {
									if (_p27._3.ctor === 'RBNode_elm_builtin') {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._3._0.ctor) {
												case 'Red':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																		break _v36_2;
																	} else {
																		if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																			break _v36_3;
																		} else {
																			break _v36_6;
																		}
																	}
																}
															}
														case 'NBlack':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																		break _v36_4;
																	} else {
																		break _v36_6;
																	}
																}
															}
														default:
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	break _v36_6;
																}
															}
													}
												case 'NBlack':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v36_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v36_3;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v36_5;
																	} else {
																		break _v36_6;
																	}
																}
															}
														case 'NBlack':
															if (_p27._0.ctor === 'BBlack') {
																if ((((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																	break _v36_4;
																} else {
																	if ((((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v36_5;
																	} else {
																		break _v36_6;
																	}
																}
															} else {
																break _v36_6;
															}
														default:
															if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																break _v36_5;
															} else {
																break _v36_6;
															}
													}
												default:
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v36_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v36_3;
																} else {
																	break _v36_6;
																}
															}
														case 'NBlack':
															if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																break _v36_4;
															} else {
																break _v36_6;
															}
														default:
															break _v36_6;
													}
											}
										} else {
											switch (_p27._3._0.ctor) {
												case 'Red':
													if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
														break _v36_0;
													} else {
														if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
															break _v36_1;
														} else {
															break _v36_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
														break _v36_5;
													} else {
														break _v36_6;
													}
												default:
													break _v36_6;
											}
										}
									} else {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._4._0.ctor) {
												case 'Red':
													if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
														break _v36_2;
													} else {
														if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
															break _v36_3;
														} else {
															break _v36_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
														break _v36_4;
													} else {
														break _v36_6;
													}
												default:
													break _v36_6;
											}
										} else {
											break _v36_6;
										}
									}
								} else {
									break _v36_6;
								}
							} while(false);
							return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._3._3._1)(_p27._3._3._2)(_p27._3._1)(_p27._3._2)(_p27._1)(_p27._2)(_p27._3._3._3)(_p27._3._3._4)(_p27._3._4)(_p27._4);
						} while(false);
						return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._3._1)(_p27._3._2)(_p27._3._4._1)(_p27._3._4._2)(_p27._1)(_p27._2)(_p27._3._3)(_p27._3._4._3)(_p27._3._4._4)(_p27._4);
					} while(false);
					return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._1)(_p27._2)(_p27._4._3._1)(_p27._4._3._2)(_p27._4._1)(_p27._4._2)(_p27._3)(_p27._4._3._3)(_p27._4._3._4)(_p27._4._4);
				} while(false);
				return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._1)(_p27._2)(_p27._4._1)(_p27._4._2)(_p27._4._4._1)(_p27._4._4._2)(_p27._3)(_p27._4._3)(_p27._4._4._3)(_p27._4._4._4);
			} while(false);
			return A5(
				_elm_lang$core$Dict$RBNode_elm_builtin,
				_elm_lang$core$Dict$Black,
				_p27._4._3._1,
				_p27._4._3._2,
				A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p27._1, _p27._2, _p27._3, _p27._4._3._3),
				A5(
					_elm_lang$core$Dict$balance,
					_elm_lang$core$Dict$Black,
					_p27._4._1,
					_p27._4._2,
					_p27._4._3._4,
					_elm_lang$core$Dict$redden(_p27._4._4)));
		} while(false);
		return A5(
			_elm_lang$core$Dict$RBNode_elm_builtin,
			_elm_lang$core$Dict$Black,
			_p27._3._4._1,
			_p27._3._4._2,
			A5(
				_elm_lang$core$Dict$balance,
				_elm_lang$core$Dict$Black,
				_p27._3._1,
				_p27._3._2,
				_elm_lang$core$Dict$redden(_p27._3._3),
				_p27._3._4._3),
			A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p27._1, _p27._2, _p27._3._4._4, _p27._4));
	} while(false);
	return tree;
};
var _elm_lang$core$Dict$balance = F5(
	function (c, k, v, l, r) {
		var tree = A5(_elm_lang$core$Dict$RBNode_elm_builtin, c, k, v, l, r);
		return _elm_lang$core$Dict$blackish(tree) ? _elm_lang$core$Dict$balanceHelp(tree) : tree;
	});
var _elm_lang$core$Dict$bubble = F5(
	function (c, k, v, l, r) {
		return (_elm_lang$core$Dict$isBBlack(l) || _elm_lang$core$Dict$isBBlack(r)) ? A5(
			_elm_lang$core$Dict$balance,
			_elm_lang$core$Dict$moreBlack(c),
			k,
			v,
			_elm_lang$core$Dict$lessBlackTree(l),
			_elm_lang$core$Dict$lessBlackTree(r)) : A5(_elm_lang$core$Dict$RBNode_elm_builtin, c, k, v, l, r);
	});
var _elm_lang$core$Dict$removeMax = F5(
	function (c, k, v, l, r) {
		var _p28 = r;
		if (_p28.ctor === 'RBEmpty_elm_builtin') {
			return A3(_elm_lang$core$Dict$rem, c, l, r);
		} else {
			return A5(
				_elm_lang$core$Dict$bubble,
				c,
				k,
				v,
				l,
				A5(_elm_lang$core$Dict$removeMax, _p28._0, _p28._1, _p28._2, _p28._3, _p28._4));
		}
	});
var _elm_lang$core$Dict$rem = F3(
	function (color, left, right) {
		var _p29 = {ctor: '_Tuple2', _0: left, _1: right};
		if (_p29._0.ctor === 'RBEmpty_elm_builtin') {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p30 = color;
				switch (_p30.ctor) {
					case 'Red':
						return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
					case 'Black':
						return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBBlack);
					default:
						return _elm_lang$core$Native_Debug.crash('cannot have bblack or nblack nodes at this point');
				}
			} else {
				var _p33 = _p29._1._0;
				var _p32 = _p29._0._0;
				var _p31 = {ctor: '_Tuple3', _0: color, _1: _p32, _2: _p33};
				if ((((_p31.ctor === '_Tuple3') && (_p31._0.ctor === 'Black')) && (_p31._1.ctor === 'LBlack')) && (_p31._2.ctor === 'Red')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._1._1, _p29._1._2, _p29._1._3, _p29._1._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/LBlack/Red',
						color,
						_elm_lang$core$Basics$toString(_p32),
						_elm_lang$core$Basics$toString(_p33));
				}
			}
		} else {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p36 = _p29._1._0;
				var _p35 = _p29._0._0;
				var _p34 = {ctor: '_Tuple3', _0: color, _1: _p35, _2: _p36};
				if ((((_p34.ctor === '_Tuple3') && (_p34._0.ctor === 'Black')) && (_p34._1.ctor === 'Red')) && (_p34._2.ctor === 'LBlack')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._0._1, _p29._0._2, _p29._0._3, _p29._0._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/Red/LBlack',
						color,
						_elm_lang$core$Basics$toString(_p35),
						_elm_lang$core$Basics$toString(_p36));
				}
			} else {
				var _p40 = _p29._0._2;
				var _p39 = _p29._0._4;
				var _p38 = _p29._0._1;
				var newLeft = A5(_elm_lang$core$Dict$removeMax, _p29._0._0, _p38, _p40, _p29._0._3, _p39);
				var _p37 = A3(_elm_lang$core$Dict$maxWithDefault, _p38, _p40, _p39);
				var k = _p37._0;
				var v = _p37._1;
				return A5(_elm_lang$core$Dict$bubble, color, k, v, newLeft, right);
			}
		}
	});
var _elm_lang$core$Dict$map = F2(
	function (f, dict) {
		var _p41 = dict;
		if (_p41.ctor === 'RBEmpty_elm_builtin') {
			return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
		} else {
			var _p42 = _p41._1;
			return A5(
				_elm_lang$core$Dict$RBNode_elm_builtin,
				_p41._0,
				_p42,
				A2(f, _p42, _p41._2),
				A2(_elm_lang$core$Dict$map, f, _p41._3),
				A2(_elm_lang$core$Dict$map, f, _p41._4));
		}
	});
var _elm_lang$core$Dict$Same = {ctor: 'Same'};
var _elm_lang$core$Dict$Remove = {ctor: 'Remove'};
var _elm_lang$core$Dict$Insert = {ctor: 'Insert'};
var _elm_lang$core$Dict$update = F3(
	function (k, alter, dict) {
		var up = function (dict) {
			var _p43 = dict;
			if (_p43.ctor === 'RBEmpty_elm_builtin') {
				var _p44 = alter(_elm_lang$core$Maybe$Nothing);
				if (_p44.ctor === 'Nothing') {
					return {ctor: '_Tuple2', _0: _elm_lang$core$Dict$Same, _1: _elm_lang$core$Dict$empty};
				} else {
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Dict$Insert,
						_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Red, k, _p44._0, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty)
					};
				}
			} else {
				var _p55 = _p43._2;
				var _p54 = _p43._4;
				var _p53 = _p43._3;
				var _p52 = _p43._1;
				var _p51 = _p43._0;
				var _p45 = A2(_elm_lang$core$Basics$compare, k, _p52);
				switch (_p45.ctor) {
					case 'EQ':
						var _p46 = alter(
							_elm_lang$core$Maybe$Just(_p55));
						if (_p46.ctor === 'Nothing') {
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Dict$Remove,
								_1: A3(_elm_lang$core$Dict$rem, _p51, _p53, _p54)
							};
						} else {
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Dict$Same,
								_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p46._0, _p53, _p54)
							};
						}
					case 'LT':
						var _p47 = up(_p53);
						var flag = _p47._0;
						var newLeft = _p47._1;
						var _p48 = flag;
						switch (_p48.ctor) {
							case 'Same':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Same,
									_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p55, newLeft, _p54)
								};
							case 'Insert':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Insert,
									_1: A5(_elm_lang$core$Dict$balance, _p51, _p52, _p55, newLeft, _p54)
								};
							default:
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Remove,
									_1: A5(_elm_lang$core$Dict$bubble, _p51, _p52, _p55, newLeft, _p54)
								};
						}
					default:
						var _p49 = up(_p54);
						var flag = _p49._0;
						var newRight = _p49._1;
						var _p50 = flag;
						switch (_p50.ctor) {
							case 'Same':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Same,
									_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p55, _p53, newRight)
								};
							case 'Insert':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Insert,
									_1: A5(_elm_lang$core$Dict$balance, _p51, _p52, _p55, _p53, newRight)
								};
							default:
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Remove,
									_1: A5(_elm_lang$core$Dict$bubble, _p51, _p52, _p55, _p53, newRight)
								};
						}
				}
			}
		};
		var _p56 = up(dict);
		var flag = _p56._0;
		var updatedDict = _p56._1;
		var _p57 = flag;
		switch (_p57.ctor) {
			case 'Same':
				return updatedDict;
			case 'Insert':
				return _elm_lang$core$Dict$ensureBlackRoot(updatedDict);
			default:
				return _elm_lang$core$Dict$blacken(updatedDict);
		}
	});
var _elm_lang$core$Dict$insert = F3(
	function (key, value, dict) {
		return A3(
			_elm_lang$core$Dict$update,
			key,
			_elm_lang$core$Basics$always(
				_elm_lang$core$Maybe$Just(value)),
			dict);
	});
var _elm_lang$core$Dict$singleton = F2(
	function (key, value) {
		return A3(_elm_lang$core$Dict$insert, key, value, _elm_lang$core$Dict$empty);
	});
var _elm_lang$core$Dict$union = F2(
	function (t1, t2) {
		return A3(_elm_lang$core$Dict$foldl, _elm_lang$core$Dict$insert, t2, t1);
	});
var _elm_lang$core$Dict$filter = F2(
	function (predicate, dictionary) {
		var add = F3(
			function (key, value, dict) {
				return A2(predicate, key, value) ? A3(_elm_lang$core$Dict$insert, key, value, dict) : dict;
			});
		return A3(_elm_lang$core$Dict$foldl, add, _elm_lang$core$Dict$empty, dictionary);
	});
var _elm_lang$core$Dict$intersect = F2(
	function (t1, t2) {
		return A2(
			_elm_lang$core$Dict$filter,
			F2(
				function (k, _p58) {
					return A2(_elm_lang$core$Dict$member, k, t2);
				}),
			t1);
	});
var _elm_lang$core$Dict$partition = F2(
	function (predicate, dict) {
		var add = F3(
			function (key, value, _p59) {
				var _p60 = _p59;
				var _p62 = _p60._1;
				var _p61 = _p60._0;
				return A2(predicate, key, value) ? {
					ctor: '_Tuple2',
					_0: A3(_elm_lang$core$Dict$insert, key, value, _p61),
					_1: _p62
				} : {
					ctor: '_Tuple2',
					_0: _p61,
					_1: A3(_elm_lang$core$Dict$insert, key, value, _p62)
				};
			});
		return A3(
			_elm_lang$core$Dict$foldl,
			add,
			{ctor: '_Tuple2', _0: _elm_lang$core$Dict$empty, _1: _elm_lang$core$Dict$empty},
			dict);
	});
var _elm_lang$core$Dict$fromList = function (assocs) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (_p63, dict) {
				var _p64 = _p63;
				return A3(_elm_lang$core$Dict$insert, _p64._0, _p64._1, dict);
			}),
		_elm_lang$core$Dict$empty,
		assocs);
};
var _elm_lang$core$Dict$remove = F2(
	function (key, dict) {
		return A3(
			_elm_lang$core$Dict$update,
			key,
			_elm_lang$core$Basics$always(_elm_lang$core$Maybe$Nothing),
			dict);
	});
var _elm_lang$core$Dict$diff = F2(
	function (t1, t2) {
		return A3(
			_elm_lang$core$Dict$foldl,
			F3(
				function (k, v, t) {
					return A2(_elm_lang$core$Dict$remove, k, t);
				}),
			t1,
			t2);
	});

//import Maybe, Native.Array, Native.List, Native.Utils, Result //

var _elm_lang$core$Native_Json = function() {


// CORE DECODERS

function succeed(msg)
{
	return {
		ctor: '<decoder>',
		tag: 'succeed',
		msg: msg
	};
}

function fail(msg)
{
	return {
		ctor: '<decoder>',
		tag: 'fail',
		msg: msg
	};
}

function decodePrimitive(tag)
{
	return {
		ctor: '<decoder>',
		tag: tag
	};
}

function decodeContainer(tag, decoder)
{
	return {
		ctor: '<decoder>',
		tag: tag,
		decoder: decoder
	};
}

function decodeNull(value)
{
	return {
		ctor: '<decoder>',
		tag: 'null',
		value: value
	};
}

function decodeField(field, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'field',
		field: field,
		decoder: decoder
	};
}

function decodeIndex(index, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'index',
		index: index,
		decoder: decoder
	};
}

function decodeKeyValuePairs(decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'key-value',
		decoder: decoder
	};
}

function mapMany(f, decoders)
{
	return {
		ctor: '<decoder>',
		tag: 'map-many',
		func: f,
		decoders: decoders
	};
}

function andThen(callback, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'andThen',
		decoder: decoder,
		callback: callback
	};
}

function oneOf(decoders)
{
	return {
		ctor: '<decoder>',
		tag: 'oneOf',
		decoders: decoders
	};
}


// DECODING OBJECTS

function map1(f, d1)
{
	return mapMany(f, [d1]);
}

function map2(f, d1, d2)
{
	return mapMany(f, [d1, d2]);
}

function map3(f, d1, d2, d3)
{
	return mapMany(f, [d1, d2, d3]);
}

function map4(f, d1, d2, d3, d4)
{
	return mapMany(f, [d1, d2, d3, d4]);
}

function map5(f, d1, d2, d3, d4, d5)
{
	return mapMany(f, [d1, d2, d3, d4, d5]);
}

function map6(f, d1, d2, d3, d4, d5, d6)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6]);
}

function map7(f, d1, d2, d3, d4, d5, d6, d7)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
}

function map8(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
}


// DECODE HELPERS

function ok(value)
{
	return { tag: 'ok', value: value };
}

function badPrimitive(type, value)
{
	return { tag: 'primitive', type: type, value: value };
}

function badIndex(index, nestedProblems)
{
	return { tag: 'index', index: index, rest: nestedProblems };
}

function badField(field, nestedProblems)
{
	return { tag: 'field', field: field, rest: nestedProblems };
}

function badIndex(index, nestedProblems)
{
	return { tag: 'index', index: index, rest: nestedProblems };
}

function badOneOf(problems)
{
	return { tag: 'oneOf', problems: problems };
}

function bad(msg)
{
	return { tag: 'fail', msg: msg };
}

function badToString(problem)
{
	var context = '_';
	while (problem)
	{
		switch (problem.tag)
		{
			case 'primitive':
				return 'Expecting ' + problem.type
					+ (context === '_' ? '' : ' at ' + context)
					+ ' but instead got: ' + jsToString(problem.value);

			case 'index':
				context += '[' + problem.index + ']';
				problem = problem.rest;
				break;

			case 'field':
				context += '.' + problem.field;
				problem = problem.rest;
				break;

			case 'oneOf':
				var problems = problem.problems;
				for (var i = 0; i < problems.length; i++)
				{
					problems[i] = badToString(problems[i]);
				}
				return 'I ran into the following problems'
					+ (context === '_' ? '' : ' at ' + context)
					+ ':\n\n' + problems.join('\n');

			case 'fail':
				return 'I ran into a `fail` decoder'
					+ (context === '_' ? '' : ' at ' + context)
					+ ': ' + problem.msg;
		}
	}
}

function jsToString(value)
{
	return value === undefined
		? 'undefined'
		: JSON.stringify(value);
}


// DECODE

function runOnString(decoder, string)
{
	var json;
	try
	{
		json = JSON.parse(string);
	}
	catch (e)
	{
		return _elm_lang$core$Result$Err('Given an invalid JSON: ' + e.message);
	}
	return run(decoder, json);
}

function run(decoder, value)
{
	var result = runHelp(decoder, value);
	return (result.tag === 'ok')
		? _elm_lang$core$Result$Ok(result.value)
		: _elm_lang$core$Result$Err(badToString(result));
}

function runHelp(decoder, value)
{
	switch (decoder.tag)
	{
		case 'bool':
			return (typeof value === 'boolean')
				? ok(value)
				: badPrimitive('a Bool', value);

		case 'int':
			if (typeof value !== 'number') {
				return badPrimitive('an Int', value);
			}

			if (-2147483647 < value && value < 2147483647 && (value | 0) === value) {
				return ok(value);
			}

			if (isFinite(value) && !(value % 1)) {
				return ok(value);
			}

			return badPrimitive('an Int', value);

		case 'float':
			return (typeof value === 'number')
				? ok(value)
				: badPrimitive('a Float', value);

		case 'string':
			return (typeof value === 'string')
				? ok(value)
				: (value instanceof String)
					? ok(value + '')
					: badPrimitive('a String', value);

		case 'null':
			return (value === null)
				? ok(decoder.value)
				: badPrimitive('null', value);

		case 'value':
			return ok(value);

		case 'list':
			if (!(value instanceof Array))
			{
				return badPrimitive('a List', value);
			}

			var list = _elm_lang$core$Native_List.Nil;
			for (var i = value.length; i--; )
			{
				var result = runHelp(decoder.decoder, value[i]);
				if (result.tag !== 'ok')
				{
					return badIndex(i, result)
				}
				list = _elm_lang$core$Native_List.Cons(result.value, list);
			}
			return ok(list);

		case 'array':
			if (!(value instanceof Array))
			{
				return badPrimitive('an Array', value);
			}

			var len = value.length;
			var array = new Array(len);
			for (var i = len; i--; )
			{
				var result = runHelp(decoder.decoder, value[i]);
				if (result.tag !== 'ok')
				{
					return badIndex(i, result);
				}
				array[i] = result.value;
			}
			return ok(_elm_lang$core$Native_Array.fromJSArray(array));

		case 'maybe':
			var result = runHelp(decoder.decoder, value);
			return (result.tag === 'ok')
				? ok(_elm_lang$core$Maybe$Just(result.value))
				: ok(_elm_lang$core$Maybe$Nothing);

		case 'field':
			var field = decoder.field;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return badPrimitive('an object with a field named `' + field + '`', value);
			}

			var result = runHelp(decoder.decoder, value[field]);
			return (result.tag === 'ok') ? result : badField(field, result);

		case 'index':
			var index = decoder.index;
			if (!(value instanceof Array))
			{
				return badPrimitive('an array', value);
			}
			if (index >= value.length)
			{
				return badPrimitive('a longer array. Need index ' + index + ' but there are only ' + value.length + ' entries', value);
			}

			var result = runHelp(decoder.decoder, value[index]);
			return (result.tag === 'ok') ? result : badIndex(index, result);

		case 'key-value':
			if (typeof value !== 'object' || value === null || value instanceof Array)
			{
				return badPrimitive('an object', value);
			}

			var keyValuePairs = _elm_lang$core$Native_List.Nil;
			for (var key in value)
			{
				var result = runHelp(decoder.decoder, value[key]);
				if (result.tag !== 'ok')
				{
					return badField(key, result);
				}
				var pair = _elm_lang$core$Native_Utils.Tuple2(key, result.value);
				keyValuePairs = _elm_lang$core$Native_List.Cons(pair, keyValuePairs);
			}
			return ok(keyValuePairs);

		case 'map-many':
			var answer = decoder.func;
			var decoders = decoder.decoders;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = runHelp(decoders[i], value);
				if (result.tag !== 'ok')
				{
					return result;
				}
				answer = answer(result.value);
			}
			return ok(answer);

		case 'andThen':
			var result = runHelp(decoder.decoder, value);
			return (result.tag !== 'ok')
				? result
				: runHelp(decoder.callback(result.value), value);

		case 'oneOf':
			var errors = [];
			var temp = decoder.decoders;
			while (temp.ctor !== '[]')
			{
				var result = runHelp(temp._0, value);

				if (result.tag === 'ok')
				{
					return result;
				}

				errors.push(result);

				temp = temp._1;
			}
			return badOneOf(errors);

		case 'fail':
			return bad(decoder.msg);

		case 'succeed':
			return ok(decoder.msg);
	}
}


// EQUALITY

function equality(a, b)
{
	if (a === b)
	{
		return true;
	}

	if (a.tag !== b.tag)
	{
		return false;
	}

	switch (a.tag)
	{
		case 'succeed':
		case 'fail':
			return a.msg === b.msg;

		case 'bool':
		case 'int':
		case 'float':
		case 'string':
		case 'value':
			return true;

		case 'null':
			return a.value === b.value;

		case 'list':
		case 'array':
		case 'maybe':
		case 'key-value':
			return equality(a.decoder, b.decoder);

		case 'field':
			return a.field === b.field && equality(a.decoder, b.decoder);

		case 'index':
			return a.index === b.index && equality(a.decoder, b.decoder);

		case 'map-many':
			if (a.func !== b.func)
			{
				return false;
			}
			return listEquality(a.decoders, b.decoders);

		case 'andThen':
			return a.callback === b.callback && equality(a.decoder, b.decoder);

		case 'oneOf':
			return listEquality(a.decoders, b.decoders);
	}
}

function listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

function encode(indentLevel, value)
{
	return JSON.stringify(value, null, indentLevel);
}

function identity(value)
{
	return value;
}

function encodeObject(keyValuePairs)
{
	var obj = {};
	while (keyValuePairs.ctor !== '[]')
	{
		var pair = keyValuePairs._0;
		obj[pair._0] = pair._1;
		keyValuePairs = keyValuePairs._1;
	}
	return obj;
}

return {
	encode: F2(encode),
	runOnString: F2(runOnString),
	run: F2(run),

	decodeNull: decodeNull,
	decodePrimitive: decodePrimitive,
	decodeContainer: F2(decodeContainer),

	decodeField: F2(decodeField),
	decodeIndex: F2(decodeIndex),

	map1: F2(map1),
	map2: F3(map2),
	map3: F4(map3),
	map4: F5(map4),
	map5: F6(map5),
	map6: F7(map6),
	map7: F8(map7),
	map8: F9(map8),
	decodeKeyValuePairs: decodeKeyValuePairs,

	andThen: F2(andThen),
	fail: fail,
	succeed: succeed,
	oneOf: oneOf,

	identity: identity,
	encodeNull: null,
	encodeArray: _elm_lang$core$Native_Array.toJSArray,
	encodeList: _elm_lang$core$Native_List.toArray,
	encodeObject: encodeObject,

	equality: equality
};

}();

var _elm_lang$core$Json_Encode$list = _elm_lang$core$Native_Json.encodeList;
var _elm_lang$core$Json_Encode$array = _elm_lang$core$Native_Json.encodeArray;
var _elm_lang$core$Json_Encode$object = _elm_lang$core$Native_Json.encodeObject;
var _elm_lang$core$Json_Encode$null = _elm_lang$core$Native_Json.encodeNull;
var _elm_lang$core$Json_Encode$bool = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$float = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$int = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$string = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$encode = _elm_lang$core$Native_Json.encode;
var _elm_lang$core$Json_Encode$Value = {ctor: 'Value'};

var _elm_lang$core$Json_Decode$null = _elm_lang$core$Native_Json.decodeNull;
var _elm_lang$core$Json_Decode$value = _elm_lang$core$Native_Json.decodePrimitive('value');
var _elm_lang$core$Json_Decode$andThen = _elm_lang$core$Native_Json.andThen;
var _elm_lang$core$Json_Decode$fail = _elm_lang$core$Native_Json.fail;
var _elm_lang$core$Json_Decode$succeed = _elm_lang$core$Native_Json.succeed;
var _elm_lang$core$Json_Decode$lazy = function (thunk) {
	return A2(
		_elm_lang$core$Json_Decode$andThen,
		thunk,
		_elm_lang$core$Json_Decode$succeed(
			{ctor: '_Tuple0'}));
};
var _elm_lang$core$Json_Decode$decodeValue = _elm_lang$core$Native_Json.run;
var _elm_lang$core$Json_Decode$decodeString = _elm_lang$core$Native_Json.runOnString;
var _elm_lang$core$Json_Decode$map8 = _elm_lang$core$Native_Json.map8;
var _elm_lang$core$Json_Decode$map7 = _elm_lang$core$Native_Json.map7;
var _elm_lang$core$Json_Decode$map6 = _elm_lang$core$Native_Json.map6;
var _elm_lang$core$Json_Decode$map5 = _elm_lang$core$Native_Json.map5;
var _elm_lang$core$Json_Decode$map4 = _elm_lang$core$Native_Json.map4;
var _elm_lang$core$Json_Decode$map3 = _elm_lang$core$Native_Json.map3;
var _elm_lang$core$Json_Decode$map2 = _elm_lang$core$Native_Json.map2;
var _elm_lang$core$Json_Decode$map = _elm_lang$core$Native_Json.map1;
var _elm_lang$core$Json_Decode$oneOf = _elm_lang$core$Native_Json.oneOf;
var _elm_lang$core$Json_Decode$maybe = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'maybe', decoder);
};
var _elm_lang$core$Json_Decode$index = _elm_lang$core$Native_Json.decodeIndex;
var _elm_lang$core$Json_Decode$field = _elm_lang$core$Native_Json.decodeField;
var _elm_lang$core$Json_Decode$at = F2(
	function (fields, decoder) {
		return A3(_elm_lang$core$List$foldr, _elm_lang$core$Json_Decode$field, decoder, fields);
	});
var _elm_lang$core$Json_Decode$keyValuePairs = _elm_lang$core$Native_Json.decodeKeyValuePairs;
var _elm_lang$core$Json_Decode$dict = function (decoder) {
	return A2(
		_elm_lang$core$Json_Decode$map,
		_elm_lang$core$Dict$fromList,
		_elm_lang$core$Json_Decode$keyValuePairs(decoder));
};
var _elm_lang$core$Json_Decode$array = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'array', decoder);
};
var _elm_lang$core$Json_Decode$list = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'list', decoder);
};
var _elm_lang$core$Json_Decode$nullable = function (decoder) {
	return _elm_lang$core$Json_Decode$oneOf(
		{
			ctor: '::',
			_0: _elm_lang$core$Json_Decode$null(_elm_lang$core$Maybe$Nothing),
			_1: {
				ctor: '::',
				_0: A2(_elm_lang$core$Json_Decode$map, _elm_lang$core$Maybe$Just, decoder),
				_1: {ctor: '[]'}
			}
		});
};
var _elm_lang$core$Json_Decode$float = _elm_lang$core$Native_Json.decodePrimitive('float');
var _elm_lang$core$Json_Decode$int = _elm_lang$core$Native_Json.decodePrimitive('int');
var _elm_lang$core$Json_Decode$bool = _elm_lang$core$Native_Json.decodePrimitive('bool');
var _elm_lang$core$Json_Decode$string = _elm_lang$core$Native_Json.decodePrimitive('string');
var _elm_lang$core$Json_Decode$Decoder = {ctor: 'Decoder'};

var _elm_lang$dom$Native_Dom = function() {

var fakeNode = {
	addEventListener: function() {},
	removeEventListener: function() {}
};

var onDocument = on(typeof document !== 'undefined' ? document : fakeNode);
var onWindow = on(typeof window !== 'undefined' ? window : fakeNode);

function on(node)
{
	return function(eventName, decoder, toTask)
	{
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {

			function performTask(event)
			{
				var result = A2(_elm_lang$core$Json_Decode$decodeValue, decoder, event);
				if (result.ctor === 'Ok')
				{
					_elm_lang$core$Native_Scheduler.rawSpawn(toTask(result._0));
				}
			}

			node.addEventListener(eventName, performTask);

			return function()
			{
				node.removeEventListener(eventName, performTask);
			};
		});
	};
}

var rAF = typeof requestAnimationFrame !== 'undefined'
	? requestAnimationFrame
	: function(callback) { callback(); };

function withNode(id, doStuff)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		rAF(function()
		{
			var node = document.getElementById(id);
			if (node === null)
			{
				callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'NotFound', _0: id }));
				return;
			}
			callback(_elm_lang$core$Native_Scheduler.succeed(doStuff(node)));
		});
	});
}


// FOCUS

function focus(id)
{
	return withNode(id, function(node) {
		node.focus();
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}

function blur(id)
{
	return withNode(id, function(node) {
		node.blur();
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}


// SCROLLING

function getScrollTop(id)
{
	return withNode(id, function(node) {
		return node.scrollTop;
	});
}

function setScrollTop(id, desiredScrollTop)
{
	return withNode(id, function(node) {
		node.scrollTop = desiredScrollTop;
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}

function toBottom(id)
{
	return withNode(id, function(node) {
		node.scrollTop = node.scrollHeight;
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}

function getScrollLeft(id)
{
	return withNode(id, function(node) {
		return node.scrollLeft;
	});
}

function setScrollLeft(id, desiredScrollLeft)
{
	return withNode(id, function(node) {
		node.scrollLeft = desiredScrollLeft;
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}

function toRight(id)
{
	return withNode(id, function(node) {
		node.scrollLeft = node.scrollWidth;
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}


// SIZE

function width(options, id)
{
	return withNode(id, function(node) {
		switch (options.ctor)
		{
			case 'Content':
				return node.scrollWidth;
			case 'VisibleContent':
				return node.clientWidth;
			case 'VisibleContentWithBorders':
				return node.offsetWidth;
			case 'VisibleContentWithBordersAndMargins':
				var rect = node.getBoundingClientRect();
				return rect.right - rect.left;
		}
	});
}

function height(options, id)
{
	return withNode(id, function(node) {
		switch (options.ctor)
		{
			case 'Content':
				return node.scrollHeight;
			case 'VisibleContent':
				return node.clientHeight;
			case 'VisibleContentWithBorders':
				return node.offsetHeight;
			case 'VisibleContentWithBordersAndMargins':
				var rect = node.getBoundingClientRect();
				return rect.bottom - rect.top;
		}
	});
}

return {
	onDocument: F3(onDocument),
	onWindow: F3(onWindow),

	focus: focus,
	blur: blur,

	getScrollTop: getScrollTop,
	setScrollTop: F2(setScrollTop),
	getScrollLeft: getScrollLeft,
	setScrollLeft: F2(setScrollLeft),
	toBottom: toBottom,
	toRight: toRight,

	height: F2(height),
	width: F2(width)
};

}();

//import Native.Utils //

var _elm_lang$core$Native_Scheduler = function() {

var MAX_STEPS = 10000;


// TASKS

function succeed(value)
{
	return {
		ctor: '_Task_succeed',
		value: value
	};
}

function fail(error)
{
	return {
		ctor: '_Task_fail',
		value: error
	};
}

function nativeBinding(callback)
{
	return {
		ctor: '_Task_nativeBinding',
		callback: callback,
		cancel: null
	};
}

function andThen(callback, task)
{
	return {
		ctor: '_Task_andThen',
		callback: callback,
		task: task
	};
}

function onError(callback, task)
{
	return {
		ctor: '_Task_onError',
		callback: callback,
		task: task
	};
}

function receive(callback)
{
	return {
		ctor: '_Task_receive',
		callback: callback
	};
}


// PROCESSES

function rawSpawn(task)
{
	var process = {
		ctor: '_Process',
		id: _elm_lang$core$Native_Utils.guid(),
		root: task,
		stack: null,
		mailbox: []
	};

	enqueue(process);

	return process;
}

function spawn(task)
{
	return nativeBinding(function(callback) {
		var process = rawSpawn(task);
		callback(succeed(process));
	});
}

function rawSend(process, msg)
{
	process.mailbox.push(msg);
	enqueue(process);
}

function send(process, msg)
{
	return nativeBinding(function(callback) {
		rawSend(process, msg);
		callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function kill(process)
{
	return nativeBinding(function(callback) {
		var root = process.root;
		if (root.ctor === '_Task_nativeBinding' && root.cancel)
		{
			root.cancel();
		}

		process.root = null;

		callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function sleep(time)
{
	return nativeBinding(function(callback) {
		var id = setTimeout(function() {
			callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}


// STEP PROCESSES

function step(numSteps, process)
{
	while (numSteps < MAX_STEPS)
	{
		var ctor = process.root.ctor;

		if (ctor === '_Task_succeed')
		{
			while (process.stack && process.stack.ctor === '_Task_onError')
			{
				process.stack = process.stack.rest;
			}
			if (process.stack === null)
			{
				break;
			}
			process.root = process.stack.callback(process.root.value);
			process.stack = process.stack.rest;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_fail')
		{
			while (process.stack && process.stack.ctor === '_Task_andThen')
			{
				process.stack = process.stack.rest;
			}
			if (process.stack === null)
			{
				break;
			}
			process.root = process.stack.callback(process.root.value);
			process.stack = process.stack.rest;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_andThen')
		{
			process.stack = {
				ctor: '_Task_andThen',
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_onError')
		{
			process.stack = {
				ctor: '_Task_onError',
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_nativeBinding')
		{
			process.root.cancel = process.root.callback(function(newRoot) {
				process.root = newRoot;
				enqueue(process);
			});

			break;
		}

		if (ctor === '_Task_receive')
		{
			var mailbox = process.mailbox;
			if (mailbox.length === 0)
			{
				break;
			}

			process.root = process.root.callback(mailbox.shift());
			++numSteps;
			continue;
		}

		throw new Error(ctor);
	}

	if (numSteps < MAX_STEPS)
	{
		return numSteps + 1;
	}
	enqueue(process);

	return numSteps;
}


// WORK QUEUE

var working = false;
var workQueue = [];

function enqueue(process)
{
	workQueue.push(process);

	if (!working)
	{
		setTimeout(work, 0);
		working = true;
	}
}

function work()
{
	var numSteps = 0;
	var process;
	while (numSteps < MAX_STEPS && (process = workQueue.shift()))
	{
		if (process.root)
		{
			numSteps = step(numSteps, process);
		}
	}
	if (!process)
	{
		working = false;
		return;
	}
	setTimeout(work, 0);
}


return {
	succeed: succeed,
	fail: fail,
	nativeBinding: nativeBinding,
	andThen: F2(andThen),
	onError: F2(onError),
	receive: receive,

	spawn: spawn,
	kill: kill,
	sleep: sleep,
	send: F2(send),

	rawSpawn: rawSpawn,
	rawSend: rawSend
};

}();
//import //

var _elm_lang$core$Native_Platform = function() {


// PROGRAMS

function program(impl)
{
	return function(flagDecoder)
	{
		return function(object, moduleName)
		{
			object['worker'] = function worker(flags)
			{
				if (typeof flags !== 'undefined')
				{
					throw new Error(
						'The `' + moduleName + '` module does not need flags.\n'
						+ 'Call ' + moduleName + '.worker() with no arguments and you should be all set!'
					);
				}

				return initialize(
					impl.init,
					impl.update,
					impl.subscriptions,
					renderer
				);
			};
		};
	};
}

function programWithFlags(impl)
{
	return function(flagDecoder)
	{
		return function(object, moduleName)
		{
			object['worker'] = function worker(flags)
			{
				if (typeof flagDecoder === 'undefined')
				{
					throw new Error(
						'Are you trying to sneak a Never value into Elm? Trickster!\n'
						+ 'It looks like ' + moduleName + '.main is defined with `programWithFlags` but has type `Program Never`.\n'
						+ 'Use `program` instead if you do not want flags.'
					);
				}

				var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
				if (result.ctor === 'Err')
				{
					throw new Error(
						moduleName + '.worker(...) was called with an unexpected argument.\n'
						+ 'I tried to convert it to an Elm value, but ran into this problem:\n\n'
						+ result._0
					);
				}

				return initialize(
					impl.init(result._0),
					impl.update,
					impl.subscriptions,
					renderer
				);
			};
		};
	};
}

function renderer(enqueue, _)
{
	return function(_) {};
}


// HTML TO PROGRAM

function htmlToProgram(vnode)
{
	var emptyBag = batch(_elm_lang$core$Native_List.Nil);
	var noChange = _elm_lang$core$Native_Utils.Tuple2(
		_elm_lang$core$Native_Utils.Tuple0,
		emptyBag
	);

	return _elm_lang$virtual_dom$VirtualDom$program({
		init: noChange,
		view: function(model) { return main; },
		update: F2(function(msg, model) { return noChange; }),
		subscriptions: function (model) { return emptyBag; }
	});
}


// INITIALIZE A PROGRAM

function initialize(init, update, subscriptions, renderer)
{
	// ambient state
	var managers = {};
	var updateView;

	// init and update state in main process
	var initApp = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		var model = init._0;
		updateView = renderer(enqueue, model);
		var cmds = init._1;
		var subs = subscriptions(model);
		dispatchEffects(managers, cmds, subs);
		callback(_elm_lang$core$Native_Scheduler.succeed(model));
	});

	function onMessage(msg, model)
	{
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
			var results = A2(update, msg, model);
			model = results._0;
			updateView(model);
			var cmds = results._1;
			var subs = subscriptions(model);
			dispatchEffects(managers, cmds, subs);
			callback(_elm_lang$core$Native_Scheduler.succeed(model));
		});
	}

	var mainProcess = spawnLoop(initApp, onMessage);

	function enqueue(msg)
	{
		_elm_lang$core$Native_Scheduler.rawSend(mainProcess, msg);
	}

	var ports = setupEffects(managers, enqueue);

	return ports ? { ports: ports } : {};
}


// EFFECT MANAGERS

var effectManagers = {};

function setupEffects(managers, callback)
{
	var ports;

	// setup all necessary effect managers
	for (var key in effectManagers)
	{
		var manager = effectManagers[key];

		if (manager.isForeign)
		{
			ports = ports || {};
			ports[key] = manager.tag === 'cmd'
				? setupOutgoingPort(key)
				: setupIncomingPort(key, callback);
		}

		managers[key] = makeManager(manager, callback);
	}

	return ports;
}

function makeManager(info, callback)
{
	var router = {
		main: callback,
		self: undefined
	};

	var tag = info.tag;
	var onEffects = info.onEffects;
	var onSelfMsg = info.onSelfMsg;

	function onMessage(msg, state)
	{
		if (msg.ctor === 'self')
		{
			return A3(onSelfMsg, router, msg._0, state);
		}

		var fx = msg._0;
		switch (tag)
		{
			case 'cmd':
				return A3(onEffects, router, fx.cmds, state);

			case 'sub':
				return A3(onEffects, router, fx.subs, state);

			case 'fx':
				return A4(onEffects, router, fx.cmds, fx.subs, state);
		}
	}

	var process = spawnLoop(info.init, onMessage);
	router.self = process;
	return process;
}

function sendToApp(router, msg)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		router.main(msg);
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function sendToSelf(router, msg)
{
	return A2(_elm_lang$core$Native_Scheduler.send, router.self, {
		ctor: 'self',
		_0: msg
	});
}


// HELPER for STATEFUL LOOPS

function spawnLoop(init, onMessage)
{
	var andThen = _elm_lang$core$Native_Scheduler.andThen;

	function loop(state)
	{
		var handleMsg = _elm_lang$core$Native_Scheduler.receive(function(msg) {
			return onMessage(msg, state);
		});
		return A2(andThen, loop, handleMsg);
	}

	var task = A2(andThen, loop, init);

	return _elm_lang$core$Native_Scheduler.rawSpawn(task);
}


// BAGS

function leaf(home)
{
	return function(value)
	{
		return {
			type: 'leaf',
			home: home,
			value: value
		};
	};
}

function batch(list)
{
	return {
		type: 'node',
		branches: list
	};
}

function map(tagger, bag)
{
	return {
		type: 'map',
		tagger: tagger,
		tree: bag
	}
}


// PIPE BAGS INTO EFFECT MANAGERS

function dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	gatherEffects(true, cmdBag, effectsDict, null);
	gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		var fx = home in effectsDict
			? effectsDict[home]
			: {
				cmds: _elm_lang$core$Native_List.Nil,
				subs: _elm_lang$core$Native_List.Nil
			};

		_elm_lang$core$Native_Scheduler.rawSend(managers[home], { ctor: 'fx', _0: fx });
	}
}

function gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.type)
	{
		case 'leaf':
			var home = bag.home;
			var effect = toEffect(isCmd, home, taggers, bag.value);
			effectsDict[home] = insert(isCmd, effect, effectsDict[home]);
			return;

		case 'node':
			var list = bag.branches;
			while (list.ctor !== '[]')
			{
				gatherEffects(isCmd, list._0, effectsDict, taggers);
				list = list._1;
			}
			return;

		case 'map':
			gatherEffects(isCmd, bag.tree, effectsDict, {
				tagger: bag.tagger,
				rest: taggers
			});
			return;
	}
}

function toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		var temp = taggers;
		while (temp)
		{
			x = temp.tagger(x);
			temp = temp.rest;
		}
		return x;
	}

	var map = isCmd
		? effectManagers[home].cmdMap
		: effectManagers[home].subMap;

	return A2(map, applyTaggers, value)
}

function insert(isCmd, newEffect, effects)
{
	effects = effects || {
		cmds: _elm_lang$core$Native_List.Nil,
		subs: _elm_lang$core$Native_List.Nil
	};
	if (isCmd)
	{
		effects.cmds = _elm_lang$core$Native_List.Cons(newEffect, effects.cmds);
		return effects;
	}
	effects.subs = _elm_lang$core$Native_List.Cons(newEffect, effects.subs);
	return effects;
}


// PORTS

function checkPortName(name)
{
	if (name in effectManagers)
	{
		throw new Error('There can only be one port named `' + name + '`, but your program has multiple.');
	}
}


// OUTGOING PORTS

function outgoingPort(name, converter)
{
	checkPortName(name);
	effectManagers[name] = {
		tag: 'cmd',
		cmdMap: outgoingPortMap,
		converter: converter,
		isForeign: true
	};
	return leaf(name);
}

var outgoingPortMap = F2(function cmdMap(tagger, value) {
	return value;
});

function setupOutgoingPort(name)
{
	var subs = [];
	var converter = effectManagers[name].converter;

	// CREATE MANAGER

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function onEffects(router, cmdList, state)
	{
		while (cmdList.ctor !== '[]')
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = converter(cmdList._0);
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
			cmdList = cmdList._1;
		}
		return init;
	}

	effectManagers[name].init = init;
	effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}


// INCOMING PORTS

function incomingPort(name, converter)
{
	checkPortName(name);
	effectManagers[name] = {
		tag: 'sub',
		subMap: incomingPortMap,
		converter: converter,
		isForeign: true
	};
	return leaf(name);
}

var incomingPortMap = F2(function subMap(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});

function setupIncomingPort(name, callback)
{
	var sentBeforeInit = [];
	var subs = _elm_lang$core$Native_List.Nil;
	var converter = effectManagers[name].converter;
	var currentOnEffects = preInitOnEffects;
	var currentSend = preInitSend;

	// CREATE MANAGER

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function preInitOnEffects(router, subList, state)
	{
		var postInitResult = postInitOnEffects(router, subList, state);

		for(var i = 0; i < sentBeforeInit.length; i++)
		{
			postInitSend(sentBeforeInit[i]);
		}

		sentBeforeInit = null; // to release objects held in queue
		currentSend = postInitSend;
		currentOnEffects = postInitOnEffects;
		return postInitResult;
	}

	function postInitOnEffects(router, subList, state)
	{
		subs = subList;
		return init;
	}

	function onEffects(router, subList, state)
	{
		return currentOnEffects(router, subList, state);
	}

	effectManagers[name].init = init;
	effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function preInitSend(value)
	{
		sentBeforeInit.push(value);
	}

	function postInitSend(value)
	{
		var temp = subs;
		while (temp.ctor !== '[]')
		{
			callback(temp._0(value));
			temp = temp._1;
		}
	}

	function send(incomingValue)
	{
		var result = A2(_elm_lang$core$Json_Decode$decodeValue, converter, incomingValue);
		if (result.ctor === 'Err')
		{
			throw new Error('Trying to send an unexpected type of value through port `' + name + '`:\n' + result._0);
		}

		currentSend(result._0);
	}

	return { send: send };
}

return {
	// routers
	sendToApp: F2(sendToApp),
	sendToSelf: F2(sendToSelf),

	// global setup
	effectManagers: effectManagers,
	outgoingPort: outgoingPort,
	incomingPort: incomingPort,

	htmlToProgram: htmlToProgram,
	program: program,
	programWithFlags: programWithFlags,
	initialize: initialize,

	// effect bags
	leaf: leaf,
	batch: batch,
	map: F2(map)
};

}();

var _elm_lang$core$Platform_Cmd$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Cmd$none = _elm_lang$core$Platform_Cmd$batch(
	{ctor: '[]'});
var _elm_lang$core$Platform_Cmd_ops = _elm_lang$core$Platform_Cmd_ops || {};
_elm_lang$core$Platform_Cmd_ops['!'] = F2(
	function (model, commands) {
		return {
			ctor: '_Tuple2',
			_0: model,
			_1: _elm_lang$core$Platform_Cmd$batch(commands)
		};
	});
var _elm_lang$core$Platform_Cmd$map = _elm_lang$core$Native_Platform.map;
var _elm_lang$core$Platform_Cmd$Cmd = {ctor: 'Cmd'};

var _elm_lang$core$Platform_Sub$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Sub$none = _elm_lang$core$Platform_Sub$batch(
	{ctor: '[]'});
var _elm_lang$core$Platform_Sub$map = _elm_lang$core$Native_Platform.map;
var _elm_lang$core$Platform_Sub$Sub = {ctor: 'Sub'};

var _elm_lang$core$Platform$hack = _elm_lang$core$Native_Scheduler.succeed;
var _elm_lang$core$Platform$sendToSelf = _elm_lang$core$Native_Platform.sendToSelf;
var _elm_lang$core$Platform$sendToApp = _elm_lang$core$Native_Platform.sendToApp;
var _elm_lang$core$Platform$programWithFlags = _elm_lang$core$Native_Platform.programWithFlags;
var _elm_lang$core$Platform$program = _elm_lang$core$Native_Platform.program;
var _elm_lang$core$Platform$Program = {ctor: 'Program'};
var _elm_lang$core$Platform$Task = {ctor: 'Task'};
var _elm_lang$core$Platform$ProcessId = {ctor: 'ProcessId'};
var _elm_lang$core$Platform$Router = {ctor: 'Router'};

var _elm_lang$core$Task$onError = _elm_lang$core$Native_Scheduler.onError;
var _elm_lang$core$Task$andThen = _elm_lang$core$Native_Scheduler.andThen;
var _elm_lang$core$Task$spawnCmd = F2(
	function (router, _p0) {
		var _p1 = _p0;
		return _elm_lang$core$Native_Scheduler.spawn(
			A2(
				_elm_lang$core$Task$andThen,
				_elm_lang$core$Platform$sendToApp(router),
				_p1._0));
	});
var _elm_lang$core$Task$fail = _elm_lang$core$Native_Scheduler.fail;
var _elm_lang$core$Task$mapError = F2(
	function (convert, task) {
		return A2(
			_elm_lang$core$Task$onError,
			function (_p2) {
				return _elm_lang$core$Task$fail(
					convert(_p2));
			},
			task);
	});
var _elm_lang$core$Task$succeed = _elm_lang$core$Native_Scheduler.succeed;
var _elm_lang$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return _elm_lang$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var _elm_lang$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (b) {
						return _elm_lang$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var _elm_lang$core$Task$map3 = F4(
	function (func, taskA, taskB, taskC) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (b) {
						return A2(
							_elm_lang$core$Task$andThen,
							function (c) {
								return _elm_lang$core$Task$succeed(
									A3(func, a, b, c));
							},
							taskC);
					},
					taskB);
			},
			taskA);
	});
var _elm_lang$core$Task$map4 = F5(
	function (func, taskA, taskB, taskC, taskD) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (b) {
						return A2(
							_elm_lang$core$Task$andThen,
							function (c) {
								return A2(
									_elm_lang$core$Task$andThen,
									function (d) {
										return _elm_lang$core$Task$succeed(
											A4(func, a, b, c, d));
									},
									taskD);
							},
							taskC);
					},
					taskB);
			},
			taskA);
	});
var _elm_lang$core$Task$map5 = F6(
	function (func, taskA, taskB, taskC, taskD, taskE) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (b) {
						return A2(
							_elm_lang$core$Task$andThen,
							function (c) {
								return A2(
									_elm_lang$core$Task$andThen,
									function (d) {
										return A2(
											_elm_lang$core$Task$andThen,
											function (e) {
												return _elm_lang$core$Task$succeed(
													A5(func, a, b, c, d, e));
											},
											taskE);
									},
									taskD);
							},
							taskC);
					},
					taskB);
			},
			taskA);
	});
var _elm_lang$core$Task$sequence = function (tasks) {
	var _p3 = tasks;
	if (_p3.ctor === '[]') {
		return _elm_lang$core$Task$succeed(
			{ctor: '[]'});
	} else {
		return A3(
			_elm_lang$core$Task$map2,
			F2(
				function (x, y) {
					return {ctor: '::', _0: x, _1: y};
				}),
			_p3._0,
			_elm_lang$core$Task$sequence(_p3._1));
	}
};
var _elm_lang$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			_elm_lang$core$Task$map,
			function (_p4) {
				return {ctor: '_Tuple0'};
			},
			_elm_lang$core$Task$sequence(
				A2(
					_elm_lang$core$List$map,
					_elm_lang$core$Task$spawnCmd(router),
					commands)));
	});
var _elm_lang$core$Task$init = _elm_lang$core$Task$succeed(
	{ctor: '_Tuple0'});
var _elm_lang$core$Task$onSelfMsg = F3(
	function (_p7, _p6, _p5) {
		return _elm_lang$core$Task$succeed(
			{ctor: '_Tuple0'});
	});
var _elm_lang$core$Task$command = _elm_lang$core$Native_Platform.leaf('Task');
var _elm_lang$core$Task$Perform = function (a) {
	return {ctor: 'Perform', _0: a};
};
var _elm_lang$core$Task$perform = F2(
	function (toMessage, task) {
		return _elm_lang$core$Task$command(
			_elm_lang$core$Task$Perform(
				A2(_elm_lang$core$Task$map, toMessage, task)));
	});
var _elm_lang$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return _elm_lang$core$Task$command(
			_elm_lang$core$Task$Perform(
				A2(
					_elm_lang$core$Task$onError,
					function (_p8) {
						return _elm_lang$core$Task$succeed(
							resultToMessage(
								_elm_lang$core$Result$Err(_p8)));
					},
					A2(
						_elm_lang$core$Task$andThen,
						function (_p9) {
							return _elm_lang$core$Task$succeed(
								resultToMessage(
									_elm_lang$core$Result$Ok(_p9)));
						},
						task))));
	});
var _elm_lang$core$Task$cmdMap = F2(
	function (tagger, _p10) {
		var _p11 = _p10;
		return _elm_lang$core$Task$Perform(
			A2(_elm_lang$core$Task$map, tagger, _p11._0));
	});
_elm_lang$core$Native_Platform.effectManagers['Task'] = {pkg: 'elm-lang/core', init: _elm_lang$core$Task$init, onEffects: _elm_lang$core$Task$onEffects, onSelfMsg: _elm_lang$core$Task$onSelfMsg, tag: 'cmd', cmdMap: _elm_lang$core$Task$cmdMap};

var _elm_lang$core$Debug$crash = _elm_lang$core$Native_Debug.crash;
var _elm_lang$core$Debug$log = _elm_lang$core$Native_Debug.log;

var _elm_lang$core$Tuple$mapSecond = F2(
	function (func, _p0) {
		var _p1 = _p0;
		return {
			ctor: '_Tuple2',
			_0: _p1._0,
			_1: func(_p1._1)
		};
	});
var _elm_lang$core$Tuple$mapFirst = F2(
	function (func, _p2) {
		var _p3 = _p2;
		return {
			ctor: '_Tuple2',
			_0: func(_p3._0),
			_1: _p3._1
		};
	});
var _elm_lang$core$Tuple$second = function (_p4) {
	var _p5 = _p4;
	return _p5._1;
};
var _elm_lang$core$Tuple$first = function (_p6) {
	var _p7 = _p6;
	return _p7._0;
};

var _elm_lang$dom$Dom_LowLevel$onWindow = _elm_lang$dom$Native_Dom.onWindow;
var _elm_lang$dom$Dom_LowLevel$onDocument = _elm_lang$dom$Native_Dom.onDocument;

var _elm_lang$virtual_dom$VirtualDom_Debug$wrap;
var _elm_lang$virtual_dom$VirtualDom_Debug$wrapWithFlags;

var _elm_lang$virtual_dom$Native_VirtualDom = function() {

var STYLE_KEY = 'STYLE';
var EVENT_KEY = 'EVENT';
var ATTR_KEY = 'ATTR';
var ATTR_NS_KEY = 'ATTR_NS';

var localDoc = typeof document !== 'undefined' ? document : {};


////////////  VIRTUAL DOM NODES  ////////////


function text(string)
{
	return {
		type: 'text',
		text: string
	};
}


function node(tag)
{
	return F2(function(factList, kidList) {
		return nodeHelp(tag, factList, kidList);
	});
}


function nodeHelp(tag, factList, kidList)
{
	var organized = organizeFacts(factList);
	var namespace = organized.namespace;
	var facts = organized.facts;

	var children = [];
	var descendantsCount = 0;
	while (kidList.ctor !== '[]')
	{
		var kid = kidList._0;
		descendantsCount += (kid.descendantsCount || 0);
		children.push(kid);
		kidList = kidList._1;
	}
	descendantsCount += children.length;

	return {
		type: 'node',
		tag: tag,
		facts: facts,
		children: children,
		namespace: namespace,
		descendantsCount: descendantsCount
	};
}


function keyedNode(tag, factList, kidList)
{
	var organized = organizeFacts(factList);
	var namespace = organized.namespace;
	var facts = organized.facts;

	var children = [];
	var descendantsCount = 0;
	while (kidList.ctor !== '[]')
	{
		var kid = kidList._0;
		descendantsCount += (kid._1.descendantsCount || 0);
		children.push(kid);
		kidList = kidList._1;
	}
	descendantsCount += children.length;

	return {
		type: 'keyed-node',
		tag: tag,
		facts: facts,
		children: children,
		namespace: namespace,
		descendantsCount: descendantsCount
	};
}


function custom(factList, model, impl)
{
	var facts = organizeFacts(factList).facts;

	return {
		type: 'custom',
		facts: facts,
		model: model,
		impl: impl
	};
}


function map(tagger, node)
{
	return {
		type: 'tagger',
		tagger: tagger,
		node: node,
		descendantsCount: 1 + (node.descendantsCount || 0)
	};
}


function thunk(func, args, thunk)
{
	return {
		type: 'thunk',
		func: func,
		args: args,
		thunk: thunk,
		node: undefined
	};
}

function lazy(fn, a)
{
	return thunk(fn, [a], function() {
		return fn(a);
	});
}

function lazy2(fn, a, b)
{
	return thunk(fn, [a,b], function() {
		return A2(fn, a, b);
	});
}

function lazy3(fn, a, b, c)
{
	return thunk(fn, [a,b,c], function() {
		return A3(fn, a, b, c);
	});
}



// FACTS


function organizeFacts(factList)
{
	var namespace, facts = {};

	while (factList.ctor !== '[]')
	{
		var entry = factList._0;
		var key = entry.key;

		if (key === ATTR_KEY || key === ATTR_NS_KEY || key === EVENT_KEY)
		{
			var subFacts = facts[key] || {};
			subFacts[entry.realKey] = entry.value;
			facts[key] = subFacts;
		}
		else if (key === STYLE_KEY)
		{
			var styles = facts[key] || {};
			var styleList = entry.value;
			while (styleList.ctor !== '[]')
			{
				var style = styleList._0;
				styles[style._0] = style._1;
				styleList = styleList._1;
			}
			facts[key] = styles;
		}
		else if (key === 'namespace')
		{
			namespace = entry.value;
		}
		else if (key === 'className')
		{
			var classes = facts[key];
			facts[key] = typeof classes === 'undefined'
				? entry.value
				: classes + ' ' + entry.value;
		}
 		else
		{
			facts[key] = entry.value;
		}
		factList = factList._1;
	}

	return {
		facts: facts,
		namespace: namespace
	};
}



////////////  PROPERTIES AND ATTRIBUTES  ////////////


function style(value)
{
	return {
		key: STYLE_KEY,
		value: value
	};
}


function property(key, value)
{
	return {
		key: key,
		value: value
	};
}


function attribute(key, value)
{
	return {
		key: ATTR_KEY,
		realKey: key,
		value: value
	};
}


function attributeNS(namespace, key, value)
{
	return {
		key: ATTR_NS_KEY,
		realKey: key,
		value: {
			value: value,
			namespace: namespace
		}
	};
}


function on(name, options, decoder)
{
	return {
		key: EVENT_KEY,
		realKey: name,
		value: {
			options: options,
			decoder: decoder
		}
	};
}


function equalEvents(a, b)
{
	if (a.options !== b.options)
	{
		if (a.options.stopPropagation !== b.options.stopPropagation || a.options.preventDefault !== b.options.preventDefault)
		{
			return false;
		}
	}
	return _elm_lang$core$Native_Json.equality(a.decoder, b.decoder);
}


function mapProperty(func, property)
{
	if (property.key !== EVENT_KEY)
	{
		return property;
	}
	return on(
		property.realKey,
		property.value.options,
		A2(_elm_lang$core$Json_Decode$map, func, property.value.decoder)
	);
}


////////////  RENDER  ////////////


function render(vNode, eventNode)
{
	switch (vNode.type)
	{
		case 'thunk':
			if (!vNode.node)
			{
				vNode.node = vNode.thunk();
			}
			return render(vNode.node, eventNode);

		case 'tagger':
			var subNode = vNode.node;
			var tagger = vNode.tagger;

			while (subNode.type === 'tagger')
			{
				typeof tagger !== 'object'
					? tagger = [tagger, subNode.tagger]
					: tagger.push(subNode.tagger);

				subNode = subNode.node;
			}

			var subEventRoot = { tagger: tagger, parent: eventNode };
			var domNode = render(subNode, subEventRoot);
			domNode.elm_event_node_ref = subEventRoot;
			return domNode;

		case 'text':
			return localDoc.createTextNode(vNode.text);

		case 'node':
			var domNode = vNode.namespace
				? localDoc.createElementNS(vNode.namespace, vNode.tag)
				: localDoc.createElement(vNode.tag);

			applyFacts(domNode, eventNode, vNode.facts);

			var children = vNode.children;

			for (var i = 0; i < children.length; i++)
			{
				domNode.appendChild(render(children[i], eventNode));
			}

			return domNode;

		case 'keyed-node':
			var domNode = vNode.namespace
				? localDoc.createElementNS(vNode.namespace, vNode.tag)
				: localDoc.createElement(vNode.tag);

			applyFacts(domNode, eventNode, vNode.facts);

			var children = vNode.children;

			for (var i = 0; i < children.length; i++)
			{
				domNode.appendChild(render(children[i]._1, eventNode));
			}

			return domNode;

		case 'custom':
			var domNode = vNode.impl.render(vNode.model);
			applyFacts(domNode, eventNode, vNode.facts);
			return domNode;
	}
}



////////////  APPLY FACTS  ////////////


function applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		switch (key)
		{
			case STYLE_KEY:
				applyStyles(domNode, value);
				break;

			case EVENT_KEY:
				applyEvents(domNode, eventNode, value);
				break;

			case ATTR_KEY:
				applyAttrs(domNode, value);
				break;

			case ATTR_NS_KEY:
				applyAttrsNS(domNode, value);
				break;

			case 'value':
				if (domNode[key] !== value)
				{
					domNode[key] = value;
				}
				break;

			default:
				domNode[key] = value;
				break;
		}
	}
}

function applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}

function applyEvents(domNode, eventNode, events)
{
	var allHandlers = domNode.elm_handlers || {};

	for (var key in events)
	{
		var handler = allHandlers[key];
		var value = events[key];

		if (typeof value === 'undefined')
		{
			domNode.removeEventListener(key, handler);
			allHandlers[key] = undefined;
		}
		else if (typeof handler === 'undefined')
		{
			var handler = makeEventHandler(eventNode, value);
			domNode.addEventListener(key, handler);
			allHandlers[key] = handler;
		}
		else
		{
			handler.info = value;
		}
	}

	domNode.elm_handlers = allHandlers;
}

function makeEventHandler(eventNode, info)
{
	function eventHandler(event)
	{
		var info = eventHandler.info;

		var value = A2(_elm_lang$core$Native_Json.run, info.decoder, event);

		if (value.ctor === 'Ok')
		{
			var options = info.options;
			if (options.stopPropagation)
			{
				event.stopPropagation();
			}
			if (options.preventDefault)
			{
				event.preventDefault();
			}

			var message = value._0;

			var currentEventNode = eventNode;
			while (currentEventNode)
			{
				var tagger = currentEventNode.tagger;
				if (typeof tagger === 'function')
				{
					message = tagger(message);
				}
				else
				{
					for (var i = tagger.length; i--; )
					{
						message = tagger[i](message);
					}
				}
				currentEventNode = currentEventNode.parent;
			}
		}
	};

	eventHandler.info = info;

	return eventHandler;
}

function applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		if (typeof value === 'undefined')
		{
			domNode.removeAttribute(key);
		}
		else
		{
			domNode.setAttribute(key, value);
		}
	}
}

function applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.namespace;
		var value = pair.value;

		if (typeof value === 'undefined')
		{
			domNode.removeAttributeNS(namespace, key);
		}
		else
		{
			domNode.setAttributeNS(namespace, key, value);
		}
	}
}



////////////  DIFF  ////////////


function diff(a, b)
{
	var patches = [];
	diffHelp(a, b, patches, 0);
	return patches;
}


function makePatch(type, index, data)
{
	return {
		index: index,
		type: type,
		data: data,
		domNode: undefined,
		eventNode: undefined
	};
}


function diffHelp(a, b, patches, index)
{
	if (a === b)
	{
		return;
	}

	var aType = a.type;
	var bType = b.type;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (aType !== bType)
	{
		patches.push(makePatch('p-redraw', index, b));
		return;
	}

	// Now we know that both nodes are the same type.
	switch (bType)
	{
		case 'thunk':
			var aArgs = a.args;
			var bArgs = b.args;
			var i = aArgs.length;
			var same = a.func === b.func && i === bArgs.length;
			while (same && i--)
			{
				same = aArgs[i] === bArgs[i];
			}
			if (same)
			{
				b.node = a.node;
				return;
			}
			b.node = b.thunk();
			var subPatches = [];
			diffHelp(a.node, b.node, subPatches, 0);
			if (subPatches.length > 0)
			{
				patches.push(makePatch('p-thunk', index, subPatches));
			}
			return;

		case 'tagger':
			// gather nested taggers
			var aTaggers = a.tagger;
			var bTaggers = b.tagger;
			var nesting = false;

			var aSubNode = a.node;
			while (aSubNode.type === 'tagger')
			{
				nesting = true;

				typeof aTaggers !== 'object'
					? aTaggers = [aTaggers, aSubNode.tagger]
					: aTaggers.push(aSubNode.tagger);

				aSubNode = aSubNode.node;
			}

			var bSubNode = b.node;
			while (bSubNode.type === 'tagger')
			{
				nesting = true;

				typeof bTaggers !== 'object'
					? bTaggers = [bTaggers, bSubNode.tagger]
					: bTaggers.push(bSubNode.tagger);

				bSubNode = bSubNode.node;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && aTaggers.length !== bTaggers.length)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !pairwiseRefEqual(aTaggers, bTaggers) : aTaggers !== bTaggers)
			{
				patches.push(makePatch('p-tagger', index, bTaggers));
			}

			// diff everything below the taggers
			diffHelp(aSubNode, bSubNode, patches, index + 1);
			return;

		case 'text':
			if (a.text !== b.text)
			{
				patches.push(makePatch('p-text', index, b.text));
				return;
			}

			return;

		case 'node':
			// Bail if obvious indicators have changed. Implies more serious
			// structural changes such that it's not worth it to diff.
			if (a.tag !== b.tag || a.namespace !== b.namespace)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);

			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			diffChildren(a, b, patches, index);
			return;

		case 'keyed-node':
			// Bail if obvious indicators have changed. Implies more serious
			// structural changes such that it's not worth it to diff.
			if (a.tag !== b.tag || a.namespace !== b.namespace)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);

			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			diffKeyedChildren(a, b, patches, index);
			return;

		case 'custom':
			if (a.impl !== b.impl)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);
			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			var patch = b.impl.diff(a,b);
			if (patch)
			{
				patches.push(makePatch('p-custom', index, patch));
				return;
			}

			return;
	}
}


// assumes the incoming arrays are the same length
function pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function diffFacts(a, b, category)
{
	var diff;

	// look for changes and removals
	for (var aKey in a)
	{
		if (aKey === STYLE_KEY || aKey === EVENT_KEY || aKey === ATTR_KEY || aKey === ATTR_NS_KEY)
		{
			var subDiff = diffFacts(a[aKey], b[aKey] || {}, aKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[aKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(aKey in b))
		{
			diff = diff || {};
			diff[aKey] =
				(typeof category === 'undefined')
					? (typeof a[aKey] === 'string' ? '' : null)
					:
				(category === STYLE_KEY)
					? ''
					:
				(category === EVENT_KEY || category === ATTR_KEY)
					? undefined
					:
				{ namespace: a[aKey].namespace, value: undefined };

			continue;
		}

		var aValue = a[aKey];
		var bValue = b[aKey];

		// reference equal, so don't worry about it
		if (aValue === bValue && aKey !== 'value'
			|| category === EVENT_KEY && equalEvents(aValue, bValue))
		{
			continue;
		}

		diff = diff || {};
		diff[aKey] = bValue;
	}

	// add new stuff
	for (var bKey in b)
	{
		if (!(bKey in a))
		{
			diff = diff || {};
			diff[bKey] = b[bKey];
		}
	}

	return diff;
}


function diffChildren(aParent, bParent, patches, rootIndex)
{
	var aChildren = aParent.children;
	var bChildren = bParent.children;

	var aLen = aChildren.length;
	var bLen = bChildren.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (aLen > bLen)
	{
		patches.push(makePatch('p-remove-last', rootIndex, aLen - bLen));
	}
	else if (aLen < bLen)
	{
		patches.push(makePatch('p-append', rootIndex, bChildren.slice(aLen)));
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	var index = rootIndex;
	var minLen = aLen < bLen ? aLen : bLen;
	for (var i = 0; i < minLen; i++)
	{
		index++;
		var aChild = aChildren[i];
		diffHelp(aChild, bChildren[i], patches, index);
		index += aChild.descendantsCount || 0;
	}
}



////////////  KEYED DIFF  ////////////


function diffKeyedChildren(aParent, bParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var aChildren = aParent.children;
	var bChildren = bParent.children;
	var aLen = aChildren.length;
	var bLen = bChildren.length;
	var aIndex = 0;
	var bIndex = 0;

	var index = rootIndex;

	while (aIndex < aLen && bIndex < bLen)
	{
		var a = aChildren[aIndex];
		var b = bChildren[bIndex];

		var aKey = a._0;
		var bKey = b._0;
		var aNode = a._1;
		var bNode = b._1;

		// check if keys match

		if (aKey === bKey)
		{
			index++;
			diffHelp(aNode, bNode, localPatches, index);
			index += aNode.descendantsCount || 0;

			aIndex++;
			bIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var aLookAhead = aIndex + 1 < aLen;
		var bLookAhead = bIndex + 1 < bLen;

		if (aLookAhead)
		{
			var aNext = aChildren[aIndex + 1];
			var aNextKey = aNext._0;
			var aNextNode = aNext._1;
			var oldMatch = bKey === aNextKey;
		}

		if (bLookAhead)
		{
			var bNext = bChildren[bIndex + 1];
			var bNextKey = bNext._0;
			var bNextNode = bNext._1;
			var newMatch = aKey === bNextKey;
		}


		// swap a and b
		if (aLookAhead && bLookAhead && newMatch && oldMatch)
		{
			index++;
			diffHelp(aNode, bNextNode, localPatches, index);
			insertNode(changes, localPatches, aKey, bNode, bIndex, inserts);
			index += aNode.descendantsCount || 0;

			index++;
			removeNode(changes, localPatches, aKey, aNextNode, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 2;
			continue;
		}

		// insert b
		if (bLookAhead && newMatch)
		{
			index++;
			insertNode(changes, localPatches, bKey, bNode, bIndex, inserts);
			diffHelp(aNode, bNextNode, localPatches, index);
			index += aNode.descendantsCount || 0;

			aIndex += 1;
			bIndex += 2;
			continue;
		}

		// remove a
		if (aLookAhead && oldMatch)
		{
			index++;
			removeNode(changes, localPatches, aKey, aNode, index);
			index += aNode.descendantsCount || 0;

			index++;
			diffHelp(aNextNode, bNode, localPatches, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 1;
			continue;
		}

		// remove a, insert b
		if (aLookAhead && bLookAhead && aNextKey === bNextKey)
		{
			index++;
			removeNode(changes, localPatches, aKey, aNode, index);
			insertNode(changes, localPatches, bKey, bNode, bIndex, inserts);
			index += aNode.descendantsCount || 0;

			index++;
			diffHelp(aNextNode, bNextNode, localPatches, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (aIndex < aLen)
	{
		index++;
		var a = aChildren[aIndex];
		var aNode = a._1;
		removeNode(changes, localPatches, a._0, aNode, index);
		index += aNode.descendantsCount || 0;
		aIndex++;
	}

	var endInserts;
	while (bIndex < bLen)
	{
		endInserts = endInserts || [];
		var b = bChildren[bIndex];
		insertNode(changes, localPatches, b._0, b._1, undefined, endInserts);
		bIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || typeof endInserts !== 'undefined')
	{
		patches.push(makePatch('p-reorder', rootIndex, {
			patches: localPatches,
			inserts: inserts,
			endInserts: endInserts
		}));
	}
}



////////////  CHANGES FROM KEYED DIFF  ////////////


var POSTFIX = '_elmW6BL';


function insertNode(changes, localPatches, key, vnode, bIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (typeof entry === 'undefined')
	{
		entry = {
			tag: 'insert',
			vnode: vnode,
			index: bIndex,
			data: undefined
		};

		inserts.push({ index: bIndex, entry: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.tag === 'remove')
	{
		inserts.push({ index: bIndex, entry: entry });

		entry.tag = 'move';
		var subPatches = [];
		diffHelp(entry.vnode, vnode, subPatches, entry.index);
		entry.index = bIndex;
		entry.data.data = {
			patches: subPatches,
			entry: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	insertNode(changes, localPatches, key + POSTFIX, vnode, bIndex, inserts);
}


function removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (typeof entry === 'undefined')
	{
		var patch = makePatch('p-remove', index, undefined);
		localPatches.push(patch);

		changes[key] = {
			tag: 'remove',
			vnode: vnode,
			index: index,
			data: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.tag === 'insert')
	{
		entry.tag = 'move';
		var subPatches = [];
		diffHelp(vnode, entry.vnode, subPatches, index);

		var patch = makePatch('p-remove', index, {
			patches: subPatches,
			entry: entry
		});
		localPatches.push(patch);

		return;
	}

	// this key has already been removed or moved, a duplicate!
	removeNode(changes, localPatches, key + POSTFIX, vnode, index);
}



////////////  ADD DOM NODES  ////////////
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function addDomNodes(domNode, vNode, patches, eventNode)
{
	addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.descendantsCount, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.index;

	while (index === low)
	{
		var patchType = patch.type;

		if (patchType === 'p-thunk')
		{
			addDomNodes(domNode, vNode.node, patch.data, eventNode);
		}
		else if (patchType === 'p-reorder')
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;

			var subPatches = patch.data.patches;
			if (subPatches.length > 0)
			{
				addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 'p-remove')
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;

			var data = patch.data;
			if (typeof data !== 'undefined')
			{
				data.entry.data = domNode;
				var subPatches = data.patches;
				if (subPatches.length > 0)
				{
					addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.index) > high)
		{
			return i;
		}
	}

	switch (vNode.type)
	{
		case 'tagger':
			var subNode = vNode.node;

			while (subNode.type === "tagger")
			{
				subNode = subNode.node;
			}

			return addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);

		case 'node':
			var vChildren = vNode.children;
			var childNodes = domNode.childNodes;
			for (var j = 0; j < vChildren.length; j++)
			{
				low++;
				var vChild = vChildren[j];
				var nextLow = low + (vChild.descendantsCount || 0);
				if (low <= index && index <= nextLow)
				{
					i = addDomNodesHelp(childNodes[j], vChild, patches, i, low, nextLow, eventNode);
					if (!(patch = patches[i]) || (index = patch.index) > high)
					{
						return i;
					}
				}
				low = nextLow;
			}
			return i;

		case 'keyed-node':
			var vChildren = vNode.children;
			var childNodes = domNode.childNodes;
			for (var j = 0; j < vChildren.length; j++)
			{
				low++;
				var vChild = vChildren[j]._1;
				var nextLow = low + (vChild.descendantsCount || 0);
				if (low <= index && index <= nextLow)
				{
					i = addDomNodesHelp(childNodes[j], vChild, patches, i, low, nextLow, eventNode);
					if (!(patch = patches[i]) || (index = patch.index) > high)
					{
						return i;
					}
				}
				low = nextLow;
			}
			return i;

		case 'text':
		case 'thunk':
			throw new Error('should never traverse `text` or `thunk` nodes like this');
	}
}



////////////  APPLY PATCHES  ////////////


function applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return applyPatchesHelp(rootDomNode, patches);
}

function applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.domNode
		var newNode = applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function applyPatch(domNode, patch)
{
	switch (patch.type)
	{
		case 'p-redraw':
			return applyPatchRedraw(domNode, patch.data, patch.eventNode);

		case 'p-facts':
			applyFacts(domNode, patch.eventNode, patch.data);
			return domNode;

		case 'p-text':
			domNode.replaceData(0, domNode.length, patch.data);
			return domNode;

		case 'p-thunk':
			return applyPatchesHelp(domNode, patch.data);

		case 'p-tagger':
			if (typeof domNode.elm_event_node_ref !== 'undefined')
			{
				domNode.elm_event_node_ref.tagger = patch.data;
			}
			else
			{
				domNode.elm_event_node_ref = { tagger: patch.data, parent: patch.eventNode };
			}
			return domNode;

		case 'p-remove-last':
			var i = patch.data;
			while (i--)
			{
				domNode.removeChild(domNode.lastChild);
			}
			return domNode;

		case 'p-append':
			var newNodes = patch.data;
			for (var i = 0; i < newNodes.length; i++)
			{
				domNode.appendChild(render(newNodes[i], patch.eventNode));
			}
			return domNode;

		case 'p-remove':
			var data = patch.data;
			if (typeof data === 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.entry;
			if (typeof entry.index !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.data = applyPatchesHelp(domNode, data.patches);
			return domNode;

		case 'p-reorder':
			return applyPatchReorder(domNode, patch);

		case 'p-custom':
			var impl = patch.data;
			return impl.applyPatch(domNode, impl.data);

		default:
			throw new Error('Ran into an unknown patch!');
	}
}


function applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = render(vNode, eventNode);

	if (typeof newNode.elm_event_node_ref === 'undefined')
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function applyPatchReorder(domNode, patch)
{
	var data = patch.data;

	// remove end inserts
	var frag = applyPatchReorderEndInsertsHelp(data.endInserts, patch);

	// removals
	domNode = applyPatchesHelp(domNode, data.patches);

	// inserts
	var inserts = data.inserts;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.entry;
		var node = entry.tag === 'move'
			? entry.data
			: render(entry.vnode, patch.eventNode);
		domNode.insertBefore(node, domNode.childNodes[insert.index]);
	}

	// add end inserts
	if (typeof frag !== 'undefined')
	{
		domNode.appendChild(frag);
	}

	return domNode;
}


function applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (typeof endInserts === 'undefined')
	{
		return;
	}

	var frag = localDoc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.entry;
		frag.appendChild(entry.tag === 'move'
			? entry.data
			: render(entry.vnode, patch.eventNode)
		);
	}
	return frag;
}


// PROGRAMS

var program = makeProgram(checkNoFlags);
var programWithFlags = makeProgram(checkYesFlags);

function makeProgram(flagChecker)
{
	return F2(function(debugWrap, impl)
	{
		return function(flagDecoder)
		{
			return function(object, moduleName, debugMetadata)
			{
				var checker = flagChecker(flagDecoder, moduleName);
				if (typeof debugMetadata === 'undefined')
				{
					normalSetup(impl, object, moduleName, checker);
				}
				else
				{
					debugSetup(A2(debugWrap, debugMetadata, impl), object, moduleName, checker);
				}
			};
		};
	});
}

function staticProgram(vNode)
{
	var nothing = _elm_lang$core$Native_Utils.Tuple2(
		_elm_lang$core$Native_Utils.Tuple0,
		_elm_lang$core$Platform_Cmd$none
	);
	return A2(program, _elm_lang$virtual_dom$VirtualDom_Debug$wrap, {
		init: nothing,
		view: function() { return vNode; },
		update: F2(function() { return nothing; }),
		subscriptions: function() { return _elm_lang$core$Platform_Sub$none; }
	})();
}


// FLAG CHECKERS

function checkNoFlags(flagDecoder, moduleName)
{
	return function(init, flags, domNode)
	{
		if (typeof flags === 'undefined')
		{
			return init;
		}

		var errorMessage =
			'The `' + moduleName + '` module does not need flags.\n'
			+ 'Initialize it with no arguments and you should be all set!';

		crash(errorMessage, domNode);
	};
}

function checkYesFlags(flagDecoder, moduleName)
{
	return function(init, flags, domNode)
	{
		if (typeof flagDecoder === 'undefined')
		{
			var errorMessage =
				'Are you trying to sneak a Never value into Elm? Trickster!\n'
				+ 'It looks like ' + moduleName + '.main is defined with `programWithFlags` but has type `Program Never`.\n'
				+ 'Use `program` instead if you do not want flags.'

			crash(errorMessage, domNode);
		}

		var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
		if (result.ctor === 'Ok')
		{
			return init(result._0);
		}

		var errorMessage =
			'Trying to initialize the `' + moduleName + '` module with an unexpected flag.\n'
			+ 'I tried to convert it to an Elm value, but ran into this problem:\n\n'
			+ result._0;

		crash(errorMessage, domNode);
	};
}

function crash(errorMessage, domNode)
{
	if (domNode)
	{
		domNode.innerHTML =
			'<div style="padding-left:1em;">'
			+ '<h2 style="font-weight:normal;"><b>Oops!</b> Something went wrong when starting your Elm program.</h2>'
			+ '<pre style="padding-left:1em;">' + errorMessage + '</pre>'
			+ '</div>';
	}

	throw new Error(errorMessage);
}


//  NORMAL SETUP

function normalSetup(impl, object, moduleName, flagChecker)
{
	object['embed'] = function embed(node, flags)
	{
		while (node.lastChild)
		{
			node.removeChild(node.lastChild);
		}

		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, node),
			impl.update,
			impl.subscriptions,
			normalRenderer(node, impl.view)
		);
	};

	object['fullscreen'] = function fullscreen(flags)
	{
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, document.body),
			impl.update,
			impl.subscriptions,
			normalRenderer(document.body, impl.view)
		);
	};
}

function normalRenderer(parentNode, view)
{
	return function(tagger, initialModel)
	{
		var eventNode = { tagger: tagger, parent: undefined };
		var initialVirtualNode = view(initialModel);
		var domNode = render(initialVirtualNode, eventNode);
		parentNode.appendChild(domNode);
		return makeStepper(domNode, view, initialVirtualNode, eventNode);
	};
}


// STEPPER

var rAF =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { setTimeout(callback, 1000 / 60); };

function makeStepper(domNode, view, initialVirtualNode, eventNode)
{
	var state = 'NO_REQUEST';
	var currNode = initialVirtualNode;
	var nextModel;

	function updateIfNeeded()
	{
		switch (state)
		{
			case 'NO_REQUEST':
				throw new Error(
					'Unexpected draw callback.\n' +
					'Please report this to <https://github.com/elm-lang/virtual-dom/issues>.'
				);

			case 'PENDING_REQUEST':
				rAF(updateIfNeeded);
				state = 'EXTRA_REQUEST';

				var nextNode = view(nextModel);
				var patches = diff(currNode, nextNode);
				domNode = applyPatches(domNode, currNode, patches, eventNode);
				currNode = nextNode;

				return;

			case 'EXTRA_REQUEST':
				state = 'NO_REQUEST';
				return;
		}
	}

	return function stepper(model)
	{
		if (state === 'NO_REQUEST')
		{
			rAF(updateIfNeeded);
		}
		state = 'PENDING_REQUEST';
		nextModel = model;
	};
}


// DEBUG SETUP

function debugSetup(impl, object, moduleName, flagChecker)
{
	object['fullscreen'] = function fullscreen(flags)
	{
		var popoutRef = { doc: undefined };
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, document.body),
			impl.update(scrollTask(popoutRef)),
			impl.subscriptions,
			debugRenderer(moduleName, document.body, popoutRef, impl.view, impl.viewIn, impl.viewOut)
		);
	};

	object['embed'] = function fullscreen(node, flags)
	{
		var popoutRef = { doc: undefined };
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, node),
			impl.update(scrollTask(popoutRef)),
			impl.subscriptions,
			debugRenderer(moduleName, node, popoutRef, impl.view, impl.viewIn, impl.viewOut)
		);
	};
}

function scrollTask(popoutRef)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var doc = popoutRef.doc;
		if (doc)
		{
			var msgs = doc.getElementsByClassName('debugger-sidebar-messages')[0];
			if (msgs)
			{
				msgs.scrollTop = msgs.scrollHeight;
			}
		}
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}


function debugRenderer(moduleName, parentNode, popoutRef, view, viewIn, viewOut)
{
	return function(tagger, initialModel)
	{
		var appEventNode = { tagger: tagger, parent: undefined };
		var eventNode = { tagger: tagger, parent: undefined };

		// make normal stepper
		var appVirtualNode = view(initialModel);
		var appNode = render(appVirtualNode, appEventNode);
		parentNode.appendChild(appNode);
		var appStepper = makeStepper(appNode, view, appVirtualNode, appEventNode);

		// make overlay stepper
		var overVirtualNode = viewIn(initialModel)._1;
		var overNode = render(overVirtualNode, eventNode);
		parentNode.appendChild(overNode);
		var wrappedViewIn = wrapViewIn(appEventNode, overNode, viewIn);
		var overStepper = makeStepper(overNode, wrappedViewIn, overVirtualNode, eventNode);

		// make debugger stepper
		var debugStepper = makeDebugStepper(initialModel, viewOut, eventNode, parentNode, moduleName, popoutRef);

		return function stepper(model)
		{
			appStepper(model);
			overStepper(model);
			debugStepper(model);
		}
	};
}

function makeDebugStepper(initialModel, view, eventNode, parentNode, moduleName, popoutRef)
{
	var curr;
	var domNode;

	return function stepper(model)
	{
		if (!model.isDebuggerOpen)
		{
			return;
		}

		if (!popoutRef.doc)
		{
			curr = view(model);
			domNode = openDebugWindow(moduleName, popoutRef, curr, eventNode);
			return;
		}

		// switch to document of popout
		localDoc = popoutRef.doc;

		var next = view(model);
		var patches = diff(curr, next);
		domNode = applyPatches(domNode, curr, patches, eventNode);
		curr = next;

		// switch back to normal document
		localDoc = document;
	};
}

function openDebugWindow(moduleName, popoutRef, virtualNode, eventNode)
{
	var w = 900;
	var h = 360;
	var x = screen.width - w;
	var y = screen.height - h;
	var debugWindow = window.open('', '', 'width=' + w + ',height=' + h + ',left=' + x + ',top=' + y);

	// switch to window document
	localDoc = debugWindow.document;

	popoutRef.doc = localDoc;
	localDoc.title = 'Debugger - ' + moduleName;
	localDoc.body.style.margin = '0';
	localDoc.body.style.padding = '0';
	var domNode = render(virtualNode, eventNode);
	localDoc.body.appendChild(domNode);

	localDoc.addEventListener('keydown', function(event) {
		if (event.metaKey && event.which === 82)
		{
			window.location.reload();
		}
		if (event.which === 38)
		{
			eventNode.tagger({ ctor: 'Up' });
			event.preventDefault();
		}
		if (event.which === 40)
		{
			eventNode.tagger({ ctor: 'Down' });
			event.preventDefault();
		}
	});

	function close()
	{
		popoutRef.doc = undefined;
		debugWindow.close();
	}
	window.addEventListener('unload', close);
	debugWindow.addEventListener('unload', function() {
		popoutRef.doc = undefined;
		window.removeEventListener('unload', close);
		eventNode.tagger({ ctor: 'Close' });
	});

	// switch back to the normal document
	localDoc = document;

	return domNode;
}


// BLOCK EVENTS

function wrapViewIn(appEventNode, overlayNode, viewIn)
{
	var ignorer = makeIgnorer(overlayNode);
	var blocking = 'Normal';
	var overflow;

	var normalTagger = appEventNode.tagger;
	var blockTagger = function() {};

	return function(model)
	{
		var tuple = viewIn(model);
		var newBlocking = tuple._0.ctor;
		appEventNode.tagger = newBlocking === 'Normal' ? normalTagger : blockTagger;
		if (blocking !== newBlocking)
		{
			traverse('removeEventListener', ignorer, blocking);
			traverse('addEventListener', ignorer, newBlocking);

			if (blocking === 'Normal')
			{
				overflow = document.body.style.overflow;
				document.body.style.overflow = 'hidden';
			}

			if (newBlocking === 'Normal')
			{
				document.body.style.overflow = overflow;
			}

			blocking = newBlocking;
		}
		return tuple._1;
	}
}

function traverse(verbEventListener, ignorer, blocking)
{
	switch(blocking)
	{
		case 'Normal':
			return;

		case 'Pause':
			return traverseHelp(verbEventListener, ignorer, mostEvents);

		case 'Message':
			return traverseHelp(verbEventListener, ignorer, allEvents);
	}
}

function traverseHelp(verbEventListener, handler, eventNames)
{
	for (var i = 0; i < eventNames.length; i++)
	{
		document.body[verbEventListener](eventNames[i], handler, true);
	}
}

function makeIgnorer(overlayNode)
{
	return function(event)
	{
		if (event.type === 'keydown' && event.metaKey && event.which === 82)
		{
			return;
		}

		var isScroll = event.type === 'scroll' || event.type === 'wheel';

		var node = event.target;
		while (node !== null)
		{
			if (node.className === 'elm-overlay-message-details' && isScroll)
			{
				return;
			}

			if (node === overlayNode && !isScroll)
			{
				return;
			}
			node = node.parentNode;
		}

		event.stopPropagation();
		event.preventDefault();
	}
}

var mostEvents = [
	'click', 'dblclick', 'mousemove',
	'mouseup', 'mousedown', 'mouseenter', 'mouseleave',
	'touchstart', 'touchend', 'touchcancel', 'touchmove',
	'pointerdown', 'pointerup', 'pointerover', 'pointerout',
	'pointerenter', 'pointerleave', 'pointermove', 'pointercancel',
	'dragstart', 'drag', 'dragend', 'dragenter', 'dragover', 'dragleave', 'drop',
	'keyup', 'keydown', 'keypress',
	'input', 'change',
	'focus', 'blur'
];

var allEvents = mostEvents.concat('wheel', 'scroll');


return {
	node: node,
	text: text,
	custom: custom,
	map: F2(map),

	on: F3(on),
	style: style,
	property: F2(property),
	attribute: F2(attribute),
	attributeNS: F3(attributeNS),
	mapProperty: F2(mapProperty),

	lazy: F2(lazy),
	lazy2: F3(lazy2),
	lazy3: F4(lazy3),
	keyedNode: F3(keyedNode),

	program: program,
	programWithFlags: programWithFlags,
	staticProgram: staticProgram
};

}();

var _elm_lang$virtual_dom$VirtualDom$programWithFlags = function (impl) {
	return A2(_elm_lang$virtual_dom$Native_VirtualDom.programWithFlags, _elm_lang$virtual_dom$VirtualDom_Debug$wrapWithFlags, impl);
};
var _elm_lang$virtual_dom$VirtualDom$program = function (impl) {
	return A2(_elm_lang$virtual_dom$Native_VirtualDom.program, _elm_lang$virtual_dom$VirtualDom_Debug$wrap, impl);
};
var _elm_lang$virtual_dom$VirtualDom$keyedNode = _elm_lang$virtual_dom$Native_VirtualDom.keyedNode;
var _elm_lang$virtual_dom$VirtualDom$lazy3 = _elm_lang$virtual_dom$Native_VirtualDom.lazy3;
var _elm_lang$virtual_dom$VirtualDom$lazy2 = _elm_lang$virtual_dom$Native_VirtualDom.lazy2;
var _elm_lang$virtual_dom$VirtualDom$lazy = _elm_lang$virtual_dom$Native_VirtualDom.lazy;
var _elm_lang$virtual_dom$VirtualDom$defaultOptions = {stopPropagation: false, preventDefault: false};
var _elm_lang$virtual_dom$VirtualDom$onWithOptions = _elm_lang$virtual_dom$Native_VirtualDom.on;
var _elm_lang$virtual_dom$VirtualDom$on = F2(
	function (eventName, decoder) {
		return A3(_elm_lang$virtual_dom$VirtualDom$onWithOptions, eventName, _elm_lang$virtual_dom$VirtualDom$defaultOptions, decoder);
	});
var _elm_lang$virtual_dom$VirtualDom$style = _elm_lang$virtual_dom$Native_VirtualDom.style;
var _elm_lang$virtual_dom$VirtualDom$mapProperty = _elm_lang$virtual_dom$Native_VirtualDom.mapProperty;
var _elm_lang$virtual_dom$VirtualDom$attributeNS = _elm_lang$virtual_dom$Native_VirtualDom.attributeNS;
var _elm_lang$virtual_dom$VirtualDom$attribute = _elm_lang$virtual_dom$Native_VirtualDom.attribute;
var _elm_lang$virtual_dom$VirtualDom$property = _elm_lang$virtual_dom$Native_VirtualDom.property;
var _elm_lang$virtual_dom$VirtualDom$map = _elm_lang$virtual_dom$Native_VirtualDom.map;
var _elm_lang$virtual_dom$VirtualDom$text = _elm_lang$virtual_dom$Native_VirtualDom.text;
var _elm_lang$virtual_dom$VirtualDom$node = _elm_lang$virtual_dom$Native_VirtualDom.node;
var _elm_lang$virtual_dom$VirtualDom$Options = F2(
	function (a, b) {
		return {stopPropagation: a, preventDefault: b};
	});
var _elm_lang$virtual_dom$VirtualDom$Node = {ctor: 'Node'};
var _elm_lang$virtual_dom$VirtualDom$Property = {ctor: 'Property'};

var _elm_lang$html$Html$programWithFlags = _elm_lang$virtual_dom$VirtualDom$programWithFlags;
var _elm_lang$html$Html$program = _elm_lang$virtual_dom$VirtualDom$program;
var _elm_lang$html$Html$beginnerProgram = function (_p0) {
	var _p1 = _p0;
	return _elm_lang$html$Html$program(
		{
			init: A2(
				_elm_lang$core$Platform_Cmd_ops['!'],
				_p1.model,
				{ctor: '[]'}),
			update: F2(
				function (msg, model) {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						A2(_p1.update, msg, model),
						{ctor: '[]'});
				}),
			view: _p1.view,
			subscriptions: function (_p2) {
				return _elm_lang$core$Platform_Sub$none;
			}
		});
};
var _elm_lang$html$Html$map = _elm_lang$virtual_dom$VirtualDom$map;
var _elm_lang$html$Html$text = _elm_lang$virtual_dom$VirtualDom$text;
var _elm_lang$html$Html$node = _elm_lang$virtual_dom$VirtualDom$node;
var _elm_lang$html$Html$body = _elm_lang$html$Html$node('body');
var _elm_lang$html$Html$section = _elm_lang$html$Html$node('section');
var _elm_lang$html$Html$nav = _elm_lang$html$Html$node('nav');
var _elm_lang$html$Html$article = _elm_lang$html$Html$node('article');
var _elm_lang$html$Html$aside = _elm_lang$html$Html$node('aside');
var _elm_lang$html$Html$h1 = _elm_lang$html$Html$node('h1');
var _elm_lang$html$Html$h2 = _elm_lang$html$Html$node('h2');
var _elm_lang$html$Html$h3 = _elm_lang$html$Html$node('h3');
var _elm_lang$html$Html$h4 = _elm_lang$html$Html$node('h4');
var _elm_lang$html$Html$h5 = _elm_lang$html$Html$node('h5');
var _elm_lang$html$Html$h6 = _elm_lang$html$Html$node('h6');
var _elm_lang$html$Html$header = _elm_lang$html$Html$node('header');
var _elm_lang$html$Html$footer = _elm_lang$html$Html$node('footer');
var _elm_lang$html$Html$address = _elm_lang$html$Html$node('address');
var _elm_lang$html$Html$main_ = _elm_lang$html$Html$node('main');
var _elm_lang$html$Html$p = _elm_lang$html$Html$node('p');
var _elm_lang$html$Html$hr = _elm_lang$html$Html$node('hr');
var _elm_lang$html$Html$pre = _elm_lang$html$Html$node('pre');
var _elm_lang$html$Html$blockquote = _elm_lang$html$Html$node('blockquote');
var _elm_lang$html$Html$ol = _elm_lang$html$Html$node('ol');
var _elm_lang$html$Html$ul = _elm_lang$html$Html$node('ul');
var _elm_lang$html$Html$li = _elm_lang$html$Html$node('li');
var _elm_lang$html$Html$dl = _elm_lang$html$Html$node('dl');
var _elm_lang$html$Html$dt = _elm_lang$html$Html$node('dt');
var _elm_lang$html$Html$dd = _elm_lang$html$Html$node('dd');
var _elm_lang$html$Html$figure = _elm_lang$html$Html$node('figure');
var _elm_lang$html$Html$figcaption = _elm_lang$html$Html$node('figcaption');
var _elm_lang$html$Html$div = _elm_lang$html$Html$node('div');
var _elm_lang$html$Html$a = _elm_lang$html$Html$node('a');
var _elm_lang$html$Html$em = _elm_lang$html$Html$node('em');
var _elm_lang$html$Html$strong = _elm_lang$html$Html$node('strong');
var _elm_lang$html$Html$small = _elm_lang$html$Html$node('small');
var _elm_lang$html$Html$s = _elm_lang$html$Html$node('s');
var _elm_lang$html$Html$cite = _elm_lang$html$Html$node('cite');
var _elm_lang$html$Html$q = _elm_lang$html$Html$node('q');
var _elm_lang$html$Html$dfn = _elm_lang$html$Html$node('dfn');
var _elm_lang$html$Html$abbr = _elm_lang$html$Html$node('abbr');
var _elm_lang$html$Html$time = _elm_lang$html$Html$node('time');
var _elm_lang$html$Html$code = _elm_lang$html$Html$node('code');
var _elm_lang$html$Html$var = _elm_lang$html$Html$node('var');
var _elm_lang$html$Html$samp = _elm_lang$html$Html$node('samp');
var _elm_lang$html$Html$kbd = _elm_lang$html$Html$node('kbd');
var _elm_lang$html$Html$sub = _elm_lang$html$Html$node('sub');
var _elm_lang$html$Html$sup = _elm_lang$html$Html$node('sup');
var _elm_lang$html$Html$i = _elm_lang$html$Html$node('i');
var _elm_lang$html$Html$b = _elm_lang$html$Html$node('b');
var _elm_lang$html$Html$u = _elm_lang$html$Html$node('u');
var _elm_lang$html$Html$mark = _elm_lang$html$Html$node('mark');
var _elm_lang$html$Html$ruby = _elm_lang$html$Html$node('ruby');
var _elm_lang$html$Html$rt = _elm_lang$html$Html$node('rt');
var _elm_lang$html$Html$rp = _elm_lang$html$Html$node('rp');
var _elm_lang$html$Html$bdi = _elm_lang$html$Html$node('bdi');
var _elm_lang$html$Html$bdo = _elm_lang$html$Html$node('bdo');
var _elm_lang$html$Html$span = _elm_lang$html$Html$node('span');
var _elm_lang$html$Html$br = _elm_lang$html$Html$node('br');
var _elm_lang$html$Html$wbr = _elm_lang$html$Html$node('wbr');
var _elm_lang$html$Html$ins = _elm_lang$html$Html$node('ins');
var _elm_lang$html$Html$del = _elm_lang$html$Html$node('del');
var _elm_lang$html$Html$img = _elm_lang$html$Html$node('img');
var _elm_lang$html$Html$iframe = _elm_lang$html$Html$node('iframe');
var _elm_lang$html$Html$embed = _elm_lang$html$Html$node('embed');
var _elm_lang$html$Html$object = _elm_lang$html$Html$node('object');
var _elm_lang$html$Html$param = _elm_lang$html$Html$node('param');
var _elm_lang$html$Html$video = _elm_lang$html$Html$node('video');
var _elm_lang$html$Html$audio = _elm_lang$html$Html$node('audio');
var _elm_lang$html$Html$source = _elm_lang$html$Html$node('source');
var _elm_lang$html$Html$track = _elm_lang$html$Html$node('track');
var _elm_lang$html$Html$canvas = _elm_lang$html$Html$node('canvas');
var _elm_lang$html$Html$math = _elm_lang$html$Html$node('math');
var _elm_lang$html$Html$table = _elm_lang$html$Html$node('table');
var _elm_lang$html$Html$caption = _elm_lang$html$Html$node('caption');
var _elm_lang$html$Html$colgroup = _elm_lang$html$Html$node('colgroup');
var _elm_lang$html$Html$col = _elm_lang$html$Html$node('col');
var _elm_lang$html$Html$tbody = _elm_lang$html$Html$node('tbody');
var _elm_lang$html$Html$thead = _elm_lang$html$Html$node('thead');
var _elm_lang$html$Html$tfoot = _elm_lang$html$Html$node('tfoot');
var _elm_lang$html$Html$tr = _elm_lang$html$Html$node('tr');
var _elm_lang$html$Html$td = _elm_lang$html$Html$node('td');
var _elm_lang$html$Html$th = _elm_lang$html$Html$node('th');
var _elm_lang$html$Html$form = _elm_lang$html$Html$node('form');
var _elm_lang$html$Html$fieldset = _elm_lang$html$Html$node('fieldset');
var _elm_lang$html$Html$legend = _elm_lang$html$Html$node('legend');
var _elm_lang$html$Html$label = _elm_lang$html$Html$node('label');
var _elm_lang$html$Html$input = _elm_lang$html$Html$node('input');
var _elm_lang$html$Html$button = _elm_lang$html$Html$node('button');
var _elm_lang$html$Html$select = _elm_lang$html$Html$node('select');
var _elm_lang$html$Html$datalist = _elm_lang$html$Html$node('datalist');
var _elm_lang$html$Html$optgroup = _elm_lang$html$Html$node('optgroup');
var _elm_lang$html$Html$option = _elm_lang$html$Html$node('option');
var _elm_lang$html$Html$textarea = _elm_lang$html$Html$node('textarea');
var _elm_lang$html$Html$keygen = _elm_lang$html$Html$node('keygen');
var _elm_lang$html$Html$output = _elm_lang$html$Html$node('output');
var _elm_lang$html$Html$progress = _elm_lang$html$Html$node('progress');
var _elm_lang$html$Html$meter = _elm_lang$html$Html$node('meter');
var _elm_lang$html$Html$details = _elm_lang$html$Html$node('details');
var _elm_lang$html$Html$summary = _elm_lang$html$Html$node('summary');
var _elm_lang$html$Html$menuitem = _elm_lang$html$Html$node('menuitem');
var _elm_lang$html$Html$menu = _elm_lang$html$Html$node('menu');

var _elm_lang$navigation$Native_Navigation = function() {


// FAKE NAVIGATION

function go(n)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		if (n !== 0)
		{
			history.go(n);
		}
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function pushState(url)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		history.pushState({}, '', url);
		callback(_elm_lang$core$Native_Scheduler.succeed(getLocation()));
	});
}

function replaceState(url)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		history.replaceState({}, '', url);
		callback(_elm_lang$core$Native_Scheduler.succeed(getLocation()));
	});
}


// REAL NAVIGATION

function reloadPage(skipCache)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		document.location.reload(skipCache);
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function setLocation(url)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		try
		{
			window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			document.location.reload(false);
		}
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}


// GET LOCATION

function getLocation()
{
	var location = document.location;

	return {
		href: location.href,
		host: location.host,
		hostname: location.hostname,
		protocol: location.protocol,
		origin: location.origin,
		port_: location.port,
		pathname: location.pathname,
		search: location.search,
		hash: location.hash,
		username: location.username,
		password: location.password
	};
}


// DETECT IE11 PROBLEMS

function isInternetExplorer11()
{
	return window.navigator.userAgent.indexOf('Trident') !== -1;
}


return {
	go: go,
	setLocation: setLocation,
	reloadPage: reloadPage,
	pushState: pushState,
	replaceState: replaceState,
	getLocation: getLocation,
	isInternetExplorer11: isInternetExplorer11
};

}();

//import Native.Scheduler //

var _elm_lang$core$Native_Time = function() {

var now = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
{
	callback(_elm_lang$core$Native_Scheduler.succeed(Date.now()));
});

function setInterval_(interval, task)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var id = setInterval(function() {
			_elm_lang$core$Native_Scheduler.rawSpawn(task);
		}, interval);

		return function() { clearInterval(id); };
	});
}

return {
	now: now,
	setInterval_: F2(setInterval_)
};

}();
var _elm_lang$core$Time$setInterval = _elm_lang$core$Native_Time.setInterval_;
var _elm_lang$core$Time$spawnHelp = F3(
	function (router, intervals, processes) {
		var _p0 = intervals;
		if (_p0.ctor === '[]') {
			return _elm_lang$core$Task$succeed(processes);
		} else {
			var _p1 = _p0._0;
			var spawnRest = function (id) {
				return A3(
					_elm_lang$core$Time$spawnHelp,
					router,
					_p0._1,
					A3(_elm_lang$core$Dict$insert, _p1, id, processes));
			};
			var spawnTimer = _elm_lang$core$Native_Scheduler.spawn(
				A2(
					_elm_lang$core$Time$setInterval,
					_p1,
					A2(_elm_lang$core$Platform$sendToSelf, router, _p1)));
			return A2(_elm_lang$core$Task$andThen, spawnRest, spawnTimer);
		}
	});
var _elm_lang$core$Time$addMySub = F2(
	function (_p2, state) {
		var _p3 = _p2;
		var _p6 = _p3._1;
		var _p5 = _p3._0;
		var _p4 = A2(_elm_lang$core$Dict$get, _p5, state);
		if (_p4.ctor === 'Nothing') {
			return A3(
				_elm_lang$core$Dict$insert,
				_p5,
				{
					ctor: '::',
					_0: _p6,
					_1: {ctor: '[]'}
				},
				state);
		} else {
			return A3(
				_elm_lang$core$Dict$insert,
				_p5,
				{ctor: '::', _0: _p6, _1: _p4._0},
				state);
		}
	});
var _elm_lang$core$Time$inMilliseconds = function (t) {
	return t;
};
var _elm_lang$core$Time$millisecond = 1;
var _elm_lang$core$Time$second = 1000 * _elm_lang$core$Time$millisecond;
var _elm_lang$core$Time$minute = 60 * _elm_lang$core$Time$second;
var _elm_lang$core$Time$hour = 60 * _elm_lang$core$Time$minute;
var _elm_lang$core$Time$inHours = function (t) {
	return t / _elm_lang$core$Time$hour;
};
var _elm_lang$core$Time$inMinutes = function (t) {
	return t / _elm_lang$core$Time$minute;
};
var _elm_lang$core$Time$inSeconds = function (t) {
	return t / _elm_lang$core$Time$second;
};
var _elm_lang$core$Time$now = _elm_lang$core$Native_Time.now;
var _elm_lang$core$Time$onSelfMsg = F3(
	function (router, interval, state) {
		var _p7 = A2(_elm_lang$core$Dict$get, interval, state.taggers);
		if (_p7.ctor === 'Nothing') {
			return _elm_lang$core$Task$succeed(state);
		} else {
			var tellTaggers = function (time) {
				return _elm_lang$core$Task$sequence(
					A2(
						_elm_lang$core$List$map,
						function (tagger) {
							return A2(
								_elm_lang$core$Platform$sendToApp,
								router,
								tagger(time));
						},
						_p7._0));
			};
			return A2(
				_elm_lang$core$Task$andThen,
				function (_p8) {
					return _elm_lang$core$Task$succeed(state);
				},
				A2(_elm_lang$core$Task$andThen, tellTaggers, _elm_lang$core$Time$now));
		}
	});
var _elm_lang$core$Time$subscription = _elm_lang$core$Native_Platform.leaf('Time');
var _elm_lang$core$Time$State = F2(
	function (a, b) {
		return {taggers: a, processes: b};
	});
var _elm_lang$core$Time$init = _elm_lang$core$Task$succeed(
	A2(_elm_lang$core$Time$State, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty));
var _elm_lang$core$Time$onEffects = F3(
	function (router, subs, _p9) {
		var _p10 = _p9;
		var rightStep = F3(
			function (_p12, id, _p11) {
				var _p13 = _p11;
				return {
					ctor: '_Tuple3',
					_0: _p13._0,
					_1: _p13._1,
					_2: A2(
						_elm_lang$core$Task$andThen,
						function (_p14) {
							return _p13._2;
						},
						_elm_lang$core$Native_Scheduler.kill(id))
				};
			});
		var bothStep = F4(
			function (interval, taggers, id, _p15) {
				var _p16 = _p15;
				return {
					ctor: '_Tuple3',
					_0: _p16._0,
					_1: A3(_elm_lang$core$Dict$insert, interval, id, _p16._1),
					_2: _p16._2
				};
			});
		var leftStep = F3(
			function (interval, taggers, _p17) {
				var _p18 = _p17;
				return {
					ctor: '_Tuple3',
					_0: {ctor: '::', _0: interval, _1: _p18._0},
					_1: _p18._1,
					_2: _p18._2
				};
			});
		var newTaggers = A3(_elm_lang$core$List$foldl, _elm_lang$core$Time$addMySub, _elm_lang$core$Dict$empty, subs);
		var _p19 = A6(
			_elm_lang$core$Dict$merge,
			leftStep,
			bothStep,
			rightStep,
			newTaggers,
			_p10.processes,
			{
				ctor: '_Tuple3',
				_0: {ctor: '[]'},
				_1: _elm_lang$core$Dict$empty,
				_2: _elm_lang$core$Task$succeed(
					{ctor: '_Tuple0'})
			});
		var spawnList = _p19._0;
		var existingDict = _p19._1;
		var killTask = _p19._2;
		return A2(
			_elm_lang$core$Task$andThen,
			function (newProcesses) {
				return _elm_lang$core$Task$succeed(
					A2(_elm_lang$core$Time$State, newTaggers, newProcesses));
			},
			A2(
				_elm_lang$core$Task$andThen,
				function (_p20) {
					return A3(_elm_lang$core$Time$spawnHelp, router, spawnList, existingDict);
				},
				killTask));
	});
var _elm_lang$core$Time$Every = F2(
	function (a, b) {
		return {ctor: 'Every', _0: a, _1: b};
	});
var _elm_lang$core$Time$every = F2(
	function (interval, tagger) {
		return _elm_lang$core$Time$subscription(
			A2(_elm_lang$core$Time$Every, interval, tagger));
	});
var _elm_lang$core$Time$subMap = F2(
	function (f, _p21) {
		var _p22 = _p21;
		return A2(
			_elm_lang$core$Time$Every,
			_p22._0,
			function (_p23) {
				return f(
					_p22._1(_p23));
			});
	});
_elm_lang$core$Native_Platform.effectManagers['Time'] = {pkg: 'elm-lang/core', init: _elm_lang$core$Time$init, onEffects: _elm_lang$core$Time$onEffects, onSelfMsg: _elm_lang$core$Time$onSelfMsg, tag: 'sub', subMap: _elm_lang$core$Time$subMap};

var _elm_lang$core$Process$kill = _elm_lang$core$Native_Scheduler.kill;
var _elm_lang$core$Process$sleep = _elm_lang$core$Native_Scheduler.sleep;
var _elm_lang$core$Process$spawn = _elm_lang$core$Native_Scheduler.spawn;

var _elm_lang$navigation$Navigation$replaceState = _elm_lang$navigation$Native_Navigation.replaceState;
var _elm_lang$navigation$Navigation$pushState = _elm_lang$navigation$Native_Navigation.pushState;
var _elm_lang$navigation$Navigation$go = _elm_lang$navigation$Native_Navigation.go;
var _elm_lang$navigation$Navigation$reloadPage = _elm_lang$navigation$Native_Navigation.reloadPage;
var _elm_lang$navigation$Navigation$setLocation = _elm_lang$navigation$Native_Navigation.setLocation;
var _elm_lang$navigation$Navigation_ops = _elm_lang$navigation$Navigation_ops || {};
_elm_lang$navigation$Navigation_ops['&>'] = F2(
	function (task1, task2) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (_p0) {
				return task2;
			},
			task1);
	});
var _elm_lang$navigation$Navigation$notify = F3(
	function (router, subs, location) {
		var send = function (_p1) {
			var _p2 = _p1;
			return A2(
				_elm_lang$core$Platform$sendToApp,
				router,
				_p2._0(location));
		};
		return A2(
			_elm_lang$navigation$Navigation_ops['&>'],
			_elm_lang$core$Task$sequence(
				A2(_elm_lang$core$List$map, send, subs)),
			_elm_lang$core$Task$succeed(
				{ctor: '_Tuple0'}));
	});
var _elm_lang$navigation$Navigation$cmdHelp = F3(
	function (router, subs, cmd) {
		var _p3 = cmd;
		switch (_p3.ctor) {
			case 'Jump':
				return _elm_lang$navigation$Navigation$go(_p3._0);
			case 'New':
				return A2(
					_elm_lang$core$Task$andThen,
					A2(_elm_lang$navigation$Navigation$notify, router, subs),
					_elm_lang$navigation$Navigation$pushState(_p3._0));
			case 'Modify':
				return A2(
					_elm_lang$core$Task$andThen,
					A2(_elm_lang$navigation$Navigation$notify, router, subs),
					_elm_lang$navigation$Navigation$replaceState(_p3._0));
			case 'Visit':
				return _elm_lang$navigation$Navigation$setLocation(_p3._0);
			default:
				return _elm_lang$navigation$Navigation$reloadPage(_p3._0);
		}
	});
var _elm_lang$navigation$Navigation$killPopWatcher = function (popWatcher) {
	var _p4 = popWatcher;
	if (_p4.ctor === 'Normal') {
		return _elm_lang$core$Process$kill(_p4._0);
	} else {
		return A2(
			_elm_lang$navigation$Navigation_ops['&>'],
			_elm_lang$core$Process$kill(_p4._0),
			_elm_lang$core$Process$kill(_p4._1));
	}
};
var _elm_lang$navigation$Navigation$onSelfMsg = F3(
	function (router, location, state) {
		return A2(
			_elm_lang$navigation$Navigation_ops['&>'],
			A3(_elm_lang$navigation$Navigation$notify, router, state.subs, location),
			_elm_lang$core$Task$succeed(state));
	});
var _elm_lang$navigation$Navigation$subscription = _elm_lang$core$Native_Platform.leaf('Navigation');
var _elm_lang$navigation$Navigation$command = _elm_lang$core$Native_Platform.leaf('Navigation');
var _elm_lang$navigation$Navigation$Location = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return function (k) {
											return {href: a, host: b, hostname: c, protocol: d, origin: e, port_: f, pathname: g, search: h, hash: i, username: j, password: k};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var _elm_lang$navigation$Navigation$State = F2(
	function (a, b) {
		return {subs: a, popWatcher: b};
	});
var _elm_lang$navigation$Navigation$init = _elm_lang$core$Task$succeed(
	A2(
		_elm_lang$navigation$Navigation$State,
		{ctor: '[]'},
		_elm_lang$core$Maybe$Nothing));
var _elm_lang$navigation$Navigation$Reload = function (a) {
	return {ctor: 'Reload', _0: a};
};
var _elm_lang$navigation$Navigation$reload = _elm_lang$navigation$Navigation$command(
	_elm_lang$navigation$Navigation$Reload(false));
var _elm_lang$navigation$Navigation$reloadAndSkipCache = _elm_lang$navigation$Navigation$command(
	_elm_lang$navigation$Navigation$Reload(true));
var _elm_lang$navigation$Navigation$Visit = function (a) {
	return {ctor: 'Visit', _0: a};
};
var _elm_lang$navigation$Navigation$load = function (url) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$Visit(url));
};
var _elm_lang$navigation$Navigation$Modify = function (a) {
	return {ctor: 'Modify', _0: a};
};
var _elm_lang$navigation$Navigation$modifyUrl = function (url) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$Modify(url));
};
var _elm_lang$navigation$Navigation$New = function (a) {
	return {ctor: 'New', _0: a};
};
var _elm_lang$navigation$Navigation$newUrl = function (url) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$New(url));
};
var _elm_lang$navigation$Navigation$Jump = function (a) {
	return {ctor: 'Jump', _0: a};
};
var _elm_lang$navigation$Navigation$back = function (n) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$Jump(0 - n));
};
var _elm_lang$navigation$Navigation$forward = function (n) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$Jump(n));
};
var _elm_lang$navigation$Navigation$cmdMap = F2(
	function (_p5, myCmd) {
		var _p6 = myCmd;
		switch (_p6.ctor) {
			case 'Jump':
				return _elm_lang$navigation$Navigation$Jump(_p6._0);
			case 'New':
				return _elm_lang$navigation$Navigation$New(_p6._0);
			case 'Modify':
				return _elm_lang$navigation$Navigation$Modify(_p6._0);
			case 'Visit':
				return _elm_lang$navigation$Navigation$Visit(_p6._0);
			default:
				return _elm_lang$navigation$Navigation$Reload(_p6._0);
		}
	});
var _elm_lang$navigation$Navigation$Monitor = function (a) {
	return {ctor: 'Monitor', _0: a};
};
var _elm_lang$navigation$Navigation$program = F2(
	function (locationToMessage, stuff) {
		var init = stuff.init(
			_elm_lang$navigation$Native_Navigation.getLocation(
				{ctor: '_Tuple0'}));
		var subs = function (model) {
			return _elm_lang$core$Platform_Sub$batch(
				{
					ctor: '::',
					_0: _elm_lang$navigation$Navigation$subscription(
						_elm_lang$navigation$Navigation$Monitor(locationToMessage)),
					_1: {
						ctor: '::',
						_0: stuff.subscriptions(model),
						_1: {ctor: '[]'}
					}
				});
		};
		return _elm_lang$html$Html$program(
			{init: init, view: stuff.view, update: stuff.update, subscriptions: subs});
	});
var _elm_lang$navigation$Navigation$programWithFlags = F2(
	function (locationToMessage, stuff) {
		var init = function (flags) {
			return A2(
				stuff.init,
				flags,
				_elm_lang$navigation$Native_Navigation.getLocation(
					{ctor: '_Tuple0'}));
		};
		var subs = function (model) {
			return _elm_lang$core$Platform_Sub$batch(
				{
					ctor: '::',
					_0: _elm_lang$navigation$Navigation$subscription(
						_elm_lang$navigation$Navigation$Monitor(locationToMessage)),
					_1: {
						ctor: '::',
						_0: stuff.subscriptions(model),
						_1: {ctor: '[]'}
					}
				});
		};
		return _elm_lang$html$Html$programWithFlags(
			{init: init, view: stuff.view, update: stuff.update, subscriptions: subs});
	});
var _elm_lang$navigation$Navigation$subMap = F2(
	function (func, _p7) {
		var _p8 = _p7;
		return _elm_lang$navigation$Navigation$Monitor(
			function (_p9) {
				return func(
					_p8._0(_p9));
			});
	});
var _elm_lang$navigation$Navigation$InternetExplorer = F2(
	function (a, b) {
		return {ctor: 'InternetExplorer', _0: a, _1: b};
	});
var _elm_lang$navigation$Navigation$Normal = function (a) {
	return {ctor: 'Normal', _0: a};
};
var _elm_lang$navigation$Navigation$spawnPopWatcher = function (router) {
	var reportLocation = function (_p10) {
		return A2(
			_elm_lang$core$Platform$sendToSelf,
			router,
			_elm_lang$navigation$Native_Navigation.getLocation(
				{ctor: '_Tuple0'}));
	};
	return _elm_lang$navigation$Native_Navigation.isInternetExplorer11(
		{ctor: '_Tuple0'}) ? A3(
		_elm_lang$core$Task$map2,
		_elm_lang$navigation$Navigation$InternetExplorer,
		_elm_lang$core$Process$spawn(
			A3(_elm_lang$dom$Dom_LowLevel$onWindow, 'popstate', _elm_lang$core$Json_Decode$value, reportLocation)),
		_elm_lang$core$Process$spawn(
			A3(_elm_lang$dom$Dom_LowLevel$onWindow, 'hashchange', _elm_lang$core$Json_Decode$value, reportLocation))) : A2(
		_elm_lang$core$Task$map,
		_elm_lang$navigation$Navigation$Normal,
		_elm_lang$core$Process$spawn(
			A3(_elm_lang$dom$Dom_LowLevel$onWindow, 'popstate', _elm_lang$core$Json_Decode$value, reportLocation)));
};
var _elm_lang$navigation$Navigation$onEffects = F4(
	function (router, cmds, subs, _p11) {
		var _p12 = _p11;
		var _p15 = _p12.popWatcher;
		var stepState = function () {
			var _p13 = {ctor: '_Tuple2', _0: subs, _1: _p15};
			_v6_2:
			do {
				if (_p13._0.ctor === '[]') {
					if (_p13._1.ctor === 'Just') {
						return A2(
							_elm_lang$navigation$Navigation_ops['&>'],
							_elm_lang$navigation$Navigation$killPopWatcher(_p13._1._0),
							_elm_lang$core$Task$succeed(
								A2(_elm_lang$navigation$Navigation$State, subs, _elm_lang$core$Maybe$Nothing)));
					} else {
						break _v6_2;
					}
				} else {
					if (_p13._1.ctor === 'Nothing') {
						return A2(
							_elm_lang$core$Task$map,
							function (_p14) {
								return A2(
									_elm_lang$navigation$Navigation$State,
									subs,
									_elm_lang$core$Maybe$Just(_p14));
							},
							_elm_lang$navigation$Navigation$spawnPopWatcher(router));
					} else {
						break _v6_2;
					}
				}
			} while(false);
			return _elm_lang$core$Task$succeed(
				A2(_elm_lang$navigation$Navigation$State, subs, _p15));
		}();
		return A2(
			_elm_lang$navigation$Navigation_ops['&>'],
			_elm_lang$core$Task$sequence(
				A2(
					_elm_lang$core$List$map,
					A2(_elm_lang$navigation$Navigation$cmdHelp, router, subs),
					cmds)),
			stepState);
	});
_elm_lang$core$Native_Platform.effectManagers['Navigation'] = {pkg: 'elm-lang/navigation', init: _elm_lang$navigation$Navigation$init, onEffects: _elm_lang$navigation$Navigation$onEffects, onSelfMsg: _elm_lang$navigation$Navigation$onSelfMsg, tag: 'fx', cmdMap: _elm_lang$navigation$Navigation$cmdMap, subMap: _elm_lang$navigation$Navigation$subMap};

var _elm_lang$html$Html_Keyed$node = _elm_lang$virtual_dom$VirtualDom$keyedNode;
var _elm_lang$html$Html_Keyed$ol = _elm_lang$html$Html_Keyed$node('ol');
var _elm_lang$html$Html_Keyed$ul = _elm_lang$html$Html_Keyed$node('ul');

var _elm_lang$html$Html_Events$keyCode = A2(_elm_lang$core$Json_Decode$field, 'keyCode', _elm_lang$core$Json_Decode$int);
var _elm_lang$html$Html_Events$targetChecked = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'target',
		_1: {
			ctor: '::',
			_0: 'checked',
			_1: {ctor: '[]'}
		}
	},
	_elm_lang$core$Json_Decode$bool);
var _elm_lang$html$Html_Events$targetValue = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'target',
		_1: {
			ctor: '::',
			_0: 'value',
			_1: {ctor: '[]'}
		}
	},
	_elm_lang$core$Json_Decode$string);
var _elm_lang$html$Html_Events$defaultOptions = _elm_lang$virtual_dom$VirtualDom$defaultOptions;
var _elm_lang$html$Html_Events$onWithOptions = _elm_lang$virtual_dom$VirtualDom$onWithOptions;
var _elm_lang$html$Html_Events$on = _elm_lang$virtual_dom$VirtualDom$on;
var _elm_lang$html$Html_Events$onFocus = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'focus',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onBlur = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'blur',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onSubmitOptions = _elm_lang$core$Native_Utils.update(
	_elm_lang$html$Html_Events$defaultOptions,
	{preventDefault: true});
var _elm_lang$html$Html_Events$onSubmit = function (msg) {
	return A3(
		_elm_lang$html$Html_Events$onWithOptions,
		'submit',
		_elm_lang$html$Html_Events$onSubmitOptions,
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onCheck = function (tagger) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'change',
		A2(_elm_lang$core$Json_Decode$map, tagger, _elm_lang$html$Html_Events$targetChecked));
};
var _elm_lang$html$Html_Events$onInput = function (tagger) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'input',
		A2(_elm_lang$core$Json_Decode$map, tagger, _elm_lang$html$Html_Events$targetValue));
};
var _elm_lang$html$Html_Events$onMouseOut = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseout',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseOver = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseover',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseLeave = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseleave',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseEnter = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseenter',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseUp = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseup',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseDown = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mousedown',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onDoubleClick = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'dblclick',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onClick = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'click',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$Options = F2(
	function (a, b) {
		return {stopPropagation: a, preventDefault: b};
	});

var _Lattyware$massivedecks$MassiveDecks_Util$tbody = _elm_lang$html$Html_Keyed$node('tbody');
var _Lattyware$massivedecks$MassiveDecks_Util$ifIdDecoder = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'target',
		_1: {
			ctor: '::',
			_0: 'id',
			_1: {ctor: '[]'}
		}
	},
	_elm_lang$core$Json_Decode$string);
var _Lattyware$massivedecks$MassiveDecks_Util$onClickIfId = F3(
	function (targetId, message, noOp) {
		return A2(
			_elm_lang$html$Html_Events$on,
			'click',
			A2(
				_elm_lang$core$Json_Decode$map,
				function (clickedId) {
					return _elm_lang$core$Native_Utils.eq(clickedId, targetId) ? message : noOp;
				},
				_Lattyware$massivedecks$MassiveDecks_Util$ifIdDecoder));
	});
var _Lattyware$massivedecks$MassiveDecks_Util$onKeyDown = F3(
	function (key, message, noOp) {
		return A2(
			_elm_lang$html$Html_Events$on,
			'keydown',
			A2(
				_elm_lang$core$Json_Decode$map,
				function (pressed) {
					return _elm_lang$core$Native_Utils.eq(pressed, key) ? message : noOp;
				},
				A2(
					_elm_lang$core$Json_Decode$at,
					{
						ctor: '::',
						_0: 'key',
						_1: {ctor: '[]'}
					},
					_elm_lang$core$Json_Decode$string)));
	});
var _Lattyware$massivedecks$MassiveDecks_Util$isNothing = function (m) {
	var _p0 = m;
	if (_p0.ctor === 'Just') {
		return false;
	} else {
		return true;
	}
};
var _Lattyware$massivedecks$MassiveDecks_Util$after = F2(
	function (waitFor, task) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (_p1) {
				return task;
			},
			_elm_lang$core$Process$sleep(waitFor));
	});
var _Lattyware$massivedecks$MassiveDecks_Util$apply = F2(
	function (fs, value) {
		return A2(
			_elm_lang$core$List$map,
			function (f) {
				return f(value);
			},
			fs);
	});
var _Lattyware$massivedecks$MassiveDecks_Util$joinWithAnd = function (items) {
	var _p2 = items;
	if (_p2.ctor === '[]') {
		return _elm_lang$core$Maybe$Nothing;
	} else {
		if (_p2._1.ctor === '[]') {
			return _elm_lang$core$Maybe$Just(_p2._0);
		} else {
			if (_p2._1._1.ctor === '[]') {
				return _elm_lang$core$Maybe$Just(
					A2(
						_elm_lang$core$Basics_ops['++'],
						_p2._0,
						A2(_elm_lang$core$Basics_ops['++'], ' and ', _p2._1._0)));
			} else {
				return _elm_lang$core$Maybe$Just(
					A2(
						_elm_lang$core$Basics_ops['++'],
						_p2._0,
						A2(
							_elm_lang$core$Basics_ops['++'],
							', ',
							A2(
								_elm_lang$core$Maybe$withDefault,
								'',
								_Lattyware$massivedecks$MassiveDecks_Util$joinWithAnd(_p2._1)))));
			}
		}
	}
};
var _Lattyware$massivedecks$MassiveDecks_Util$pluralHas = function (items) {
	var _p3 = _elm_lang$core$List$length(items);
	if (_p3 === 1) {
		return 'has';
	} else {
		return 'have';
	}
};
var _Lattyware$massivedecks$MassiveDecks_Util$mapFirst = F2(
	function (f, xs) {
		return A2(
			_elm_lang$core$List$indexedMap,
			F2(
				function (index, x) {
					return _elm_lang$core$Native_Utils.eq(index, 0) ? f(x) : x;
				}),
			xs);
	});
var _Lattyware$massivedecks$MassiveDecks_Util$firstLetterToUpper = function (str) {
	return A2(
		_elm_lang$core$Basics_ops['++'],
		_elm_lang$core$String$toUpper(
			A2(_elm_lang$core$String$left, 1, str)),
		A2(_elm_lang$core$String$dropLeft, 1, str));
};
var _Lattyware$massivedecks$MassiveDecks_Util$get = F2(
	function (list, index) {
		var _p4 = A2(_elm_lang$core$List$drop, index, list);
		if (_p4.ctor === '[]') {
			return _elm_lang$core$Maybe$Nothing;
		} else {
			return _elm_lang$core$Maybe$Just(_p4._0);
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Util$getAll = F2(
	function (list, indices) {
		return A2(
			_elm_lang$core$List$filterMap,
			_Lattyware$massivedecks$MassiveDecks_Util$get(list),
			indices);
	});
var _Lattyware$massivedecks$MassiveDecks_Util$getAllWithIndex = F2(
	function (list, indices) {
		return A2(
			_Lattyware$massivedecks$MassiveDecks_Util$getAll,
			A2(
				_elm_lang$core$List$indexedMap,
				F2(
					function (v0, v1) {
						return {ctor: '_Tuple2', _0: v0, _1: v1};
					}),
				list),
			indices);
	});
var _Lattyware$massivedecks$MassiveDecks_Util_ops = _Lattyware$massivedecks$MassiveDecks_Util_ops || {};
_Lattyware$massivedecks$MassiveDecks_Util_ops[':>'] = F3(
	function (a, b, model) {
		var _p5 = a(model);
		var aModel = _p5._0;
		var aMsg = _p5._1;
		var _p6 = b(aModel);
		var bModel = _p6._0;
		var bMsg = _p6._1;
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			bModel,
			{
				ctor: '::',
				_0: aMsg,
				_1: {
					ctor: '::',
					_0: bMsg,
					_1: {ctor: '[]'}
				}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Util$cmd = function (message) {
	return A2(
		_elm_lang$core$Task$perform,
		_elm_lang$core$Basics$identity,
		_elm_lang$core$Task$succeed(message));
};
var _Lattyware$massivedecks$MassiveDecks_Util$lobbyUrl = F2(
	function (url, lobbyId) {
		return A2(
			_elm_lang$core$Basics_ops['++'],
			url,
			A2(_elm_lang$core$Basics_ops['++'], '#', lobbyId));
	});
var _Lattyware$massivedecks$MassiveDecks_Util$interleave = F2(
	function (list1, list2) {
		var _p7 = list1;
		if (_p7.ctor === '[]') {
			return list2;
		} else {
			var _p8 = list2;
			if (_p8.ctor === '[]') {
				return list1;
			} else {
				return {
					ctor: '::',
					_0: _p8._0,
					_1: {
						ctor: '::',
						_0: _p7._0,
						_1: A2(_Lattyware$massivedecks$MassiveDecks_Util$interleave, _p7._1, _p8._1)
					}
				};
			}
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Util$find = F2(
	function (check, items) {
		return _elm_lang$core$List$head(
			A2(_elm_lang$core$List$filter, check, items));
	});
var _Lattyware$massivedecks$MassiveDecks_Util$or = F2(
	function (a, b) {
		var _p9 = a;
		if (_p9.ctor === 'Just') {
			return a;
		} else {
			return b;
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Util$andMaybe = F2(
	function (maybeExtra, values) {
		return A2(
			_elm_lang$core$List$append,
			values,
			A2(
				_elm_lang$core$Maybe$withDefault,
				{ctor: '[]'},
				A2(
					_elm_lang$core$Maybe$map,
					function (value) {
						return {
							ctor: '::',
							_0: value,
							_1: {ctor: '[]'}
						};
					},
					maybeExtra)));
	});
var _Lattyware$massivedecks$MassiveDecks_Util$impossible = function (n) {
	impossible:
	while (true) {
		var _v7 = n;
		n = _v7;
		continue impossible;
	}
};

var _Lattyware$massivedecks$MassiveDecks_Models_Player$byId = F2(
	function (id, players) {
		return A2(
			_Lattyware$massivedecks$MassiveDecks_Util$find,
			function (player) {
				return _elm_lang$core$Native_Utils.eq(player.id, id);
			},
			players);
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Player$statusName = function (status) {
	var _p0 = status;
	switch (_p0.ctor) {
		case 'NotPlayed':
			return 'not-played';
		case 'Played':
			return 'played';
		case 'Czar':
			return 'czar';
		case 'Ai':
			return 'ai';
		case 'Neutral':
			return 'neutral';
		default:
			return 'skipping';
	}
};
var _Lattyware$massivedecks$MassiveDecks_Models_Player$Player = F6(
	function (a, b, c, d, e, f) {
		return {id: a, name: b, status: c, score: d, disconnected: e, left: f};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Player$PlayedByAndWinner = F2(
	function (a, b) {
		return {playedBy: a, winner: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Player$Secret = F2(
	function (a, b) {
		return {id: a, secret: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Player$Skipping = {ctor: 'Skipping'};
var _Lattyware$massivedecks$MassiveDecks_Models_Player$Neutral = {ctor: 'Neutral'};
var _Lattyware$massivedecks$MassiveDecks_Models_Player$Ai = {ctor: 'Ai'};
var _Lattyware$massivedecks$MassiveDecks_Models_Player$Czar = {ctor: 'Czar'};
var _Lattyware$massivedecks$MassiveDecks_Models_Player$Played = {ctor: 'Played'};
var _Lattyware$massivedecks$MassiveDecks_Models_Player$NotPlayed = {ctor: 'NotPlayed'};
var _Lattyware$massivedecks$MassiveDecks_Models_Player$nameToStatus = function (name) {
	var _p1 = name;
	switch (_p1) {
		case 'not-played':
			return _elm_lang$core$Maybe$Just(_Lattyware$massivedecks$MassiveDecks_Models_Player$NotPlayed);
		case 'played':
			return _elm_lang$core$Maybe$Just(_Lattyware$massivedecks$MassiveDecks_Models_Player$Played);
		case 'czar':
			return _elm_lang$core$Maybe$Just(_Lattyware$massivedecks$MassiveDecks_Models_Player$Czar);
		case 'ai':
			return _elm_lang$core$Maybe$Just(_Lattyware$massivedecks$MassiveDecks_Models_Player$Ai);
		case 'neutral':
			return _elm_lang$core$Maybe$Just(_Lattyware$massivedecks$MassiveDecks_Models_Player$Neutral);
		case 'skipping':
			return _elm_lang$core$Maybe$Just(_Lattyware$massivedecks$MassiveDecks_Models_Player$Skipping);
		default:
			return _elm_lang$core$Maybe$Nothing;
	}
};

var _Lattyware$massivedecks$MassiveDecks_Models_Card$playedCardsByPlayer = F2(
	function (players, cards) {
		return _elm_lang$core$Dict$fromList(
			A3(
				_elm_lang$core$List$map2,
				F2(
					function (v0, v1) {
						return {ctor: '_Tuple2', _0: v0, _1: v1};
					}),
				players,
				cards));
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Card$winningCards = F2(
	function (cards, playedByAndWinner) {
		var winner = playedByAndWinner.winner;
		var cardsByPlayer = A2(_Lattyware$massivedecks$MassiveDecks_Models_Card$playedCardsByPlayer, playedByAndWinner.playedBy, cards);
		return A2(_elm_lang$core$Dict$get, winner, cardsByPlayer);
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Card$filled = F2(
	function (call, playedCards) {
		return _elm_lang$core$String$concat(
			A2(
				_Lattyware$massivedecks$MassiveDecks_Util$interleave,
				A2(
					_elm_lang$core$List$map,
					function (_) {
						return _.text;
					},
					playedCards),
				call.parts));
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Card$slots = function (call) {
	return _elm_lang$core$List$length(call.parts) - 1;
};
var _Lattyware$massivedecks$MassiveDecks_Models_Card$Call = F2(
	function (a, b) {
		return {id: a, parts: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Card$Response = F2(
	function (a, b) {
		return {id: a, text: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Card$Hand = function (a) {
	return {hand: a};
};

var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$afterTimeLimit = function (state) {
	var _p0 = state;
	switch (_p0.ctor) {
		case 'P':
			return _p0._0.afterTimeLimit;
		case 'J':
			return _p0._0.afterTimeLimit;
		default:
			return false;
	}
};
var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$Round = F3(
	function (a, b, c) {
		return {czar: a, call: b, state: c};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$Playing = F2(
	function (a, b) {
		return {numberPlayed: a, afterTimeLimit: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$Judging = F2(
	function (a, b) {
		return {responses: a, afterTimeLimit: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$Finished = F2(
	function (a, b) {
		return {responses: a, playedByAndWinner: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$FinishedRound = F3(
	function (a, b, c) {
		return {czar: a, call: b, state: c};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$F = function (a) {
	return {ctor: 'F', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$finished = F2(
	function (responses, playedByAndWinner) {
		return _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$F(
			A2(_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$Finished, responses, playedByAndWinner));
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$J = function (a) {
	return {ctor: 'J', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$judging = F2(
	function (responses, afterTimeLimit) {
		return _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$J(
			A2(_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$Judging, responses, afterTimeLimit));
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$P = function (a) {
	return {ctor: 'P', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$playing = F2(
	function (numberPlayed, afterTimeLimit) {
		return _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$P(
			A2(_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$Playing, numberPlayed, afterTimeLimit));
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$setAfterTimeLimit = F2(
	function (round, afterTimeLimit) {
		var _p1 = round.state;
		switch (_p1.ctor) {
			case 'P':
				return _elm_lang$core$Native_Utils.update(
					round,
					{
						state: _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$P(
							_elm_lang$core$Native_Utils.update(
								_p1._0,
								{afterTimeLimit: afterTimeLimit}))
					});
			case 'J':
				return _elm_lang$core$Native_Utils.update(
					round,
					{
						state: _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$J(
							_elm_lang$core$Native_Utils.update(
								_p1._0,
								{afterTimeLimit: afterTimeLimit}))
					});
			default:
				return round;
		}
	});

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$toString = function (id) {
	var _p0 = id;
	return 'reboot';
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$Reboot = {ctor: 'Reboot'};

var _Lattyware$massivedecks$MassiveDecks_Models_Game$GameCodeAndSecret = F2(
	function (a, b) {
		return {gameCode: a, secret: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game$Config = F3(
	function (a, b, c) {
		return {decks: a, houseRules: b, password: c};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game$DeckInfo = F4(
	function (a, b, c, d) {
		return {id: a, name: b, calls: c, responses: d};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game$Lobby = F5(
	function (a, b, c, d, e) {
		return {gameCode: a, owner: b, config: c, players: d, game: e};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game$LobbyAndHand = F2(
	function (a, b) {
		return {lobby: a, hand: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game$Finished = {ctor: 'Finished'};
var _Lattyware$massivedecks$MassiveDecks_Models_Game$Playing = function (a) {
	return {ctor: 'Playing', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Game$Configuring = {ctor: 'Configuring'};

var _Lattyware$massivedecks$MassiveDecks_Models$pathFromLocation = function (location) {
	return {
		gameCode: A2(
			_elm_lang$core$Maybe$map,
			_elm_lang$core$Tuple$second,
			_elm_lang$core$String$uncons(location.hash))
	};
};
var _Lattyware$massivedecks$MassiveDecks_Models$Init = F5(
	function (a, b, c, d, e) {
		return {version: a, url: b, existingGames: c, seed: d, browserNotificationsSupported: e};
	});
var _Lattyware$massivedecks$MassiveDecks_Models$Path = function (a) {
	return {gameCode: a};
};

var _elm_lang$html$Html_Attributes$map = _elm_lang$virtual_dom$VirtualDom$mapProperty;
var _elm_lang$html$Html_Attributes$attribute = _elm_lang$virtual_dom$VirtualDom$attribute;
var _elm_lang$html$Html_Attributes$contextmenu = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'contextmenu', value);
};
var _elm_lang$html$Html_Attributes$draggable = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'draggable', value);
};
var _elm_lang$html$Html_Attributes$itemprop = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'itemprop', value);
};
var _elm_lang$html$Html_Attributes$tabindex = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'tabIndex',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$charset = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'charset', value);
};
var _elm_lang$html$Html_Attributes$height = function (value) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'height',
		_elm_lang$core$Basics$toString(value));
};
var _elm_lang$html$Html_Attributes$width = function (value) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'width',
		_elm_lang$core$Basics$toString(value));
};
var _elm_lang$html$Html_Attributes$formaction = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'formAction', value);
};
var _elm_lang$html$Html_Attributes$list = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'list', value);
};
var _elm_lang$html$Html_Attributes$minlength = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'minLength',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$maxlength = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'maxlength',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$size = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'size',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$form = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'form', value);
};
var _elm_lang$html$Html_Attributes$cols = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'cols',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$rows = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'rows',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$challenge = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'challenge', value);
};
var _elm_lang$html$Html_Attributes$media = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'media', value);
};
var _elm_lang$html$Html_Attributes$rel = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'rel', value);
};
var _elm_lang$html$Html_Attributes$datetime = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'datetime', value);
};
var _elm_lang$html$Html_Attributes$pubdate = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'pubdate', value);
};
var _elm_lang$html$Html_Attributes$colspan = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'colspan',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$rowspan = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'rowspan',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$manifest = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'manifest', value);
};
var _elm_lang$html$Html_Attributes$property = _elm_lang$virtual_dom$VirtualDom$property;
var _elm_lang$html$Html_Attributes$stringProperty = F2(
	function (name, string) {
		return A2(
			_elm_lang$html$Html_Attributes$property,
			name,
			_elm_lang$core$Json_Encode$string(string));
	});
var _elm_lang$html$Html_Attributes$class = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'className', name);
};
var _elm_lang$html$Html_Attributes$id = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'id', name);
};
var _elm_lang$html$Html_Attributes$title = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'title', name);
};
var _elm_lang$html$Html_Attributes$accesskey = function ($char) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'accessKey',
		_elm_lang$core$String$fromChar($char));
};
var _elm_lang$html$Html_Attributes$dir = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'dir', value);
};
var _elm_lang$html$Html_Attributes$dropzone = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'dropzone', value);
};
var _elm_lang$html$Html_Attributes$lang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'lang', value);
};
var _elm_lang$html$Html_Attributes$content = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'content', value);
};
var _elm_lang$html$Html_Attributes$httpEquiv = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'httpEquiv', value);
};
var _elm_lang$html$Html_Attributes$language = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'language', value);
};
var _elm_lang$html$Html_Attributes$src = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'src', value);
};
var _elm_lang$html$Html_Attributes$alt = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'alt', value);
};
var _elm_lang$html$Html_Attributes$preload = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'preload', value);
};
var _elm_lang$html$Html_Attributes$poster = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'poster', value);
};
var _elm_lang$html$Html_Attributes$kind = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'kind', value);
};
var _elm_lang$html$Html_Attributes$srclang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'srclang', value);
};
var _elm_lang$html$Html_Attributes$sandbox = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'sandbox', value);
};
var _elm_lang$html$Html_Attributes$srcdoc = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'srcdoc', value);
};
var _elm_lang$html$Html_Attributes$type_ = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'type', value);
};
var _elm_lang$html$Html_Attributes$value = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'value', value);
};
var _elm_lang$html$Html_Attributes$defaultValue = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'defaultValue', value);
};
var _elm_lang$html$Html_Attributes$placeholder = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'placeholder', value);
};
var _elm_lang$html$Html_Attributes$accept = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'accept', value);
};
var _elm_lang$html$Html_Attributes$acceptCharset = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'acceptCharset', value);
};
var _elm_lang$html$Html_Attributes$action = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'action', value);
};
var _elm_lang$html$Html_Attributes$autocomplete = function (bool) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'autocomplete',
		bool ? 'on' : 'off');
};
var _elm_lang$html$Html_Attributes$enctype = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'enctype', value);
};
var _elm_lang$html$Html_Attributes$method = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'method', value);
};
var _elm_lang$html$Html_Attributes$name = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'name', value);
};
var _elm_lang$html$Html_Attributes$pattern = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'pattern', value);
};
var _elm_lang$html$Html_Attributes$for = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'htmlFor', value);
};
var _elm_lang$html$Html_Attributes$max = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'max', value);
};
var _elm_lang$html$Html_Attributes$min = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'min', value);
};
var _elm_lang$html$Html_Attributes$step = function (n) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'step', n);
};
var _elm_lang$html$Html_Attributes$wrap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'wrap', value);
};
var _elm_lang$html$Html_Attributes$usemap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'useMap', value);
};
var _elm_lang$html$Html_Attributes$shape = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'shape', value);
};
var _elm_lang$html$Html_Attributes$coords = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'coords', value);
};
var _elm_lang$html$Html_Attributes$keytype = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'keytype', value);
};
var _elm_lang$html$Html_Attributes$align = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'align', value);
};
var _elm_lang$html$Html_Attributes$cite = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'cite', value);
};
var _elm_lang$html$Html_Attributes$href = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'href', value);
};
var _elm_lang$html$Html_Attributes$target = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'target', value);
};
var _elm_lang$html$Html_Attributes$downloadAs = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'download', value);
};
var _elm_lang$html$Html_Attributes$hreflang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'hreflang', value);
};
var _elm_lang$html$Html_Attributes$ping = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'ping', value);
};
var _elm_lang$html$Html_Attributes$start = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'start',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$headers = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'headers', value);
};
var _elm_lang$html$Html_Attributes$scope = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'scope', value);
};
var _elm_lang$html$Html_Attributes$boolProperty = F2(
	function (name, bool) {
		return A2(
			_elm_lang$html$Html_Attributes$property,
			name,
			_elm_lang$core$Json_Encode$bool(bool));
	});
var _elm_lang$html$Html_Attributes$hidden = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'hidden', bool);
};
var _elm_lang$html$Html_Attributes$contenteditable = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'contentEditable', bool);
};
var _elm_lang$html$Html_Attributes$spellcheck = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'spellcheck', bool);
};
var _elm_lang$html$Html_Attributes$async = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'async', bool);
};
var _elm_lang$html$Html_Attributes$defer = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'defer', bool);
};
var _elm_lang$html$Html_Attributes$scoped = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'scoped', bool);
};
var _elm_lang$html$Html_Attributes$autoplay = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'autoplay', bool);
};
var _elm_lang$html$Html_Attributes$controls = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'controls', bool);
};
var _elm_lang$html$Html_Attributes$loop = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'loop', bool);
};
var _elm_lang$html$Html_Attributes$default = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'default', bool);
};
var _elm_lang$html$Html_Attributes$seamless = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'seamless', bool);
};
var _elm_lang$html$Html_Attributes$checked = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'checked', bool);
};
var _elm_lang$html$Html_Attributes$selected = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'selected', bool);
};
var _elm_lang$html$Html_Attributes$autofocus = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'autofocus', bool);
};
var _elm_lang$html$Html_Attributes$disabled = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'disabled', bool);
};
var _elm_lang$html$Html_Attributes$multiple = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'multiple', bool);
};
var _elm_lang$html$Html_Attributes$novalidate = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'noValidate', bool);
};
var _elm_lang$html$Html_Attributes$readonly = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'readOnly', bool);
};
var _elm_lang$html$Html_Attributes$required = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'required', bool);
};
var _elm_lang$html$Html_Attributes$ismap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'isMap', value);
};
var _elm_lang$html$Html_Attributes$download = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'download', bool);
};
var _elm_lang$html$Html_Attributes$reversed = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'reversed', bool);
};
var _elm_lang$html$Html_Attributes$classList = function (list) {
	return _elm_lang$html$Html_Attributes$class(
		A2(
			_elm_lang$core$String$join,
			' ',
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$Tuple$first,
				A2(_elm_lang$core$List$filter, _elm_lang$core$Tuple$second, list))));
};
var _elm_lang$html$Html_Attributes$style = _elm_lang$virtual_dom$VirtualDom$style;

var _Lattyware$massivedecks$MassiveDecks_Components_Tabs$viewPane = F3(
	function (current, renderer, model) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$classList(
					{
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 'mui-tabs__pane', _1: true},
						_1: {
							ctor: '::',
							_0: {
								ctor: '_Tuple2',
								_0: 'mui--is-active',
								_1: _elm_lang$core$Native_Utils.eq(current, model.id)
							},
							_1: {ctor: '[]'}
						}
					}),
				_1: {ctor: '[]'}
			},
			renderer(model.id));
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Tabs$update = F2(
	function (message, model) {
		var _p0 = message;
		return _elm_lang$core$Native_Utils.update(
			model,
			{current: _p0._0});
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Tabs$Model = F3(
	function (a, b, c) {
		return {tabs: a, current: b, tagger: c};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Tabs$init = _Lattyware$massivedecks$MassiveDecks_Components_Tabs$Model;
var _Lattyware$massivedecks$MassiveDecks_Components_Tabs$Tab = F2(
	function (a, b) {
		return {id: a, title: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Tabs$SetTab = function (a) {
	return {ctor: 'SetTab', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_Tabs$viewTab = F3(
	function (tagger, current, model) {
		return A2(
			_elm_lang$html$Html$li,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$classList(
					{
						ctor: '::',
						_0: {
							ctor: '_Tuple2',
							_0: 'mui--is-active',
							_1: _elm_lang$core$Native_Utils.eq(current, model.id)
						},
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$a,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Events$onClick(
							tagger(
								_Lattyware$massivedecks$MassiveDecks_Components_Tabs$SetTab(model.id))),
						_1: {ctor: '[]'}
					},
					model.title),
				_1: {ctor: '[]'}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Tabs$view = F2(
	function (renderer, model) {
		return A2(
			_elm_lang$core$Basics_ops['++'],
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$ul,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('mui-tabs__bar mui-tabs__bar--justified'),
						_1: {ctor: '[]'}
					},
					A2(
						_elm_lang$core$List$map,
						A2(_Lattyware$massivedecks$MassiveDecks_Components_Tabs$viewTab, model.tagger, model.current),
						model.tabs)),
				_1: {ctor: '[]'}
			},
			A2(
				_elm_lang$core$List$map,
				A2(_Lattyware$massivedecks$MassiveDecks_Components_Tabs$viewPane, model.current, renderer),
				model.tabs));
	});

var _Lattyware$massivedecks$MassiveDecks_Components_Storage$different = F2(
	function (check, existing) {
		return !_elm_lang$core$Native_Utils.eq(check.gameCode, existing.gameCode);
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Storage$leave = function (gameCodeAndSecret) {
	return _elm_lang$core$List$filter(
		_Lattyware$massivedecks$MassiveDecks_Components_Storage$different(gameCodeAndSecret));
};
var _Lattyware$massivedecks$MassiveDecks_Components_Storage$join = F2(
	function (gameCodeAndSecret, model) {
		return {
			ctor: '::',
			_0: gameCodeAndSecret,
			_1: A2(
				_elm_lang$core$List$filter,
				_Lattyware$massivedecks$MassiveDecks_Components_Storage$different(gameCodeAndSecret),
				model)
		};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Storage$store = _elm_lang$core$Native_Platform.outgoingPort(
	'store',
	function (v) {
		return _elm_lang$core$Native_List.toArray(v).map(
			function (v) {
				return {
					gameCode: v.gameCode,
					secret: {id: v.secret.id, secret: v.secret.secret}
				};
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Storage$update = F2(
	function (message, model) {
		var _p0 = message;
		if (_p0.ctor === 'Store') {
			return {
				ctor: '_Tuple2',
				_0: model,
				_1: _Lattyware$massivedecks$MassiveDecks_Components_Storage$store(model)
			};
		} else {
			return {
				ctor: '_Tuple2',
				_0: {ctor: '[]'},
				_1: _Lattyware$massivedecks$MassiveDecks_Components_Storage$store(
					{ctor: '[]'})
			};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Storage$Clear = {ctor: 'Clear'};
var _Lattyware$massivedecks$MassiveDecks_Components_Storage$Store = {ctor: 'Store'};

var _Lattyware$massivedecks$MassiveDecks_Components_Icon$spinner = A2(
	_elm_lang$html$Html$i,
	{
		ctor: '::',
		_0: _elm_lang$html$Html_Attributes$class('fa fa-circle-o-notch fa-spin'),
		_1: {ctor: '[]'}
	},
	{ctor: '[]'});
var _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon = function (name) {
	return A2(
		_elm_lang$html$Html$i,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class(
				A2(_elm_lang$core$Basics_ops['++'], 'fa fa-fw fa-', name)),
			_1: {ctor: '[]'}
		},
		{ctor: '[]'});
};
var _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon = function (name) {
	return A2(
		_elm_lang$html$Html$i,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class(
				A2(_elm_lang$core$Basics_ops['++'], 'fa fa-', name)),
			_1: {ctor: '[]'}
		},
		{ctor: '[]'});
};

var _Lattyware$massivedecks$MassiveDecks_Components_Input$update = F2(
	function (message, model) {
		var _p0 = message;
		var identity = _p0._0;
		var change = _p0._1;
		if (_elm_lang$core$Native_Utils.eq(identity, model.identity)) {
			var _p1 = change;
			switch (_p1.ctor) {
				case 'Changed':
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Native_Utils.update(
							model,
							{value: _p1._0, error: _elm_lang$core$Maybe$Nothing}),
						_1: _elm_lang$core$Platform_Cmd$none
					};
				case 'Error':
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Native_Utils.update(
							model,
							{error: _p1._0}),
						_1: _elm_lang$core$Platform_Cmd$none
					};
				case 'Submit':
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Native_Utils.update(
							model,
							{error: _elm_lang$core$Maybe$Nothing}),
						_1: model.submit
					};
				case 'SetEnabled':
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Native_Utils.update(
							model,
							{enabled: _p1._0}),
						_1: _elm_lang$core$Platform_Cmd$none
					};
				case 'SetDefaultValue':
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Native_Utils.update(
							model,
							{value: _p1._0}),
						_1: _elm_lang$core$Platform_Cmd$none
					};
				default:
					return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
			}
		} else {
			return {
				ctor: '_Tuple2',
				_0: _elm_lang$core$Native_Utils.update(
					model,
					{error: _elm_lang$core$Maybe$Nothing}),
				_1: _elm_lang$core$Platform_Cmd$none
			};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Input$error = function (message) {
	return A2(
		_elm_lang$core$Maybe$map,
		function (error) {
			return A2(
				_elm_lang$html$Html$span,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('input-error'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('exclamation'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html$text(' '),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text(error),
							_1: {ctor: '[]'}
						}
					}
				});
		},
		message);
};
var _Lattyware$massivedecks$MassiveDecks_Components_Input$subscriptions = function (model) {
	return _elm_lang$core$Platform_Sub$none;
};
var _Lattyware$massivedecks$MassiveDecks_Components_Input$initWithExtra = F8(
	function (identity, $class, label, value, placeholder, extra, submit, embedMethod) {
		return {identity: identity, $class: $class, label: label, value: value, placeholder: placeholder, error: _elm_lang$core$Maybe$Nothing, extra: extra, embedMethod: embedMethod, submit: submit, enabled: true};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Input$init = F7(
	function (identity, $class, label, value, placeholder, submit, embedMethod) {
		return A8(
			_Lattyware$massivedecks$MassiveDecks_Components_Input$initWithExtra,
			identity,
			$class,
			label,
			value,
			placeholder,
			function (_p2) {
				return {ctor: '[]'};
			},
			submit,
			embedMethod);
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Input$Model = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return {identity: a, $class: b, label: c, placeholder: d, value: e, error: f, extra: g, embedMethod: h, submit: i, enabled: j};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var _Lattyware$massivedecks$MassiveDecks_Components_Input$NoOp = {ctor: 'NoOp'};
var _Lattyware$massivedecks$MassiveDecks_Components_Input$SetDefaultValue = function (a) {
	return {ctor: 'SetDefaultValue', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_Input$SetEnabled = function (a) {
	return {ctor: 'SetEnabled', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_Input$Submit = {ctor: 'Submit'};
var _Lattyware$massivedecks$MassiveDecks_Components_Input$Error = function (a) {
	return {ctor: 'Error', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_Input$Changed = function (a) {
	return {ctor: 'Changed', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_Input$view = function (model) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class(model.$class),
			_1: {ctor: '[]'}
		},
		A2(
			_elm_lang$core$Basics_ops['++'],
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('mui-textfield'),
						_1: {ctor: '[]'}
					},
					A2(
						_Lattyware$massivedecks$MassiveDecks_Util$andMaybe,
						_Lattyware$massivedecks$MassiveDecks_Components_Input$error(model.error),
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$input,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$type_('text'),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$defaultValue(model.value),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$placeholder(model.placeholder),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$disabled(!model.enabled),
												_1: {
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html_Events$on,
														'input',
														A2(
															_elm_lang$core$Json_Decode$map,
															function (value) {
																return model.embedMethod(
																	{
																		ctor: '_Tuple2',
																		_0: model.identity,
																		_1: _Lattyware$massivedecks$MassiveDecks_Components_Input$Changed(value)
																	});
															},
															_elm_lang$html$Html_Events$targetValue)),
													_1: {
														ctor: '::',
														_0: A3(
															_Lattyware$massivedecks$MassiveDecks_Util$onKeyDown,
															'Enter',
															model.embedMethod(
																{ctor: '_Tuple2', _0: model.identity, _1: _Lattyware$massivedecks$MassiveDecks_Components_Input$Submit}),
															model.embedMethod(
																{ctor: '_Tuple2', _0: model.identity, _1: _Lattyware$massivedecks$MassiveDecks_Components_Input$NoOp})),
														_1: {ctor: '[]'}
													}
												}
											}
										}
									}
								},
								{ctor: '[]'}),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$label,
									{ctor: '[]'},
									A2(
										_elm_lang$core$List$append,
										{
											ctor: '::',
											_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('info-circle'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html$text(' '),
												_1: {ctor: '[]'}
											}
										},
										model.label)),
								_1: {ctor: '[]'}
							}
						})),
				_1: {ctor: '[]'}
			},
			model.extra(model.value)));
};

var _Lattyware$massivedecks$MassiveDecks_Components_Errors$reportUrl = F2(
	function (applicationInfo, message) {
		var version = _elm_lang$core$String$isEmpty(applicationInfo.version) ? 'Not Specified' : applicationInfo.version;
		var full = A2(
			_elm_lang$core$Basics_ops['++'],
			message,
			A2(
				_elm_lang$core$Basics_ops['++'],
				'\n\nApplication Info:\n\tVersion: ',
				A2(
					_elm_lang$core$Basics_ops['++'],
					version,
					A2(_elm_lang$core$Basics_ops['++'], '\n\tURL: ', applicationInfo.url))));
		return A2(_elm_lang$core$Basics_ops['++'], 'https://github.com/Lattyware/massivedecks/issues/new?body=', full);
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$reportText = function (message) {
	return A2(_elm_lang$core$Basics_ops['++'], 'I was [a short explanation of what you were doing] when I got the following error: \n\n', message);
};
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$update = F2(
	function (message, model) {
		var _p0 = message;
		if (_p0.ctor === 'New') {
			var $new = {id: model.currentId, message: _p0._0, bugReport: _p0._1};
			return {
				ctor: '_Tuple2',
				_0: _elm_lang$core$Native_Utils.update(
					model,
					{
						errors: A2(
							_elm_lang$core$Basics_ops['++'],
							model.errors,
							{
								ctor: '::',
								_0: $new,
								_1: {ctor: '[]'}
							}),
						currentId: model.currentId + 1
					}),
				_1: _elm_lang$core$Platform_Cmd$none
			};
		} else {
			return {
				ctor: '_Tuple2',
				_0: _elm_lang$core$Native_Utils.update(
					model,
					{
						errors: A2(
							_elm_lang$core$List$filter,
							function (error) {
								return !_elm_lang$core$Native_Utils.eq(error.id, _p0._0);
							},
							model.errors)
					}),
				_1: _elm_lang$core$Platform_Cmd$none
			};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$init = {
	currentId: 0,
	errors: {ctor: '[]'}
};
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$Model = F2(
	function (a, b) {
		return {currentId: a, errors: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$ApplicationInfo = F2(
	function (a, b) {
		return {url: a, version: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$Error = F3(
	function (a, b, c) {
		return {id: a, message: b, bugReport: c};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$Remove = function (a) {
	return {ctor: 'Remove', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$errorMessage = F2(
	function (applicationInfo, error) {
		var url = A2(
			_Lattyware$massivedecks$MassiveDecks_Components_Errors$reportUrl,
			applicationInfo,
			_Lattyware$massivedecks$MassiveDecks_Components_Errors$reportText(error.message));
		var bugReportLink = error.bugReport ? _elm_lang$core$Maybe$Just(
			A2(
				_elm_lang$html$Html$p,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$a,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$href(url),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$target('_blank'),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$rel('noopener'),
									_1: {ctor: '[]'}
								}
							}
						},
						{
							ctor: '::',
							_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('bug'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text(' Report this as a bug.'),
								_1: {ctor: '[]'}
							}
						}),
					_1: {ctor: '[]'}
				})) : _elm_lang$core$Maybe$Nothing;
		return A2(
			_elm_lang$html$Html$li,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('error'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{ctor: '[]'},
					A2(
						_Lattyware$massivedecks$MassiveDecks_Util$andMaybe,
						bugReportLink,
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$a,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('link'),
									_1: {
										ctor: '::',
										_0: A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
										_1: {
											ctor: '::',
											_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Events$onClick(
													_Lattyware$massivedecks$MassiveDecks_Components_Errors$Remove(error.id)),
												_1: {ctor: '[]'}
											}
										}
									}
								},
								{
									ctor: '::',
									_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('times'),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$h5,
									{ctor: '[]'},
									{
										ctor: '::',
										_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('exclamation-triangle'),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html$text(' Error'),
											_1: {ctor: '[]'}
										}
									}),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$div,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('mui-divider'),
											_1: {ctor: '[]'}
										},
										{ctor: '[]'}),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$p,
											{ctor: '[]'},
											{
												ctor: '::',
												_0: _elm_lang$html$Html$text(error.message),
												_1: {ctor: '[]'}
											}),
										_1: {ctor: '[]'}
									}
								}
							}
						})),
				_1: {ctor: '[]'}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$view = F2(
	function (applicationInfo, model) {
		return A2(
			_elm_lang$html$Html$ol,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$id('error-panel'),
				_1: {ctor: '[]'}
			},
			A2(
				_elm_lang$core$List$map,
				_Lattyware$massivedecks$MassiveDecks_Components_Errors$errorMessage(applicationInfo),
				model.errors));
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$New = F2(
	function (a, b) {
		return {ctor: 'New', _0: a, _1: b};
	});

var _Lattyware$massivedecks$MassiveDecks_Components_Overlay$update = F2(
	function (message, model) {
		var _p0 = message;
		switch (_p0.ctor) {
			case 'Show':
				return _elm_lang$core$Native_Utils.update(
					model,
					{
						overlay: _elm_lang$core$Maybe$Just(_p0._0)
					});
			case 'Hide':
				return _elm_lang$core$Native_Utils.update(
					model,
					{overlay: _elm_lang$core$Maybe$Nothing});
			default:
				return model;
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Overlay$init = function (wrap) {
	return {overlay: _elm_lang$core$Maybe$Nothing, wrap: wrap};
};
var _Lattyware$massivedecks$MassiveDecks_Components_Overlay$Model = F2(
	function (a, b) {
		return {overlay: a, wrap: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Overlay$Overlay = F3(
	function (a, b, c) {
		return {icon: a, title: b, contents: c};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Overlay$NoOp = {ctor: 'NoOp'};
var _Lattyware$massivedecks$MassiveDecks_Components_Overlay$Hide = {ctor: 'Hide'};
var _Lattyware$massivedecks$MassiveDecks_Components_Overlay$view = function (model) {
	var _p1 = model.overlay;
	if (_p1.ctor === 'Just') {
		var _p2 = _p1._0;
		return {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$id('mui-overlay'),
					_1: {
						ctor: '::',
						_0: A3(
							_Lattyware$massivedecks$MassiveDecks_Util$onClickIfId,
							'mui-overlay',
							model.wrap(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Hide),
							model.wrap(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$NoOp)),
						_1: {
							ctor: '::',
							_0: A3(
								_Lattyware$massivedecks$MassiveDecks_Util$onKeyDown,
								'Escape',
								model.wrap(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Hide),
								model.wrap(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$NoOp)),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$tabindex(0),
								_1: {ctor: '[]'}
							}
						}
					}
				},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('overlay mui-panel'),
							_1: {ctor: '[]'}
						},
						A2(
							_elm_lang$core$Basics_ops['++'],
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$h1,
									{ctor: '[]'},
									{
										ctor: '::',
										_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon(_p2.icon),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html$text(' '),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html$text(_p2.title),
												_1: {ctor: '[]'}
											}
										}
									}),
								_1: {ctor: '[]'}
							},
							A2(
								_elm_lang$core$Basics_ops['++'],
								_p2.contents,
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$p,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('close-link'),
											_1: {ctor: '[]'}
										},
										{
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$a,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$class('link'),
													_1: {
														ctor: '::',
														_0: A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
														_1: {
															ctor: '::',
															_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Events$onClick(
																	model.wrap(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Hide)),
																_1: {ctor: '[]'}
															}
														}
													}
												},
												{
													ctor: '::',
													_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('times'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html$text(' Close'),
														_1: {ctor: '[]'}
													}
												}),
											_1: {ctor: '[]'}
										}),
									_1: {ctor: '[]'}
								}))),
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		};
	} else {
		return {ctor: '[]'};
	}
};
var _Lattyware$massivedecks$MassiveDecks_Components_Overlay$Show = function (a) {
	return {ctor: 'Show', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_Overlay$map = F2(
	function (mapper, message) {
		var _p3 = message;
		switch (_p3.ctor) {
			case 'Show':
				var _p4 = _p3._0;
				return _Lattyware$massivedecks$MassiveDecks_Components_Overlay$Show(
					A3(
						_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Overlay,
						_p4.icon,
						_p4.title,
						A2(
							_elm_lang$core$List$map,
							_elm_lang$html$Html$map(mapper),
							_p4.contents)));
			case 'Hide':
				return _Lattyware$massivedecks$MassiveDecks_Components_Overlay$Hide;
			default:
				return _Lattyware$massivedecks$MassiveDecks_Components_Overlay$NoOp;
		}
	});

var _Lattyware$massivedecks$MassiveDecks_Components_Title$title = _elm_lang$core$Native_Platform.outgoingPort(
	'title',
	function (v) {
		return v;
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Title$set = _Lattyware$massivedecks$MassiveDecks_Components_Title$title;

var _Lattyware$massivedecks$MassiveDecks_Models_Notification$hide = function (notification) {
	return _elm_lang$core$Native_Utils.update(
		notification,
		{visible: false});
};
var _Lattyware$massivedecks$MassiveDecks_Models_Notification$Notification = F4(
	function (a, b, c, d) {
		return {icon: a, name: b, description: c, visible: d};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Notification$playerFromIdAndPlayers = F4(
	function (id, players, icon, suffix) {
		return A2(
			_elm_lang$core$Maybe$map,
			function (name) {
				return A4(
					_Lattyware$massivedecks$MassiveDecks_Models_Notification$Notification,
					icon,
					name,
					A2(_elm_lang$core$Basics_ops['++'], name, suffix),
					true);
			},
			A2(
				_elm_lang$core$Maybe$map,
				function (_) {
					return _.name;
				},
				A2(_Lattyware$massivedecks$MassiveDecks_Models_Player$byId, id, players)));
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Notification$playerJoin = F2(
	function (id, players) {
		return A4(_Lattyware$massivedecks$MassiveDecks_Models_Notification$playerFromIdAndPlayers, id, players, 'sign-in', ' has joined the game.');
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Notification$playerReconnect = F2(
	function (id, players) {
		return A4(_Lattyware$massivedecks$MassiveDecks_Models_Notification$playerFromIdAndPlayers, id, players, 'sign-in', ' has reconnected to the game.');
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Notification$playerDisconnect = F2(
	function (id, players) {
		return A4(_Lattyware$massivedecks$MassiveDecks_Models_Notification$playerFromIdAndPlayers, id, players, 'minus-circle', ' has disconnected from the game.');
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Notification$playerLeft = F2(
	function (id, players) {
		return A4(_Lattyware$massivedecks$MassiveDecks_Models_Notification$playerFromIdAndPlayers, id, players, 'sign-out', ' has left the game.');
	});

var _elm_lang$window$Native_Window = function()
{

var size = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)	{
	callback(_elm_lang$core$Native_Scheduler.succeed({
		width: window.innerWidth,
		height: window.innerHeight
	}));
});

return {
	size: size
};

}();
var _elm_lang$window$Window_ops = _elm_lang$window$Window_ops || {};
_elm_lang$window$Window_ops['&>'] = F2(
	function (task1, task2) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (_p0) {
				return task2;
			},
			task1);
	});
var _elm_lang$window$Window$onSelfMsg = F3(
	function (router, dimensions, state) {
		var _p1 = state;
		if (_p1.ctor === 'Nothing') {
			return _elm_lang$core$Task$succeed(state);
		} else {
			var send = function (_p2) {
				var _p3 = _p2;
				return A2(
					_elm_lang$core$Platform$sendToApp,
					router,
					_p3._0(dimensions));
			};
			return A2(
				_elm_lang$window$Window_ops['&>'],
				_elm_lang$core$Task$sequence(
					A2(_elm_lang$core$List$map, send, _p1._0.subs)),
				_elm_lang$core$Task$succeed(state));
		}
	});
var _elm_lang$window$Window$init = _elm_lang$core$Task$succeed(_elm_lang$core$Maybe$Nothing);
var _elm_lang$window$Window$size = _elm_lang$window$Native_Window.size;
var _elm_lang$window$Window$width = A2(
	_elm_lang$core$Task$map,
	function (_) {
		return _.width;
	},
	_elm_lang$window$Window$size);
var _elm_lang$window$Window$height = A2(
	_elm_lang$core$Task$map,
	function (_) {
		return _.height;
	},
	_elm_lang$window$Window$size);
var _elm_lang$window$Window$onEffects = F3(
	function (router, newSubs, oldState) {
		var _p4 = {ctor: '_Tuple2', _0: oldState, _1: newSubs};
		if (_p4._0.ctor === 'Nothing') {
			if (_p4._1.ctor === '[]') {
				return _elm_lang$core$Task$succeed(_elm_lang$core$Maybe$Nothing);
			} else {
				return A2(
					_elm_lang$core$Task$andThen,
					function (pid) {
						return _elm_lang$core$Task$succeed(
							_elm_lang$core$Maybe$Just(
								{subs: newSubs, pid: pid}));
					},
					_elm_lang$core$Process$spawn(
						A3(
							_elm_lang$dom$Dom_LowLevel$onWindow,
							'resize',
							_elm_lang$core$Json_Decode$succeed(
								{ctor: '_Tuple0'}),
							function (_p5) {
								return A2(
									_elm_lang$core$Task$andThen,
									_elm_lang$core$Platform$sendToSelf(router),
									_elm_lang$window$Window$size);
							})));
			}
		} else {
			if (_p4._1.ctor === '[]') {
				return A2(
					_elm_lang$window$Window_ops['&>'],
					_elm_lang$core$Process$kill(_p4._0._0.pid),
					_elm_lang$core$Task$succeed(_elm_lang$core$Maybe$Nothing));
			} else {
				return _elm_lang$core$Task$succeed(
					_elm_lang$core$Maybe$Just(
						{subs: newSubs, pid: _p4._0._0.pid}));
			}
		}
	});
var _elm_lang$window$Window$subscription = _elm_lang$core$Native_Platform.leaf('Window');
var _elm_lang$window$Window$Size = F2(
	function (a, b) {
		return {width: a, height: b};
	});
var _elm_lang$window$Window$MySub = function (a) {
	return {ctor: 'MySub', _0: a};
};
var _elm_lang$window$Window$resizes = function (tagger) {
	return _elm_lang$window$Window$subscription(
		_elm_lang$window$Window$MySub(tagger));
};
var _elm_lang$window$Window$subMap = F2(
	function (func, _p6) {
		var _p7 = _p6;
		return _elm_lang$window$Window$MySub(
			function (_p8) {
				return func(
					_p7._0(_p8));
			});
	});
_elm_lang$core$Native_Platform.effectManagers['Window'] = {pkg: 'elm-lang/window', init: _elm_lang$window$Window$init, onEffects: _elm_lang$window$Window$onEffects, onSelfMsg: _elm_lang$window$Window$onSelfMsg, tag: 'sub', subMap: _elm_lang$window$Window$subMap};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Sidebar$init = function (enhanceWidth) {
	return {enhanceWidth: enhanceWidth, hidden: false, shownAsOverlay: false};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Sidebar$Model = F3(
	function (a, b, c) {
		return {enhanceWidth: a, hidden: b, shownAsOverlay: c};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Sidebar$Hide = {ctor: 'Hide'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Sidebar$Show = function (a) {
	return {ctor: 'Show', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Sidebar$update = F2(
	function (message, model) {
		var _p0 = message;
		switch (_p0.ctor) {
			case 'Toggle':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A2(_elm_lang$core$Task$perform, _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Sidebar$Show, _elm_lang$window$Window$width)
				};
			case 'Show':
				return model.shownAsOverlay ? {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{shownAsOverlay: false}),
					_1: _elm_lang$core$Platform_Cmd$none
				} : ((_elm_lang$core$Native_Utils.cmp(_p0._0, model.enhanceWidth) > 0) ? {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{hidden: !model.hidden}),
					_1: _elm_lang$core$Platform_Cmd$none
				} : {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{shownAsOverlay: true}),
					_1: _elm_lang$core$Platform_Cmd$none
				});
			default:
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{shownAsOverlay: false}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Sidebar$Toggle = {ctor: 'Toggle'};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage = function (a) {
	return {ctor: 'LocalMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage = function (a) {
	return {ctor: 'ErrorMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$HandUpdate = function (a) {
	return {ctor: 'HandUpdate', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$NoOp = {ctor: 'NoOp'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$SetPassword = {ctor: 'SetPassword'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$DisableRule = function (a) {
	return {ctor: 'DisableRule', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$EnableRule = function (a) {
	return {ctor: 'EnableRule', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$StartGame = {ctor: 'StartGame'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$AddAi = {ctor: 'AddAi'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$InputMessage = function (a) {
	return {ctor: 'InputMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ConfigureDecks = function (a) {
	return {ctor: 'ConfigureDecks', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$AddDeck = {ctor: 'AddDeck'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Fail = F2(
	function (a, b) {
		return {ctor: 'Fail', _0: a, _1: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Add = function (a) {
	return {ctor: 'Add', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Request = function (a) {
	return {ctor: 'Request', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Password = {ctor: 'Password'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$DeckId = {ctor: 'DeckId'};

var _Lattyware$massivedecks$MassiveDecks_Components_TTS$init = {enabled: false};
var _Lattyware$massivedecks$MassiveDecks_Components_TTS$say = _elm_lang$core$Native_Platform.outgoingPort(
	'say',
	function (v) {
		return v;
	});
var _Lattyware$massivedecks$MassiveDecks_Components_TTS$Model = function (a) {
	return {enabled: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_TTS$Enabled = function (a) {
	return {ctor: 'Enabled', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_TTS$Say = function (a) {
	return {ctor: 'Say', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_TTS$update = F2(
	function (message, model) {
		var _p0 = message;
		if (_p0.ctor === 'Say') {
			return {
				ctor: '_Tuple2',
				_0: model,
				_1: model.enabled ? _Lattyware$massivedecks$MassiveDecks_Components_TTS$say(_p0._0) : _elm_lang$core$Platform_Cmd$none
			};
		} else {
			var _p1 = _p0._0;
			return {
				ctor: '_Tuple2',
				_0: _elm_lang$core$Native_Utils.update(
					model,
					{enabled: _p1}),
				_1: _p1 ? _elm_lang$core$Platform_Cmd$none : _Lattyware$massivedecks$MassiveDecks_Util$cmd(
					_Lattyware$massivedecks$MassiveDecks_Components_TTS$Say(''))
			};
		}
	});

var _Lattyware$massivedecks$MassiveDecks_Scenes_History_Messages$LocalMessage = function (a) {
	return {ctor: 'LocalMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_History_Messages$Close = {ctor: 'Close'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_History_Messages$ErrorMessage = function (a) {
	return {ctor: 'ErrorMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_History_Messages$Load = function (a) {
	return {ctor: 'Load', _0: a};
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage = function (a) {
	return {ctor: 'LocalMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage = function (a) {
	return {ctor: 'ErrorMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$TTSMessage = function (a) {
	return {ctor: 'TTSMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$HandUpdate = function (a) {
	return {ctor: 'HandUpdate', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$NoOp = {ctor: 'NoOp'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$HistoryMessage = function (a) {
	return {ctor: 'HistoryMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ViewHistory = {ctor: 'ViewHistory'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$FinishRound = function (a) {
	return {ctor: 'FinishRound', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Redraw = {ctor: 'Redraw'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Back = {ctor: 'Back'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Skip = function (a) {
	return {ctor: 'Skip', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$AnimatePlayedCards = {ctor: 'AnimatePlayedCards'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$NextRound = {ctor: 'NextRound'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Choose = function (a) {
	return {ctor: 'Choose', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Consider = function (a) {
	return {ctor: 'Consider', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Play = {ctor: 'Play'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Withdraw = function (a) {
	return {ctor: 'Withdraw', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Pick = function (a) {
	return {ctor: 'Pick', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LobbyAndHandUpdated = {ctor: 'LobbyAndHandUpdated'};

var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$init = F2(
	function (supported, enabled) {
		return {supported: supported, enabled: enabled, permission: _elm_lang$core$Maybe$Nothing};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$permissions = _elm_lang$core$Native_Platform.incomingPort('permissions', _elm_lang$core$Json_Decode$string);
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$notifications = _elm_lang$core$Native_Platform.outgoingPort(
	'notifications',
	function (v) {
		return {
			title: v.title,
			icon: (v.icon.ctor === 'Nothing') ? null : v.icon._0
		};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$requestPermission = _elm_lang$core$Native_Platform.outgoingPort(
	'requestPermission',
	function (v) {
		return null;
	});
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$Model = F3(
	function (a, b, c) {
		return {supported: a, enabled: b, permission: c};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$Notification = F2(
	function (a, b) {
		return {title: a, icon: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$Default = {ctor: 'Default'};
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$Denied = {ctor: 'Denied'};
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$Granted = {ctor: 'Granted'};
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$PermissionChanged = function (a) {
	return {ctor: 'PermissionChanged', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$update = F2(
	function (message, model) {
		var _p0 = message;
		switch (_p0.ctor) {
			case 'PermissionGiven':
				var _p1 = _p0._0;
				return {
					ctor: '_Tuple3',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							permission: _elm_lang$core$Maybe$Just(_p1)
						}),
					_1: _elm_lang$core$Platform_Cmd$none,
					_2: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
						_Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$PermissionChanged(_p1))
				};
			case 'SendNotification':
				return (model.supported && model.enabled) ? {
					ctor: '_Tuple3',
					_0: model,
					_1: _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$notifications(_p0._0),
					_2: _elm_lang$core$Platform_Cmd$none
				} : {ctor: '_Tuple3', _0: model, _1: _elm_lang$core$Platform_Cmd$none, _2: _elm_lang$core$Platform_Cmd$none};
			case 'EnableNotifications':
				return {
					ctor: '_Tuple3',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{enabled: true}),
					_1: _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$requestPermission(
						{ctor: '_Tuple0'}),
					_2: _elm_lang$core$Platform_Cmd$none
				};
			default:
				return {
					ctor: '_Tuple3',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{enabled: false}),
					_1: _elm_lang$core$Platform_Cmd$none,
					_2: _elm_lang$core$Platform_Cmd$none
				};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$DisableNotifications = {ctor: 'DisableNotifications'};
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$disable = _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$DisableNotifications;
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$EnableNotifications = {ctor: 'EnableNotifications'};
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$enable = _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$EnableNotifications;
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$SendNotification = function (a) {
	return {ctor: 'SendNotification', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$notify = function (notification) {
	return _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$SendNotification(notification);
};
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$PermissionGiven = function (a) {
	return {ctor: 'PermissionGiven', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$permission = function (name) {
	var permission = function () {
		var _p2 = name;
		switch (_p2) {
			case 'granted':
				return _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$Granted;
			case 'denied':
				return _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$Denied;
			case 'default':
				return _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$Default;
			default:
				var _p3 = A2(_elm_lang$core$Debug$log, 'Unexpected permission for browser notifications, assuming denied', name);
				return _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$Denied;
		}
	}();
	return _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$PermissionGiven(permission);
};
var _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$subscriptions = function (model) {
	return (model.supported && (model.enabled && _elm_lang$core$Native_Utils.eq(model.permission, _elm_lang$core$Maybe$Nothing))) ? _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$permissions(_Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$permission) : _elm_lang$core$Platform_Sub$none;
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage = function (a) {
	return {ctor: 'LocalMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$Leave = {ctor: 'Leave'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$OverlayMessage = function (a) {
	return {ctor: 'OverlayMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ErrorMessage = function (a) {
	return {ctor: 'ErrorMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$TTSMessage = function (a) {
	return {ctor: 'TTSMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SidebarMessage = function (a) {
	return {ctor: 'SidebarMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage = function (a) {
	return {ctor: 'PlayingMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ConfigMessage = function (a) {
	return {ctor: 'ConfigMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationsMessage = function (a) {
	return {ctor: 'BrowserNotificationsMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$NoOp = {ctor: 'NoOp'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$Batch = function (a) {
	return {ctor: 'Batch', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$RenderQr = {ctor: 'RenderQr'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationForUser = F3(
	function (a, b, c) {
		return {ctor: 'BrowserNotificationForUser', _0: a, _1: b, _2: c};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$DisplayInviteOverlay = {ctor: 'DisplayInviteOverlay'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$Identify = {ctor: 'Identify'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateHand = function (a) {
	return {ctor: 'UpdateHand', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby = function (a) {
	return {ctor: 'UpdateLobby', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobbyAndHand = function (a) {
	return {ctor: 'UpdateLobbyAndHand', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SetNotification = function (a) {
	return {ctor: 'SetNotification', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$DismissNotification = function (a) {
	return {ctor: 'DismissNotification', _0: a};
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$NoOp = {ctor: 'NoOp'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Batch = function (a) {
	return {ctor: 'Batch', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$SetPasswordRequired = {ctor: 'SetPasswordRequired'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$StorageMessage = function (a) {
	return {ctor: 'StorageMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$TabsMessage = function (a) {
	return {ctor: 'TabsMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$OverlayMessage = function (a) {
	return {ctor: 'OverlayMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage = function (a) {
	return {ctor: 'ErrorMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$LobbyMessage = function (a) {
	return {ctor: 'LobbyMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$InputMessage = function (a) {
	return {ctor: 'InputMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ClearExistingGame = function (a) {
	return {ctor: 'ClearExistingGame', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$TryExistingGame = function (a) {
	return {ctor: 'TryExistingGame', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobby = F2(
	function (a, b) {
		return {ctor: 'JoinLobby', _0: a, _1: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$MoveToLobby = function (a) {
	return {ctor: 'MoveToLobby', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$StoreCredentialsAndMoveToLobby = F2(
	function (a, b) {
		return {ctor: 'StoreCredentialsAndMoveToLobby', _0: a, _1: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsExistingPlayer = F2(
	function (a, b) {
		return {ctor: 'JoinLobbyAsExistingPlayer', _0: a, _1: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinGivenLobbyAsNewPlayer = function (a) {
	return {ctor: 'JoinGivenLobbyAsNewPlayer', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsNewPlayer = {ctor: 'JoinLobbyAsNewPlayer'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$SetButtonsEnabled = function (a) {
	return {ctor: 'SetButtonsEnabled', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$CreateLobby = {ctor: 'CreateLobby'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$PathChange = function (a) {
	return {ctor: 'PathChange', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$SubmitCurrentTab = {ctor: 'SubmitCurrentTab'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Password = {ctor: 'Password'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$GameCode = {ctor: 'GameCode'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Name = {ctor: 'Name'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Join = {ctor: 'Join'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Create = {ctor: 'Create'};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Models$Model = F4(
	function (a, b, c, d) {
		return {decks: a, deckIdInput: b, passwordInput: c, loadingDecks: d};
	});

var _elm_lang$core$Random$onSelfMsg = F3(
	function (_p1, _p0, seed) {
		return _elm_lang$core$Task$succeed(seed);
	});
var _elm_lang$core$Random$magicNum8 = 2147483562;
var _elm_lang$core$Random$range = function (_p2) {
	return {ctor: '_Tuple2', _0: 0, _1: _elm_lang$core$Random$magicNum8};
};
var _elm_lang$core$Random$magicNum7 = 2147483399;
var _elm_lang$core$Random$magicNum6 = 2147483563;
var _elm_lang$core$Random$magicNum5 = 3791;
var _elm_lang$core$Random$magicNum4 = 40692;
var _elm_lang$core$Random$magicNum3 = 52774;
var _elm_lang$core$Random$magicNum2 = 12211;
var _elm_lang$core$Random$magicNum1 = 53668;
var _elm_lang$core$Random$magicNum0 = 40014;
var _elm_lang$core$Random$step = F2(
	function (_p3, seed) {
		var _p4 = _p3;
		return _p4._0(seed);
	});
var _elm_lang$core$Random$onEffects = F3(
	function (router, commands, seed) {
		var _p5 = commands;
		if (_p5.ctor === '[]') {
			return _elm_lang$core$Task$succeed(seed);
		} else {
			var _p6 = A2(_elm_lang$core$Random$step, _p5._0._0, seed);
			var value = _p6._0;
			var newSeed = _p6._1;
			return A2(
				_elm_lang$core$Task$andThen,
				function (_p7) {
					return A3(_elm_lang$core$Random$onEffects, router, _p5._1, newSeed);
				},
				A2(_elm_lang$core$Platform$sendToApp, router, value));
		}
	});
var _elm_lang$core$Random$listHelp = F4(
	function (list, n, generate, seed) {
		listHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 1) < 0) {
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$List$reverse(list),
					_1: seed
				};
			} else {
				var _p8 = generate(seed);
				var value = _p8._0;
				var newSeed = _p8._1;
				var _v2 = {ctor: '::', _0: value, _1: list},
					_v3 = n - 1,
					_v4 = generate,
					_v5 = newSeed;
				list = _v2;
				n = _v3;
				generate = _v4;
				seed = _v5;
				continue listHelp;
			}
		}
	});
var _elm_lang$core$Random$minInt = -2147483648;
var _elm_lang$core$Random$maxInt = 2147483647;
var _elm_lang$core$Random$iLogBase = F2(
	function (b, i) {
		return (_elm_lang$core$Native_Utils.cmp(i, b) < 0) ? 1 : (1 + A2(_elm_lang$core$Random$iLogBase, b, (i / b) | 0));
	});
var _elm_lang$core$Random$command = _elm_lang$core$Native_Platform.leaf('Random');
var _elm_lang$core$Random$Generator = function (a) {
	return {ctor: 'Generator', _0: a};
};
var _elm_lang$core$Random$list = F2(
	function (n, _p9) {
		var _p10 = _p9;
		return _elm_lang$core$Random$Generator(
			function (seed) {
				return A4(
					_elm_lang$core$Random$listHelp,
					{ctor: '[]'},
					n,
					_p10._0,
					seed);
			});
	});
var _elm_lang$core$Random$map = F2(
	function (func, _p11) {
		var _p12 = _p11;
		return _elm_lang$core$Random$Generator(
			function (seed0) {
				var _p13 = _p12._0(seed0);
				var a = _p13._0;
				var seed1 = _p13._1;
				return {
					ctor: '_Tuple2',
					_0: func(a),
					_1: seed1
				};
			});
	});
var _elm_lang$core$Random$map2 = F3(
	function (func, _p15, _p14) {
		var _p16 = _p15;
		var _p17 = _p14;
		return _elm_lang$core$Random$Generator(
			function (seed0) {
				var _p18 = _p16._0(seed0);
				var a = _p18._0;
				var seed1 = _p18._1;
				var _p19 = _p17._0(seed1);
				var b = _p19._0;
				var seed2 = _p19._1;
				return {
					ctor: '_Tuple2',
					_0: A2(func, a, b),
					_1: seed2
				};
			});
	});
var _elm_lang$core$Random$pair = F2(
	function (genA, genB) {
		return A3(
			_elm_lang$core$Random$map2,
			F2(
				function (v0, v1) {
					return {ctor: '_Tuple2', _0: v0, _1: v1};
				}),
			genA,
			genB);
	});
var _elm_lang$core$Random$map3 = F4(
	function (func, _p22, _p21, _p20) {
		var _p23 = _p22;
		var _p24 = _p21;
		var _p25 = _p20;
		return _elm_lang$core$Random$Generator(
			function (seed0) {
				var _p26 = _p23._0(seed0);
				var a = _p26._0;
				var seed1 = _p26._1;
				var _p27 = _p24._0(seed1);
				var b = _p27._0;
				var seed2 = _p27._1;
				var _p28 = _p25._0(seed2);
				var c = _p28._0;
				var seed3 = _p28._1;
				return {
					ctor: '_Tuple2',
					_0: A3(func, a, b, c),
					_1: seed3
				};
			});
	});
var _elm_lang$core$Random$map4 = F5(
	function (func, _p32, _p31, _p30, _p29) {
		var _p33 = _p32;
		var _p34 = _p31;
		var _p35 = _p30;
		var _p36 = _p29;
		return _elm_lang$core$Random$Generator(
			function (seed0) {
				var _p37 = _p33._0(seed0);
				var a = _p37._0;
				var seed1 = _p37._1;
				var _p38 = _p34._0(seed1);
				var b = _p38._0;
				var seed2 = _p38._1;
				var _p39 = _p35._0(seed2);
				var c = _p39._0;
				var seed3 = _p39._1;
				var _p40 = _p36._0(seed3);
				var d = _p40._0;
				var seed4 = _p40._1;
				return {
					ctor: '_Tuple2',
					_0: A4(func, a, b, c, d),
					_1: seed4
				};
			});
	});
var _elm_lang$core$Random$map5 = F6(
	function (func, _p45, _p44, _p43, _p42, _p41) {
		var _p46 = _p45;
		var _p47 = _p44;
		var _p48 = _p43;
		var _p49 = _p42;
		var _p50 = _p41;
		return _elm_lang$core$Random$Generator(
			function (seed0) {
				var _p51 = _p46._0(seed0);
				var a = _p51._0;
				var seed1 = _p51._1;
				var _p52 = _p47._0(seed1);
				var b = _p52._0;
				var seed2 = _p52._1;
				var _p53 = _p48._0(seed2);
				var c = _p53._0;
				var seed3 = _p53._1;
				var _p54 = _p49._0(seed3);
				var d = _p54._0;
				var seed4 = _p54._1;
				var _p55 = _p50._0(seed4);
				var e = _p55._0;
				var seed5 = _p55._1;
				return {
					ctor: '_Tuple2',
					_0: A5(func, a, b, c, d, e),
					_1: seed5
				};
			});
	});
var _elm_lang$core$Random$andThen = F2(
	function (callback, _p56) {
		var _p57 = _p56;
		return _elm_lang$core$Random$Generator(
			function (seed) {
				var _p58 = _p57._0(seed);
				var result = _p58._0;
				var newSeed = _p58._1;
				var _p59 = callback(result);
				var genB = _p59._0;
				return genB(newSeed);
			});
	});
var _elm_lang$core$Random$State = F2(
	function (a, b) {
		return {ctor: 'State', _0: a, _1: b};
	});
var _elm_lang$core$Random$initState = function (seed) {
	var s = A2(_elm_lang$core$Basics$max, seed, 0 - seed);
	var q = (s / (_elm_lang$core$Random$magicNum6 - 1)) | 0;
	var s2 = A2(_elm_lang$core$Basics_ops['%'], q, _elm_lang$core$Random$magicNum7 - 1);
	var s1 = A2(_elm_lang$core$Basics_ops['%'], s, _elm_lang$core$Random$magicNum6 - 1);
	return A2(_elm_lang$core$Random$State, s1 + 1, s2 + 1);
};
var _elm_lang$core$Random$next = function (_p60) {
	var _p61 = _p60;
	var _p63 = _p61._1;
	var _p62 = _p61._0;
	var k2 = (_p63 / _elm_lang$core$Random$magicNum3) | 0;
	var rawState2 = (_elm_lang$core$Random$magicNum4 * (_p63 - (k2 * _elm_lang$core$Random$magicNum3))) - (k2 * _elm_lang$core$Random$magicNum5);
	var newState2 = (_elm_lang$core$Native_Utils.cmp(rawState2, 0) < 0) ? (rawState2 + _elm_lang$core$Random$magicNum7) : rawState2;
	var k1 = (_p62 / _elm_lang$core$Random$magicNum1) | 0;
	var rawState1 = (_elm_lang$core$Random$magicNum0 * (_p62 - (k1 * _elm_lang$core$Random$magicNum1))) - (k1 * _elm_lang$core$Random$magicNum2);
	var newState1 = (_elm_lang$core$Native_Utils.cmp(rawState1, 0) < 0) ? (rawState1 + _elm_lang$core$Random$magicNum6) : rawState1;
	var z = newState1 - newState2;
	var newZ = (_elm_lang$core$Native_Utils.cmp(z, 1) < 0) ? (z + _elm_lang$core$Random$magicNum8) : z;
	return {
		ctor: '_Tuple2',
		_0: newZ,
		_1: A2(_elm_lang$core$Random$State, newState1, newState2)
	};
};
var _elm_lang$core$Random$split = function (_p64) {
	var _p65 = _p64;
	var _p68 = _p65._1;
	var _p67 = _p65._0;
	var _p66 = _elm_lang$core$Tuple$second(
		_elm_lang$core$Random$next(_p65));
	var t1 = _p66._0;
	var t2 = _p66._1;
	var new_s2 = _elm_lang$core$Native_Utils.eq(_p68, 1) ? (_elm_lang$core$Random$magicNum7 - 1) : (_p68 - 1);
	var new_s1 = _elm_lang$core$Native_Utils.eq(_p67, _elm_lang$core$Random$magicNum6 - 1) ? 1 : (_p67 + 1);
	return {
		ctor: '_Tuple2',
		_0: A2(_elm_lang$core$Random$State, new_s1, t2),
		_1: A2(_elm_lang$core$Random$State, t1, new_s2)
	};
};
var _elm_lang$core$Random$Seed = function (a) {
	return {ctor: 'Seed', _0: a};
};
var _elm_lang$core$Random$int = F2(
	function (a, b) {
		return _elm_lang$core$Random$Generator(
			function (_p69) {
				var _p70 = _p69;
				var _p75 = _p70._0;
				var base = 2147483561;
				var f = F3(
					function (n, acc, state) {
						f:
						while (true) {
							var _p71 = n;
							if (_p71 === 0) {
								return {ctor: '_Tuple2', _0: acc, _1: state};
							} else {
								var _p72 = _p75.next(state);
								var x = _p72._0;
								var nextState = _p72._1;
								var _v27 = n - 1,
									_v28 = x + (acc * base),
									_v29 = nextState;
								n = _v27;
								acc = _v28;
								state = _v29;
								continue f;
							}
						}
					});
				var _p73 = (_elm_lang$core$Native_Utils.cmp(a, b) < 0) ? {ctor: '_Tuple2', _0: a, _1: b} : {ctor: '_Tuple2', _0: b, _1: a};
				var lo = _p73._0;
				var hi = _p73._1;
				var k = (hi - lo) + 1;
				var n = A2(_elm_lang$core$Random$iLogBase, base, k);
				var _p74 = A3(f, n, 1, _p75.state);
				var v = _p74._0;
				var nextState = _p74._1;
				return {
					ctor: '_Tuple2',
					_0: lo + A2(_elm_lang$core$Basics_ops['%'], v, k),
					_1: _elm_lang$core$Random$Seed(
						_elm_lang$core$Native_Utils.update(
							_p75,
							{state: nextState}))
				};
			});
	});
var _elm_lang$core$Random$bool = A2(
	_elm_lang$core$Random$map,
	F2(
		function (x, y) {
			return _elm_lang$core$Native_Utils.eq(x, y);
		})(1),
	A2(_elm_lang$core$Random$int, 0, 1));
var _elm_lang$core$Random$float = F2(
	function (a, b) {
		return _elm_lang$core$Random$Generator(
			function (seed) {
				var _p76 = A2(
					_elm_lang$core$Random$step,
					A2(_elm_lang$core$Random$int, _elm_lang$core$Random$minInt, _elm_lang$core$Random$maxInt),
					seed);
				var number = _p76._0;
				var newSeed = _p76._1;
				var negativeOneToOne = _elm_lang$core$Basics$toFloat(number) / _elm_lang$core$Basics$toFloat(_elm_lang$core$Random$maxInt - _elm_lang$core$Random$minInt);
				var _p77 = (_elm_lang$core$Native_Utils.cmp(a, b) < 0) ? {ctor: '_Tuple2', _0: a, _1: b} : {ctor: '_Tuple2', _0: b, _1: a};
				var lo = _p77._0;
				var hi = _p77._1;
				var scaled = ((lo + hi) / 2) + ((hi - lo) * negativeOneToOne);
				return {ctor: '_Tuple2', _0: scaled, _1: newSeed};
			});
	});
var _elm_lang$core$Random$initialSeed = function (n) {
	return _elm_lang$core$Random$Seed(
		{
			state: _elm_lang$core$Random$initState(n),
			next: _elm_lang$core$Random$next,
			split: _elm_lang$core$Random$split,
			range: _elm_lang$core$Random$range
		});
};
var _elm_lang$core$Random$init = A2(
	_elm_lang$core$Task$andThen,
	function (t) {
		return _elm_lang$core$Task$succeed(
			_elm_lang$core$Random$initialSeed(
				_elm_lang$core$Basics$round(t)));
	},
	_elm_lang$core$Time$now);
var _elm_lang$core$Random$Generate = function (a) {
	return {ctor: 'Generate', _0: a};
};
var _elm_lang$core$Random$generate = F2(
	function (tagger, generator) {
		return _elm_lang$core$Random$command(
			_elm_lang$core$Random$Generate(
				A2(_elm_lang$core$Random$map, tagger, generator)));
	});
var _elm_lang$core$Random$cmdMap = F2(
	function (func, _p78) {
		var _p79 = _p78;
		return _elm_lang$core$Random$Generate(
			A2(_elm_lang$core$Random$map, func, _p79._0));
	});
_elm_lang$core$Native_Platform.effectManagers['Random'] = {pkg: 'elm-lang/core', init: _elm_lang$core$Random$init, onEffects: _elm_lang$core$Random$onEffects, onSelfMsg: _elm_lang$core$Random$onSelfMsg, tag: 'cmd', cmdMap: _elm_lang$core$Random$cmdMap};

var _Lattyware$massivedecks$MassiveDecks_Scenes_History_Models$Model = function (a) {
	return {rounds: a};
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Models$Model = F6(
	function (a, b, c, d, e, f) {
		return {picked: a, considering: b, finishedRound: c, shownPlayed: d, seed: e, history: f};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Models$ShownPlayedCards = F2(
	function (a, b) {
		return {animated: a, toAnimate: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Models$ShownCard = F4(
	function (a, b, c, d) {
		return {rotation: a, horizontalPos: b, isLeft: c, verticalPos: d};
	});

var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Models$Model = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return function (k) {
											return {lobby: a, hand: b, config: c, playing: d, browserNotifications: e, secret: f, init: g, notification: h, qrNeedsRendering: i, sidebar: j, tts: k};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Models$Model = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return function (k) {
											return function (l) {
												return {lobby: a, init: b, path: c, nameInput: d, gameCodeInput: e, passwordInput: f, passwordRequired: g, errors: h, overlay: i, buttonsEnabled: j, tabs: k, storage: l};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};

var _Lattyware$massivedecks$MassiveDecks_Components_About$contents = function (version) {
	return A2(
		_elm_lang$core$Basics_ops['++'],
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$p,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('Massive Decks is a web game based on the excellent '),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$a,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$href('https://cardsagainsthumanity.com/'),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$target('_blank'),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$rel('noopener'),
										_1: {ctor: '[]'}
									}
								}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text('Cards against Humanity'),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text(' - a party game where you play white cards to try and produce the most amusing outcome when '),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text('combined with the given black card.'),
								_1: {ctor: '[]'}
							}
						}
					}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$p,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('Massive Decks is also inspired by: '),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$ul,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$li,
										{ctor: '[]'},
										{
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$a,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$href('https://www.cardcastgame.com/'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$target('_blank'),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$rel('noopener'),
															_1: {ctor: '[]'}
														}
													}
												},
												{
													ctor: '::',
													_0: _elm_lang$html$Html$text('Cardcast'),
													_1: {ctor: '[]'}
												}),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html$text(' - an app that allows you to play on a ChromeCast.'),
												_1: {ctor: '[]'}
											}
										}),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$li,
											{ctor: '[]'},
											{
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$a,
													{
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$href('http://pretendyoure.xyz/zy/'),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$target('_blank'),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$rel('noopener'),
																_1: {ctor: '[]'}
															}
														}
													},
													{
														ctor: '::',
														_0: _elm_lang$html$Html$text('Pretend You\'re Xyzzy'),
														_1: {ctor: '[]'}
													}),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html$text(' - a web game where you can jump in with people you don\'t know.'),
													_1: {ctor: '[]'}
												}
											}),
										_1: {ctor: '[]'}
									}
								}),
							_1: {ctor: '[]'}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$p,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('This is an open source game developed in '),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$a,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$href('http://elm-lang.org/'),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$target('_blank'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$rel('noopener'),
												_1: {ctor: '[]'}
											}
										}
									},
									{
										ctor: '::',
										_0: _elm_lang$html$Html$text('Elm'),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html$text(' for the client and '),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$a,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$href('http://www.scala-lang.org/'),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$target('_blank'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$rel('noopener'),
														_1: {ctor: '[]'}
													}
												}
											},
											{
												ctor: '::',
												_0: _elm_lang$html$Html$text('Scala'),
												_1: {ctor: '[]'}
											}),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html$text(' for the server.'),
											_1: {ctor: '[]'}
										}
									}
								}
							}
						}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$p,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text('We also use: '),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$ul,
										{ctor: '[]'},
										{
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$li,
												{ctor: '[]'},
												{
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$a,
														{
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$href('https://www.cardcastgame.com/'),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$target('_blank'),
																_1: {
																	ctor: '::',
																	_0: _elm_lang$html$Html_Attributes$rel('noopener'),
																	_1: {ctor: '[]'}
																}
															}
														},
														{
															ctor: '::',
															_0: _elm_lang$html$Html$text('Cardcast'),
															_1: {ctor: '[]'}
														}),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html$text('\'s APIs for getting decks of cards (you can go there to make your own!).'),
														_1: {ctor: '[]'}
													}
												}),
											_1: {
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$li,
													{ctor: '[]'},
													{
														ctor: '::',
														_0: _elm_lang$html$Html$text('The '),
														_1: {
															ctor: '::',
															_0: A2(
																_elm_lang$html$Html$a,
																{
																	ctor: '::',
																	_0: _elm_lang$html$Html_Attributes$href('https://www.playframework.com/'),
																	_1: {
																		ctor: '::',
																		_0: _elm_lang$html$Html_Attributes$target('_blank'),
																		_1: {
																			ctor: '::',
																			_0: _elm_lang$html$Html_Attributes$rel('noopener'),
																			_1: {ctor: '[]'}
																		}
																	}
																},
																{
																	ctor: '::',
																	_0: _elm_lang$html$Html$text('Play framework'),
																	_1: {ctor: '[]'}
																}),
															_1: {ctor: '[]'}
														}
													}),
												_1: {
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$li,
														{ctor: '[]'},
														{
															ctor: '::',
															_0: A2(
																_elm_lang$html$Html$a,
																{
																	ctor: '::',
																	_0: _elm_lang$html$Html_Attributes$href('http://lesscss.org/'),
																	_1: {
																		ctor: '::',
																		_0: _elm_lang$html$Html_Attributes$target('_blank'),
																		_1: {
																			ctor: '::',
																			_0: _elm_lang$html$Html_Attributes$rel('noopener'),
																			_1: {ctor: '[]'}
																		}
																	}
																},
																{
																	ctor: '::',
																	_0: _elm_lang$html$Html$text('Less'),
																	_1: {ctor: '[]'}
																}),
															_1: {ctor: '[]'}
														}),
													_1: {
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html$li,
															{ctor: '[]'},
															{
																ctor: '::',
																_0: A2(
																	_elm_lang$html$Html$a,
																	{
																		ctor: '::',
																		_0: _elm_lang$html$Html_Attributes$href('https://fortawesome.github.io/Font-Awesome/'),
																		_1: {
																			ctor: '::',
																			_0: _elm_lang$html$Html_Attributes$target('_blank'),
																			_1: {
																				ctor: '::',
																				_0: _elm_lang$html$Html_Attributes$rel('noopener'),
																				_1: {ctor: '[]'}
																			}
																		}
																	},
																	{
																		ctor: '::',
																		_0: _elm_lang$html$Html$text('Font Awesome'),
																		_1: {ctor: '[]'}
																	}),
																_1: {ctor: '[]'}
															}),
														_1: {
															ctor: '::',
															_0: A2(
																_elm_lang$html$Html$li,
																{ctor: '[]'},
																{
																	ctor: '::',
																	_0: A2(
																		_elm_lang$html$Html$a,
																		{
																			ctor: '::',
																			_0: _elm_lang$html$Html_Attributes$href('https://www.muicss.com'),
																			_1: {
																				ctor: '::',
																				_0: _elm_lang$html$Html_Attributes$target('_blank'),
																				_1: {
																					ctor: '::',
																					_0: _elm_lang$html$Html_Attributes$rel('noopener'),
																					_1: {ctor: '[]'}
																				}
																			}
																		},
																		{
																			ctor: '::',
																			_0: _elm_lang$html$Html$text('MUI'),
																			_1: {ctor: '[]'}
																		}),
																	_1: {ctor: '[]'}
																}),
															_1: {ctor: '[]'}
														}
													}
												}
											}
										}),
									_1: {ctor: '[]'}
								}
							}),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$p,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('Bug reports and contributions are welcome on the '),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$a,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$href('https://github.com/Lattyware/massivedecks'),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$target('_blank'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$rel('noopener'),
														_1: {ctor: '[]'}
													}
												}
											},
											{
												ctor: '::',
												_0: _elm_lang$html$Html$text('GitHub repository'),
												_1: {ctor: '[]'}
											}),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html$text(', where you can find the complete source to the game, under the AGPLv3 license. The game concept '),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html$text('\'Cards against Humanity\' is used under a '),
												_1: {
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$a,
														{
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$href('https://creativecommons.org/licenses/by-nc-sa/2.0/'),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$target('_blank'),
																_1: {
																	ctor: '::',
																	_0: _elm_lang$html$Html_Attributes$rel('noopener'),
																	_1: {ctor: '[]'}
																}
															}
														},
														{
															ctor: '::',
															_0: _elm_lang$html$Html$text('Creative Commons BY-NC-SA 2.0 license'),
															_1: {ctor: '[]'}
														}),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html$text(' granted by '),
														_1: {
															ctor: '::',
															_0: A2(
																_elm_lang$html$Html$a,
																{
																	ctor: '::',
																	_0: _elm_lang$html$Html_Attributes$href('https://cardsagainsthumanity.com/'),
																	_1: {
																		ctor: '::',
																		_0: _elm_lang$html$Html_Attributes$target('_blank'),
																		_1: {
																			ctor: '::',
																			_0: _elm_lang$html$Html_Attributes$rel('noopener'),
																			_1: {ctor: '[]'}
																		}
																	}
																},
																{
																	ctor: '::',
																	_0: _elm_lang$html$Html$text('Cards against Humanity'),
																	_1: {ctor: '[]'}
																}),
															_1: {ctor: '[]'}
														}
													}
												}
											}
										}
									}
								}),
							_1: {ctor: '[]'}
						}
					}
				}
			}
		},
		_elm_lang$core$String$isEmpty(version) ? {ctor: '[]'} : {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$p,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text(
						A2(
							_elm_lang$core$Basics_ops['++'],
							'This server is running version ',
							A2(_elm_lang$core$Basics_ops['++'], version, '.'))),
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Components_About$title = 'About';
var _Lattyware$massivedecks$MassiveDecks_Components_About$icon = 'info-circle';
var _Lattyware$massivedecks$MassiveDecks_Components_About$show = function (version) {
	return _Lattyware$massivedecks$MassiveDecks_Components_Overlay$Show(
		A3(
			_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Overlay,
			_Lattyware$massivedecks$MassiveDecks_Components_About$icon,
			_Lattyware$massivedecks$MassiveDecks_Components_About$title,
			_Lattyware$massivedecks$MassiveDecks_Components_About$contents(version)));
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$createLobbyButton = function (enabled) {
	return A2(
		_elm_lang$html$Html$button,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--large mui-btn--primary'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$CreateLobby),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$disabled(!enabled),
					_1: {ctor: '[]'}
				}
			}
		},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text('Create Game'),
			_1: {ctor: '[]'}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$joinLobbyButton = function (enabled) {
	return A2(
		_elm_lang$html$Html$button,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--large mui-btn--primary'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsNewPlayer),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$disabled(!enabled),
					_1: {ctor: '[]'}
				}
			}
		},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text('Join Game'),
			_1: {ctor: '[]'}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$existingGame = function (game) {
	return {
		ctor: '_Tuple2',
		_0: game.gameCode,
		_1: A2(
			_elm_lang$html$Html$li,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$a,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$href(
							A2(_elm_lang$core$Basics_ops['++'], '#', game.gameCode)),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(
							A2(
								_elm_lang$core$Basics_ops['++'],
								'Game \"',
								A2(_elm_lang$core$Basics_ops['++'], game.gameCode, '\"'))),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			})
	};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$existingGames = function (games) {
	return _elm_lang$core$List$isEmpty(games) ? {ctor: '[]'} : {
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('rejoin mui--divider-bottom'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$span,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('You can rejoin '),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html_Keyed$ul,
						{ctor: '[]'},
						A2(_elm_lang$core$List$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$existingGame, games)),
					_1: {ctor: '[]'}
				}
			}),
		_1: {ctor: '[]'}
	};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$renderTab = F4(
	function (nameEntered, gameCodeEntered, model, tab) {
		var _p0 = tab;
		if (_p0.ctor === 'Create') {
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$createLobbyButton(nameEntered && model.buttonsEnabled),
				_1: {ctor: '[]'}
			};
		} else {
			return _elm_lang$core$List$concat(
				{
					ctor: '::',
					_0: {
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Components_Input$view(model.gameCodeInput),
						_1: {ctor: '[]'}
					},
					_1: {
						ctor: '::',
						_0: _elm_lang$core$Native_Utils.eq(
							model.passwordRequired,
							_elm_lang$core$Maybe$Just(model.gameCodeInput.value)) ? {
							ctor: '::',
							_0: _Lattyware$massivedecks$MassiveDecks_Components_Input$view(model.passwordInput),
							_1: {ctor: '[]'}
						} : {ctor: '[]'},
						_1: {
							ctor: '::',
							_0: {
								ctor: '::',
								_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$joinLobbyButton(nameEntered && (gameCodeEntered && model.buttonsEnabled)),
								_1: {ctor: '[]'}
							},
							_1: {ctor: '[]'}
						}
					}
				});
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$view = function (model) {
	var versionInfo = _elm_lang$core$String$isEmpty(model.init.version) ? {ctor: '[]'} : {
		ctor: '::',
		_0: _elm_lang$html$Html$text(' Version '),
		_1: {
			ctor: '::',
			_0: _elm_lang$html$Html$text(model.init.version),
			_1: {ctor: '[]'}
		}
	};
	var gameCodeEntered = !_elm_lang$core$String$isEmpty(model.gameCodeInput.value);
	var nameEntered = !_elm_lang$core$String$isEmpty(model.nameInput.value);
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$id('start-screen'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$id('start-screen-content'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('mui-panel'),
						_1: {ctor: '[]'}
					}
				},
				A2(
					_elm_lang$core$Basics_ops['++'],
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$h1,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('mui--divider-bottom'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text('Massive Decks'),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					},
					A2(
						_elm_lang$core$Basics_ops['++'],
						_Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$existingGames(model.storage),
						A2(
							_elm_lang$core$Basics_ops['++'],
							{
								ctor: '::',
								_0: _Lattyware$massivedecks$MassiveDecks_Components_Input$view(model.nameInput),
								_1: {ctor: '[]'}
							},
							A2(
								_Lattyware$massivedecks$MassiveDecks_Components_Tabs$view,
								A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$renderTab, nameEntered, gameCodeEntered, model),
								model.tabs))))),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$footer,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$a,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$href('https://www.scoutingjanderooij.nl'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$img,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$src('images/icon.svg'),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$alt('Scouts Against Humanity Logo.'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$title('Scouts Against Humanity'),
												_1: {ctor: '[]'}
											}
										}
									},
									{ctor: '[]'}),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$p,
								{ctor: '[]'},
								versionInfo),
							_1: {ctor: '[]'}
						}
					}),
				_1: {ctor: '[]'}
			}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$alreadyInGameOverlay = A3(
	_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Overlay,
	'info-circle',
	'Already in game.',
	{
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html$p,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: _elm_lang$html$Html$text('You are already in this game, so you have joined as an existing player.'),
				_1: {ctor: '[]'}
			}),
		_1: {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$p,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('If you want to join as a new player, please '),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$a,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('link'),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$title('Leave the game.'),
									_1: {
										ctor: '::',
										_0: A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
										_1: {
											ctor: '::',
											_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Events$onClick(
													_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Batch(
														{
															ctor: '::',
															_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$LobbyMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$Leave),
															_1: {
																ctor: '::',
																_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$OverlayMessage(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Hide),
																_1: {ctor: '[]'}
															}
														})),
												_1: {ctor: '[]'}
											}
										}
									}
								}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text('leave the game'),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text(' first.'),
							_1: {ctor: '[]'}
						}
					}
				}),
			_1: {ctor: '[]'}
		}
	});

var _elm_lang$websocket$Native_WebSocket = function() {

function open(url, settings)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		try
		{
			var socket = new WebSocket(url);
			socket.elm_web_socket = true;
		}
		catch(err)
		{
			return callback(_elm_lang$core$Native_Scheduler.fail({
				ctor: err.name === 'SecurityError' ? 'BadSecurity' : 'BadArgs',
				_0: err.message
			}));
		}

		socket.addEventListener("open", function(event) {
			callback(_elm_lang$core$Native_Scheduler.succeed(socket));
		});

		socket.addEventListener("message", function(event) {
			_elm_lang$core$Native_Scheduler.rawSpawn(A2(settings.onMessage, socket, event.data));
		});

		socket.addEventListener("close", function(event) {
			_elm_lang$core$Native_Scheduler.rawSpawn(settings.onClose({
				code: event.code,
				reason: event.reason,
				wasClean: event.wasClean
			}));
		});

		return function()
		{
			if (socket && socket.close)
			{
				socket.close();
			}
		};
	});
}

function send(socket, string)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var result =
			socket.readyState === WebSocket.OPEN
				? _elm_lang$core$Maybe$Nothing
				: _elm_lang$core$Maybe$Just({ ctor: 'NotOpen' });

		try
		{
			socket.send(string);
		}
		catch(err)
		{
			result = _elm_lang$core$Maybe$Just({ ctor: 'BadString' });
		}

		callback(_elm_lang$core$Native_Scheduler.succeed(result));
	});
}

function close(code, reason, socket)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		try
		{
			socket.close(code, reason);
		}
		catch(err)
		{
			return callback(_elm_lang$core$Native_Scheduler.fail(_elm_lang$core$Maybe$Just({
				ctor: err.name === 'SyntaxError' ? 'BadReason' : 'BadCode'
			})));
		}
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Maybe$Nothing));
	});
}

function bytesQueued(socket)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		callback(_elm_lang$core$Native_Scheduler.succeed(socket.bufferedAmount));
	});
}

return {
	open: F2(open),
	send: F2(send),
	close: F3(close),
	bytesQueued: bytesQueued
};

}();

var _elm_lang$websocket$WebSocket_LowLevel$bytesQueued = _elm_lang$websocket$Native_WebSocket.bytesQueued;
var _elm_lang$websocket$WebSocket_LowLevel$send = _elm_lang$websocket$Native_WebSocket.send;
var _elm_lang$websocket$WebSocket_LowLevel$closeWith = _elm_lang$websocket$Native_WebSocket.close;
var _elm_lang$websocket$WebSocket_LowLevel$close = function (socket) {
	return A2(
		_elm_lang$core$Task$map,
		_elm_lang$core$Basics$always(
			{ctor: '_Tuple0'}),
		A3(_elm_lang$websocket$WebSocket_LowLevel$closeWith, 1000, '', socket));
};
var _elm_lang$websocket$WebSocket_LowLevel$open = _elm_lang$websocket$Native_WebSocket.open;
var _elm_lang$websocket$WebSocket_LowLevel$Settings = F2(
	function (a, b) {
		return {onMessage: a, onClose: b};
	});
var _elm_lang$websocket$WebSocket_LowLevel$WebSocket = {ctor: 'WebSocket'};
var _elm_lang$websocket$WebSocket_LowLevel$BadArgs = {ctor: 'BadArgs'};
var _elm_lang$websocket$WebSocket_LowLevel$BadSecurity = {ctor: 'BadSecurity'};
var _elm_lang$websocket$WebSocket_LowLevel$BadReason = {ctor: 'BadReason'};
var _elm_lang$websocket$WebSocket_LowLevel$BadCode = {ctor: 'BadCode'};
var _elm_lang$websocket$WebSocket_LowLevel$BadString = {ctor: 'BadString'};
var _elm_lang$websocket$WebSocket_LowLevel$NotOpen = {ctor: 'NotOpen'};

var _elm_lang$websocket$WebSocket$closeConnection = function (connection) {
	var _p0 = connection;
	if (_p0.ctor === 'Opening') {
		return _elm_lang$core$Process$kill(_p0._1);
	} else {
		return _elm_lang$websocket$WebSocket_LowLevel$close(_p0._0);
	}
};
var _elm_lang$websocket$WebSocket$after = function (backoff) {
	return (_elm_lang$core$Native_Utils.cmp(backoff, 1) < 0) ? _elm_lang$core$Task$succeed(
		{ctor: '_Tuple0'}) : _elm_lang$core$Process$sleep(
		_elm_lang$core$Basics$toFloat(
			10 * Math.pow(2, backoff)));
};
var _elm_lang$websocket$WebSocket$removeQueue = F2(
	function (name, state) {
		return _elm_lang$core$Native_Utils.update(
			state,
			{
				queues: A2(_elm_lang$core$Dict$remove, name, state.queues)
			});
	});
var _elm_lang$websocket$WebSocket$updateSocket = F3(
	function (name, connection, state) {
		return _elm_lang$core$Native_Utils.update(
			state,
			{
				sockets: A3(_elm_lang$core$Dict$insert, name, connection, state.sockets)
			});
	});
var _elm_lang$websocket$WebSocket$add = F2(
	function (value, maybeList) {
		var _p1 = maybeList;
		if (_p1.ctor === 'Nothing') {
			return _elm_lang$core$Maybe$Just(
				{
					ctor: '::',
					_0: value,
					_1: {ctor: '[]'}
				});
		} else {
			return _elm_lang$core$Maybe$Just(
				{ctor: '::', _0: value, _1: _p1._0});
		}
	});
var _elm_lang$websocket$WebSocket$buildSubDict = F2(
	function (subs, dict) {
		buildSubDict:
		while (true) {
			var _p2 = subs;
			if (_p2.ctor === '[]') {
				return dict;
			} else {
				if (_p2._0.ctor === 'Listen') {
					var _v3 = _p2._1,
						_v4 = A3(
						_elm_lang$core$Dict$update,
						_p2._0._0,
						_elm_lang$websocket$WebSocket$add(_p2._0._1),
						dict);
					subs = _v3;
					dict = _v4;
					continue buildSubDict;
				} else {
					var _v5 = _p2._1,
						_v6 = A3(
						_elm_lang$core$Dict$update,
						_p2._0._0,
						function (_p3) {
							return _elm_lang$core$Maybe$Just(
								A2(
									_elm_lang$core$Maybe$withDefault,
									{ctor: '[]'},
									_p3));
						},
						dict);
					subs = _v5;
					dict = _v6;
					continue buildSubDict;
				}
			}
		}
	});
var _elm_lang$websocket$WebSocket_ops = _elm_lang$websocket$WebSocket_ops || {};
_elm_lang$websocket$WebSocket_ops['&>'] = F2(
	function (t1, t2) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (_p4) {
				return t2;
			},
			t1);
	});
var _elm_lang$websocket$WebSocket$sendMessagesHelp = F3(
	function (cmds, socketsDict, queuesDict) {
		sendMessagesHelp:
		while (true) {
			var _p5 = cmds;
			if (_p5.ctor === '[]') {
				return _elm_lang$core$Task$succeed(queuesDict);
			} else {
				var _p9 = _p5._1;
				var _p8 = _p5._0._0;
				var _p7 = _p5._0._1;
				var _p6 = A2(_elm_lang$core$Dict$get, _p8, socketsDict);
				if ((_p6.ctor === 'Just') && (_p6._0.ctor === 'Connected')) {
					return A2(
						_elm_lang$websocket$WebSocket_ops['&>'],
						A2(_elm_lang$websocket$WebSocket_LowLevel$send, _p6._0._0, _p7),
						A3(_elm_lang$websocket$WebSocket$sendMessagesHelp, _p9, socketsDict, queuesDict));
				} else {
					var _v9 = _p9,
						_v10 = socketsDict,
						_v11 = A3(
						_elm_lang$core$Dict$update,
						_p8,
						_elm_lang$websocket$WebSocket$add(_p7),
						queuesDict);
					cmds = _v9;
					socketsDict = _v10;
					queuesDict = _v11;
					continue sendMessagesHelp;
				}
			}
		}
	});
var _elm_lang$websocket$WebSocket$subscription = _elm_lang$core$Native_Platform.leaf('WebSocket');
var _elm_lang$websocket$WebSocket$command = _elm_lang$core$Native_Platform.leaf('WebSocket');
var _elm_lang$websocket$WebSocket$State = F3(
	function (a, b, c) {
		return {sockets: a, queues: b, subs: c};
	});
var _elm_lang$websocket$WebSocket$init = _elm_lang$core$Task$succeed(
	A3(_elm_lang$websocket$WebSocket$State, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty));
var _elm_lang$websocket$WebSocket$Send = F2(
	function (a, b) {
		return {ctor: 'Send', _0: a, _1: b};
	});
var _elm_lang$websocket$WebSocket$send = F2(
	function (url, message) {
		return _elm_lang$websocket$WebSocket$command(
			A2(_elm_lang$websocket$WebSocket$Send, url, message));
	});
var _elm_lang$websocket$WebSocket$cmdMap = F2(
	function (_p11, _p10) {
		var _p12 = _p10;
		return A2(_elm_lang$websocket$WebSocket$Send, _p12._0, _p12._1);
	});
var _elm_lang$websocket$WebSocket$KeepAlive = function (a) {
	return {ctor: 'KeepAlive', _0: a};
};
var _elm_lang$websocket$WebSocket$keepAlive = function (url) {
	return _elm_lang$websocket$WebSocket$subscription(
		_elm_lang$websocket$WebSocket$KeepAlive(url));
};
var _elm_lang$websocket$WebSocket$Listen = F2(
	function (a, b) {
		return {ctor: 'Listen', _0: a, _1: b};
	});
var _elm_lang$websocket$WebSocket$listen = F2(
	function (url, tagger) {
		return _elm_lang$websocket$WebSocket$subscription(
			A2(_elm_lang$websocket$WebSocket$Listen, url, tagger));
	});
var _elm_lang$websocket$WebSocket$subMap = F2(
	function (func, sub) {
		var _p13 = sub;
		if (_p13.ctor === 'Listen') {
			return A2(
				_elm_lang$websocket$WebSocket$Listen,
				_p13._0,
				function (_p14) {
					return func(
						_p13._1(_p14));
				});
		} else {
			return _elm_lang$websocket$WebSocket$KeepAlive(_p13._0);
		}
	});
var _elm_lang$websocket$WebSocket$Connected = function (a) {
	return {ctor: 'Connected', _0: a};
};
var _elm_lang$websocket$WebSocket$Opening = F2(
	function (a, b) {
		return {ctor: 'Opening', _0: a, _1: b};
	});
var _elm_lang$websocket$WebSocket$BadOpen = function (a) {
	return {ctor: 'BadOpen', _0: a};
};
var _elm_lang$websocket$WebSocket$GoodOpen = F2(
	function (a, b) {
		return {ctor: 'GoodOpen', _0: a, _1: b};
	});
var _elm_lang$websocket$WebSocket$Die = function (a) {
	return {ctor: 'Die', _0: a};
};
var _elm_lang$websocket$WebSocket$Receive = F2(
	function (a, b) {
		return {ctor: 'Receive', _0: a, _1: b};
	});
var _elm_lang$websocket$WebSocket$open = F2(
	function (name, router) {
		return A2(
			_elm_lang$websocket$WebSocket_LowLevel$open,
			name,
			{
				onMessage: F2(
					function (_p15, msg) {
						return A2(
							_elm_lang$core$Platform$sendToSelf,
							router,
							A2(_elm_lang$websocket$WebSocket$Receive, name, msg));
					}),
				onClose: function (details) {
					return A2(
						_elm_lang$core$Platform$sendToSelf,
						router,
						_elm_lang$websocket$WebSocket$Die(name));
				}
			});
	});
var _elm_lang$websocket$WebSocket$attemptOpen = F3(
	function (router, backoff, name) {
		var badOpen = function (_p16) {
			return A2(
				_elm_lang$core$Platform$sendToSelf,
				router,
				_elm_lang$websocket$WebSocket$BadOpen(name));
		};
		var goodOpen = function (ws) {
			return A2(
				_elm_lang$core$Platform$sendToSelf,
				router,
				A2(_elm_lang$websocket$WebSocket$GoodOpen, name, ws));
		};
		var actuallyAttemptOpen = A2(
			_elm_lang$core$Task$onError,
			badOpen,
			A2(
				_elm_lang$core$Task$andThen,
				goodOpen,
				A2(_elm_lang$websocket$WebSocket$open, name, router)));
		return _elm_lang$core$Process$spawn(
			A2(
				_elm_lang$websocket$WebSocket_ops['&>'],
				_elm_lang$websocket$WebSocket$after(backoff),
				actuallyAttemptOpen));
	});
var _elm_lang$websocket$WebSocket$onEffects = F4(
	function (router, cmds, subs, state) {
		var newSubs = A2(_elm_lang$websocket$WebSocket$buildSubDict, subs, _elm_lang$core$Dict$empty);
		var cleanup = function (newQueues) {
			var rightStep = F3(
				function (name, connection, getNewSockets) {
					return A2(
						_elm_lang$websocket$WebSocket_ops['&>'],
						_elm_lang$websocket$WebSocket$closeConnection(connection),
						getNewSockets);
				});
			var bothStep = F4(
				function (name, _p17, connection, getNewSockets) {
					return A2(
						_elm_lang$core$Task$map,
						A2(_elm_lang$core$Dict$insert, name, connection),
						getNewSockets);
				});
			var leftStep = F3(
				function (name, _p18, getNewSockets) {
					return A2(
						_elm_lang$core$Task$andThen,
						function (newSockets) {
							return A2(
								_elm_lang$core$Task$andThen,
								function (pid) {
									return _elm_lang$core$Task$succeed(
										A3(
											_elm_lang$core$Dict$insert,
											name,
											A2(_elm_lang$websocket$WebSocket$Opening, 0, pid),
											newSockets));
								},
								A3(_elm_lang$websocket$WebSocket$attemptOpen, router, 0, name));
						},
						getNewSockets);
				});
			var newEntries = A2(
				_elm_lang$core$Dict$union,
				newQueues,
				A2(
					_elm_lang$core$Dict$map,
					F2(
						function (k, v) {
							return {ctor: '[]'};
						}),
					newSubs));
			var collectNewSockets = A6(
				_elm_lang$core$Dict$merge,
				leftStep,
				bothStep,
				rightStep,
				newEntries,
				state.sockets,
				_elm_lang$core$Task$succeed(_elm_lang$core$Dict$empty));
			return A2(
				_elm_lang$core$Task$andThen,
				function (newSockets) {
					return _elm_lang$core$Task$succeed(
						A3(_elm_lang$websocket$WebSocket$State, newSockets, newQueues, newSubs));
				},
				collectNewSockets);
		};
		var sendMessagesGetNewQueues = A3(_elm_lang$websocket$WebSocket$sendMessagesHelp, cmds, state.sockets, state.queues);
		return A2(_elm_lang$core$Task$andThen, cleanup, sendMessagesGetNewQueues);
	});
var _elm_lang$websocket$WebSocket$onSelfMsg = F3(
	function (router, selfMsg, state) {
		var _p19 = selfMsg;
		switch (_p19.ctor) {
			case 'Receive':
				var sends = A2(
					_elm_lang$core$List$map,
					function (tagger) {
						return A2(
							_elm_lang$core$Platform$sendToApp,
							router,
							tagger(_p19._1));
					},
					A2(
						_elm_lang$core$Maybe$withDefault,
						{ctor: '[]'},
						A2(_elm_lang$core$Dict$get, _p19._0, state.subs)));
				return A2(
					_elm_lang$websocket$WebSocket_ops['&>'],
					_elm_lang$core$Task$sequence(sends),
					_elm_lang$core$Task$succeed(state));
			case 'Die':
				var _p21 = _p19._0;
				var _p20 = A2(_elm_lang$core$Dict$get, _p21, state.sockets);
				if (_p20.ctor === 'Nothing') {
					return _elm_lang$core$Task$succeed(state);
				} else {
					return A2(
						_elm_lang$core$Task$andThen,
						function (pid) {
							return _elm_lang$core$Task$succeed(
								A3(
									_elm_lang$websocket$WebSocket$updateSocket,
									_p21,
									A2(_elm_lang$websocket$WebSocket$Opening, 0, pid),
									state));
						},
						A3(_elm_lang$websocket$WebSocket$attemptOpen, router, 0, _p21));
				}
			case 'GoodOpen':
				var _p24 = _p19._1;
				var _p23 = _p19._0;
				var _p22 = A2(_elm_lang$core$Dict$get, _p23, state.queues);
				if (_p22.ctor === 'Nothing') {
					return _elm_lang$core$Task$succeed(
						A3(
							_elm_lang$websocket$WebSocket$updateSocket,
							_p23,
							_elm_lang$websocket$WebSocket$Connected(_p24),
							state));
				} else {
					return A3(
						_elm_lang$core$List$foldl,
						F2(
							function (msg, task) {
								return A2(
									_elm_lang$websocket$WebSocket_ops['&>'],
									A2(_elm_lang$websocket$WebSocket_LowLevel$send, _p24, msg),
									task);
							}),
						_elm_lang$core$Task$succeed(
							A2(
								_elm_lang$websocket$WebSocket$removeQueue,
								_p23,
								A3(
									_elm_lang$websocket$WebSocket$updateSocket,
									_p23,
									_elm_lang$websocket$WebSocket$Connected(_p24),
									state))),
						_p22._0);
				}
			default:
				var _p27 = _p19._0;
				var _p25 = A2(_elm_lang$core$Dict$get, _p27, state.sockets);
				if (_p25.ctor === 'Nothing') {
					return _elm_lang$core$Task$succeed(state);
				} else {
					if (_p25._0.ctor === 'Opening') {
						var _p26 = _p25._0._0;
						return A2(
							_elm_lang$core$Task$andThen,
							function (pid) {
								return _elm_lang$core$Task$succeed(
									A3(
										_elm_lang$websocket$WebSocket$updateSocket,
										_p27,
										A2(_elm_lang$websocket$WebSocket$Opening, _p26 + 1, pid),
										state));
							},
							A3(_elm_lang$websocket$WebSocket$attemptOpen, router, _p26 + 1, _p27));
					} else {
						return _elm_lang$core$Task$succeed(state);
					}
				}
		}
	});
_elm_lang$core$Native_Platform.effectManagers['WebSocket'] = {pkg: 'elm-lang/websocket', init: _elm_lang$websocket$WebSocket$init, onEffects: _elm_lang$websocket$WebSocket$onEffects, onSelfMsg: _elm_lang$websocket$WebSocket$onSelfMsg, tag: 'fx', cmdMap: _elm_lang$websocket$WebSocket$cmdMap, subMap: _elm_lang$websocket$WebSocket$subMap};

var _elm_lang$animation_frame$Native_AnimationFrame = function()
{

function create()
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var id = requestAnimationFrame(function() {
			callback(_elm_lang$core$Native_Scheduler.succeed(Date.now()));
		});

		return function() {
			cancelAnimationFrame(id);
		};
	});
}

return {
	create: create
};

}();

var _elm_lang$animation_frame$AnimationFrame$rAF = _elm_lang$animation_frame$Native_AnimationFrame.create(
	{ctor: '_Tuple0'});
var _elm_lang$animation_frame$AnimationFrame$subscription = _elm_lang$core$Native_Platform.leaf('AnimationFrame');
var _elm_lang$animation_frame$AnimationFrame$State = F3(
	function (a, b, c) {
		return {subs: a, request: b, oldTime: c};
	});
var _elm_lang$animation_frame$AnimationFrame$init = _elm_lang$core$Task$succeed(
	A3(
		_elm_lang$animation_frame$AnimationFrame$State,
		{ctor: '[]'},
		_elm_lang$core$Maybe$Nothing,
		0));
var _elm_lang$animation_frame$AnimationFrame$onEffects = F3(
	function (router, subs, _p0) {
		var _p1 = _p0;
		var _p5 = _p1.request;
		var _p4 = _p1.oldTime;
		var _p2 = {ctor: '_Tuple2', _0: _p5, _1: subs};
		if (_p2._0.ctor === 'Nothing') {
			if (_p2._1.ctor === '[]') {
				return _elm_lang$core$Task$succeed(
					A3(
						_elm_lang$animation_frame$AnimationFrame$State,
						{ctor: '[]'},
						_elm_lang$core$Maybe$Nothing,
						_p4));
			} else {
				return A2(
					_elm_lang$core$Task$andThen,
					function (pid) {
						return A2(
							_elm_lang$core$Task$andThen,
							function (time) {
								return _elm_lang$core$Task$succeed(
									A3(
										_elm_lang$animation_frame$AnimationFrame$State,
										subs,
										_elm_lang$core$Maybe$Just(pid),
										time));
							},
							_elm_lang$core$Time$now);
					},
					_elm_lang$core$Process$spawn(
						A2(
							_elm_lang$core$Task$andThen,
							_elm_lang$core$Platform$sendToSelf(router),
							_elm_lang$animation_frame$AnimationFrame$rAF)));
			}
		} else {
			if (_p2._1.ctor === '[]') {
				return A2(
					_elm_lang$core$Task$andThen,
					function (_p3) {
						return _elm_lang$core$Task$succeed(
							A3(
								_elm_lang$animation_frame$AnimationFrame$State,
								{ctor: '[]'},
								_elm_lang$core$Maybe$Nothing,
								_p4));
					},
					_elm_lang$core$Process$kill(_p2._0._0));
			} else {
				return _elm_lang$core$Task$succeed(
					A3(_elm_lang$animation_frame$AnimationFrame$State, subs, _p5, _p4));
			}
		}
	});
var _elm_lang$animation_frame$AnimationFrame$onSelfMsg = F3(
	function (router, newTime, _p6) {
		var _p7 = _p6;
		var _p10 = _p7.subs;
		var diff = newTime - _p7.oldTime;
		var send = function (sub) {
			var _p8 = sub;
			if (_p8.ctor === 'Time') {
				return A2(
					_elm_lang$core$Platform$sendToApp,
					router,
					_p8._0(newTime));
			} else {
				return A2(
					_elm_lang$core$Platform$sendToApp,
					router,
					_p8._0(diff));
			}
		};
		return A2(
			_elm_lang$core$Task$andThen,
			function (pid) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (_p9) {
						return _elm_lang$core$Task$succeed(
							A3(
								_elm_lang$animation_frame$AnimationFrame$State,
								_p10,
								_elm_lang$core$Maybe$Just(pid),
								newTime));
					},
					_elm_lang$core$Task$sequence(
						A2(_elm_lang$core$List$map, send, _p10)));
			},
			_elm_lang$core$Process$spawn(
				A2(
					_elm_lang$core$Task$andThen,
					_elm_lang$core$Platform$sendToSelf(router),
					_elm_lang$animation_frame$AnimationFrame$rAF)));
	});
var _elm_lang$animation_frame$AnimationFrame$Diff = function (a) {
	return {ctor: 'Diff', _0: a};
};
var _elm_lang$animation_frame$AnimationFrame$diffs = function (tagger) {
	return _elm_lang$animation_frame$AnimationFrame$subscription(
		_elm_lang$animation_frame$AnimationFrame$Diff(tagger));
};
var _elm_lang$animation_frame$AnimationFrame$Time = function (a) {
	return {ctor: 'Time', _0: a};
};
var _elm_lang$animation_frame$AnimationFrame$times = function (tagger) {
	return _elm_lang$animation_frame$AnimationFrame$subscription(
		_elm_lang$animation_frame$AnimationFrame$Time(tagger));
};
var _elm_lang$animation_frame$AnimationFrame$subMap = F2(
	function (func, sub) {
		var _p11 = sub;
		if (_p11.ctor === 'Time') {
			return _elm_lang$animation_frame$AnimationFrame$Time(
				function (_p12) {
					return func(
						_p11._0(_p12));
				});
		} else {
			return _elm_lang$animation_frame$AnimationFrame$Diff(
				function (_p13) {
					return func(
						_p11._0(_p13));
				});
		}
	});
_elm_lang$core$Native_Platform.effectManagers['AnimationFrame'] = {pkg: 'elm-lang/animation-frame', init: _elm_lang$animation_frame$AnimationFrame$init, onEffects: _elm_lang$animation_frame$AnimationFrame$onEffects, onSelfMsg: _elm_lang$animation_frame$AnimationFrame$onSelfMsg, tag: 'sub', subMap: _elm_lang$animation_frame$AnimationFrame$subMap};

var _Lattyware$massivedecks$MassiveDecks_Components_QR$view = function (containerId) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$id(containerId),
			_1: {ctor: '[]'}
		},
		{ctor: '[]'});
};
var _Lattyware$massivedecks$MassiveDecks_Components_QR$qr = _elm_lang$core$Native_Platform.outgoingPort(
	'qr',
	function (v) {
		return {id: v.id, value: v.value};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_QR$encodeAndRender = F2(
	function (containerId, value) {
		return _Lattyware$massivedecks$MassiveDecks_Components_QR$qr(
			{id: containerId, value: value});
	});

var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$customDecoder = F2(
	function (decoder, toResult) {
		return A2(
			_elm_lang$core$Json_Decode$andThen,
			function (a) {
				var _p0 = toResult(a);
				if (_p0.ctor === 'Ok') {
					return _elm_lang$core$Json_Decode$succeed(_p0._0);
				} else {
					return _elm_lang$core$Json_Decode$fail(_p0._0);
				}
			},
			decoder);
	});
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$ruleNameToId = function (name) {
	var _p1 = name;
	if (_p1 === 'reboot') {
		return _elm_lang$core$Maybe$Just(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$Reboot);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$houseRuleDecoder = A2(
	_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$customDecoder,
	_elm_lang$core$Json_Decode$string,
	function (name) {
		return A2(
			_elm_lang$core$Result$fromMaybe,
			A2(
				_elm_lang$core$Basics_ops['++'],
				'Unknown house rule \'',
				A2(_elm_lang$core$Basics_ops['++'], name, '\'.')),
			_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$ruleNameToId(name));
	});
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder = _elm_lang$core$Json_Decode$int;
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerSecretDecoder = A3(
	_elm_lang$core$Json_Decode$map2,
	_Lattyware$massivedecks$MassiveDecks_Models_Player$Secret,
	A2(_elm_lang$core$Json_Decode$field, 'id', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
	A2(_elm_lang$core$Json_Decode$field, 'secret', _elm_lang$core$Json_Decode$string));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responseDecoder = A3(
	_elm_lang$core$Json_Decode$map2,
	_Lattyware$massivedecks$MassiveDecks_Models_Card$Response,
	A2(_elm_lang$core$Json_Decode$field, 'id', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'text', _elm_lang$core$Json_Decode$string));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$callDecoder = A3(
	_elm_lang$core$Json_Decode$map2,
	_Lattyware$massivedecks$MassiveDecks_Models_Card$Call,
	A2(_elm_lang$core$Json_Decode$field, 'id', _elm_lang$core$Json_Decode$string),
	A2(
		_elm_lang$core$Json_Decode$field,
		'parts',
		_elm_lang$core$Json_Decode$list(_elm_lang$core$Json_Decode$string)));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playedByAndWinnerDecoder = A3(
	_elm_lang$core$Json_Decode$map2,
	_Lattyware$massivedecks$MassiveDecks_Models_Player$PlayedByAndWinner,
	A2(
		_elm_lang$core$Json_Decode$field,
		'playedBy',
		_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder)),
	A2(_elm_lang$core$Json_Decode$field, 'winner', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$finishedStateDecoder = A3(
	_elm_lang$core$Json_Decode$map2,
	_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$Finished,
	A2(
		_elm_lang$core$Json_Decode$field,
		'cards',
		_elm_lang$core$Json_Decode$list(
			_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responseDecoder))),
	A2(_elm_lang$core$Json_Decode$field, 'playedByAndWinner', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playedByAndWinnerDecoder));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$finishedRoundDecoder = A4(
	_elm_lang$core$Json_Decode$map3,
	_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$FinishedRound,
	A2(_elm_lang$core$Json_Decode$field, 'czar', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
	A2(_elm_lang$core$Json_Decode$field, 'call', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$callDecoder),
	A2(_elm_lang$core$Json_Decode$field, 'state', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$finishedStateDecoder));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$roundStateDecoder = A2(
	_elm_lang$core$Json_Decode$andThen,
	function (roundState) {
		var _p2 = roundState;
		switch (_p2) {
			case 'playing':
				return A3(
					_elm_lang$core$Json_Decode$map2,
					_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$playing,
					A2(_elm_lang$core$Json_Decode$field, 'numberPlayed', _elm_lang$core$Json_Decode$int),
					A2(_elm_lang$core$Json_Decode$field, 'afterTimeLimit', _elm_lang$core$Json_Decode$bool));
			case 'judging':
				return A3(
					_elm_lang$core$Json_Decode$map2,
					_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$judging,
					A2(
						_elm_lang$core$Json_Decode$field,
						'cards',
						_elm_lang$core$Json_Decode$list(
							_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responseDecoder))),
					A2(_elm_lang$core$Json_Decode$field, 'afterTimeLimit', _elm_lang$core$Json_Decode$bool));
			case 'finished':
				return A2(_elm_lang$core$Json_Decode$map, _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$F, _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$finishedStateDecoder);
			default:
				return _elm_lang$core$Json_Decode$fail(
					A2(
						_elm_lang$core$Basics_ops['++'],
						'Unknown round state \'',
						A2(_elm_lang$core$Basics_ops['++'], roundState, '\'.')));
		}
	},
	A2(_elm_lang$core$Json_Decode$field, 'roundState', _elm_lang$core$Json_Decode$string));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$roundDecoder = A4(
	_elm_lang$core$Json_Decode$map3,
	_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$Round,
	A2(_elm_lang$core$Json_Decode$field, 'czar', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
	A2(_elm_lang$core$Json_Decode$field, 'call', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$callDecoder),
	A2(_elm_lang$core$Json_Decode$field, 'state', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$roundStateDecoder));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$gameStateDecoder = A2(
	_elm_lang$core$Json_Decode$andThen,
	function (gameState) {
		var _p3 = gameState;
		switch (_p3) {
			case 'configuring':
				return _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_Models_Game$Configuring);
			case 'playing':
				return A2(
					_elm_lang$core$Json_Decode$map,
					_Lattyware$massivedecks$MassiveDecks_Models_Game$Playing,
					A2(_elm_lang$core$Json_Decode$field, 'round', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$roundDecoder));
			case 'finished':
				return _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_Models_Game$Finished);
			default:
				return _elm_lang$core$Json_Decode$fail(
					A2(
						_elm_lang$core$Basics_ops['++'],
						'Unknown game state \'',
						A2(_elm_lang$core$Basics_ops['++'], gameState, '\'.')));
		}
	},
	A2(_elm_lang$core$Json_Decode$field, 'gameState', _elm_lang$core$Json_Decode$string));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerStatusDecoder = A2(
	_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$customDecoder,
	_elm_lang$core$Json_Decode$string,
	function (name) {
		return A2(
			_elm_lang$core$Result$fromMaybe,
			A2(
				_elm_lang$core$Basics_ops['++'],
				'Unknown player status \'',
				A2(_elm_lang$core$Basics_ops['++'], name, '\'.')),
			_Lattyware$massivedecks$MassiveDecks_Models_Player$nameToStatus(name));
	});
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerDecoder = A7(
	_elm_lang$core$Json_Decode$map6,
	_Lattyware$massivedecks$MassiveDecks_Models_Player$Player,
	A2(_elm_lang$core$Json_Decode$field, 'id', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
	A2(_elm_lang$core$Json_Decode$field, 'name', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'status', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerStatusDecoder),
	A2(_elm_lang$core$Json_Decode$field, 'score', _elm_lang$core$Json_Decode$int),
	A2(_elm_lang$core$Json_Decode$field, 'disconnected', _elm_lang$core$Json_Decode$bool),
	A2(_elm_lang$core$Json_Decode$field, 'left', _elm_lang$core$Json_Decode$bool));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder = A2(
	_elm_lang$core$Json_Decode$map,
	_Lattyware$massivedecks$MassiveDecks_Models_Card$Hand,
	A2(
		_elm_lang$core$Json_Decode$field,
		'hand',
		_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responseDecoder)));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$deckInfoDecoder = A5(
	_elm_lang$core$Json_Decode$map4,
	_Lattyware$massivedecks$MassiveDecks_Models_Game$DeckInfo,
	A2(_elm_lang$core$Json_Decode$field, 'id', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'name', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'calls', _elm_lang$core$Json_Decode$int),
	A2(_elm_lang$core$Json_Decode$field, 'responses', _elm_lang$core$Json_Decode$int));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$configDecoder = A4(
	_elm_lang$core$Json_Decode$map3,
	_Lattyware$massivedecks$MassiveDecks_Models_Game$Config,
	A2(
		_elm_lang$core$Json_Decode$field,
		'decks',
		_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$deckInfoDecoder)),
	A2(
		_elm_lang$core$Json_Decode$field,
		'houseRules',
		_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$houseRuleDecoder)),
	_elm_lang$core$Json_Decode$maybe(
		A2(_elm_lang$core$Json_Decode$field, 'password', _elm_lang$core$Json_Decode$string)));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$gameCodeAndSecretDecoder = A3(
	_elm_lang$core$Json_Decode$map2,
	_Lattyware$massivedecks$MassiveDecks_Models_Game$GameCodeAndSecret,
	A2(_elm_lang$core$Json_Decode$field, 'gameCode', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'secret', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerSecretDecoder));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$lobbyDecoder = A6(
	_elm_lang$core$Json_Decode$map5,
	_Lattyware$massivedecks$MassiveDecks_Models_Game$Lobby,
	A2(_elm_lang$core$Json_Decode$field, 'gameCode', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'owner', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
	A2(_elm_lang$core$Json_Decode$field, 'config', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$configDecoder),
	A2(
		_elm_lang$core$Json_Decode$field,
		'players',
		_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerDecoder)),
	A2(_elm_lang$core$Json_Decode$field, 'state', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$gameStateDecoder));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$lobbyAndHandDecoder = A3(
	_elm_lang$core$Json_Decode$map2,
	_Lattyware$massivedecks$MassiveDecks_Models_Game$LobbyAndHand,
	A2(_elm_lang$core$Json_Decode$field, 'lobby', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$lobbyDecoder),
	A2(_elm_lang$core$Json_Decode$field, 'hand', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder));

var _Lattyware$massivedecks$MassiveDecks_Models_Event$RoundTimeLimitHit = {ctor: 'RoundTimeLimitHit'};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$ConfigChange = function (a) {
	return {ctor: 'ConfigChange', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$GameEnd = {ctor: 'GameEnd'};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$GameStart = F2(
	function (a, b) {
		return {ctor: 'GameStart', _0: a, _1: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Event$RoundEnd = function (a) {
	return {ctor: 'RoundEnd', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$RoundJudging = function (a) {
	return {ctor: 'RoundJudging', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$RoundPlayed = function (a) {
	return {ctor: 'RoundPlayed', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$RoundStart = F2(
	function (a, b) {
		return {ctor: 'RoundStart', _0: a, _1: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Event$HandChange = function (a) {
	return {ctor: 'HandChange', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerScoreChange = F2(
	function (a, b) {
		return {ctor: 'PlayerScoreChange', _0: a, _1: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerReconnect = function (a) {
	return {ctor: 'PlayerReconnect', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerDisconnect = function (a) {
	return {ctor: 'PlayerDisconnect', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerLeft = function (a) {
	return {ctor: 'PlayerLeft', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerStatus = F2(
	function (a, b) {
		return {ctor: 'PlayerStatus', _0: a, _1: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerJoin = function (a) {
	return {ctor: 'PlayerJoin', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$Sync = function (a) {
	return {ctor: 'Sync', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$specificEventDecoder = function (name) {
	var _p0 = name;
	switch (_p0) {
		case 'Sync':
			return A2(
				_elm_lang$core$Json_Decode$map,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$Sync,
				A2(_elm_lang$core$Json_Decode$field, 'lobbyAndHand', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$lobbyAndHandDecoder));
		case 'PlayerJoin':
			return A2(
				_elm_lang$core$Json_Decode$map,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerJoin,
				A2(_elm_lang$core$Json_Decode$field, 'player', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerDecoder));
		case 'PlayerStatus':
			return A3(
				_elm_lang$core$Json_Decode$map2,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerStatus,
				A2(_elm_lang$core$Json_Decode$field, 'player', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
				A2(_elm_lang$core$Json_Decode$field, 'status', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerStatusDecoder));
		case 'PlayerLeft':
			return A2(
				_elm_lang$core$Json_Decode$map,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerLeft,
				A2(_elm_lang$core$Json_Decode$field, 'player', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder));
		case 'PlayerDisconnect':
			return A2(
				_elm_lang$core$Json_Decode$map,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerDisconnect,
				A2(_elm_lang$core$Json_Decode$field, 'player', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder));
		case 'PlayerReconnect':
			return A2(
				_elm_lang$core$Json_Decode$map,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerReconnect,
				A2(_elm_lang$core$Json_Decode$field, 'player', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder));
		case 'PlayerScoreChange':
			return A3(
				_elm_lang$core$Json_Decode$map2,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerScoreChange,
				A2(_elm_lang$core$Json_Decode$field, 'player', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
				A2(_elm_lang$core$Json_Decode$field, 'score', _elm_lang$core$Json_Decode$int));
		case 'HandChange':
			return A2(
				_elm_lang$core$Json_Decode$map,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$HandChange,
				A2(_elm_lang$core$Json_Decode$field, 'hand', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder));
		case 'RoundStart':
			return A3(
				_elm_lang$core$Json_Decode$map2,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$RoundStart,
				A2(_elm_lang$core$Json_Decode$field, 'czar', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
				A2(_elm_lang$core$Json_Decode$field, 'call', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$callDecoder));
		case 'RoundPlayed':
			return A2(
				_elm_lang$core$Json_Decode$map,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$RoundPlayed,
				A2(_elm_lang$core$Json_Decode$field, 'playedCards', _elm_lang$core$Json_Decode$int));
		case 'RoundJudging':
			return A2(
				_elm_lang$core$Json_Decode$map,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$RoundJudging,
				A2(
					_elm_lang$core$Json_Decode$field,
					'playedCards',
					_elm_lang$core$Json_Decode$list(
						_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responseDecoder))));
		case 'RoundEnd':
			return A2(
				_elm_lang$core$Json_Decode$map,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$RoundEnd,
				A2(_elm_lang$core$Json_Decode$field, 'finishedRound', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$finishedRoundDecoder));
		case 'GameStart':
			return A3(
				_elm_lang$core$Json_Decode$map2,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$GameStart,
				A2(_elm_lang$core$Json_Decode$field, 'czar', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
				A2(_elm_lang$core$Json_Decode$field, 'call', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$callDecoder));
		case 'GameEnd':
			return _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_Models_Event$GameEnd);
		case 'ConfigChange':
			return A2(
				_elm_lang$core$Json_Decode$map,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$ConfigChange,
				A2(_elm_lang$core$Json_Decode$field, 'config', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$configDecoder));
		case 'RoundTimeLimitHit':
			return _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_Models_Event$RoundTimeLimitHit);
		default:
			return _elm_lang$core$Json_Decode$fail(
				A2(_elm_lang$core$Basics_ops['++'], _p0, ' is not a recognised event.'));
	}
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$eventDecoder = A2(
	_elm_lang$core$Json_Decode$andThen,
	_Lattyware$massivedecks$MassiveDecks_Models_Event$specificEventDecoder,
	A2(_elm_lang$core$Json_Decode$field, 'event', _elm_lang$core$Json_Decode$string));
var _Lattyware$massivedecks$MassiveDecks_Models_Event$fromJson = function (json) {
	return A2(_elm_lang$core$Json_Decode$decodeString, _Lattyware$massivedecks$MassiveDecks_Models_Event$eventDecoder, json);
};

var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodeNameAndPassword = F2(
	function (name, password) {
		return _elm_lang$core$Json_Encode$object(
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'name',
					_1: _elm_lang$core$Json_Encode$string(name)
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'password',
						_1: _elm_lang$core$Json_Encode$string(password)
					},
					_1: {ctor: '[]'}
				}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodeName = function (name) {
	return _elm_lang$core$Json_Encode$object(
		{
			ctor: '::',
			_0: {
				ctor: '_Tuple2',
				_0: 'name',
				_1: _elm_lang$core$Json_Encode$string(name)
			},
			_1: {ctor: '[]'}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerId = function (playerId) {
	return _elm_lang$core$Json_Encode$int(playerId);
};
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerSecret = function (playerSecret) {
	return _elm_lang$core$Json_Encode$object(
		{
			ctor: '::',
			_0: {
				ctor: '_Tuple2',
				_0: 'id',
				_1: _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerId(playerSecret.id)
			},
			_1: {
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'secret',
					_1: _elm_lang$core$Json_Encode$string(playerSecret.secret)
				},
				_1: {ctor: '[]'}
			}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodeDeckId = function (id) {
	return {
		ctor: '_Tuple2',
		_0: 'deckId',
		_1: _elm_lang$core$Json_Encode$string(id)
	};
};
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodeCommand = F3(
	function (action, playerSecret, rest) {
		return _elm_lang$core$Json_Encode$object(
			A2(
				_elm_lang$core$List$append,
				{
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'command',
						_1: _elm_lang$core$Json_Encode$string(action)
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple2',
							_0: 'secret',
							_1: _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerSecret(playerSecret)
						},
						_1: {ctor: '[]'}
					}
				},
				rest));
	});

var _elm_lang$http$Native_Http = function() {


// ENCODING AND DECODING

function encodeUri(string)
{
	return encodeURIComponent(string);
}

function decodeUri(string)
{
	try
	{
		return _elm_lang$core$Maybe$Just(decodeURIComponent(string));
	}
	catch(e)
	{
		return _elm_lang$core$Maybe$Nothing;
	}
}


// SEND REQUEST

function toTask(request, maybeProgress)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var xhr = new XMLHttpRequest();

		configureProgress(xhr, maybeProgress);

		xhr.addEventListener('error', function() {
			callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'NetworkError' }));
		});
		xhr.addEventListener('timeout', function() {
			callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'Timeout' }));
		});
		xhr.addEventListener('load', function() {
			callback(handleResponse(xhr, request.expect.responseToResult));
		});

		try
		{
			xhr.open(request.method, request.url, true);
		}
		catch (e)
		{
			return callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'BadUrl', _0: request.url }));
		}

		configureRequest(xhr, request);
		send(xhr, request.body);

		return function() { xhr.abort(); };
	});
}

function configureProgress(xhr, maybeProgress)
{
	if (maybeProgress.ctor === 'Nothing')
	{
		return;
	}

	xhr.addEventListener('progress', function(event) {
		if (!event.lengthComputable)
		{
			return;
		}
		_elm_lang$core$Native_Scheduler.rawSpawn(maybeProgress._0({
			bytes: event.loaded,
			bytesExpected: event.total
		}));
	});
}

function configureRequest(xhr, request)
{
	function setHeader(pair)
	{
		xhr.setRequestHeader(pair._0, pair._1);
	}

	A2(_elm_lang$core$List$map, setHeader, request.headers);
	xhr.responseType = request.expect.responseType;
	xhr.withCredentials = request.withCredentials;

	if (request.timeout.ctor === 'Just')
	{
		xhr.timeout = request.timeout._0;
	}
}

function send(xhr, body)
{
	switch (body.ctor)
	{
		case 'EmptyBody':
			xhr.send();
			return;

		case 'StringBody':
			xhr.setRequestHeader('Content-Type', body._0);
			xhr.send(body._1);
			return;

		case 'FormDataBody':
			xhr.send(body._0);
			return;
	}
}


// RESPONSES

function handleResponse(xhr, responseToResult)
{
	var response = toResponse(xhr);

	if (xhr.status < 200 || 300 <= xhr.status)
	{
		response.body = xhr.responseText;
		return _elm_lang$core$Native_Scheduler.fail({
			ctor: 'BadStatus',
			_0: response
		});
	}

	var result = responseToResult(response);

	if (result.ctor === 'Ok')
	{
		return _elm_lang$core$Native_Scheduler.succeed(result._0);
	}
	else
	{
		response.body = xhr.responseText;
		return _elm_lang$core$Native_Scheduler.fail({
			ctor: 'BadPayload',
			_0: result._0,
			_1: response
		});
	}
}

function toResponse(xhr)
{
	return {
		status: { code: xhr.status, message: xhr.statusText },
		headers: parseHeaders(xhr.getAllResponseHeaders()),
		url: xhr.responseURL,
		body: xhr.response
	};
}

function parseHeaders(rawHeaders)
{
	var headers = _elm_lang$core$Dict$empty;

	if (!rawHeaders)
	{
		return headers;
	}

	var headerPairs = rawHeaders.split('\u000d\u000a');
	for (var i = headerPairs.length; i--; )
	{
		var headerPair = headerPairs[i];
		var index = headerPair.indexOf('\u003a\u0020');
		if (index > 0)
		{
			var key = headerPair.substring(0, index);
			var value = headerPair.substring(index + 2);

			headers = A3(_elm_lang$core$Dict$update, key, function(oldValue) {
				if (oldValue.ctor === 'Just')
				{
					return _elm_lang$core$Maybe$Just(value + ', ' + oldValue._0);
				}
				return _elm_lang$core$Maybe$Just(value);
			}, headers);
		}
	}

	return headers;
}


// EXPECTORS

function expectStringResponse(responseToResult)
{
	return {
		responseType: 'text',
		responseToResult: responseToResult
	};
}

function mapExpect(func, expect)
{
	return {
		responseType: expect.responseType,
		responseToResult: function(response) {
			var convertedResponse = expect.responseToResult(response);
			return A2(_elm_lang$core$Result$map, func, convertedResponse);
		}
	};
}


// BODY

function multipart(parts)
{
	var formData = new FormData();

	while (parts.ctor !== '[]')
	{
		var part = parts._0;
		formData.append(part._0, part._1);
		parts = parts._1;
	}

	return { ctor: 'FormDataBody', _0: formData };
}

return {
	toTask: F2(toTask),
	expectStringResponse: expectStringResponse,
	mapExpect: F2(mapExpect),
	multipart: multipart,
	encodeUri: encodeUri,
	decodeUri: decodeUri
};

}();

var _elm_lang$http$Http_Internal$map = F2(
	function (func, request) {
		return _elm_lang$core$Native_Utils.update(
			request,
			{
				expect: A2(_elm_lang$http$Native_Http.mapExpect, func, request.expect)
			});
	});
var _elm_lang$http$Http_Internal$RawRequest = F7(
	function (a, b, c, d, e, f, g) {
		return {method: a, headers: b, url: c, body: d, expect: e, timeout: f, withCredentials: g};
	});
var _elm_lang$http$Http_Internal$Request = function (a) {
	return {ctor: 'Request', _0: a};
};
var _elm_lang$http$Http_Internal$Expect = {ctor: 'Expect'};
var _elm_lang$http$Http_Internal$FormDataBody = {ctor: 'FormDataBody'};
var _elm_lang$http$Http_Internal$StringBody = F2(
	function (a, b) {
		return {ctor: 'StringBody', _0: a, _1: b};
	});
var _elm_lang$http$Http_Internal$EmptyBody = {ctor: 'EmptyBody'};
var _elm_lang$http$Http_Internal$Header = F2(
	function (a, b) {
		return {ctor: 'Header', _0: a, _1: b};
	});

var _elm_lang$http$Http$decodeUri = _elm_lang$http$Native_Http.decodeUri;
var _elm_lang$http$Http$encodeUri = _elm_lang$http$Native_Http.encodeUri;
var _elm_lang$http$Http$expectStringResponse = _elm_lang$http$Native_Http.expectStringResponse;
var _elm_lang$http$Http$expectJson = function (decoder) {
	return _elm_lang$http$Http$expectStringResponse(
		function (response) {
			return A2(_elm_lang$core$Json_Decode$decodeString, decoder, response.body);
		});
};
var _elm_lang$http$Http$expectString = _elm_lang$http$Http$expectStringResponse(
	function (response) {
		return _elm_lang$core$Result$Ok(response.body);
	});
var _elm_lang$http$Http$multipartBody = _elm_lang$http$Native_Http.multipart;
var _elm_lang$http$Http$stringBody = _elm_lang$http$Http_Internal$StringBody;
var _elm_lang$http$Http$jsonBody = function (value) {
	return A2(
		_elm_lang$http$Http_Internal$StringBody,
		'application/json',
		A2(_elm_lang$core$Json_Encode$encode, 0, value));
};
var _elm_lang$http$Http$emptyBody = _elm_lang$http$Http_Internal$EmptyBody;
var _elm_lang$http$Http$header = _elm_lang$http$Http_Internal$Header;
var _elm_lang$http$Http$request = _elm_lang$http$Http_Internal$Request;
var _elm_lang$http$Http$post = F3(
	function (url, body, decoder) {
		return _elm_lang$http$Http$request(
			{
				method: 'POST',
				headers: {ctor: '[]'},
				url: url,
				body: body,
				expect: _elm_lang$http$Http$expectJson(decoder),
				timeout: _elm_lang$core$Maybe$Nothing,
				withCredentials: false
			});
	});
var _elm_lang$http$Http$get = F2(
	function (url, decoder) {
		return _elm_lang$http$Http$request(
			{
				method: 'GET',
				headers: {ctor: '[]'},
				url: url,
				body: _elm_lang$http$Http$emptyBody,
				expect: _elm_lang$http$Http$expectJson(decoder),
				timeout: _elm_lang$core$Maybe$Nothing,
				withCredentials: false
			});
	});
var _elm_lang$http$Http$getString = function (url) {
	return _elm_lang$http$Http$request(
		{
			method: 'GET',
			headers: {ctor: '[]'},
			url: url,
			body: _elm_lang$http$Http$emptyBody,
			expect: _elm_lang$http$Http$expectString,
			timeout: _elm_lang$core$Maybe$Nothing,
			withCredentials: false
		});
};
var _elm_lang$http$Http$toTask = function (_p0) {
	var _p1 = _p0;
	return A2(_elm_lang$http$Native_Http.toTask, _p1._0, _elm_lang$core$Maybe$Nothing);
};
var _elm_lang$http$Http$send = F2(
	function (resultToMessage, request) {
		return A2(
			_elm_lang$core$Task$attempt,
			resultToMessage,
			_elm_lang$http$Http$toTask(request));
	});
var _elm_lang$http$Http$Response = F4(
	function (a, b, c, d) {
		return {url: a, status: b, headers: c, body: d};
	});
var _elm_lang$http$Http$BadPayload = F2(
	function (a, b) {
		return {ctor: 'BadPayload', _0: a, _1: b};
	});
var _elm_lang$http$Http$BadStatus = function (a) {
	return {ctor: 'BadStatus', _0: a};
};
var _elm_lang$http$Http$NetworkError = {ctor: 'NetworkError'};
var _elm_lang$http$Http$Timeout = {ctor: 'Timeout'};
var _elm_lang$http$Http$BadUrl = function (a) {
	return {ctor: 'BadUrl', _0: a};
};
var _elm_lang$http$Http$StringPart = F2(
	function (a, b) {
		return {ctor: 'StringPart', _0: a, _1: b};
	});
var _elm_lang$http$Http$stringPart = _elm_lang$http$Http$StringPart;

var _Lattyware$massivedecks$MassiveDecks_API_Request$errorKeyDecoder = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'error',
		_1: {ctor: '[]'}
	},
	_elm_lang$core$Json_Decode$string);
var _Lattyware$massivedecks$MassiveDecks_API_Request$genericErrorHandler = function (error) {
	var _p0 = error;
	switch (_p0.ctor) {
		case 'Known':
			return A2(
				_Lattyware$massivedecks$MassiveDecks_Components_Errors$New,
				A2(
					_elm_lang$core$Basics_ops['++'],
					'An error was not correctly handled: ',
					_elm_lang$core$Basics$toString(_p0._0)),
				true);
		case 'Unknown':
			var _p1 = _p0._0;
			return A2(
				_Lattyware$massivedecks$MassiveDecks_Components_Errors$New,
				A2(
					_elm_lang$core$Basics_ops['++'],
					'An error was not not recognised (status ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(_p1.status.code),
						A2(_elm_lang$core$Basics_ops['++'], '): ', _p1.body))),
				true);
		default:
			switch (_p0._0.ctor) {
				case 'Timeout':
					return A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$New, 'Timed out trying to connect to the server.', false);
				case 'NetworkError':
					return A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$New, 'There was a network error trying to connect to the server.', false);
				case 'BadUrl':
					return A2(
						_Lattyware$massivedecks$MassiveDecks_Components_Errors$New,
						A2(
							_elm_lang$core$Basics_ops['++'],
							'The URL \'',
							A2(_elm_lang$core$Basics_ops['++'], _p0._0._0, '\' was invalid.')),
						true);
				case 'BadStatus':
					var _p2 = _p0._0._0;
					return A2(
						_Lattyware$massivedecks$MassiveDecks_Components_Errors$New,
						A2(
							_elm_lang$core$Basics_ops['++'],
							'Recieved an unexpected response (',
							A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Basics$toString(_p2.status.code),
								A2(_elm_lang$core$Basics_ops['++'], ') from the server: ', _p2.status.message))),
						true);
				default:
					return A2(
						_Lattyware$massivedecks$MassiveDecks_Components_Errors$New,
						A2(_elm_lang$core$Basics_ops['++'], 'The response recieved from the server wasn\'t what we expected: ', _p0._0._0),
						true);
			}
	}
};
var _Lattyware$massivedecks$MassiveDecks_API_Request$handleErrors = F3(
	function (onSpecificError, onGeneralError, error) {
		var _p3 = error;
		if (_p3.ctor === 'Known') {
			return onSpecificError(_p3._0);
		} else {
			return onGeneralError(
				_Lattyware$massivedecks$MassiveDecks_API_Request$genericErrorHandler(error));
		}
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$Request = F5(
	function (a, b, c, d, e) {
		return {method: a, url: b, body: c, errors: d, resultDecoder: e};
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$request = F5(
	function (verb, url, body, errors, resultDecoder) {
		return A5(
			_Lattyware$massivedecks$MassiveDecks_API_Request$Request,
			verb,
			url,
			body,
			_elm_lang$core$Dict$fromList(errors),
			resultDecoder);
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$Unknown = function (a) {
	return {ctor: 'Unknown', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_API_Request$Known = function (a) {
	return {ctor: 'Known', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_API_Request$errorDecoder = F3(
	function (response, errorName, knownErrors) {
		var decoder = A2(
			_elm_lang$core$Dict$get,
			{ctor: '_Tuple2', _0: response.status.code, _1: errorName},
			knownErrors);
		var _p4 = decoder;
		if (_p4.ctor === 'Just') {
			return A2(_elm_lang$core$Json_Decode$map, _Lattyware$massivedecks$MassiveDecks_API_Request$Known, _p4._0);
		} else {
			return _elm_lang$core$Json_Decode$succeed(
				_Lattyware$massivedecks$MassiveDecks_API_Request$Unknown(response));
		}
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$General = function (a) {
	return {ctor: 'General', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_API_Request$Result = function (a) {
	return {ctor: 'Result', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_API_Request$Error = function (a) {
	return {ctor: 'Error', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_API_Request$resultOrErrorDecoder = F3(
	function (response, resultDecoder, knownErrors) {
		return A2(
			_elm_lang$core$Json_Decode$andThen,
			function (error) {
				var _p5 = error;
				if (_p5.ctor === 'Just') {
					return A2(
						_elm_lang$core$Json_Decode$map,
						_Lattyware$massivedecks$MassiveDecks_API_Request$Error,
						A3(_Lattyware$massivedecks$MassiveDecks_API_Request$errorDecoder, response, _p5._0, knownErrors));
				} else {
					return A2(_elm_lang$core$Json_Decode$map, _Lattyware$massivedecks$MassiveDecks_API_Request$Result, resultDecoder);
				}
			},
			_elm_lang$core$Json_Decode$maybe(_Lattyware$massivedecks$MassiveDecks_API_Request$errorKeyDecoder));
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$handleResponse = F3(
	function (resultDecoder, knownErrors, response) {
		return A2(
			_elm_lang$core$Json_Decode$decodeString,
			A3(_Lattyware$massivedecks$MassiveDecks_API_Request$resultOrErrorDecoder, response, resultDecoder, knownErrors),
			response.body);
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$send = F4(
	function (request, onSpecificError, onGeneralError, onSuccess) {
		var req = _elm_lang$http$Http$request(
			{
				method: request.method,
				headers: {ctor: '[]'},
				url: request.url,
				body: function () {
					var _p6 = request.body;
					if (_p6.ctor === 'Just') {
						return _elm_lang$http$Http$jsonBody(_p6._0);
					} else {
						return _elm_lang$http$Http$emptyBody;
					}
				}(),
				expect: _elm_lang$http$Http$expectStringResponse(
					A2(_Lattyware$massivedecks$MassiveDecks_API_Request$handleResponse, request.resultDecoder, request.errors)),
				timeout: _elm_lang$core$Maybe$Nothing,
				withCredentials: false
			});
		return A2(
			_elm_lang$http$Http$send,
			function (result) {
				var _p7 = result;
				if (_p7.ctor === 'Ok') {
					var _p8 = _p7._0;
					if (_p8.ctor === 'Error') {
						return A3(_Lattyware$massivedecks$MassiveDecks_API_Request$handleErrors, onSpecificError, onGeneralError, _p8._0);
					} else {
						return onSuccess(_p8._0);
					}
				} else {
					var _p12 = _p7._0;
					return A3(
						_Lattyware$massivedecks$MassiveDecks_API_Request$handleErrors,
						onSpecificError,
						onGeneralError,
						function () {
							var _p9 = _p12;
							if (_p9.ctor === 'BadStatus') {
								var _p11 = _p9._0;
								return A2(
									_elm_lang$core$Result$withDefault,
									_Lattyware$massivedecks$MassiveDecks_API_Request$General(_p12),
									A2(
										_elm_lang$core$Json_Decode$decodeString,
										A2(
											_elm_lang$core$Json_Decode$andThen,
											function (n) {
												var _p10 = n;
												if (_p10.ctor === 'Just') {
													return A3(_Lattyware$massivedecks$MassiveDecks_API_Request$errorDecoder, _p11, _p10._0, request.errors);
												} else {
													return _elm_lang$core$Json_Decode$succeed(
														_Lattyware$massivedecks$MassiveDecks_API_Request$General(_p12));
												}
											},
											_elm_lang$core$Json_Decode$maybe(_Lattyware$massivedecks$MassiveDecks_API_Request$errorKeyDecoder)),
										_p11.body));
							} else {
								return _Lattyware$massivedecks$MassiveDecks_API_Request$General(_p12);
							}
						}());
				}
			},
			req);
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$send_ = F3(
	function (request, onGeneralError, onSuccess) {
		return A4(_Lattyware$massivedecks$MassiveDecks_API_Request$send, request, _Lattyware$massivedecks$MassiveDecks_Util$impossible, onGeneralError, onSuccess);
	});

var _Lattyware$massivedecks$MassiveDecks_API$commandRequest = F6(
	function (name, args, errors, decoder, gameCode, secret) {
		return A5(
			_Lattyware$massivedecks$MassiveDecks_API_Request$request,
			'POST',
			A2(_elm_lang$core$Basics_ops['++'], '/api/lobbies/', gameCode),
			_elm_lang$core$Maybe$Just(
				A3(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodeCommand, name, secret, args)),
			errors,
			decoder);
	});
var _Lattyware$massivedecks$MassiveDecks_API$setPassword = F3(
	function (gameCode, secret, password) {
		return A6(
			_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
			'setPassword',
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'password',
					_1: _elm_lang$core$Json_Encode$string(password)
				},
				_1: {ctor: '[]'}
			},
			{ctor: '[]'},
			_elm_lang$core$Json_Decode$succeed(
				{ctor: '_Tuple0'}),
			gameCode,
			secret);
	});
var _Lattyware$massivedecks$MassiveDecks_API$disableRule = F3(
	function (rule, gameCode, secret) {
		return A6(
			_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
			'disableRule',
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'rule',
					_1: _elm_lang$core$Json_Encode$string(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$toString(rule))
				},
				_1: {ctor: '[]'}
			},
			{ctor: '[]'},
			_elm_lang$core$Json_Decode$succeed(
				{ctor: '_Tuple0'}),
			gameCode,
			secret);
	});
var _Lattyware$massivedecks$MassiveDecks_API$enableRule = F3(
	function (rule, gameCode, secret) {
		return A6(
			_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
			'enableRule',
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'rule',
					_1: _elm_lang$core$Json_Encode$string(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$toString(rule))
				},
				_1: {ctor: '[]'}
			},
			{ctor: '[]'},
			_elm_lang$core$Json_Decode$succeed(
				{ctor: '_Tuple0'}),
			gameCode,
			secret);
	});
var _Lattyware$massivedecks$MassiveDecks_API$leave = F2(
	function (gameCode, secret) {
		return A5(
			_Lattyware$massivedecks$MassiveDecks_API_Request$request,
			'POST',
			A2(
				_elm_lang$core$Basics_ops['++'],
				'/api/lobbies/',
				A2(
					_elm_lang$core$Basics_ops['++'],
					gameCode,
					A2(
						_elm_lang$core$Basics_ops['++'],
						'/players/',
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Basics$toString(secret.id),
							'/leave')))),
			_elm_lang$core$Maybe$Just(
				_Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerSecret(secret)),
			{ctor: '[]'},
			_elm_lang$core$Json_Decode$succeed(
				{ctor: '_Tuple0'}));
	});
var _Lattyware$massivedecks$MassiveDecks_API$back = A4(
	_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
	'back',
	{ctor: '[]'},
	{ctor: '[]'},
	_elm_lang$core$Json_Decode$succeed(
		{ctor: '_Tuple0'}));
var _Lattyware$massivedecks$MassiveDecks_API$newAi = F2(
	function (gameCode, secret) {
		return A5(
			_Lattyware$massivedecks$MassiveDecks_API_Request$request,
			'POST',
			A2(
				_elm_lang$core$Basics_ops['++'],
				'/api/lobbies/',
				A2(_elm_lang$core$Basics_ops['++'], gameCode, '/players/newAi')),
			_elm_lang$core$Maybe$Just(
				_Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerSecret(secret)),
			{ctor: '[]'},
			_elm_lang$core$Json_Decode$succeed(
				{ctor: '_Tuple0'}));
	});
var _Lattyware$massivedecks$MassiveDecks_API$getHistory = function (gameCode) {
	return A5(
		_Lattyware$massivedecks$MassiveDecks_API_Request$request,
		'GET',
		A2(
			_elm_lang$core$Basics_ops['++'],
			'/api/lobbies/',
			A2(_elm_lang$core$Basics_ops['++'], gameCode, '/history')),
		_elm_lang$core$Maybe$Nothing,
		{ctor: '[]'},
		_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$finishedRoundDecoder));
};
var _Lattyware$massivedecks$MassiveDecks_API$getHand = F2(
	function (gameCode, secret) {
		return A5(
			_Lattyware$massivedecks$MassiveDecks_API_Request$request,
			'POST',
			A2(
				_elm_lang$core$Basics_ops['++'],
				'/api/lobbies/',
				A2(
					_elm_lang$core$Basics_ops['++'],
					gameCode,
					A2(
						_elm_lang$core$Basics_ops['++'],
						'/players/',
						_elm_lang$core$Basics$toString(secret.id)))),
			_elm_lang$core$Maybe$Just(
				_Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerSecret(secret)),
			{ctor: '[]'},
			_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder);
	});
var _Lattyware$massivedecks$MassiveDecks_API$createLobby = function (name) {
	return A5(
		_Lattyware$massivedecks$MassiveDecks_API_Request$request,
		'POST',
		'/api/lobbies',
		_elm_lang$core$Maybe$Just(
			_Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodeName(name)),
		{ctor: '[]'},
		_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$gameCodeAndSecretDecoder);
};
var _Lattyware$massivedecks$MassiveDecks_API$NewPlayerLobbyNotFound = {ctor: 'NewPlayerLobbyNotFound'};
var _Lattyware$massivedecks$MassiveDecks_API$PasswordWrong = {ctor: 'PasswordWrong'};
var _Lattyware$massivedecks$MassiveDecks_API$NameInUse = {ctor: 'NameInUse'};
var _Lattyware$massivedecks$MassiveDecks_API$newPlayer = F3(
	function (gameCode, name, password) {
		return A5(
			_Lattyware$massivedecks$MassiveDecks_API_Request$request,
			'POST',
			A2(
				_elm_lang$core$Basics_ops['++'],
				'/api/lobbies/',
				A2(_elm_lang$core$Basics_ops['++'], gameCode, '/players')),
			_elm_lang$core$Maybe$Just(
				A2(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodeNameAndPassword, name, password)),
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'name-in-use'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$NameInUse)
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: {ctor: '_Tuple2', _0: 403, _1: 'password-wrong'},
						_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$PasswordWrong)
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple2',
							_0: {ctor: '_Tuple2', _0: 404, _1: 'lobby-not-found'},
							_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$NewPlayerLobbyNotFound)
						},
						_1: {ctor: '[]'}
					}
				}
			},
			_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerSecretDecoder);
	});
var _Lattyware$massivedecks$MassiveDecks_API$SecretWrongOrNotAPlayer = {ctor: 'SecretWrongOrNotAPlayer'};
var _Lattyware$massivedecks$MassiveDecks_API$LobbyNotFound = {ctor: 'LobbyNotFound'};
var _Lattyware$massivedecks$MassiveDecks_API$getLobbyAndHand = A4(
	_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
	'getLobbyAndHand',
	{ctor: '[]'},
	{
		ctor: '::',
		_0: {
			ctor: '_Tuple2',
			_0: {ctor: '_Tuple2', _0: 404, _1: 'lobby-not-found'},
			_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$LobbyNotFound)
		},
		_1: {
			ctor: '::',
			_0: {
				ctor: '_Tuple2',
				_0: {ctor: '_Tuple2', _0: 403, _1: 'secret-wrong-or-not-a-player'},
				_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$SecretWrongOrNotAPlayer)
			},
			_1: {ctor: '[]'}
		}
	},
	_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$lobbyAndHandDecoder);
var _Lattyware$massivedecks$MassiveDecks_API$DeckNotFound = {ctor: 'DeckNotFound'};
var _Lattyware$massivedecks$MassiveDecks_API$CardcastTimeout = {ctor: 'CardcastTimeout'};
var _Lattyware$massivedecks$MassiveDecks_API$addDeck = F3(
	function (gameCode, secret, playCode) {
		return A6(
			_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
			'addDeck',
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'playCode',
					_1: _elm_lang$core$Json_Encode$string(playCode)
				},
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 502, _1: 'cardcast-timeout'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$CardcastTimeout)
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: {ctor: '_Tuple2', _0: 400, _1: 'deck-not-found'},
						_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$DeckNotFound)
					},
					_1: {ctor: '[]'}
				}
			},
			_elm_lang$core$Json_Decode$succeed(
				{ctor: '_Tuple0'}),
			gameCode,
			secret);
	});
var _Lattyware$massivedecks$MassiveDecks_API$GameInProgress = {ctor: 'GameInProgress'};
var _Lattyware$massivedecks$MassiveDecks_API$NotEnoughPlayers = function (a) {
	return {ctor: 'NotEnoughPlayers', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_API$newGame = F2(
	function (gameCode, secret) {
		return A6(
			_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
			'newGame',
			{ctor: '[]'},
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'game-in-progress'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$GameInProgress)
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: {ctor: '_Tuple2', _0: 400, _1: 'not-enough-players'},
						_1: A2(
							_elm_lang$core$Json_Decode$map,
							_Lattyware$massivedecks$MassiveDecks_API$NotEnoughPlayers,
							A2(_elm_lang$core$Json_Decode$field, 'required', _elm_lang$core$Json_Decode$int))
					},
					_1: {ctor: '[]'}
				}
			},
			_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder,
			gameCode,
			secret);
	});
var _Lattyware$massivedecks$MassiveDecks_API$NotCzar = {ctor: 'NotCzar'};
var _Lattyware$massivedecks$MassiveDecks_API$choose = F3(
	function (gameCode, secret, winner) {
		return A6(
			_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
			'choose',
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'winner',
					_1: _elm_lang$core$Json_Encode$int(winner)
				},
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'not-czar'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$NotCzar)
				},
				_1: {ctor: '[]'}
			},
			_elm_lang$core$Json_Decode$succeed(
				{ctor: '_Tuple0'}),
			gameCode,
			secret);
	});
var _Lattyware$massivedecks$MassiveDecks_API$WrongNumberOfCards = F2(
	function (a, b) {
		return {ctor: 'WrongNumberOfCards', _0: a, _1: b};
	});
var _Lattyware$massivedecks$MassiveDecks_API$AlreadyJudging = {ctor: 'AlreadyJudging'};
var _Lattyware$massivedecks$MassiveDecks_API$AlreadyPlayed = {ctor: 'AlreadyPlayed'};
var _Lattyware$massivedecks$MassiveDecks_API$NotInRound = {ctor: 'NotInRound'};
var _Lattyware$massivedecks$MassiveDecks_API$play = F3(
	function (gameCode, secret, ids) {
		return A6(
			_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
			'play',
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'ids',
					_1: _elm_lang$core$Json_Encode$list(
						A2(_elm_lang$core$List$map, _elm_lang$core$Json_Encode$string, ids))
				},
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'not-in-round'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$NotInRound)
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: {ctor: '_Tuple2', _0: 400, _1: 'already-played'},
						_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$AlreadyPlayed)
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple2',
							_0: {ctor: '_Tuple2', _0: 400, _1: 'already-judging'},
							_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$AlreadyJudging)
						},
						_1: {
							ctor: '::',
							_0: {
								ctor: '_Tuple2',
								_0: {ctor: '_Tuple2', _0: 400, _1: 'wrong-number-of-cards-played'},
								_1: A3(
									_elm_lang$core$Json_Decode$map2,
									_Lattyware$massivedecks$MassiveDecks_API$WrongNumberOfCards,
									A2(_elm_lang$core$Json_Decode$field, 'got', _elm_lang$core$Json_Decode$int),
									A2(_elm_lang$core$Json_Decode$field, 'expected', _elm_lang$core$Json_Decode$int))
							},
							_1: {ctor: '[]'}
						}
					}
				}
			},
			_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder,
			gameCode,
			secret);
	});
var _Lattyware$massivedecks$MassiveDecks_API$PlayersNotSkippable = {ctor: 'PlayersNotSkippable'};
var _Lattyware$massivedecks$MassiveDecks_API$NotEnoughPlayersToSkip = function (a) {
	return {ctor: 'NotEnoughPlayersToSkip', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_API$skip = F3(
	function (gameCode, secret, players) {
		return A6(
			_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
			'skip',
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'players',
					_1: _elm_lang$core$Json_Encode$list(
						A2(_elm_lang$core$List$map, _elm_lang$core$Json_Encode$int, players))
				},
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'not-enough-players'},
					_1: A2(
						_elm_lang$core$Json_Decode$map,
						_Lattyware$massivedecks$MassiveDecks_API$NotEnoughPlayersToSkip,
						A2(_elm_lang$core$Json_Decode$field, 'required', _elm_lang$core$Json_Decode$int))
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: {ctor: '_Tuple2', _0: 400, _1: 'players-must-be-skippable'},
						_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$PlayersNotSkippable)
					},
					_1: {ctor: '[]'}
				}
			},
			_elm_lang$core$Json_Decode$succeed(
				{ctor: '_Tuple0'}),
			gameCode,
			secret);
	});
var _Lattyware$massivedecks$MassiveDecks_API$NotEnoughPoints = {ctor: 'NotEnoughPoints'};
var _Lattyware$massivedecks$MassiveDecks_API$redraw = A4(
	_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
	'redraw',
	{ctor: '[]'},
	{
		ctor: '::',
		_0: {
			ctor: '_Tuple2',
			_0: {ctor: '_Tuple2', _0: 400, _1: 'not-enough-points'},
			_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$NotEnoughPoints)
		},
		_1: {ctor: '[]'}
	},
	_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder);

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$response = F3(
	function (picked, attributes, response) {
		var classes = {
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$classList(
				{
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'card', _1: true},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 'response', _1: true},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'mui-panel', _1: true},
							_1: {
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: 'picked', _1: picked},
								_1: {ctor: '[]'}
							}
						}
					}
				}),
			_1: {ctor: '[]'}
		};
		return A2(
			_elm_lang$html$Html$div,
			_elm_lang$core$List$concat(
				{
					ctor: '::',
					_0: classes,
					_1: {
						ctor: '::',
						_0: attributes,
						_1: {ctor: '[]'}
					}
				}),
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('response-text'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(
							_Lattyware$massivedecks$MassiveDecks_Util$firstLetterToUpper(response.text)),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text('.'),
							_1: {ctor: '[]'}
						}
					}),
				_1: {ctor: '[]'}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$slot = function (value) {
	return A2(
		_elm_lang$html$Html$span,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('slot'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text(value),
			_1: {ctor: '[]'}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$slots = F3(
	function (count, placeholder, picked) {
		var extra = count - _elm_lang$core$List$length(picked);
		return A2(
			_elm_lang$core$List$map,
			_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$slot,
			_elm_lang$core$List$concat(
				{
					ctor: '::',
					_0: picked,
					_1: {
						ctor: '::',
						_0: A2(_elm_lang$core$List$repeat, extra, placeholder),
						_1: {ctor: '[]'}
					}
				}));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$callText = F2(
	function (call, picked) {
		var extra = _Lattyware$massivedecks$MassiveDecks_Models_Card$slots(call) - _elm_lang$core$List$length(picked);
		var pickedText = A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.text;
			},
			picked);
		var withSlots = A2(
			_Lattyware$massivedecks$MassiveDecks_Util$interleave,
			_elm_lang$core$List$concat(
				{
					ctor: '::',
					_0: pickedText,
					_1: {
						ctor: '::',
						_0: A2(_elm_lang$core$List$repeat, extra, 'blank'),
						_1: {ctor: '[]'}
					}
				}),
			call.parts);
		var responseFirst = A2(
			_elm_lang$core$Maybe$withDefault,
			false,
			A2(
				_elm_lang$core$Maybe$map,
				F2(
					function (x, y) {
						return _elm_lang$core$Native_Utils.eq(x, y);
					})(''),
				_elm_lang$core$List$head(call.parts)));
		var _p0 = responseFirst ? {
			ctor: '_Tuple2',
			_0: call.parts,
			_1: A2(_Lattyware$massivedecks$MassiveDecks_Util$mapFirst, _Lattyware$massivedecks$MassiveDecks_Util$firstLetterToUpper, pickedText)
		} : {
			ctor: '_Tuple2',
			_0: A2(_Lattyware$massivedecks$MassiveDecks_Util$mapFirst, _Lattyware$massivedecks$MassiveDecks_Util$firstLetterToUpper, call.parts),
			_1: pickedText
		};
		var parts = _p0._0;
		var responses = _p0._1;
		return A2(_elm_lang$core$String$join, ' ', withSlots);
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$call = F2(
	function (call, picked) {
		var spanned = A2(
			_elm_lang$core$List$map,
			function (part) {
				return A2(
					_elm_lang$html$Html$span,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(part),
						_1: {ctor: '[]'}
					});
			},
			call.parts);
		var pickedText = A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.text;
			},
			picked);
		var responseFirst = A2(
			_elm_lang$core$Maybe$withDefault,
			false,
			A2(
				_elm_lang$core$Maybe$map,
				F2(
					function (x, y) {
						return _elm_lang$core$Native_Utils.eq(x, y);
					})(''),
				_elm_lang$core$List$head(call.parts)));
		var _p1 = responseFirst ? {
			ctor: '_Tuple2',
			_0: call.parts,
			_1: A2(_Lattyware$massivedecks$MassiveDecks_Util$mapFirst, _Lattyware$massivedecks$MassiveDecks_Util$firstLetterToUpper, pickedText)
		} : {
			ctor: '_Tuple2',
			_0: A2(_Lattyware$massivedecks$MassiveDecks_Util$mapFirst, _Lattyware$massivedecks$MassiveDecks_Util$firstLetterToUpper, call.parts),
			_1: pickedText
		};
		var parts = _p1._0;
		var responses = _p1._1;
		var withSlots = A2(
			_Lattyware$massivedecks$MassiveDecks_Util$interleave,
			A3(
				_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$slots,
				_Lattyware$massivedecks$MassiveDecks_Models_Card$slots(call),
				'',
				responses),
			spanned);
		var callContents = responseFirst ? A2(
			_elm_lang$core$Maybe$withDefault,
			withSlots,
			_elm_lang$core$List$tail(withSlots)) : withSlots;
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('card call mui-panel'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('call-text'),
						_1: {ctor: '[]'}
					},
					callContents),
				_1: {ctor: '[]'}
			});
	});

var _Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$closeButton = A2(
	_elm_lang$html$Html$button,
	{
		ctor: '::',
		_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--fab'),
		_1: {
			ctor: '::',
			_0: _elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_History_Messages$Close),
			_1: {ctor: '[]'}
		}
	},
	{
		ctor: '::',
		_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('times'),
		_1: {ctor: '[]'}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$responses = F4(
	function (players, winnerId, playerId, responses) {
		var winner = _elm_lang$core$Native_Utils.eq(playerId, winnerId);
		var winnerPrefix = winner ? {
			ctor: '::',
			_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('trophy'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html$text(' '),
				_1: {ctor: '[]'}
			}
		} : {ctor: '[]'};
		var player = A2(
			_elm_lang$core$Maybe$withDefault,
			{ctor: '[]'},
			A2(
				_elm_lang$core$Maybe$map,
				function (player) {
					return A2(
						_elm_lang$core$Basics_ops['++'],
						winnerPrefix,
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text(player.name),
							_1: {ctor: '[]'}
						});
				},
				A2(_Lattyware$massivedecks$MassiveDecks_Models_Player$byId, playerId, players)));
		return A2(
			_elm_lang$html$Html$li,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('responses'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$div,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$classList(
									{
										ctor: '::',
										_0: {ctor: '_Tuple2', _0: 'who', _1: true},
										_1: {
											ctor: '::',
											_0: {ctor: '_Tuple2', _0: 'won', _1: winner},
											_1: {ctor: '[]'}
										}
									}),
								_1: {ctor: '[]'}
							},
							player),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html_Keyed$ul,
								{ctor: '[]'},
								A2(
									_elm_lang$core$List$map,
									function (r) {
										return {
											ctor: '_Tuple2',
											_0: r.id,
											_1: A2(
												_elm_lang$html$Html$li,
												{ctor: '[]'},
												{
													ctor: '::',
													_0: A3(
														_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$response,
														false,
														{ctor: '[]'},
														r),
													_1: {ctor: '[]'}
												})
										};
									},
									responses)),
							_1: {ctor: '[]'}
						}
					}),
				_1: {ctor: '[]'}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$finishedRound = F2(
	function (players, round) {
		var czar = A2(
			_elm_lang$core$Maybe$withDefault,
			{ctor: '[]'},
			A2(
				_elm_lang$core$Maybe$map,
				function (player) {
					return {
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('gavel'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text(' '),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text(player.name),
								_1: {ctor: '[]'}
							}
						}
					};
				},
				A2(_Lattyware$massivedecks$MassiveDecks_Models_Player$byId, round.czar, players)));
		var state = round.state;
		var playedBy = state.playedByAndWinner.playedBy;
		var winner = state.playedByAndWinner.winner;
		var playedCardsByPlayer = _elm_lang$core$Dict$toList(
			A2(_Lattyware$massivedecks$MassiveDecks_Models_Card$playedCardsByPlayer, playedBy, state.responses));
		return A2(
			_elm_lang$html$Html$li,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('round'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$div,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('who'),
								_1: {ctor: '[]'}
							},
							czar),
						_1: {
							ctor: '::',
							_0: A2(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$call,
								round.call,
								{ctor: '[]'}),
							_1: {ctor: '[]'}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html_Keyed$ul,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('plays'),
							_1: {ctor: '[]'}
						},
						A2(
							_elm_lang$core$List$map,
							function (_p0) {
								var _p1 = _p0;
								var _p2 = _p1._0;
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Basics$toString(_p2),
									_1: A4(_Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$responses, players, winner, _p2, _p1._1)
								};
							},
							playedCardsByPlayer)),
					_1: {ctor: '[]'}
				}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$view = F2(
	function (model, players) {
		var content = function () {
			var _p3 = model.rounds;
			if (_p3.ctor === 'Just') {
				return A2(
					_elm_lang$html$Html_Keyed$ul,
					{ctor: '[]'},
					A2(
						_elm_lang$core$List$map,
						function (round) {
							return {
								ctor: '_Tuple2',
								_0: round.call.id,
								_1: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$finishedRound, players, round)
							};
						},
						_p3._0));
			} else {
				return _Lattyware$massivedecks$MassiveDecks_Components_Icon$spinner;
			}
		}();
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$id('history'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$h1,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('mui--divider-bottom'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('Previous Rounds'),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$closeButton,
					_1: {
						ctor: '::',
						_0: content,
						_1: {ctor: '[]'}
					}
				}
			});
	});

var _Lattyware$massivedecks$MassiveDecks_Scenes_History$update = F2(
	function (message, model) {
		var _p0 = message;
		return {
			ctor: '_Tuple2',
			_0: _elm_lang$core$Native_Utils.update(
				model,
				{
					rounds: _elm_lang$core$Maybe$Just(_p0._0)
				}),
			_1: _elm_lang$core$Platform_Cmd$none
		};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_History$view = _Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$view;
var _Lattyware$massivedecks$MassiveDecks_Scenes_History$subscriptions = function (model) {
	return _elm_lang$core$Platform_Sub$none;
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_History$init = function (gameCode) {
	return {
		ctor: '_Tuple2',
		_0: {rounds: _elm_lang$core$Maybe$Nothing},
		_1: A3(
			_Lattyware$massivedecks$MassiveDecks_API_Request$send_,
			_Lattyware$massivedecks$MassiveDecks_API$getHistory(gameCode),
			_Lattyware$massivedecks$MassiveDecks_Scenes_History_Messages$ErrorMessage,
			function (_p1) {
				return _Lattyware$massivedecks$MassiveDecks_Scenes_History_Messages$LocalMessage(
					_Lattyware$massivedecks$MassiveDecks_Scenes_History_Messages$Load(_p1));
			})
	};
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule$HouseRule = F5(
	function (a, b, c, d, e) {
		return {id: a, icon: b, name: c, description: d, actions: e};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule$Action = F5(
	function (a, b, c, d, e) {
		return {icon: a, text: b, description: c, onClick: d, enabled: e};
	});

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Reboot$checkEnabled = function (lobbyModel) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		false,
		A2(
			_elm_lang$core$Maybe$map,
			function (player) {
				return _elm_lang$core$Native_Utils.cmp(player.score, 0) > 0;
			},
			A2(_Lattyware$massivedecks$MassiveDecks_Models_Player$byId, lobbyModel.secret.id, lobbyModel.lobby.players)));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Reboot$rebootAction = {icon: 'recycle', text: 'Redraw', description: 'Lose one point to discard your hand and draw a new one.', onClick: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Redraw, enabled: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Reboot$checkEnabled};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Reboot$rule = {
	id: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$Reboot,
	icon: 'recycle',
	name: 'Rebooting the Universe',
	description: 'At any time, players may trade in a point to discard their hand and redraw.',
	actions: {
		ctor: '::',
		_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Reboot$rebootAction,
		_1: {ctor: '[]'}
	}
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Available$houseRules = {
	ctor: '::',
	_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Reboot$rule,
	_1: {ctor: '[]'}
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$renderDisconnectedNotice = F3(
	function (ids, has, disconnectedNames) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('notice'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$h3,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('minus-circle'),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$span,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text(disconnectedNames),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text(' '),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html$text(has),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html$text(' disconnected from the game.'),
										_1: {ctor: '[]'}
									}
								}
							}
						}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$div,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('actions'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$button,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small'),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html_Events$onClick(
												_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Skip(ids)),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$title('They will be removed from this round, and won\'t be in future rounds until they reconnect.'),
												_1: {ctor: '[]'}
											}
										}
									},
									{
										ctor: '::',
										_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('fast-forward'),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html$text(' Skip'),
											_1: {ctor: '[]'}
										}
									}),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}
				}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$disconnectedNotice = function (players) {
	var disconnected = A2(
		_elm_lang$core$List$filter,
		function (player) {
			return player.disconnected && (!_elm_lang$core$Native_Utils.eq(player.status, _Lattyware$massivedecks$MassiveDecks_Models_Player$Skipping));
		},
		players);
	var disconnectedNames = _Lattyware$massivedecks$MassiveDecks_Util$joinWithAnd(
		A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.name;
			},
			disconnected));
	var disconnectedIds = A2(
		_elm_lang$core$List$map,
		function (_) {
			return _.id;
		},
		disconnected);
	return A2(
		_elm_lang$core$Maybe$withDefault,
		{ctor: '[]'},
		A2(
			_elm_lang$core$Maybe$map,
			function (item) {
				return {
					ctor: '::',
					_0: item,
					_1: {ctor: '[]'}
				};
			},
			A2(
				_elm_lang$core$Maybe$map,
				A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$renderDisconnectedNotice,
					disconnectedIds,
					_Lattyware$massivedecks$MassiveDecks_Util$pluralHas(disconnected)),
				disconnectedNames)));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$renderTimeoutNotice = F5(
	function (includesPlayer, description, ids, has, names) {
		return includesPlayer ? A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('notice'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$h3,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('exclamation-circle'),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$span,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('The time has run out for you to have '),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text(description),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html$text(' and you can now be skipped.'),
									_1: {ctor: '[]'}
								}
							}
						}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$div,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('actions'),
								_1: {ctor: '[]'}
							},
							{ctor: '[]'}),
						_1: {ctor: '[]'}
					}
				}
			}) : A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('notice'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$h3,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('minus-circle'),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$span,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text(names),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text(' '),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html$text(has),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html$text(' not '),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html$text(description),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html$text(' before the round timer ran out.'),
												_1: {ctor: '[]'}
											}
										}
									}
								}
							}
						}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$div,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('actions'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$button,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small'),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html_Events$onClick(
												_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Skip(ids)),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$title('They will be removed from this round, and won\'t be in future rounds until they come back.'),
												_1: {ctor: '[]'}
											}
										}
									},
									{
										ctor: '::',
										_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('fast-forward'),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html$text(' Skip'),
											_1: {ctor: '[]'}
										}
									}),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}
				}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$timeoutNotice = F4(
	function (playerId, players, judging, timeout) {
		var requiredStatus = judging ? _Lattyware$massivedecks$MassiveDecks_Models_Player$Czar : _Lattyware$massivedecks$MassiveDecks_Models_Player$NotPlayed;
		var timedOutPlayers = A2(
			_elm_lang$core$List$filter,
			function (player) {
				return _elm_lang$core$Native_Utils.eq(player.status, requiredStatus);
			},
			players);
		var timedOutNames = _Lattyware$massivedecks$MassiveDecks_Util$joinWithAnd(
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.name;
				},
				timedOutPlayers));
		var timedOutIds = A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.id;
			},
			timedOutPlayers);
		var includesPlayer = A2(_elm_lang$core$List$member, playerId, timedOutIds);
		var description = judging ? 'picked a winnner for the round' : 'played into the round';
		return timeout ? A2(
			_elm_lang$core$Maybe$withDefault,
			{ctor: '[]'},
			A2(
				_elm_lang$core$Maybe$map,
				function (item) {
					return {
						ctor: '::',
						_0: item,
						_1: {ctor: '[]'}
					};
				},
				A2(
					_elm_lang$core$Maybe$map,
					A4(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$renderTimeoutNotice,
						includesPlayer,
						description,
						timedOutIds,
						_Lattyware$massivedecks$MassiveDecks_Util$pluralHas(timedOutPlayers)),
					timedOutNames))) : {ctor: '[]'};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$renderSkippingNotice = {
	ctor: '::',
	_0: A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('notice'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$h3,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('fast-forward'),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$span,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('You are currently being skipped because you took too long to play.'),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('actions'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$button,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small'),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Back),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$title('Rejoin the game.'),
											_1: {ctor: '[]'}
										}
									}
								},
								{
									ctor: '::',
									_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('sign-in'),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html$text(' Rejoin'),
										_1: {ctor: '[]'}
									}
								}),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			}
		}),
	_1: {ctor: '[]'}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$skippingNotice = F2(
	function (players, id) {
		var renderSkippingNoticeIfSkipping = function (status) {
			var _p0 = status;
			if (_p0.ctor === 'Skipping') {
				return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$renderSkippingNotice;
			} else {
				return {ctor: '[]'};
			}
		};
		var status = A2(
			_elm_lang$core$Maybe$map,
			function (_) {
				return _.status;
			},
			A2(
				_Lattyware$massivedecks$MassiveDecks_Util$find,
				function (player) {
					return _elm_lang$core$Native_Utils.eq(player.id, id);
				},
				players));
		return A2(
			_elm_lang$core$Maybe$withDefault,
			{ctor: '[]'},
			A2(_elm_lang$core$Maybe$map, renderSkippingNoticeIfSkipping, status));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$warningDrawer = function (contents) {
	var hidden = _elm_lang$core$List$isEmpty(contents);
	var classes = {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 'hidden', _1: hidden},
		_1: {ctor: '[]'}
	};
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$id('warning-drawer'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$classList(classes),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$button,
				{
					ctor: '::',
					_0: A2(_elm_lang$html$Html_Attributes$attribute, 'onClick', 'toggleWarningDrawer()'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('toggle mui-btn mui-btn--small mui-btn--fab'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$title('Warning notices.'),
							_1: {ctor: '[]'}
						}
					}
				},
				{
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('exclamation-triangle'),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('top'),
						_1: {ctor: '[]'}
					},
					{ctor: '[]'}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('contents'),
							_1: {ctor: '[]'}
						},
						contents),
					_1: {ctor: '[]'}
				}
			}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$stateInfo = function (state) {
	var _p1 = state;
	if (_p1.ctor === 'Playing') {
		var _p2 = _p1._0.state;
		if (_p2.ctor === 'J') {
			return _elm_lang$core$Maybe$Just('The card czar is now picking a winner.');
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$statusInfo = F2(
	function (players, id) {
		var _p3 = A2(
			_elm_lang$core$Maybe$map,
			function (_) {
				return _.status;
			},
			A2(
				_Lattyware$massivedecks$MassiveDecks_Util$find,
				function (player) {
					return _elm_lang$core$Native_Utils.eq(player.id, id);
				},
				players));
		if (_p3.ctor === 'Just') {
			var _p4 = _p3._0;
			switch (_p4.ctor) {
				case 'Skipping':
					return _elm_lang$core$Maybe$Nothing;
				case 'Neutral':
					return _elm_lang$core$Maybe$Just('You joined while this round was already in play, you will be able to play next round.');
				case 'Czar':
					return _elm_lang$core$Maybe$Just('As card czar for this round - you don\'t play into the round, you pick the winner.');
				default:
					return _elm_lang$core$Maybe$Nothing;
			}
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$infoBar = F2(
	function (lobby, secret) {
		var content = A2(
			_Lattyware$massivedecks$MassiveDecks_Util$or,
			_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$stateInfo(lobby.game),
			A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$statusInfo, lobby.players, secret.id));
		var _p5 = content;
		if (_p5.ctor === 'Just') {
			return {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$id('info-bar'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('mui--z1'),
							_1: {ctor: '[]'}
						}
					},
					{
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('info-circle'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text(' '),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text(_p5._0),
								_1: {ctor: '[]'}
							}
						}
					}),
				_1: {ctor: '[]'}
			};
		} else {
			return {ctor: '[]'};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$chooseButton = function (playedId) {
	return A2(
		_elm_lang$html$Html$button,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('choose-button mui-btn mui-btn--small mui-btn--accent mui-btn--fab'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Events$onClick(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Choose(playedId)),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('trophy'),
			_1: {ctor: '[]'}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedResponse = function (response) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('card response mui-panel'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('response-text'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text(
						_Lattyware$massivedecks$MassiveDecks_Util$firstLetterToUpper(response.text)),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html$text('.'),
						_1: {ctor: '[]'}
					}
				}),
			_1: {ctor: '[]'}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedCards = F3(
	function (isCzar, playedId, cards) {
		return A2(
			_elm_lang$html$Html$ol,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Events$onClick(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Consider(playedId)),
				_1: {ctor: '[]'}
			},
			A2(
				_elm_lang$core$List$map,
				function (card) {
					return A2(
						_elm_lang$html$Html$li,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedResponse(card),
							_1: {ctor: '[]'}
						});
				},
				cards));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedView = F2(
	function (isCzar, responses) {
		return A2(
			_elm_lang$html$Html$ol,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('played mui--divider-top'),
				_1: {ctor: '[]'}
			},
			A2(
				_elm_lang$core$List$indexedMap,
				F2(
					function (index, pc) {
						return A2(
							_elm_lang$html$Html$li,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedCards, isCzar, index, pc),
								_1: {ctor: '[]'}
							});
					}),
				responses));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playButton = A2(
	_elm_lang$html$Html$button,
	{
		ctor: '::',
		_0: _elm_lang$html$Html_Attributes$class('play-button mui-btn mui-btn--small mui-btn--accent mui-btn--fab'),
		_1: {
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$title('Play these responses.'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Play),
				_1: {ctor: '[]'}
			}
		}
	},
	{
		ctor: '::',
		_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('check'),
		_1: {ctor: '[]'}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$withdrawButton = function (id) {
	return A2(
		_elm_lang$html$Html$button,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('withdraw-button mui-btn mui-btn--small mui-btn--danger mui-btn--fab'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$title('Take back this response.'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Events$onClick(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Withdraw(id)),
					_1: {ctor: '[]'}
				}
			}
		},
		{
			ctor: '::',
			_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('times'),
			_1: {ctor: '[]'}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$pickedResponse = function (response) {
	var item = A2(
		_elm_lang$html$Html$li,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('card response mui-panel'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('response-text'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text(
								_Lattyware$massivedecks$MassiveDecks_Util$firstLetterToUpper(response.text)),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text('.'),
								_1: {ctor: '[]'}
							}
						}),
					_1: {
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$withdrawButton(response.id),
						_1: {ctor: '[]'}
					}
				}),
			_1: {ctor: '[]'}
		});
	return {ctor: '_Tuple2', _0: response.id, _1: item};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$handRender = F2(
	function (disabled, contents) {
		var classes = A2(
			_elm_lang$core$Basics_ops['++'],
			'hand mui--divider-top',
			disabled ? ' disabled' : '');
		return A2(
			_elm_lang$html$Html_Keyed$ul,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class(classes),
				_1: {ctor: '[]'}
			},
			A2(
				_elm_lang$core$List$map,
				function (_p6) {
					var _p7 = _p6;
					return {
						ctor: '_Tuple2',
						_0: _p7._0,
						_1: A2(
							_elm_lang$html$Html$li,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: _p7._1,
								_1: {ctor: '[]'}
							})
					};
				},
				contents));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$positioning = function (shownCard) {
	var horizontalDirection = shownCard.isLeft ? 'left' : 'right';
	return _elm_lang$html$Html_Attributes$style(
		{
			ctor: '::',
			_0: {
				ctor: '_Tuple2',
				_0: 'transform',
				_1: A2(
					_elm_lang$core$Basics_ops['++'],
					'rotate(',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(shownCard.rotation),
						'deg)'))
			},
			_1: {
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: horizontalDirection,
					_1: A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(shownCard.horizontalPos),
						'%')
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'top',
						_1: A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Basics$toString(shownCard.verticalPos),
							'%')
					},
					_1: {ctor: '[]'}
				}
			}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$blankResponse = function (shownCard) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('card mui-panel'),
			_1: {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$positioning(shownCard),
				_1: {ctor: '[]'}
			}
		},
		{ctor: '[]'});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$pickedView = F3(
	function (picked, slots, shownPlayed) {
		var numberPicked = _elm_lang$core$List$length(picked);
		var pb = (_elm_lang$core$Native_Utils.cmp(numberPicked, slots) < 0) ? {ctor: '[]'} : {
			ctor: '::',
			_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playButton,
			_1: {ctor: '[]'}
		};
		return {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('picked'),
					_1: {ctor: '[]'}
				},
				A2(
					_elm_lang$core$Basics_ops['++'],
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html_Keyed$ol,
							{ctor: '[]'},
							A2(_elm_lang$core$List$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$pickedResponse, picked)),
						_1: {ctor: '[]'}
					},
					pb)),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('others-picked'),
						_1: {ctor: '[]'}
					},
					A2(_elm_lang$core$List$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$blankResponse, shownPlayed)),
				_1: {ctor: '[]'}
			}
		};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$response = F3(
	function (picked, disabled, response) {
		var isPicked = A2(_elm_lang$core$List$member, response.id, picked);
		var clickHandler = (isPicked || disabled) ? {ctor: '[]'} : {
			ctor: '::',
			_0: _elm_lang$html$Html_Events$onClick(
				_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Pick(response.id)),
			_1: {ctor: '[]'}
		};
		return {
			ctor: '_Tuple2',
			_0: response.id,
			_1: A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$response, isPicked, clickHandler, response)
		};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$handView = F3(
	function (picked, disabled, responses) {
		return A2(
			_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$handRender,
			disabled,
			A2(
				_elm_lang$core$List$map,
				A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$response, picked, disabled),
				responses));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playArea = function (contents) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('play-area'),
			_1: {ctor: '[]'}
		},
		contents);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$czarName = F2(
	function (players, czarId) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			'',
			A2(
				_elm_lang$core$Maybe$map,
				function (_) {
					return _.name;
				},
				_elm_lang$core$List$head(
					A2(
						_elm_lang$core$List$filter,
						function (player) {
							return _elm_lang$core$Native_Utils.eq(player.id, czarId);
						},
						players))));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$winnerHeaderAndContents = F2(
	function (round, players) {
		var winner = A2(
			_elm_lang$core$Maybe$withDefault,
			'',
			A2(
				_elm_lang$core$Maybe$map,
				function (_) {
					return _.name;
				},
				A2(_Lattyware$massivedecks$MassiveDecks_Util$get, players, round.state.playedByAndWinner.winner)));
		var cards = round.state.responses;
		var winning = A2(
			_elm_lang$core$Maybe$withDefault,
			{ctor: '[]'},
			A2(_Lattyware$massivedecks$MassiveDecks_Models_Card$winningCards, cards, round.state.playedByAndWinner));
		return {
			ctor: '_Tuple2',
			_0: {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('trophy'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html$text(
						A2(_elm_lang$core$Basics_ops['++'], ' ', winner)),
					_1: {ctor: '[]'}
				}
			},
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('winner mui-panel'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$h1,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('trophy'),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$h2,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text(
										A2(
											_elm_lang$core$Basics_ops['++'],
											' ',
											A2(_Lattyware$massivedecks$MassiveDecks_Models_Card$filled, round.call, winning))),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$h3,
									{ctor: '[]'},
									{
										ctor: '::',
										_0: _elm_lang$html$Html$text(
											A2(_elm_lang$core$Basics_ops['++'], '- ', winner)),
										_1: {ctor: '[]'}
									}),
								_1: {ctor: '[]'}
							}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$button,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$id('next-round-button'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--primary mui-btn--raised'),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$NextRound),
									_1: {ctor: '[]'}
								}
							}
						},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('Next Round'),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			}
		};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$consideringView = F3(
	function (considering, consideringCards, isCzar) {
		var extra = isCzar ? {
			ctor: '::',
			_0: {
				ctor: '_Tuple2',
				_0: '!!button',
				_1: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$chooseButton(considering)
			},
			_1: {ctor: '[]'}
		} : {ctor: '[]'};
		return A2(
			_elm_lang$html$Html$div,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html_Keyed$ol,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('considering'),
						_1: {ctor: '[]'}
					},
					A2(
						_elm_lang$core$Basics_ops['++'],
						A2(
							_elm_lang$core$List$map,
							function (card) {
								return {
									ctor: '_Tuple2',
									_0: card.id,
									_1: A2(
										_elm_lang$html$Html$li,
										{ctor: '[]'},
										{
											ctor: '::',
											_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedResponse(card),
											_1: {ctor: '[]'}
										})
								};
							},
							consideringCards),
						extra)),
				_1: {ctor: '[]'}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$getById = F2(
	function (cards, id) {
		return _elm_lang$core$List$head(
			A2(
				_elm_lang$core$List$filter,
				function (card) {
					return _elm_lang$core$Native_Utils.eq(card.id, id);
				},
				cards));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$getAllById = F2(
	function (ids, cards) {
		return A2(
			_elm_lang$core$List$filterMap,
			_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$getById(cards),
			ids);
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$gameMenuItem = F3(
	function (lobbyModel, rule, action) {
		var enabled = action.enabled(lobbyModel);
		var message = enabled ? action.onClick : _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$NoOp;
		return A2(
			_elm_lang$html$Html$li,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$a,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$classList(
							{
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: 'link', _1: true},
								_1: {
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: 'disabled', _1: !enabled},
									_1: {ctor: '[]'}
								}
							}),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$title(action.description),
							_1: {
								ctor: '::',
								_0: A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
								_1: {
									ctor: '::',
									_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html_Events$onClick(message),
										_1: {ctor: '[]'}
									}
								}
							}
						}
					},
					{
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon(action.icon),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text(' '),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text(action.text),
								_1: {ctor: '[]'}
							}
						}
					}),
				_1: {ctor: '[]'}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$gameMenuItems = F2(
	function (lobbyModel, rule) {
		return A2(
			_elm_lang$core$List$map,
			A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$gameMenuItem, lobbyModel, rule),
			rule.actions);
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$gameMenu = function (lobbyModel) {
	var enabled = A2(
		_elm_lang$core$List$filter,
		function (rule) {
			return A2(_elm_lang$core$List$member, rule.id, lobbyModel.lobby.config.houseRules);
		},
		_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Available$houseRules);
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('action-menu mui-dropdown'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$button,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--fab'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$title('Game actions.'),
						_1: {
							ctor: '::',
							_0: A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-toggle', 'dropdown'),
							_1: {ctor: '[]'}
						}
					}
				},
				{
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('bars'),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$ul,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('mui-dropdown__menu mui-dropdown__menu--right'),
						_1: {ctor: '[]'}
					},
					A2(
						_elm_lang$core$Basics_ops['++'],
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$li,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$a,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$classList(
												{
													ctor: '::',
													_0: {ctor: '_Tuple2', _0: 'link', _1: true},
													_1: {ctor: '[]'}
												}),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$title('View previous rounds from the game.'),
												_1: {
													ctor: '::',
													_0: A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
													_1: {
														ctor: '::',
														_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ViewHistory),
															_1: {ctor: '[]'}
														}
													}
												}
											}
										},
										{
											ctor: '::',
											_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('history'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html$text(' '),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html$text('Game History'),
													_1: {ctor: '[]'}
												}
											}
										}),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						},
						A2(
							_elm_lang$core$List$concatMap,
							_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$gameMenuItems(lobbyModel),
							enabled))),
				_1: {ctor: '[]'}
			}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$roundContents = F2(
	function (lobbyModel, round) {
		var id = lobbyModel.secret.id;
		var isCzar = _elm_lang$core$Native_Utils.eq(round.czar, id);
		var model = lobbyModel.playing;
		var hand = lobbyModel.hand.hand;
		var picked = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$getAllById, model.picked, hand);
		var callFill = function () {
			var _p8 = round.state;
			switch (_p8.ctor) {
				case 'P':
					return picked;
				case 'J':
					return A2(
						_elm_lang$core$Maybe$withDefault,
						{ctor: '[]'},
						A2(
							_elm_lang$core$Maybe$andThen,
							_Lattyware$massivedecks$MassiveDecks_Util$get(_p8._0.responses),
							model.considering));
				default:
					return {ctor: '[]'};
			}
		}();
		var pickedOrChosen = function () {
			var _p9 = round.state;
			switch (_p9.ctor) {
				case 'P':
					return A3(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$pickedView,
						picked,
						_Lattyware$massivedecks$MassiveDecks_Models_Card$slots(round.call),
						A2(_elm_lang$core$Basics_ops['++'], model.shownPlayed.animated, model.shownPlayed.toAnimate));
				case 'J':
					var _p10 = model.considering;
					if (_p10.ctor === 'Just') {
						var _p12 = _p10._0;
						var _p11 = A2(_Lattyware$massivedecks$MassiveDecks_Util$get, _p9._0.responses, _p12);
						if (_p11.ctor === 'Just') {
							return {
								ctor: '::',
								_0: A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$consideringView, _p12, _p11._0, isCzar),
								_1: {ctor: '[]'}
							};
						} else {
							return {ctor: '[]'};
						}
					} else {
						return {ctor: '[]'};
					}
				default:
					return {ctor: '[]'};
			}
		}();
		var lobby = lobbyModel.lobby;
		var canPlay = A2(
			_elm_lang$core$List$all,
			function (player) {
				return _elm_lang$core$Native_Utils.eq(player.status, _Lattyware$massivedecks$MassiveDecks_Models_Player$NotPlayed);
			},
			A2(
				_elm_lang$core$List$filter,
				function (player) {
					return _elm_lang$core$Native_Utils.eq(player.id, id);
				},
				lobby.players));
		var playedOrHand = function () {
			var _p13 = round.state;
			switch (_p13.ctor) {
				case 'P':
					return A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$handView, model.picked, !canPlay, hand);
				case 'J':
					return A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedView, isCzar, _p13._0.responses);
				default:
					return A2(
						_elm_lang$html$Html$div,
						{ctor: '[]'},
						{ctor: '[]'});
			}
		}();
		return {
			ctor: '::',
			_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playArea(
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('round-area'),
							_1: {ctor: '[]'}
						},
						_elm_lang$core$List$concat(
							{
								ctor: '::',
								_0: {
									ctor: '::',
									_0: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$call, round.call, callFill),
									_1: {ctor: '[]'}
								},
								_1: {
									ctor: '::',
									_0: pickedOrChosen,
									_1: {ctor: '[]'}
								}
							})),
					_1: {
						ctor: '::',
						_0: playedOrHand,
						_1: {
							ctor: '::',
							_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$gameMenu(lobbyModel),
							_1: {ctor: '[]'}
						}
					}
				}),
			_1: {ctor: '[]'}
		};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$view = F2(
	function (lobbyModel, round) {
		var judging = function () {
			var _p14 = round.state;
			if (_p14.ctor === 'J') {
				return true;
			} else {
				return false;
			}
		}();
		var timedOut = _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$afterTimeLimit(round.state);
		var lobby = lobbyModel.lobby;
		var model = lobbyModel.playing;
		var _p15 = function () {
			var _p16 = model.finishedRound;
			if (_p16.ctor === 'Just') {
				return A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$winnerHeaderAndContents, _p16._0, lobby.players);
			} else {
				return {
					ctor: '_Tuple2',
					_0: {
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('gavel'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text(
								A2(
									_elm_lang$core$Basics_ops['++'],
									' ',
									A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$czarName, lobby.players, round.czar))),
							_1: {ctor: '[]'}
						}
					},
					_1: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$roundContents, lobbyModel, round)
				};
			}
		}();
		var header = _p15._0;
		var content = _p15._1;
		var _p17 = model.history;
		if (_p17.ctor === 'Nothing') {
			return {
				ctor: '_Tuple2',
				_0: header,
				_1: _elm_lang$core$List$concat(
					{
						ctor: '::',
						_0: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$infoBar, lobby, lobbyModel.secret),
						_1: {
							ctor: '::',
							_0: content,
							_1: {
								ctor: '::',
								_0: {
									ctor: '::',
									_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$warningDrawer(
										_elm_lang$core$List$concat(
											{
												ctor: '::',
												_0: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$skippingNotice, lobby.players, lobbyModel.secret.id),
												_1: {
													ctor: '::',
													_0: A4(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$timeoutNotice, lobbyModel.secret.id, lobby.players, judging, timedOut),
													_1: {
														ctor: '::',
														_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$disconnectedNotice(lobby.players),
														_1: {ctor: '[]'}
													}
												}
											})),
									_1: {ctor: '[]'}
								},
								_1: {ctor: '[]'}
							}
						}
					})
			};
		} else {
			return {
				ctor: '_Tuple2',
				_0: {ctor: '[]'},
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$map,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$HistoryMessage,
						A2(_Lattyware$massivedecks$MassiveDecks_Scenes_History$view, _p17._0, lobbyModel.lobby.players)),
					_1: {ctor: '[]'}
				}
			};
		}
	});

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$randomPositioning = A5(
	_elm_lang$core$Random$map4,
	_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Models$ShownCard,
	A2(_elm_lang$core$Random$int, -90, 90),
	A2(_elm_lang$core$Random$int, 25, 50),
	_elm_lang$core$Random$bool,
	A2(_elm_lang$core$Random$int, -5, 1));
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$initialRandomPositioning = A4(
	_elm_lang$core$Random$map3,
	F3(
		function (r, h, l) {
			return A4(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Models$ShownCard, r, h, l, -100);
		}),
	A2(_elm_lang$core$Random$int, -75, 75),
	A2(_elm_lang$core$Random$int, 0, 50),
	_elm_lang$core$Random$bool);
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$updatePositioning = F2(
	function (shownPlayed, seed) {
		var _p0 = A2(
			_elm_lang$core$Random$step,
			A2(
				_elm_lang$core$Random$list,
				_elm_lang$core$List$length(shownPlayed.toAnimate),
				_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$randomPositioning),
			seed);
		var newAnimated = _p0._0;
		var newSeed = _p0._1;
		return {
			ctor: '_Tuple2',
			_0: A2(
				_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Models$ShownPlayedCards,
				A2(_elm_lang$core$Basics_ops['++'], shownPlayed.animated, newAnimated),
				{ctor: '[]'}),
			_1: newSeed
		};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$addShownPlayed = F2(
	function ($new, seed) {
		return A2(
			_elm_lang$core$Random$step,
			A2(_elm_lang$core$Random$list, $new, _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$initialRandomPositioning),
			seed);
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$skipErrorHandler = function (error) {
	var _p1 = error;
	if (_p1.ctor === 'NotEnoughPlayersToSkip') {
		return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage(
			A2(
				_Lattyware$massivedecks$MassiveDecks_Components_Errors$New,
				A2(
					_elm_lang$core$Basics_ops['++'],
					'There are not enough players in the game to skip (must have at least ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(_p1._0),
						').')),
				false));
	} else {
		return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage(
			A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$New, 'The players can\'t be skipped as they are not inactive.', false));
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$playErrorHandler = function (error) {
	var _p2 = error;
	switch (_p2.ctor) {
		case 'NotInRound':
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage(
				A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$New, 'You can\'t play as you are not in this round.', false));
		case 'AlreadyPlayed':
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage(
				A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$New, 'You can\'t play as you have already played in this round.', false));
		case 'AlreadyJudging':
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage(
				A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$New, 'You can\'t play as the round is already in it\'s judging phase.', false));
		default:
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage(
				A2(
					_Lattyware$massivedecks$MassiveDecks_Components_Errors$New,
					A2(
						_elm_lang$core$Basics_ops['++'],
						'You played the wrong number of cards - you played ',
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Basics$toString(_p2._0),
							A2(
								_elm_lang$core$Basics_ops['++'],
								' cards, but the call needs ',
								A2(
									_elm_lang$core$Basics_ops['++'],
									_elm_lang$core$Basics$toString(_p2._1),
									'cards.')))),
					false));
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$chooseErrorHandler = function (error) {
	var _p3 = error;
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage(
		A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$New, 'You can\'t pick a winner as you are not the card czar this round.', false));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$redrawErrorHandler = function (error) {
	var _p4 = error;
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage(
		A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$New, 'You do not have enough points to redraw your hand.', false));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$lobbyAndHandUpdated = F2(
	function (lobbyModel, round) {
		var playedCards = function () {
			var _p5 = round.state;
			if (_p5.ctor === 'P') {
				return _elm_lang$core$Maybe$Just(_p5._0.numberPlayed);
			} else {
				return _elm_lang$core$Maybe$Nothing;
			}
		}();
		var model = lobbyModel.playing;
		var shownPlayed = model.shownPlayed;
		var _p6 = function () {
			var _p7 = playedCards;
			if (_p7.ctor === 'Just') {
				var existing = _elm_lang$core$List$length(shownPlayed.animated) + _elm_lang$core$List$length(shownPlayed.toAnimate);
				var toShow = _p7._0 * _Lattyware$massivedecks$MassiveDecks_Models_Card$slots(round.call);
				var _p8 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$addShownPlayed, toShow - existing, model.seed);
				var $new = _p8._0;
				var seed = _p8._1;
				return {
					ctor: '_Tuple2',
					_0: A2(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Models$ShownPlayedCards,
						shownPlayed.animated,
						A2(_elm_lang$core$Basics_ops['++'], shownPlayed.toAnimate, $new)),
					_1: seed
				};
			} else {
				return {
					ctor: '_Tuple2',
					_0: A2(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Models$ShownPlayedCards,
						{ctor: '[]'},
						{ctor: '[]'}),
					_1: model.seed
				};
			}
		}();
		var newShownPlayed = _p6._0;
		var seed = _p6._1;
		var newModel = _elm_lang$core$Native_Utils.update(
			model,
			{shownPlayed: newShownPlayed, seed: seed});
		var lobby = lobbyModel.lobby;
		return {ctor: '_Tuple2', _0: newModel, _1: _elm_lang$core$Platform_Cmd$none};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$ignore = function (_p9) {
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$NoOp);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$update = F3(
	function (message, lobbyModel, round) {
		var secret = lobbyModel.secret;
		var lobby = lobbyModel.lobby;
		var gameCode = lobby.gameCode;
		var model = lobbyModel.playing;
		var _p10 = message;
		switch (_p10.ctor) {
			case 'Pick':
				var playing = function () {
					var _p11 = round.state;
					if (_p11.ctor === 'P') {
						return true;
					} else {
						return false;
					}
				}();
				var slots = _Lattyware$massivedecks$MassiveDecks_Models_Card$slots(round.call);
				var canPlay = _elm_lang$core$Native_Utils.cmp(
					_elm_lang$core$List$length(model.picked),
					slots) < 0;
				return (playing && canPlay) ? {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							picked: A2(
								_elm_lang$core$Basics_ops['++'],
								model.picked,
								{
									ctor: '::',
									_0: _p10._0,
									_1: {ctor: '[]'}
								})
						}),
					_1: _elm_lang$core$Platform_Cmd$none
				} : {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
			case 'Withdraw':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							picked: A2(
								_elm_lang$core$List$filter,
								F2(
									function (x, y) {
										return !_elm_lang$core$Native_Utils.eq(x, y);
									})(_p10._0),
								model.picked)
						}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'Play':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							picked: {ctor: '[]'}
						}),
					_1: A4(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send,
						A3(_Lattyware$massivedecks$MassiveDecks_API$play, gameCode, secret, model.picked),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$playErrorHandler,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$HandUpdate)
				};
			case 'Consider':
				var _p15 = _p10._0;
				var speech = A2(
					_elm_lang$core$Maybe$withDefault,
					_elm_lang$core$Platform_Cmd$none,
					A2(
						_elm_lang$core$Maybe$map,
						function (_p12) {
							var _p13 = _p12;
							return _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$TTSMessage(
									_Lattyware$massivedecks$MassiveDecks_Components_TTS$Say(
										A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$callText, _p13._0.call, _p13._1))));
						},
						function () {
							var _p14 = round.state;
							if (_p14.ctor === 'J') {
								return A2(
									_elm_lang$core$Maybe$map,
									function (fill) {
										return {ctor: '_Tuple2', _0: round, _1: fill};
									},
									A2(_Lattyware$massivedecks$MassiveDecks_Util$get, _p14._0.responses, _p15));
							} else {
								return _elm_lang$core$Maybe$Nothing;
							}
						}()));
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							considering: _elm_lang$core$Maybe$Just(_p15)
						}),
					_1: speech
				};
			case 'Choose':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{considering: _elm_lang$core$Maybe$Nothing}),
					_1: A4(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send,
						A3(_Lattyware$massivedecks$MassiveDecks_API$choose, gameCode, secret, _p10._0),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$chooseErrorHandler,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$ignore)
				};
			case 'NextRound':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{considering: _elm_lang$core$Maybe$Nothing, finishedRound: _elm_lang$core$Maybe$Nothing}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'AnimatePlayedCards':
				var _p16 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$updatePositioning, model.shownPlayed, model.seed);
				var shownPlayed = _p16._0;
				var seed = _p16._1;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{seed: seed, shownPlayed: shownPlayed}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'Skip':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A4(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send,
						A3(_Lattyware$massivedecks$MassiveDecks_API$skip, gameCode, secret, _p10._0),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$skipErrorHandler,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$ignore)
				};
			case 'Back':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A3(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send_,
						A2(_Lattyware$massivedecks$MassiveDecks_API$back, gameCode, secret),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$ignore)
				};
			case 'LobbyAndHandUpdated':
				return A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$lobbyAndHandUpdated, lobbyModel, round);
			case 'Redraw':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A4(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send,
						A2(_Lattyware$massivedecks$MassiveDecks_API$redraw, lobbyModel.lobby.gameCode, lobbyModel.secret),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$redrawErrorHandler,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$HandUpdate)
				};
			case 'FinishRound':
				var _p17 = _p10._0;
				var cards = _p17.state.responses;
				var winning = A2(
					_elm_lang$core$Maybe$withDefault,
					{ctor: '[]'},
					A2(_Lattyware$massivedecks$MassiveDecks_Models_Card$winningCards, cards, _p17.state.playedByAndWinner));
				var speech = A2(_Lattyware$massivedecks$MassiveDecks_Models_Card$filled, _p17.call, winning);
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							finishedRound: _elm_lang$core$Maybe$Just(_p17)
						}),
					_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$TTSMessage(
							_Lattyware$massivedecks$MassiveDecks_Components_TTS$Say(speech)))
				};
			case 'HistoryMessage':
				var _p18 = model.history;
				if (_p18.ctor === 'Just') {
					var _p19 = _p10._0;
					switch (_p19.ctor) {
						case 'ErrorMessage':
							return {
								ctor: '_Tuple2',
								_0: model,
								_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage(_p19._0))
							};
						case 'Close':
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Native_Utils.update(
									model,
									{history: _elm_lang$core$Maybe$Nothing}),
								_1: _elm_lang$core$Platform_Cmd$none
							};
						default:
							var _p20 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_History$update, _p19._0, _p18._0);
							var newHistory = _p20._0;
							var cmd = _p20._1;
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Native_Utils.update(
									model,
									{
										history: _elm_lang$core$Maybe$Just(newHistory)
									}),
								_1: A2(
									_elm_lang$core$Platform_Cmd$map,
									function (_p21) {
										return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage(
											_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$HistoryMessage(_p21));
									},
									cmd)
							};
					}
				} else {
					return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
				}
			case 'ViewHistory':
				var _p22 = _Lattyware$massivedecks$MassiveDecks_Scenes_History$init(lobbyModel.lobby.gameCode);
				var historyModel = _p22._0;
				var command = _p22._1;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							history: _elm_lang$core$Maybe$Just(historyModel)
						}),
					_1: A2(
						_elm_lang$core$Platform_Cmd$map,
						function (_p23) {
							return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$HistoryMessage(_p23));
						},
						command)
				};
			default:
				return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$view = F2(
	function (model, round) {
		var _p24 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$view, model, round);
		var header = _p24._0;
		var content = _p24._1;
		return {
			ctor: '_Tuple2',
			_0: A2(
				_elm_lang$core$List$map,
				_elm_lang$html$Html$map(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage),
				header),
			_1: A2(
				_elm_lang$core$List$map,
				_elm_lang$html$Html$map(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage),
				content)
		};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$subscriptions = function (model) {
	return _elm_lang$core$List$isEmpty(model.shownPlayed.toAnimate) ? _elm_lang$core$Platform_Sub$none : _elm_lang$animation_frame$AnimationFrame$diffs(
		function (_p25) {
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$AnimatePlayedCards);
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$hack = function (seed) {
	return A2(
		_elm_lang$core$Result$withDefault,
		0,
		_elm_lang$core$String$toInt(seed));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$houseRule = function (id) {
	var _p26 = id;
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Reboot$rule;
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$init = function (init) {
	return {
		picked: {ctor: '[]'},
		considering: _elm_lang$core$Maybe$Nothing,
		finishedRound: _elm_lang$core$Maybe$Nothing,
		shownPlayed: {
			animated: {ctor: '[]'},
			toAnimate: {ctor: '[]'}
		},
		seed: _elm_lang$core$Random$initialSeed(
			_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$hack(init.seed)),
		history: _elm_lang$core$Maybe$Nothing
	};
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$startGameWarning = function (canStart) {
	return canStart ? _elm_lang$html$Html$text('') : A2(
		_elm_lang$html$Html$span,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('info-circle'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html$text(' You will need at least two players to start the game.'),
				_1: {ctor: '[]'}
			}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$startGameButton = F3(
	function (notOwner, enoughPlayers, enoughCards) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$id('start-game'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$startGameWarning(enoughPlayers),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$button,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--primary mui-btn--raised'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$StartGame),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$disabled((!(enoughPlayers && enoughCards)) || notOwner),
									_1: {ctor: '[]'}
								}
							}
						},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('Start Game'),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$houseRuleTemplate = F7(
	function (canNotChangeConfig, id_, title, icon, description, buttonText, message) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$id(id_),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('house-rule'),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$h3,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon(icon),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html$text(' '),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html$text(title),
										_1: {ctor: '[]'}
									}
								}
							}),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$button,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--primary'),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html_Events$onClick(message),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$disabled(canNotChangeConfig),
											_1: {ctor: '[]'}
										}
									}
								},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text(buttonText),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$p,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text(description),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$rando = function (canNotChangeConfig) {
	return A7(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$houseRuleTemplate, canNotChangeConfig, 'rando', 'Rando Cardrissian', 'cogs', 'Every round, one random card will be played for an imaginary player named Rando Cardrissian, if he wins, all players go home in a state of everlasting shame.', 'Add an AI player', _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$AddAi);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$houseRule = F3(
	function (canNotChangeConfig, enabled, rule) {
		var _p0 = enabled ? {
			ctor: '_Tuple2',
			_0: 'Disable',
			_1: _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$DisableRule(rule.id)
		} : {
			ctor: '_Tuple2',
			_0: 'Enable',
			_1: _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$EnableRule(rule.id)
		};
		var buttonText = _p0._0;
		var command = _p0._1;
		return A7(
			_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$houseRuleTemplate,
			canNotChangeConfig,
			_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$toString(rule.id),
			rule.name,
			rule.icon,
			rule.description,
			buttonText,
			command);
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$emptyDeckListInfo = function (display) {
	return display ? {
		ctor: '::',
		_0: {
			ctor: '_Tuple2',
			_0: '!!emptyInfo',
			_1: A2(
				_elm_lang$html$Html$tr,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$td,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$colspan(4),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('info-circle'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text(' You will need to add at least one '),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$a,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$href('https://www.cardcastgame.com/browse'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$target('_blank'),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$rel('noopener'),
													_1: {ctor: '[]'}
												}
											}
										},
										{
											ctor: '::',
											_0: _elm_lang$html$Html$text('Cardcast deck'),
											_1: {ctor: '[]'}
										}),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html$text(' to the game.'),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html$text(' Not sure? Try '),
											_1: {
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$a,
													{
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$class('link'),
														_1: {
															ctor: '::',
															_0: A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
															_1: {
																ctor: '::',
																_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
																_1: {
																	ctor: '::',
																	_0: _elm_lang$html$Html_Events$onClick(
																		_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ConfigureDecks(
																			_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Request('33BEU'))),
																	_1: {ctor: '[]'}
																}
															}
														}
													},
													{
														ctor: '::',
														_0: _elm_lang$html$Html$text('clicking here to add the Cards Against Humanity base set'),
														_1: {ctor: '[]'}
													}),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html$text('.'),
													_1: {ctor: '[]'}
												}
											}
										}
									}
								}
							}
						}),
					_1: {ctor: '[]'}
				})
		},
		_1: {ctor: '[]'}
	} : {ctor: '[]'};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckLink = function (id) {
	return A2(
		_elm_lang$html$Html$a,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$href(
				A2(_elm_lang$core$Basics_ops['++'], 'https://www.cardcastgame.com/browse/deck/', id)),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$target('_blank'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$rel('noopener'),
					_1: {ctor: '[]'}
				}
			}
		},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text(id),
			_1: {ctor: '[]'}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$loadingDeckEntry = function (deckId) {
	var row = A2(
		_elm_lang$html$Html$tr,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$td,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckLink(deckId),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$td,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$colspan(3),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$spinner,
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}
		});
	return {ctor: '_Tuple2', _0: deckId, _1: row};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$loadedDeckEntry = function (deck) {
	var row = A2(
		_elm_lang$html$Html$tr,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$td,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckLink(deck.id),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$td,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$title(deck.name),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(deck.name),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$td,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text(
								_elm_lang$core$Basics$toString(deck.calls)),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$td,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(
									_elm_lang$core$Basics$toString(deck.responses)),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}
				}
			}
		});
	return {ctor: '_Tuple2', _0: deck.id, _1: row};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckList = F4(
	function (canNotChangeConfig, decks, loadingDecks, deckId) {
		return A2(
			_elm_lang$html$Html$table,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('decks mui-table'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$thead,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$tr,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$th,
									{ctor: '[]'},
									{
										ctor: '::',
										_0: _elm_lang$html$Html$text('Id'),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$th,
										{ctor: '[]'},
										{
											ctor: '::',
											_0: _elm_lang$html$Html$text('Name'),
											_1: {ctor: '[]'}
										}),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$th,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$title('Calls'),
												_1: {ctor: '[]'}
											},
											{
												ctor: '::',
												_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('square'),
												_1: {ctor: '[]'}
											}),
										_1: {
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$th,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$title('Responses'),
													_1: {ctor: '[]'}
												},
												{
													ctor: '::',
													_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('square-o'),
													_1: {ctor: '[]'}
												}),
											_1: {ctor: '[]'}
										}
									}
								}
							}),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_Lattyware$massivedecks$MassiveDecks_Util$tbody,
						{ctor: '[]'},
						_elm_lang$core$List$concat(
							{
								ctor: '::',
								_0: (canNotChangeConfig && _elm_lang$core$List$isEmpty(decks)) ? {
									ctor: '::',
									_0: {
										ctor: '_Tuple2',
										_0: '!!emptyInfo',
										_1: A2(
											_elm_lang$html$Html$tr,
											{ctor: '[]'},
											{
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$td,
													{
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$colspan(4),
														_1: {ctor: '[]'}
													},
													{
														ctor: '::',
														_0: _elm_lang$html$Html$text('No decks have been added yet.'),
														_1: {ctor: '[]'}
													}),
												_1: {ctor: '[]'}
											})
									},
									_1: {ctor: '[]'}
								} : {ctor: '[]'},
								_1: {
									ctor: '::',
									_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$emptyDeckListInfo(
										(!canNotChangeConfig) && (_elm_lang$core$List$isEmpty(decks) && _elm_lang$core$List$isEmpty(loadingDecks))),
									_1: {
										ctor: '::',
										_0: A2(_elm_lang$core$List$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$loadedDeckEntry, decks),
										_1: {
											ctor: '::',
											_0: A2(_elm_lang$core$List$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$loadingDeckEntry, loadingDecks),
											_1: {
												ctor: '::',
												_0: canNotChangeConfig ? {ctor: '[]'} : {
													ctor: '::',
													_0: {
														ctor: '_Tuple2',
														_0: '!!input',
														_1: A2(
															_elm_lang$html$Html$tr,
															{ctor: '[]'},
															{
																ctor: '::',
																_0: A2(
																	_elm_lang$html$Html$td,
																	{
																		ctor: '::',
																		_0: _elm_lang$html$Html_Attributes$colspan(4),
																		_1: {ctor: '[]'}
																	},
																	{
																		ctor: '::',
																		_0: _Lattyware$massivedecks$MassiveDecks_Components_Input$view(deckId),
																		_1: {ctor: '[]'}
																	}),
																_1: {ctor: '[]'}
															})
													},
													_1: {ctor: '[]'}
												},
												_1: {ctor: '[]'}
											}
										}
									}
								}
							})),
					_1: {ctor: '[]'}
				}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$addDeckButton = function (deckId) {
	return {
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html$button,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--primary mui-btn--fab'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$disabled(
						_elm_lang$core$String$isEmpty(deckId)),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Events$onClick(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ConfigureDecks(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Request(deckId))),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$title('Add deck to game.'),
							_1: {ctor: '[]'}
						}
					}
				}
			},
			{
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('plus'),
				_1: {ctor: '[]'}
			}),
		_1: {ctor: '[]'}
	};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckIdInputLabel = {
	ctor: '::',
	_0: _elm_lang$html$Html$text(' A '),
	_1: {
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html$a,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$href('https://www.cardcastgame.com/browse'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$target('_blank'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$rel('noopener'),
						_1: {ctor: '[]'}
					}
				}
			},
			{
				ctor: '::',
				_0: _elm_lang$html$Html$text('Cardcast'),
				_1: {ctor: '[]'}
			}),
		_1: {
			ctor: '::',
			_0: _elm_lang$html$Html$text(' Play Code'),
			_1: {ctor: '[]'}
		}
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$invite = F2(
	function (appUrl, lobbyId) {
		var url = A2(_Lattyware$massivedecks$MassiveDecks_Util$lobbyUrl, appUrl, lobbyId);
		return A2(
			_elm_lang$html$Html$div,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$p,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('Invite others to the game with the code \''),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$strong,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('game-code'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text(lobbyId),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text('\' to enter on the main page, or give them this link: '),
								_1: {ctor: '[]'}
							}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$p,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$a,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$href(url),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text(url),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$setPasswordButton = function (password) {
	return {
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html$button,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--primary'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$SetPassword),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$title('Set the password.'),
						_1: {ctor: '[]'}
					}
				}
			},
			{
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('lock'),
				_1: {ctor: '[]'}
			}),
		_1: {ctor: '[]'}
	};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$password = function (passwordInputModel) {
	return A2(
		_elm_lang$html$Html$div,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$h3,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('key'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html$text(' Privacy'),
						_1: {ctor: '[]'}
					}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$p,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('A password that players will need to enter to get in the game. People already in the game will not need to enter it, and anyone in the game will be able to see it.'),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Components_Input$view(passwordInputModel),
					_1: {ctor: '[]'}
				}
			}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$passwordInputLabel = {
	ctor: '::',
	_0: _elm_lang$html$Html$text('If blank, anyone with the game code can join.'),
	_1: {ctor: '[]'}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$infoBar = {
	ctor: '::',
	_0: A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$id('info-bar'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('mui--z1'),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('info-circle'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html$text(' '),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html$text('You can\'t change the configuration of the game, as you are not the owner.'),
					_1: {ctor: '[]'}
				}
			}
		}),
	_1: {ctor: '[]'}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$view = function (lobbyModel) {
	var canNotChangeConfig = !_elm_lang$core$Native_Utils.eq(lobbyModel.lobby.owner, lobbyModel.secret.id);
	var lobby = lobbyModel.lobby;
	var decks = lobby.config.decks;
	var enoughCards = !_elm_lang$core$List$isEmpty(decks);
	var enoughPlayers = _elm_lang$core$Native_Utils.cmp(
		_elm_lang$core$List$length(lobby.players),
		1) > 0;
	var model = lobbyModel.config;
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$id('config'),
			_1: {ctor: '[]'}
		},
		A2(
			_elm_lang$core$Basics_ops['++'],
			canNotChangeConfig ? _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$infoBar : {ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$id('config-content'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('mui-panel'),
							_1: {ctor: '[]'}
						}
					},
					{
						ctor: '::',
						_0: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$invite, lobbyModel.init.url, lobby.gameCode),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$div,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('mui-divider'),
									_1: {ctor: '[]'}
								},
								{ctor: '[]'}),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$h1,
									{ctor: '[]'},
									{
										ctor: '::',
										_0: _elm_lang$html$Html$text('Game Setup'),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$ul,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('mui-tabs__bar'),
											_1: {ctor: '[]'}
										},
										{
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$li,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$class('mui--is-active'),
													_1: {ctor: '[]'}
												},
												{
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$a,
														{
															ctor: '::',
															_0: A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-toggle', 'tab'),
															_1: {
																ctor: '::',
																_0: A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-controls', 'decks'),
																_1: {ctor: '[]'}
															}
														},
														{
															ctor: '::',
															_0: _elm_lang$html$Html$text('Decks'),
															_1: {ctor: '[]'}
														}),
													_1: {ctor: '[]'}
												}),
											_1: {
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$li,
													{ctor: '[]'},
													{
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html$a,
															{
																ctor: '::',
																_0: A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-toggle', 'tab'),
																_1: {
																	ctor: '::',
																	_0: A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-controls', 'house-rules'),
																	_1: {ctor: '[]'}
																}
															},
															{
																ctor: '::',
																_0: _elm_lang$html$Html$text('House Rules'),
																_1: {ctor: '[]'}
															}),
														_1: {ctor: '[]'}
													}),
												_1: {
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$li,
														{ctor: '[]'},
														{
															ctor: '::',
															_0: A2(
																_elm_lang$html$Html$a,
																{
																	ctor: '::',
																	_0: A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-toggle', 'tab'),
																	_1: {
																		ctor: '::',
																		_0: A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-controls', 'lobby-settings'),
																		_1: {ctor: '[]'}
																	}
																},
																{
																	ctor: '::',
																	_0: _elm_lang$html$Html$text('Lobby Settings'),
																	_1: {ctor: '[]'}
																}),
															_1: {ctor: '[]'}
														}),
													_1: {ctor: '[]'}
												}
											}
										}),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$div,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$id('decks'),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$class('mui-tabs__pane mui--is-active'),
													_1: {ctor: '[]'}
												}
											},
											{
												ctor: '::',
												_0: A4(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckList, canNotChangeConfig, decks, model.loadingDecks, model.deckIdInput),
												_1: {ctor: '[]'}
											}),
										_1: {
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$div,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$id('house-rules'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$class('mui-tabs__pane'),
														_1: {ctor: '[]'}
													}
												},
												A2(
													_elm_lang$core$Basics_ops['++'],
													{
														ctor: '::',
														_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$rando(canNotChangeConfig),
														_1: {ctor: '[]'}
													},
													A2(
														_elm_lang$core$List$map,
														function (rule) {
															return A3(
																_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$houseRule,
																canNotChangeConfig,
																A2(_elm_lang$core$List$member, rule.id, lobbyModel.lobby.config.houseRules),
																rule);
														},
														_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Available$houseRules))),
											_1: {
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$div,
													{
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$id('lobby-settings'),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$class('mui-tabs__pane'),
															_1: {ctor: '[]'}
														}
													},
													{
														ctor: '::',
														_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$password(model.passwordInput),
														_1: {ctor: '[]'}
													}),
												_1: {
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$div,
														{
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$class('mui-divider'),
															_1: {ctor: '[]'}
														},
														{ctor: '[]'}),
													_1: {
														ctor: '::',
														_0: A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$startGameButton, canNotChangeConfig, enoughPlayers, enoughCards),
														_1: {ctor: '[]'}
													}
												}
											}
										}
									}
								}
							}
						}
					}),
				_1: {ctor: '[]'}
			}));
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$newGameErrorHandler = function (error) {
	var _p0 = error;
	if (_p0.ctor === 'GameInProgress') {
		return _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage(
			A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$New, 'Can\'t start the game - it is already in progress.', false));
	} else {
		return _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage(
			A2(
				_Lattyware$massivedecks$MassiveDecks_Components_Errors$New,
				A2(
					_elm_lang$core$Basics_ops['++'],
					'Can\'t start the game - you need at least ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(_p0._0),
						' players to start the game.')),
				false));
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$addDeckErrorHandler = F2(
	function (deckId, error) {
		var _p1 = error;
		if (_p1.ctor === 'CardcastTimeout') {
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage(
				_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ConfigureDecks(
					A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Fail, deckId, 'There was a problem accessing CardCast, please try again after a short wait.')));
		} else {
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage(
				_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ConfigureDecks(
					A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Fail, deckId, 'The given play code doesn\'t exist, please check you have the correct code.')));
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$removeDeckLoadingSpinner = F2(
	function (deckId, model) {
		return _elm_lang$core$Native_Utils.update(
			model,
			{
				loadingDecks: A2(
					_elm_lang$core$List$filter,
					F2(
						function (x, y) {
							return !_elm_lang$core$Native_Utils.eq(x, y);
						})(deckId),
					model.loadingDecks)
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$inputSetErrorCmd = F2(
	function (inputId, error) {
		return _Lattyware$massivedecks$MassiveDecks_Util$cmd(
			_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage(
				_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$InputMessage(
					{
						ctor: '_Tuple2',
						_0: inputId,
						_1: _Lattyware$massivedecks$MassiveDecks_Components_Input$Error(
							_elm_lang$core$Maybe$Just(error))
					})));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$inputClearErrorCmd = function (inputId) {
	return _Lattyware$massivedecks$MassiveDecks_Util$cmd(
		_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage(
			_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$InputMessage(
				{
					ctor: '_Tuple2',
					_0: inputId,
					_1: _Lattyware$massivedecks$MassiveDecks_Components_Input$Error(_elm_lang$core$Maybe$Nothing)
				})));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$ignore = function (_p2) {
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$NoOp);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$update = F2(
	function (message, lobbyModel) {
		var model = lobbyModel.config;
		var secret = lobbyModel.secret;
		var gameCode = lobbyModel.lobby.gameCode;
		var lobby = lobbyModel.lobby;
		var _p3 = message;
		switch (_p3.ctor) {
			case 'AddDeck':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ConfigureDecks(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Request(model.deckIdInput.value))))
				};
			case 'ConfigureDecks':
				switch (_p3._0.ctor) {
					case 'Request':
						var deckId = _elm_lang$core$String$toUpper(_p3._0._0);
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								model,
								{
									loadingDecks: A2(
										_elm_lang$core$Basics_ops['++'],
										model.loadingDecks,
										{
											ctor: '::',
											_0: deckId,
											_1: {ctor: '[]'}
										})
								}),
							{
								ctor: '::',
								_0: A4(
									_Lattyware$massivedecks$MassiveDecks_API_Request$send,
									A3(_Lattyware$massivedecks$MassiveDecks_API$addDeck, gameCode, secret, deckId),
									_Lattyware$massivedecks$MassiveDecks_Scenes_Config$addDeckErrorHandler(deckId),
									_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage,
									function (_p4) {
										return _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage(
											_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ConfigureDecks(
												_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Add(deckId)));
									}),
								_1: {
									ctor: '::',
									_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Config$inputClearErrorCmd(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$DeckId),
									_1: {ctor: '[]'}
								}
							});
					case 'Add':
						return {
							ctor: '_Tuple2',
							_0: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Config$removeDeckLoadingSpinner, _p3._0._0, model),
							_1: _elm_lang$core$Platform_Cmd$none
						};
					default:
						return {
							ctor: '_Tuple2',
							_0: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Config$removeDeckLoadingSpinner, _p3._0._0, model),
							_1: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Config$inputSetErrorCmd, _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$DeckId, _p3._0._1)
						};
				}
			case 'InputMessage':
				var _p7 = _p3._0;
				var _p5 = A2(_Lattyware$massivedecks$MassiveDecks_Components_Input$update, _p7, lobbyModel.config.passwordInput);
				var passwordInput = _p5._0;
				var passwordMsg = _p5._1;
				var _p6 = A2(_Lattyware$massivedecks$MassiveDecks_Components_Input$update, _p7, lobbyModel.config.deckIdInput);
				var deckIdInput = _p6._0;
				var deckIdMsg = _p6._1;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{deckIdInput: deckIdInput, passwordInput: passwordInput}),
					{
						ctor: '::',
						_0: A2(_elm_lang$core$Platform_Cmd$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage, deckIdMsg),
						_1: {
							ctor: '::',
							_0: A2(_elm_lang$core$Platform_Cmd$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage, passwordMsg),
							_1: {ctor: '[]'}
						}
					});
			case 'AddAi':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A3(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send_,
						A2(_Lattyware$massivedecks$MassiveDecks_API$newAi, gameCode, secret),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage,
						function (_p8) {
							return _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$NoOp);
						})
				};
			case 'StartGame':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A4(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send,
						A2(_Lattyware$massivedecks$MassiveDecks_API$newGame, gameCode, secret),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config$newGameErrorHandler,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$HandUpdate)
				};
			case 'EnableRule':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A3(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send_,
						A3(_Lattyware$massivedecks$MassiveDecks_API$enableRule, _p3._0, gameCode, secret),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config$ignore)
				};
			case 'DisableRule':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A3(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send_,
						A3(_Lattyware$massivedecks$MassiveDecks_API$disableRule, _p3._0, gameCode, secret),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config$ignore)
				};
			case 'SetPassword':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A3(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send_,
						A3(_Lattyware$massivedecks$MassiveDecks_API$setPassword, gameCode, secret, model.passwordInput.value),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config$ignore)
				};
			default:
				return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$view = function (lobbyModel) {
	return A2(
		_elm_lang$html$Html$map,
		_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage,
		_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$view(lobbyModel));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$subscriptions = function (model) {
	return _elm_lang$core$Platform_Sub$none;
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$init = F2(
	function (lobby, secret) {
		var config = lobby.config;
		var canChangeConfig = _elm_lang$core$Native_Utils.eq(lobby.owner, secret.id);
		var setPasswordButton = canChangeConfig ? _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$setPasswordButton : function (_p9) {
			return {ctor: '[]'};
		};
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			{
				decks: {ctor: '[]'},
				deckIdInput: A8(
					_Lattyware$massivedecks$MassiveDecks_Components_Input$initWithExtra,
					_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$DeckId,
					'input-with-button',
					_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckIdInputLabel,
					'',
					'Play Code',
					_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$addDeckButton,
					_Lattyware$massivedecks$MassiveDecks_Util$cmd(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$AddDeck),
					_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$InputMessage),
				passwordInput: A8(
					_Lattyware$massivedecks$MassiveDecks_Components_Input$initWithExtra,
					_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Password,
					'input-with-button',
					_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$passwordInputLabel,
					A2(_elm_lang$core$Maybe$withDefault, '', config.password),
					'Password',
					setPasswordButton,
					_Lattyware$massivedecks$MassiveDecks_Util$cmd(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$SetPassword),
					_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$InputMessage),
				loadingDecks: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$InputMessage(
							{
								ctor: '_Tuple2',
								_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Password,
								_1: _Lattyware$massivedecks$MassiveDecks_Components_Input$SetEnabled(canChangeConfig)
							}))),
				_1: {ctor: '[]'}
			});
	});

var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$notificationsMenuItem = function (model) {
	var _p0 = (!model.supported) ? {
		ctor: '_Tuple2',
		_0: _elm_lang$core$Maybe$Just('Your browser does not support desktop notifications.'),
		_1: false
	} : (_elm_lang$core$Native_Utils.eq(
		model.permission,
		_elm_lang$core$Maybe$Just(_Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$Denied)) ? {
		ctor: '_Tuple2',
		_0: _elm_lang$core$Maybe$Just('You have denied Massive Decks permission to display desktop notifications.'),
		_1: false
	} : {ctor: '_Tuple2', _0: _elm_lang$core$Maybe$Nothing, _1: model.enabled});
	var notClickable = _p0._0;
	var enabled = _p0._1;
	var classes = _elm_lang$html$Html_Attributes$classList(
		{
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 'link', _1: true},
			_1: {
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'disabled',
					_1: !_Lattyware$massivedecks$MassiveDecks_Util$isNothing(notClickable)
				},
				_1: {ctor: '[]'}
			}
		});
	var extraAttrs = function () {
		var _p1 = notClickable;
		if (_p1.ctor === 'Nothing') {
			return {
				ctor: '::',
				_0: _elm_lang$html$Html_Events$onClick(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationsMessage(
							enabled ? _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$disable : _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$enable))),
				_1: {ctor: '[]'}
			};
		} else {
			return {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$title(_p1._0),
				_1: {ctor: '[]'}
			};
		}
	}();
	var attributes = A2(
		_elm_lang$core$Basics_ops['++'],
		{
			ctor: '::',
			_0: classes,
			_1: {
				ctor: '::',
				_0: A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
				_1: {
					ctor: '::',
					_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
					_1: {ctor: '[]'}
				}
			}
		},
		extraAttrs);
	var description = A2(
		_elm_lang$core$Basics_ops['++'],
		' ',
		A2(
			_elm_lang$core$Basics_ops['++'],
			enabled ? 'Disable' : 'Enable',
			' Notifications'));
	return {
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html$li,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$a,
					attributes,
					{
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon(
							enabled ? 'bell-slash' : 'bell'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text(description),
							_1: {ctor: '[]'}
						}
					}),
				_1: {ctor: '[]'}
			}),
		_1: {ctor: '[]'}
	};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$gameMenu = function (model) {
	var url = A2(
		_Lattyware$massivedecks$MassiveDecks_Components_Errors$reportUrl,
		{url: model.init.url, version: model.init.version},
		'I was [a short explanation of what you were doing] when [a short explanation of the bug].');
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('menu mui-dropdown'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$button,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--primary'),
					_1: {
						ctor: '::',
						_0: A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-toggle', 'dropdown'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$title('Game menu.'),
							_1: {ctor: '[]'}
						}
					}
				},
				{
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('ellipsis-h'),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$ul,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('mui-dropdown__menu mui-dropdown__menu--right'),
						_1: {ctor: '[]'}
					},
					A2(
						_elm_lang$core$Basics_ops['++'],
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$li,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$a,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('link'),
											_1: {
												ctor: '::',
												_0: A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
												_1: {
													ctor: '::',
													_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html_Events$onClick(
															_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$DisplayInviteOverlay)),
														_1: {ctor: '[]'}
													}
												}
											}
										},
										{
											ctor: '::',
											_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('bullhorn'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html$text(' Invite Players'),
												_1: {ctor: '[]'}
											}
										}),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						},
						A2(
							_elm_lang$core$Basics_ops['++'],
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$notificationsMenuItem(model.browserNotifications),
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$li,
									{ctor: '[]'},
									{
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$a,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('link'),
												_1: {
													ctor: '::',
													_0: A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
													_1: {
														ctor: '::',
														_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Events$onClick(
																_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
																	_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$TTSMessage(
																		_Lattyware$massivedecks$MassiveDecks_Components_TTS$Enabled(!model.tts.enabled)))),
															_1: {ctor: '[]'}
														}
													}
												}
											},
											model.tts.enabled ? {
												ctor: '::',
												_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('volume-off'),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html$text(' Disable Speech'),
													_1: {ctor: '[]'}
												}
											} : {
												ctor: '::',
												_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('volume-up'),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html$text(' Enable Speech'),
													_1: {ctor: '[]'}
												}
											}),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$li,
										{ctor: '[]'},
										{
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$a,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$class('link'),
													_1: {
														ctor: '::',
														_0: A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
														_1: {
															ctor: '::',
															_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$Leave),
																_1: {ctor: '[]'}
															}
														}
													}
												},
												{
													ctor: '::',
													_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('sign-out'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html$text(' Leave Game'),
														_1: {ctor: '[]'}
													}
												}),
											_1: {ctor: '[]'}
										}),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$li,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('mui-divider'),
												_1: {ctor: '[]'}
											},
											{ctor: '[]'}),
										_1: {
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$li,
												{ctor: '[]'},
												{
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$a,
														{
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$class('link'),
															_1: {
																ctor: '::',
																_0: A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
																_1: {
																	ctor: '::',
																	_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
																	_1: {
																		ctor: '::',
																		_0: _elm_lang$html$Html_Events$onClick(
																			_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$OverlayMessage(
																				_Lattyware$massivedecks$MassiveDecks_Components_About$show(model.init.version))),
																		_1: {ctor: '[]'}
																	}
																}
															}
														},
														{
															ctor: '::',
															_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('info-circle'),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html$text(' About'),
																_1: {ctor: '[]'}
															}
														}),
													_1: {ctor: '[]'}
												}),
											_1: {
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$li,
													{ctor: '[]'},
													{
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html$a,
															{
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$href(url),
																_1: {
																	ctor: '::',
																	_0: _elm_lang$html$Html_Attributes$target('_blank'),
																	_1: {
																		ctor: '::',
																		_0: _elm_lang$html$Html_Attributes$rel('noopener'),
																		_1: {ctor: '[]'}
																	}
																}
															},
															{
																ctor: '::',
																_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('bug'),
																_1: {
																	ctor: '::',
																	_0: _elm_lang$html$Html$text(' Report a bug'),
																	_1: {ctor: '[]'}
																}
															}),
														_1: {ctor: '[]'}
													}),
												_1: {ctor: '[]'}
											}
										}
									}
								}
							}))),
				_1: {ctor: '[]'}
			}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$inviteOverlay = F2(
	function (appUrl, gameCode) {
		var url = A2(_Lattyware$massivedecks$MassiveDecks_Util$lobbyUrl, appUrl, gameCode);
		var contents = {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$p,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('To invite other players, simply send them this link: '),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$p,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$a,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$href(url),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(url),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$p,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('Have them scan this QR code: '),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Components_QR$view('invite-qr-code'),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$p,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('Or give them this game code to enter on the start page: '),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$p,
									{ctor: '[]'},
									{
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$input,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$readonly(true),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$value(gameCode),
													_1: {ctor: '[]'}
												}
											},
											{ctor: '[]'}),
										_1: {ctor: '[]'}
									}),
								_1: {ctor: '[]'}
							}
						}
					}
				}
			}
		};
		return _Lattyware$massivedecks$MassiveDecks_Components_Overlay$Show(
			{icon: 'bullhorn', title: 'Invite Players', contents: contents});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$statusIconName = function (status) {
	var _p2 = status;
	switch (_p2.ctor) {
		case 'NotPlayed':
			return _elm_lang$core$Maybe$Just('hourglass');
		case 'Played':
			return _elm_lang$core$Maybe$Just('check');
		case 'Czar':
			return _elm_lang$core$Maybe$Just('gavel');
		case 'Ai':
			return _elm_lang$core$Maybe$Just('cogs');
		case 'Neutral':
			return _elm_lang$core$Maybe$Nothing;
		default:
			return _elm_lang$core$Maybe$Just('fast-forward');
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$statusIcon = function (status) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		_elm_lang$html$Html$text(''),
		A2(
			_elm_lang$core$Maybe$map,
			_Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon,
			_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$statusIconName(status)));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$playerIcon = function (player) {
	return player.left ? _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('sign-out') : _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$statusIcon(player.status);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$statusDescription = function (player) {
	var _p3 = player.status;
	switch (_p3.ctor) {
		case 'NotPlayed':
			return 'Choosing';
		case 'Played':
			return 'Played';
		case 'Czar':
			return 'Round Czar';
		case 'Ai':
			return 'A Computer';
		case 'Neutral':
			return '';
		default:
			return 'Being Skipped';
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$notificationPopup = function (notification) {
	var _p4 = notification;
	if (_p4.ctor === 'Just') {
		var _p5 = _p4._0;
		var hidden = _p5.visible ? '' : 'hide';
		return {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class(
						A2(_elm_lang$core$Basics_ops['++'], 'badge mui--z2 ', hidden)),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$title(_p5.description),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Events$onClick(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$DismissNotification(_p5))),
							_1: {ctor: '[]'}
						}
					}
				},
				{
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon(_p5.icon),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html$text(
							A2(_elm_lang$core$Basics_ops['++'], ' ', _p5.name)),
						_1: {ctor: '[]'}
					}
				}),
			_1: {ctor: '[]'}
		};
	} else {
		return {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('badge mui--z2 hide'),
					_1: {ctor: '[]'}
				},
				{ctor: '[]'}),
			_1: {ctor: '[]'}
		};
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$scoresButton = A2(
	_elm_lang$html$Html$button,
	{
		ctor: '::',
		_0: _elm_lang$html$Html_Attributes$class('scores-toggle mui-btn mui-btn--small mui-btn--primary badged'),
		_1: {
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$title('Players.'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Events$onClick(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SidebarMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Sidebar$Toggle))),
				_1: {ctor: '[]'}
			}
		}
	},
	{
		ctor: '::',
		_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('users'),
		_1: {ctor: '[]'}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$appHeader = F2(
	function (contents, model) {
		return A2(
			_elm_lang$html$Html$header,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('mui-appbar mui--z1 mui--appbar-line-height'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$div,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('mui--appbar-line-height'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$span,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('score-buttons'),
										_1: {ctor: '[]'}
									},
									A2(
										_elm_lang$core$Basics_ops['++'],
										{
											ctor: '::',
											_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$scoresButton,
											_1: {ctor: '[]'}
										},
										_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$notificationPopup(model.notification))),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$span,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$id('title'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('mui--text-title mui--visible-xs-inline-block'),
												_1: {ctor: '[]'}
											}
										},
										contents),
									_1: {
										ctor: '::',
										_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$gameMenu(model),
										_1: {ctor: '[]'}
									}
								}
							}),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$score = F3(
	function (client, owner, player) {
		var afterNameTitle = A2(
			_elm_lang$core$Basics_ops['++'],
			_elm_lang$core$Native_Utils.eq(player.id, owner) ? ' (Owner)' : '',
			A2(
				_elm_lang$core$Basics_ops['++'],
				_elm_lang$core$Native_Utils.eq(player.id, client) ? ' (You)' : '',
				player.disconnected ? ' (Disconnected)' : ''));
		var prename = _elm_lang$core$List$concat(
			{
				ctor: '::',
				_0: _elm_lang$core$Native_Utils.eq(player.id, owner) ? {
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('star'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html$text(' '),
						_1: {ctor: '[]'}
					}
				} : {ctor: '[]'},
				_1: {
					ctor: '::',
					_0: _elm_lang$core$Native_Utils.eq(player.id, client) ? {
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('user-circle'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text(' '),
							_1: {ctor: '[]'}
						}
					} : {ctor: '[]'},
					_1: {
						ctor: '::',
						_0: player.disconnected ? {
							ctor: '::',
							_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('minus-circle'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text(' '),
								_1: {ctor: '[]'}
							}
						} : {ctor: '[]'},
						_1: {ctor: '[]'}
					}
				}
			});
		var classes = _elm_lang$html$Html_Attributes$classList(
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: _Lattyware$massivedecks$MassiveDecks_Models_Player$statusName(player.status),
					_1: true
				},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'disconnected', _1: player.disconnected},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 'left', _1: player.left},
						_1: {
							ctor: '::',
							_0: {
								ctor: '_Tuple2',
								_0: 'you',
								_1: _elm_lang$core$Native_Utils.eq(player.id, client)
							},
							_1: {ctor: '[]'}
						}
					}
				}
			});
		return A2(
			_elm_lang$html$Html$tr,
			{
				ctor: '::',
				_0: classes,
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$td,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('state'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$title(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$statusDescription(player)),
							_1: {ctor: '[]'}
						}
					},
					{
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$playerIcon(player),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$td,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('name'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$title(
									A2(_elm_lang$core$Basics_ops['++'], player.name, afterNameTitle)),
								_1: {ctor: '[]'}
							}
						},
						A2(
							_elm_lang$core$List$append,
							prename,
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(player.name),
								_1: {ctor: '[]'}
							})),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$td,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('score'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(
									_elm_lang$core$Basics$toString(player.score)),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}
				}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$scores = F4(
	function (client, owner, shownAsOverlay, players) {
		var hideMessage = _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
			_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SidebarMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Sidebar$Hide));
		var closeLink = shownAsOverlay ? {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$a,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('link close-link'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$title('Hide.'),
						_1: {
							ctor: '::',
							_0: A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
							_1: {
								ctor: '::',
								_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Events$onClick(hideMessage),
									_1: {ctor: '[]'}
								}
							}
						}
					}
				},
				{
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('times'),
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		} : {ctor: '[]'};
		var sidebar = A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$id('scores'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$classList(
						{
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'shownAsOverlay', _1: shownAsOverlay},
							_1: {
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: 'mui--z1', _1: true},
								_1: {ctor: '[]'}
							}
						}),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$id('scores-title'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('mui--appbar-line-height mui--text-headline'),
							_1: {ctor: '[]'}
						}
					},
					A2(
						_elm_lang$core$Basics_ops['++'],
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('Players'),
							_1: {ctor: '[]'}
						},
						closeLink)),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('mui-divider'),
							_1: {ctor: '[]'}
						},
						{ctor: '[]'}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$table,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('mui-table'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$thead,
									{ctor: '[]'},
									{
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$tr,
											{ctor: '[]'},
											{
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$th,
													{
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$class('state'),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$title('State'),
															_1: {ctor: '[]'}
														}
													},
													{
														ctor: '::',
														_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('tasks'),
														_1: {ctor: '[]'}
													}),
												_1: {
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$th,
														{
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$class('name'),
															_1: {ctor: '[]'}
														},
														{
															ctor: '::',
															_0: _elm_lang$html$Html$text('Player'),
															_1: {ctor: '[]'}
														}),
													_1: {
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html$th,
															{
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$class('score'),
																_1: {
																	ctor: '::',
																	_0: _elm_lang$html$Html_Attributes$title('Score'),
																	_1: {ctor: '[]'}
																}
															},
															{
																ctor: '::',
																_0: _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('trophy'),
																_1: {ctor: '[]'}
															}),
														_1: {ctor: '[]'}
													}
												}
											}),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$tbody,
										{ctor: '[]'},
										A2(
											_elm_lang$core$List$map,
											A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$score, client, owner),
											players)),
									_1: {ctor: '[]'}
								}
							}),
						_1: {ctor: '[]'}
					}
				}
			});
		return shownAsOverlay ? A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$id('mui-overlay'),
				_1: {
					ctor: '::',
					_0: A3(
						_Lattyware$massivedecks$MassiveDecks_Util$onClickIfId,
						'mui-overlay',
						hideMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$NoOp)),
					_1: {
						ctor: '::',
						_0: A3(
							_Lattyware$massivedecks$MassiveDecks_Util$onKeyDown,
							'Escape',
							hideMessage,
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$NoOp)),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$tabindex(0),
							_1: {ctor: '[]'}
						}
					}
				}
			},
			{
				ctor: '::',
				_0: sidebar,
				_1: {ctor: '[]'}
			}) : sidebar;
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$spacer = A2(
	_elm_lang$html$Html$div,
	{
		ctor: '::',
		_0: _elm_lang$html$Html_Attributes$class('mui--appbar-height'),
		_1: {ctor: '[]'}
	},
	{ctor: '[]'});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$contentWrapper = function (contents) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$id('content-wrapper'),
			_1: {ctor: '[]'}
		},
		contents);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$root = F2(
	function (hideScores, contents) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$classList(
					{
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 'content', _1: true},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'hide-scores', _1: hideScores},
							_1: {ctor: '[]'}
						}
					}),
				_1: {ctor: '[]'}
			},
			contents);
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$view = function (model) {
	var url = model.init.url;
	var lobby = model.lobby;
	var gameCode = lobby.gameCode;
	var players = lobby.players;
	var _p6 = function () {
		var _p7 = lobby.game;
		switch (_p7.ctor) {
			case 'Configuring':
				return {
					ctor: '_Tuple2',
					_0: {ctor: '[]'},
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$map,
							function (_p8) {
								return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ConfigMessage(_p8));
							},
							_Lattyware$massivedecks$MassiveDecks_Scenes_Config$view(model)),
						_1: {ctor: '[]'}
					}
				};
			case 'Playing':
				var _p9 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$view, model, _p7._0);
				var h = _p9._0;
				var c = _p9._1;
				return {
					ctor: '_Tuple2',
					_0: A2(
						_elm_lang$core$List$map,
						_elm_lang$html$Html$map(
							function (_p10) {
								return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage(_p10));
							}),
						h),
					_1: A2(
						_elm_lang$core$List$map,
						_elm_lang$html$Html$map(
							function (_p11) {
								return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage(_p11));
							}),
						c)
				};
			default:
				return {
					ctor: '_Tuple2',
					_0: {ctor: '[]'},
					_1: {ctor: '[]'}
				};
		}
	}();
	var header = _p6._0;
	var contents = _p6._1;
	return A2(
		_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$root,
		model.sidebar.hidden,
		{
			ctor: '::',
			_0: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$appHeader, header, model),
			_1: {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$spacer,
				_1: {
					ctor: '::',
					_0: A4(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$scores, model.secret.id, model.lobby.owner, model.sidebar.shownAsOverlay, players),
					_1: {
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$contentWrapper(contents),
						_1: {ctor: '[]'}
					}
				}
			}
		});
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$notificationChange = F2(
	function (model, notification) {
		var newNotification = A2(_Lattyware$massivedecks$MassiveDecks_Util$or, model.notification, notification);
		var cmd = function () {
			var _p0 = newNotification;
			if (_p0.ctor === 'Just') {
				var dismiss = A2(
					_Lattyware$massivedecks$MassiveDecks_Util$after,
					_elm_lang$core$Time$second * 5,
					_elm_lang$core$Task$succeed(_p0._0));
				return A2(
					_elm_lang$core$Task$perform,
					function (_p1) {
						return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$DismissNotification(_p1));
					},
					dismiss);
			} else {
				return _elm_lang$core$Platform_Cmd$none;
			}
		}();
		return {
			ctor: '_Tuple2',
			_0: _elm_lang$core$Native_Utils.update(
				model,
				{notification: newNotification}),
			_1: cmd
		};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateLobbyAndHand = F2(
	function (lobbyAndHand, model) {
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			_elm_lang$core$Native_Utils.update(
				model,
				{lobby: lobbyAndHand.lobby, hand: lobbyAndHand.hand}),
			{
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LobbyAndHandUpdated)))),
				_1: {ctor: '[]'}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$icon = F2(
	function (model, name) {
		return _elm_lang$core$Maybe$Just(
			A2(
				_elm_lang$core$Basics_ops['++'],
				model.init.url,
				A2(
					_elm_lang$core$Basics_ops['++'],
					'assets/images/icons/',
					A2(_elm_lang$core$Basics_ops['++'], name, '.png'))));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$overlayAlert = function (message) {
	var _p2 = message;
	var _p3 = _p2._0;
	if (_p3.ctor === 'Denied') {
		return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$OverlayMessage(
			_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Show(
				A3(
					_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Overlay,
					'times-circle',
					'Can\'t enable desktop notifications.',
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('You did not give Massive Decks permission to give you desktop notifications.'),
						_1: {ctor: '[]'}
					})));
	} else {
		return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$NoOp);
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateRound = function (roundUpdate) {
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby(
		function (lobby) {
			var game = function () {
				var _p4 = lobby.game;
				if (_p4.ctor === 'Playing') {
					return _Lattyware$massivedecks$MassiveDecks_Models_Game$Playing(
						roundUpdate(_p4._0));
				} else {
					return _p4;
				}
			}();
			return _elm_lang$core$Native_Utils.update(
				lobby,
				{game: game});
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateRoundState = function (roundStateUpdate) {
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateRound(
		function (round) {
			return _elm_lang$core$Native_Utils.update(
				round,
				{
					state: roundStateUpdate(round.state)
				});
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updatePlayer = F2(
	function (playerId, playerUpdate) {
		return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby(
			function (lobby) {
				return _elm_lang$core$Native_Utils.update(
					lobby,
					{
						players: A2(
							_elm_lang$core$List$map,
							function (player) {
								return _elm_lang$core$Native_Utils.eq(player.id, playerId) ? playerUpdate(player) : player;
							},
							lobby.players)
					});
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$lobbyRound = function (lobby) {
	var _p5 = lobby.game;
	if (_p5.ctor === 'Playing') {
		return _elm_lang$core$Maybe$Just(_p5._0);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$handleEvent = function (event) {
	var _p6 = event;
	switch (_p6.ctor) {
		case 'Sync':
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobbyAndHand(_p6._0),
				_1: {ctor: '[]'}
			};
		case 'PlayerJoin':
			var _p7 = _p6._0;
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SetNotification(
					_Lattyware$massivedecks$MassiveDecks_Models_Notification$playerJoin(_p7.id)),
				_1: {
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby(
						function (lobby) {
							return _elm_lang$core$Native_Utils.update(
								lobby,
								{
									players: A2(
										_elm_lang$core$Basics_ops['++'],
										lobby.players,
										{
											ctor: '::',
											_0: _p7,
											_1: {ctor: '[]'}
										})
								});
						}),
					_1: {ctor: '[]'}
				}
			};
		case 'PlayerStatus':
			var _p12 = _p6._1;
			var _p11 = _p6._0;
			var browserNotification = function () {
				var _p8 = _p12;
				switch (_p8.ctor) {
					case 'NotPlayed':
						return {
							ctor: '::',
							_0: A3(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationForUser,
								function (_p9) {
									return _elm_lang$core$Maybe$Just(_p11);
								},
								'You need to play a card for the round.',
								'hourglass'),
							_1: {ctor: '[]'}
						};
					case 'Skipping':
						return {
							ctor: '::',
							_0: A3(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationForUser,
								function (_p10) {
									return _elm_lang$core$Maybe$Just(_p11);
								},
								'You are being skipped due to inactivity.',
								'fast-forward'),
							_1: {ctor: '[]'}
						};
					default:
						return {ctor: '[]'};
				}
			}();
			return A2(
				_elm_lang$core$Basics_ops['++'],
				{
					ctor: '::',
					_0: A2(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updatePlayer,
						_p11,
						function (player) {
							return _elm_lang$core$Native_Utils.update(
								player,
								{status: _p12});
						}),
					_1: {ctor: '[]'}
				},
				browserNotification);
		case 'PlayerLeft':
			var _p13 = _p6._0;
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SetNotification(
					_Lattyware$massivedecks$MassiveDecks_Models_Notification$playerLeft(_p13)),
				_1: {
					ctor: '::',
					_0: A2(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updatePlayer,
						_p13,
						function (player) {
							return _elm_lang$core$Native_Utils.update(
								player,
								{left: true});
						}),
					_1: {ctor: '[]'}
				}
			};
		case 'PlayerDisconnect':
			var _p14 = _p6._0;
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SetNotification(
					_Lattyware$massivedecks$MassiveDecks_Models_Notification$playerDisconnect(_p14)),
				_1: {
					ctor: '::',
					_0: A2(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updatePlayer,
						_p14,
						function (player) {
							return _elm_lang$core$Native_Utils.update(
								player,
								{disconnected: true});
						}),
					_1: {ctor: '[]'}
				}
			};
		case 'PlayerReconnect':
			var _p15 = _p6._0;
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SetNotification(
					_Lattyware$massivedecks$MassiveDecks_Models_Notification$playerReconnect(_p15)),
				_1: {
					ctor: '::',
					_0: A2(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updatePlayer,
						_p15,
						function (player) {
							return _elm_lang$core$Native_Utils.update(
								player,
								{disconnected: false});
						}),
					_1: {ctor: '[]'}
				}
			};
		case 'PlayerScoreChange':
			return {
				ctor: '::',
				_0: A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updatePlayer,
					_p6._0,
					function (player) {
						return _elm_lang$core$Native_Utils.update(
							player,
							{score: _p6._1});
					}),
				_1: {ctor: '[]'}
			};
		case 'HandChange':
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateHand(_p6._0),
				_1: {ctor: '[]'}
			};
		case 'RoundStart':
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby(
					function (lobby) {
						return _elm_lang$core$Native_Utils.update(
							lobby,
							{
								game: _Lattyware$massivedecks$MassiveDecks_Models_Game$Playing(
									A3(
										_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$Round,
										_p6._0,
										_p6._1,
										A2(_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$playing, 0, false)))
							});
					}),
				_1: {ctor: '[]'}
			};
		case 'RoundPlayed':
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateRoundState(
					function (state) {
						return A2(
							_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$playing,
							_p6._0,
							_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$afterTimeLimit(state));
					}),
				_1: {ctor: '[]'}
			};
		case 'RoundJudging':
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateRoundState(
					function (state) {
						return A2(_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$judging, _p6._0, false);
					}),
				_1: {
					ctor: '::',
					_0: A3(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationForUser,
						function (lobby) {
							return A2(
								_elm_lang$core$Maybe$map,
								function (_) {
									return _.czar;
								},
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$lobbyRound(lobby));
						},
						'You need to pick a winner for the round.',
						'gavel'),
					_1: {ctor: '[]'}
				}
			};
		case 'RoundEnd':
			var _p16 = _p6._0;
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateRoundState(
					function (state) {
						return _Lattyware$massivedecks$MassiveDecks_Models_Game_Round$F(_p16.state);
					}),
				_1: {
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$FinishRound(_p16))),
					_1: {ctor: '[]'}
				}
			};
		case 'GameStart':
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby(
					function (lobby) {
						return _elm_lang$core$Native_Utils.update(
							lobby,
							{
								game: _Lattyware$massivedecks$MassiveDecks_Models_Game$Playing(
									A3(
										_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$Round,
										_p6._0,
										_p6._1,
										A2(_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$playing, 0, false)))
							});
					}),
				_1: {ctor: '[]'}
			};
		case 'GameEnd':
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby(
					function (lobby) {
						return _elm_lang$core$Native_Utils.update(
							lobby,
							{game: _Lattyware$massivedecks$MassiveDecks_Models_Game$Finished});
					}),
				_1: {
					ctor: '::',
					_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateHand(
						{
							hand: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			};
		case 'ConfigChange':
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby(
					function (lobby) {
						return _elm_lang$core$Native_Utils.update(
							lobby,
							{config: _p6._0});
					}),
				_1: {ctor: '[]'}
			};
		default:
			return {
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateRound(
					function (round) {
						return A2(_Lattyware$massivedecks$MassiveDecks_Models_Game_Round$setAfterTimeLimit, round, true);
					}),
				_1: {ctor: '[]'}
			};
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$view = function (model) {
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$view(model);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$webSocketResponseDecoder = function (response) {
	if (_elm_lang$core$Native_Utils.eq(response, 'identify')) {
		return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$Identify);
	} else {
		var _p17 = _Lattyware$massivedecks$MassiveDecks_Models_Event$fromJson(response);
		if (_p17.ctor === 'Ok') {
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
				_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$Batch(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$handleEvent(_p17._0)));
		} else {
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ErrorMessage(
				A2(
					_Lattyware$massivedecks$MassiveDecks_Components_Errors$New,
					A2(_elm_lang$core$Basics_ops['++'], 'Error handling notification: ', _p17._0),
					true));
		}
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$webSocketUrl = F2(
	function (url, gameCode) {
		var _p18 = function () {
			var _p19 = A2(_elm_lang$core$String$split, ':', url);
			if (_p19.ctor === '[]') {
				return {
					ctor: '_Tuple2',
					_0: 'No protocol.',
					_1: {ctor: '[]'}
				};
			} else {
				return {ctor: '_Tuple2', _0: _p19._0, _1: _p19._1};
			}
		}();
		var protocol = _p18._0;
		var rest = _p18._1;
		var host = A2(_elm_lang$core$String$join, ':', rest);
		var baseUrl = function () {
			var _p20 = protocol;
			switch (_p20) {
				case 'http':
					return A2(_elm_lang$core$Basics_ops['++'], 'ws:', host);
				case 'https':
					return A2(_elm_lang$core$Basics_ops['++'], 'wss:', host);
				default:
					var _p21 = A2(_elm_lang$core$Debug$log, 'Assuming https due to unknown protocol for URL', _p20);
					return A2(_elm_lang$core$Basics_ops['++'], 'wss:', host);
			}
		}();
		return A2(
			_elm_lang$core$Basics_ops['++'],
			baseUrl,
			A2(
				_elm_lang$core$Basics_ops['++'],
				'api/lobbies/',
				A2(_elm_lang$core$Basics_ops['++'], gameCode, '/notifications')));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$update = F2(
	function (message, model) {
		var lobby = model.lobby;
		var _p22 = message;
		switch (_p22.ctor) {
			case 'ConfigMessage':
				var _p23 = _p22._0;
				switch (_p23.ctor) {
					case 'ErrorMessage':
						return {
							ctor: '_Tuple2',
							_0: model,
							_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ErrorMessage(_p23._0))
						};
					case 'HandUpdate':
						return A2(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateLobbyAndHand,
							A2(_Lattyware$massivedecks$MassiveDecks_Models_Game$LobbyAndHand, model.lobby, _p23._0),
							model);
					default:
						var _p24 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Config$update, _p23._0, model);
						var config = _p24._0;
						var cmd = _p24._1;
						return {
							ctor: '_Tuple2',
							_0: _elm_lang$core$Native_Utils.update(
								model,
								{config: config}),
							_1: A2(
								_elm_lang$core$Platform_Cmd$map,
								function (_p25) {
									return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
										_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ConfigMessage(_p25));
								},
								cmd)
						};
				}
			case 'PlayingMessage':
				var _p26 = _p22._0;
				switch (_p26.ctor) {
					case 'ErrorMessage':
						return {
							ctor: '_Tuple2',
							_0: model,
							_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ErrorMessage(_p26._0))
						};
					case 'HandUpdate':
						return A2(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateLobbyAndHand,
							A2(_Lattyware$massivedecks$MassiveDecks_Models_Game$LobbyAndHand, model.lobby, _p26._0),
							model);
					case 'TTSMessage':
						return {
							ctor: '_Tuple2',
							_0: model,
							_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$TTSMessage(_p26._0)))
						};
					default:
						var _p27 = model.lobby.game;
						if (_p27.ctor === 'Playing') {
							var _p28 = A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$update, _p26._0, model, _p27._0);
							var playing = _p28._0;
							var cmd = _p28._1;
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Native_Utils.update(
									model,
									{playing: playing}),
								_1: A2(
									_elm_lang$core$Platform_Cmd$map,
									function (_p29) {
										return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
											_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage(_p29));
									},
									cmd)
							};
						} else {
							return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
						}
				}
			case 'SidebarMessage':
				var _p30 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Sidebar$update, _p22._0, model.sidebar);
				var sidebarModel = _p30._0;
				var cmd = _p30._1;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{sidebar: sidebarModel}),
					_1: A2(
						_elm_lang$core$Platform_Cmd$map,
						function (_p31) {
							return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SidebarMessage(_p31));
						},
						cmd)
				};
			case 'TTSMessage':
				var _p32 = A2(_Lattyware$massivedecks$MassiveDecks_Components_TTS$update, _p22._0, model.tts);
				var ttsModel = _p32._0;
				var cmd = _p32._1;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{tts: ttsModel}),
					_1: A2(
						_elm_lang$core$Platform_Cmd$map,
						function (_p33) {
							return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$TTSMessage(_p33));
						},
						cmd)
				};
			case 'BrowserNotificationsMessage':
				var _p34 = A2(_Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$update, _p22._0, model.browserNotifications);
				var browserNotifications = _p34._0;
				var localCmd = _p34._1;
				var cmd = _p34._2;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{browserNotifications: browserNotifications}),
					{
						ctor: '::',
						_0: A2(
							_elm_lang$core$Platform_Cmd$map,
							function (_p35) {
								return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationsMessage(_p35));
							},
							localCmd),
						_1: {
							ctor: '::',
							_0: A2(_elm_lang$core$Platform_Cmd$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$overlayAlert, cmd),
							_1: {ctor: '[]'}
						}
					});
			case 'BrowserNotificationForUser':
				var cmd = function () {
					var _p36 = _p22._0(lobby);
					if (_p36.ctor === 'Just') {
						return _elm_lang$core$Native_Utils.eq(_p36._0, model.secret.id) ? _Lattyware$massivedecks$MassiveDecks_Util$cmd(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationsMessage(
									_Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$notify(
										{
											title: _p22._1,
											icon: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$icon, model, _p22._2)
										})))) : _elm_lang$core$Platform_Cmd$none;
					} else {
						return _elm_lang$core$Platform_Cmd$none;
					}
				}();
				return {ctor: '_Tuple2', _0: model, _1: cmd};
			case 'UpdateLobbyAndHand':
				return A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateLobbyAndHand, _p22._0, model);
			case 'UpdateLobby':
				return A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateLobbyAndHand,
					A2(
						_Lattyware$massivedecks$MassiveDecks_Models_Game$LobbyAndHand,
						_p22._0(lobby),
						model.hand),
					model);
			case 'UpdateHand':
				return A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateLobbyAndHand,
					A2(_Lattyware$massivedecks$MassiveDecks_Models_Game$LobbyAndHand, model.lobby, _p22._0),
					model);
			case 'SetNotification':
				return A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$notificationChange,
					model,
					_p22._0(lobby.players));
			case 'Identify':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A2(
						_elm_lang$core$Platform_Cmd$map,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage,
						A2(
							_elm_lang$websocket$WebSocket$send,
							A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$webSocketUrl, model.init.url, model.lobby.gameCode),
							A2(
								_elm_lang$core$Json_Encode$encode,
								0,
								_Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerSecret(model.secret))))
				};
			case 'DisplayInviteOverlay':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{qrNeedsRendering: true}),
					{
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$OverlayMessage(
								A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$inviteOverlay, model.init.url, model.lobby.gameCode))),
						_1: {ctor: '[]'}
					});
			case 'RenderQr':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{qrNeedsRendering: false}),
					{
						ctor: '::',
						_0: A2(
							_Lattyware$massivedecks$MassiveDecks_Components_QR$encodeAndRender,
							'invite-qr-code',
							A2(_Lattyware$massivedecks$MassiveDecks_Util$lobbyUrl, model.init.url, model.lobby.gameCode)),
						_1: {ctor: '[]'}
					});
			case 'DismissNotification':
				var newModel = _elm_lang$core$Native_Utils.eq(
					model.notification,
					_elm_lang$core$Maybe$Just(_p22._0)) ? _elm_lang$core$Native_Utils.update(
					model,
					{
						notification: A2(_elm_lang$core$Maybe$map, _Lattyware$massivedecks$MassiveDecks_Models_Notification$hide, model.notification)
					}) : model;
				return {ctor: '_Tuple2', _0: newModel, _1: _elm_lang$core$Platform_Cmd$none};
			case 'Batch':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					A2(
						_elm_lang$core$List$map,
						function (_p37) {
							return _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_p37));
						},
						_p22._0));
			default:
				return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$subscriptions = function (model) {
	var render = model.qrNeedsRendering ? {
		ctor: '::',
		_0: _elm_lang$animation_frame$AnimationFrame$diffs(
			function (_p38) {
				return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$RenderQr);
			}),
		_1: {ctor: '[]'}
	} : {ctor: '[]'};
	var browserNotifications = A2(
		_elm_lang$core$Platform_Sub$map,
		_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationsMessage,
		_Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$subscriptions(model.browserNotifications));
	var websocket = A2(
		_elm_lang$websocket$WebSocket$listen,
		A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$webSocketUrl, model.init.url, model.lobby.gameCode),
		_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$webSocketResponseDecoder);
	var delegated = function () {
		var _p39 = model.lobby.game;
		switch (_p39.ctor) {
			case 'Configuring':
				return A2(
					_elm_lang$core$Platform_Sub$map,
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ConfigMessage,
					_Lattyware$massivedecks$MassiveDecks_Scenes_Config$subscriptions(model.config));
			case 'Playing':
				return A2(
					_elm_lang$core$Platform_Sub$map,
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage,
					_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$subscriptions(model.playing));
			default:
				return _elm_lang$core$Platform_Sub$none;
		}
	}();
	return _elm_lang$core$Platform_Sub$batch(
		A2(
			_elm_lang$core$Basics_ops['++'],
			{
				ctor: '::',
				_0: A2(_elm_lang$core$Platform_Sub$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage, delegated),
				_1: {
					ctor: '::',
					_0: websocket,
					_1: {
						ctor: '::',
						_0: A2(_elm_lang$core$Platform_Sub$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage, browserNotifications),
						_1: {ctor: '[]'}
					}
				}
			},
			render));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$init = F3(
	function (init, lobbyAndHand, secret) {
		var _p40 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Config$init, lobbyAndHand.lobby, secret);
		var config = _p40._0;
		var configCmd = _p40._1;
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			{
				lobby: lobbyAndHand.lobby,
				hand: lobbyAndHand.hand,
				config: config,
				playing: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$init(init),
				browserNotifications: A2(_Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$init, init.browserNotificationsSupported, false),
				secret: secret,
				init: init,
				notification: _elm_lang$core$Maybe$Nothing,
				qrNeedsRendering: false,
				sidebar: _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Sidebar$init(768),
				tts: _Lattyware$massivedecks$MassiveDecks_Components_TTS$init
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$core$Platform_Cmd$map,
					function (_p41) {
						return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ConfigMessage(_p41));
					},
					configCmd),
				_1: {ctor: '[]'}
			});
	});

var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$getLobbyAndHandErrorHandler = F2(
	function (gameCodeAndSecret, error) {
		var errorMessage = function () {
			var _p0 = error;
			if (_p0.ctor === 'LobbyNotFound') {
				return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ClearExistingGame(gameCodeAndSecret);
			} else {
				return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ClearExistingGame(gameCodeAndSecret);
			}
		}();
		return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Batch(
			{
				ctor: '::',
				_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$SetButtonsEnabled(true),
				_1: {
					ctor: '::',
					_0: errorMessage,
					_1: {ctor: '[]'}
				}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$newPlayerErrorHandler = function (error) {
	var errorMessage = function () {
		var _p1 = error;
		switch (_p1.ctor) {
			case 'NameInUse':
				return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$InputMessage(
					{
						ctor: '_Tuple2',
						_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Name,
						_1: _Lattyware$massivedecks$MassiveDecks_Components_Input$Error(
							_elm_lang$core$Maybe$Just('This name is already in use in this game, try something else.'))
					});
			case 'PasswordWrong':
				return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Batch(
					{
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$SetPasswordRequired,
						_1: {
							ctor: '::',
							_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$InputMessage(
								{
									ctor: '_Tuple2',
									_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Password,
									_1: _Lattyware$massivedecks$MassiveDecks_Components_Input$Error(
										_elm_lang$core$Maybe$Just('This game requires a password, please check you have the right one.'))
								}),
							_1: {ctor: '[]'}
						}
					});
			default:
				return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$InputMessage(
					{
						ctor: '_Tuple2',
						_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$GameCode,
						_1: _Lattyware$massivedecks$MassiveDecks_Components_Input$Error(
							_elm_lang$core$Maybe$Just('This game doesn\'t exist - check you have the right code.'))
					});
		}
	}();
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Batch(
		{
			ctor: '::',
			_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$SetButtonsEnabled(true),
			_1: {
				ctor: '::',
				_0: errorMessage,
				_1: {ctor: '[]'}
			}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$title = 'Massive Decks';
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$urlUpdate = F2(
	function (path, model) {
		var setInput = A2(
			_elm_lang$core$Maybe$map,
			function (gameCode) {
				return _Lattyware$massivedecks$MassiveDecks_Util$cmd(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$InputMessage(
						{
							ctor: '_Tuple2',
							_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$GameCode,
							_1: _Lattyware$massivedecks$MassiveDecks_Components_Input$SetDefaultValue(gameCode)
						}));
			},
			path.gameCode);
		var noGameCode = function () {
			var _p2 = path.gameCode;
			if (_p2.ctor === 'Just') {
				return false;
			} else {
				return true;
			}
		}();
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			_elm_lang$core$Native_Utils.update(
				model,
				{
					path: path,
					lobby: noGameCode ? _elm_lang$core$Maybe$Nothing : model.lobby,
					buttonsEnabled: true
				}),
			{
				ctor: '::',
				_0: noGameCode ? _elm_lang$core$Platform_Cmd$none : _Lattyware$massivedecks$MassiveDecks_Util$cmd(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$TabsMessage(
						_Lattyware$massivedecks$MassiveDecks_Components_Tabs$SetTab(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Join))),
				_1: {
					ctor: '::',
					_0: A2(_elm_lang$core$Maybe$withDefault, _elm_lang$core$Platform_Cmd$none, setInput),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$core$Maybe$withDefault,
							_Lattyware$massivedecks$MassiveDecks_Components_Title$set(_Lattyware$massivedecks$MassiveDecks_Scenes_Start$title),
							A2(
								_elm_lang$core$Maybe$map,
								function (gc) {
									return _Lattyware$massivedecks$MassiveDecks_Components_Title$set(
										A2(
											_elm_lang$core$Basics_ops['++'],
											'Game ',
											A2(
												_elm_lang$core$Basics_ops['++'],
												gc,
												A2(_elm_lang$core$Basics_ops['++'], ' - ', _Lattyware$massivedecks$MassiveDecks_Scenes_Start$title))));
								},
								path.gameCode)),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$core$Maybe$withDefault,
								_elm_lang$core$Platform_Cmd$none,
								A2(
									_elm_lang$core$Maybe$map,
									function (_p3) {
										return _Lattyware$massivedecks$MassiveDecks_Util$cmd(
											_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$TryExistingGame(_p3));
									},
									path.gameCode)),
							_1: {ctor: '[]'}
						}
					}
				}
			});
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$update = F2(
	function (message, model) {
		var _p4 = message;
		switch (_p4.ctor) {
			case 'ErrorMessage':
				var _p5 = A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$update, _p4._0, model.errors);
				var newErrors = _p5._0;
				var cmd = _p5._1;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{errors: newErrors}),
					_1: A2(_elm_lang$core$Platform_Cmd$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage, cmd)
				};
			case 'PathChange':
				return A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Start$urlUpdate, _p4._0, model);
			case 'TabsMessage':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							tabs: A2(_Lattyware$massivedecks$MassiveDecks_Components_Tabs$update, _p4._0, model.tabs)
						}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'ClearExistingGame':
				var _p6 = _p4._0;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{
							storage: A2(_Lattyware$massivedecks$MassiveDecks_Components_Storage$leave, _p6, model.storage)
						}),
					{
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$OverlayMessage(
								_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Show(
									A3(
										_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Overlay,
										'info-circle',
										'Game over.',
										{
											ctor: '::',
											_0: _elm_lang$html$Html$text(
												A2(
													_elm_lang$core$Basics_ops['++'],
													'The game ',
													A2(_elm_lang$core$Basics_ops['++'], _p6.gameCode, ' has ended.'))),
											_1: {ctor: '[]'}
										})))),
						_1: {
							ctor: '::',
							_0: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$StorageMessage(_Lattyware$massivedecks$MassiveDecks_Components_Storage$Store)),
							_1: {
								ctor: '::',
								_0: _elm_lang$navigation$Navigation$newUrl(model.init.url),
								_1: {ctor: '[]'}
							}
						}
					});
			case 'TryExistingGame':
				var existing = _elm_lang$core$List$head(
					A2(
						_elm_lang$core$List$filter,
						function (_p7) {
							return A2(
								F2(
									function (x, y) {
										return _elm_lang$core$Native_Utils.eq(x, y);
									}),
								_p4._0,
								function (_) {
									return _.gameCode;
								}(_p7));
						},
						model.storage));
				var cmd = A2(
					_elm_lang$core$Maybe$withDefault,
					_elm_lang$navigation$Navigation$modifyUrl(model.init.url),
					A2(
						_elm_lang$core$Maybe$map,
						function (existing) {
							return _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsExistingPlayer, existing.secret, existing.gameCode));
						},
						existing));
				return {ctor: '_Tuple2', _0: model, _1: cmd};
			case 'CreateLobby':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{buttonsEnabled: false}),
					_1: A3(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send_,
						_Lattyware$massivedecks$MassiveDecks_API$createLobby(model.nameInput.value),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage,
						function (gameCodeAndSecret) {
							return A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$StoreCredentialsAndMoveToLobby, gameCodeAndSecret.gameCode, gameCodeAndSecret.secret);
						})
				};
			case 'SubmitCurrentTab':
				var _p8 = model.tabs.current;
				if (_p8.ctor === 'Create') {
					return {
						ctor: '_Tuple2',
						_0: model,
						_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$CreateLobby)
					};
				} else {
					return {
						ctor: '_Tuple2',
						_0: model,
						_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsNewPlayer)
					};
				}
			case 'SetButtonsEnabled':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{buttonsEnabled: _p4._0}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'SetPasswordRequired':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							passwordRequired: _elm_lang$core$Maybe$Just(model.gameCodeInput.value)
						}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'JoinLobbyAsNewPlayer':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{buttonsEnabled: false}),
					_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinGivenLobbyAsNewPlayer(model.gameCodeInput.value))
				};
			case 'JoinGivenLobbyAsNewPlayer':
				var _p11 = _p4._0;
				var _p10 = _elm_lang$core$List$head(
					A2(
						_elm_lang$core$List$filter,
						function (_p9) {
							return A2(
								F2(
									function (x, y) {
										return _elm_lang$core$Native_Utils.eq(x, y);
									}),
								_p11,
								function (_) {
									return _.gameCode;
								}(_p9));
						},
						model.storage));
				if (_p10.ctor === 'Nothing') {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						model,
						{
							ctor: '::',
							_0: A4(
								_Lattyware$massivedecks$MassiveDecks_API_Request$send,
								A3(_Lattyware$massivedecks$MassiveDecks_API$newPlayer, _p11, model.nameInput.value, model.passwordInput.value),
								_Lattyware$massivedecks$MassiveDecks_Scenes_Start$newPlayerErrorHandler,
								_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage,
								_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$StoreCredentialsAndMoveToLobby(_p11)),
							_1: {ctor: '[]'}
						});
				} else {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						model,
						{
							ctor: '::',
							_0: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$MoveToLobby(_p11)),
							_1: {
								ctor: '::',
								_0: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$OverlayMessage(
										_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Show(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$alreadyInGameOverlay))),
								_1: {ctor: '[]'}
							}
						});
				}
			case 'StoreCredentialsAndMoveToLobby':
				var _p12 = _p4._0;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{
							storage: A2(
								_Lattyware$massivedecks$MassiveDecks_Components_Storage$join,
								A2(_Lattyware$massivedecks$MassiveDecks_Models_Game$GameCodeAndSecret, _p12, _p4._1),
								model.storage)
						}),
					{
						ctor: '::',
						_0: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$StorageMessage(_Lattyware$massivedecks$MassiveDecks_Components_Storage$Store)),
						_1: {
							ctor: '::',
							_0: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$MoveToLobby(_p12)),
							_1: {ctor: '[]'}
						}
					});
			case 'MoveToLobby':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{
						ctor: '::',
						_0: _elm_lang$navigation$Navigation$newUrl(
							A2(
								_elm_lang$core$Basics_ops['++'],
								model.init.url,
								A2(_elm_lang$core$Basics_ops['++'], '#', _p4._0))),
						_1: {ctor: '[]'}
					});
			case 'JoinLobbyAsExistingPlayer':
				var _p14 = _p4._0;
				var _p13 = _p4._1;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{
						ctor: '::',
						_0: A4(
							_Lattyware$massivedecks$MassiveDecks_API_Request$send,
							A2(_Lattyware$massivedecks$MassiveDecks_API$getLobbyAndHand, _p13, _p14),
							_Lattyware$massivedecks$MassiveDecks_Scenes_Start$getLobbyAndHandErrorHandler(
								A2(_Lattyware$massivedecks$MassiveDecks_Models_Game$GameCodeAndSecret, _p13, _p14)),
							_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage,
							_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobby(_p14)),
						_1: {ctor: '[]'}
					});
			case 'JoinLobby':
				var _p15 = A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$init, model.init, _p4._1, _p4._0);
				var lobby = _p15._0;
				var cmd = _p15._1;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{
							lobby: _elm_lang$core$Maybe$Just(lobby)
						}),
					{
						ctor: '::',
						_0: A2(_elm_lang$core$Platform_Cmd$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$LobbyMessage, cmd),
						_1: {ctor: '[]'}
					});
			case 'InputMessage':
				var _p19 = _p4._0;
				var _p16 = A2(_Lattyware$massivedecks$MassiveDecks_Components_Input$update, _p19, model.passwordInput);
				var passwordInput = _p16._0;
				var passwordCmd = _p16._1;
				var _p17 = A2(_Lattyware$massivedecks$MassiveDecks_Components_Input$update, _p19, model.gameCodeInput);
				var gameCodeInput = _p17._0;
				var gameCodeCmd = _p17._1;
				var _p18 = A2(_Lattyware$massivedecks$MassiveDecks_Components_Input$update, _p19, model.nameInput);
				var nameInput = _p18._0;
				var nameCmd = _p18._1;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{nameInput: nameInput, gameCodeInput: gameCodeInput, passwordInput: passwordInput}),
					_1: _elm_lang$core$Platform_Cmd$batch(
						{
							ctor: '::',
							_0: nameCmd,
							_1: {
								ctor: '::',
								_0: gameCodeCmd,
								_1: {
									ctor: '::',
									_0: passwordCmd,
									_1: {ctor: '[]'}
								}
							}
						})
				};
			case 'OverlayMessage':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							overlay: A2(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$update, _p4._0, model.overlay)
						}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'StorageMessage':
				var _p20 = A2(_Lattyware$massivedecks$MassiveDecks_Components_Storage$update, _p4._0, model.storage);
				var storageModel = _p20._0;
				var cmd = _p20._1;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{storage: storageModel}),
					_1: A2(_elm_lang$core$Platform_Cmd$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$StorageMessage, cmd)
				};
			case 'LobbyMessage':
				var _p21 = _p4._0;
				switch (_p21.ctor) {
					case 'ErrorMessage':
						return {
							ctor: '_Tuple2',
							_0: model,
							_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage(_p21._0))
						};
					case 'OverlayMessage':
						return {
							ctor: '_Tuple2',
							_0: model,
							_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$OverlayMessage(
									A2(
										_Lattyware$massivedecks$MassiveDecks_Components_Overlay$map,
										function (_p22) {
											return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$LobbyMessage(
												_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_p22));
										},
										_p21._0)))
						};
					case 'Leave':
						var _p23 = function () {
							var _p24 = model.lobby;
							if (_p24.ctor === 'Nothing') {
								return {
									ctor: '_Tuple2',
									_0: {ctor: '[]'},
									_1: model.storage
								};
							} else {
								var _p26 = _p24._0;
								return {
									ctor: '_Tuple2',
									_0: {
										ctor: '::',
										_0: A3(
											_Lattyware$massivedecks$MassiveDecks_API_Request$send_,
											A2(_Lattyware$massivedecks$MassiveDecks_API$leave, _p26.lobby.gameCode, _p26.secret),
											_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage,
											function (_p25) {
												return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$NoOp;
											}),
										_1: {
											ctor: '::',
											_0: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
												_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$StorageMessage(_Lattyware$massivedecks$MassiveDecks_Components_Storage$Store)),
											_1: {ctor: '[]'}
										}
									},
									_1: A2(
										_Lattyware$massivedecks$MassiveDecks_Components_Storage$leave,
										A2(_Lattyware$massivedecks$MassiveDecks_Models_Game$GameCodeAndSecret, _p26.lobby.gameCode, _p26.secret),
										model.storage)
								};
							}
						}();
						var leave = _p23._0;
						var storage = _p23._1;
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								model,
								{lobby: _elm_lang$core$Maybe$Nothing, buttonsEnabled: true, storage: storage}),
							A2(
								_elm_lang$core$Basics_ops['++'],
								{
									ctor: '::',
									_0: _elm_lang$navigation$Navigation$newUrl(model.init.url),
									_1: {ctor: '[]'}
								},
								leave));
					default:
						var _p27 = model.lobby;
						if (_p27.ctor === 'Nothing') {
							return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
						} else {
							var _p28 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$update, _p21._0, _p27._0);
							var newLobby = _p28._0;
							var cmd = _p28._1;
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Native_Utils.update(
									model,
									{
										lobby: _elm_lang$core$Maybe$Just(newLobby)
									}),
								_1: A2(_elm_lang$core$Platform_Cmd$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$LobbyMessage, cmd)
							};
						}
				}
			case 'Batch':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: _elm_lang$core$Platform_Cmd$batch(
						A2(_elm_lang$core$List$map, _Lattyware$massivedecks$MassiveDecks_Util$cmd, _p4._0))
				};
			default:
				return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$view = function (model) {
	var contents = function () {
		var _p29 = model.lobby;
		if (_p29.ctor === 'Nothing') {
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$view(model);
		} else {
			return A2(
				_elm_lang$html$Html$map,
				_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$LobbyMessage,
				_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$view(_p29._0));
		}
	}();
	return A2(
		_elm_lang$html$Html$div,
		{ctor: '[]'},
		A2(
			_elm_lang$core$Basics_ops['++'],
			{
				ctor: '::',
				_0: contents,
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$map,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage,
						A2(
							_Lattyware$massivedecks$MassiveDecks_Components_Errors$view,
							{url: model.init.url, version: model.init.version},
							model.errors)),
					_1: {ctor: '[]'}
				}
			},
			_Lattyware$massivedecks$MassiveDecks_Components_Overlay$view(model.overlay)));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$subscriptions = function (model) {
	var _p30 = model.lobby;
	if (_p30.ctor === 'Nothing') {
		return _elm_lang$core$Platform_Sub$none;
	} else {
		return A2(
			_elm_lang$core$Platform_Sub$map,
			_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$LobbyMessage,
			_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$subscriptions(_p30._0));
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$init = F2(
	function (init, location) {
		var path = _Lattyware$massivedecks$MassiveDecks_Models$pathFromLocation(location);
		var tab = _elm_lang$core$String$isEmpty(
			A2(_elm_lang$core$Maybe$withDefault, '', path.gameCode)) ? _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Create : _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Join;
		return {
			ctor: '_Tuple2',
			_0: {
				lobby: _elm_lang$core$Maybe$Nothing,
				init: init,
				path: path,
				nameInput: A7(
					_Lattyware$massivedecks$MassiveDecks_Components_Input$init,
					_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Name,
					'name-input',
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('Your name in the game.'),
						_1: {ctor: '[]'}
					},
					'',
					'Nickname',
					_Lattyware$massivedecks$MassiveDecks_Util$cmd(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$SubmitCurrentTab),
					_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$InputMessage),
				gameCodeInput: A7(
					_Lattyware$massivedecks$MassiveDecks_Components_Input$init,
					_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$GameCode,
					'game-code-input',
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('The code for the game to join.'),
						_1: {ctor: '[]'}
					},
					A2(_elm_lang$core$Maybe$withDefault, '', path.gameCode),
					'',
					_Lattyware$massivedecks$MassiveDecks_Util$cmd(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsNewPlayer),
					_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$InputMessage),
				passwordInput: A7(
					_Lattyware$massivedecks$MassiveDecks_Components_Input$init,
					_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Password,
					'password-input',
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('The password for the game to join.'),
						_1: {ctor: '[]'}
					},
					'',
					'Password',
					_Lattyware$massivedecks$MassiveDecks_Util$cmd(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsNewPlayer),
					_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$InputMessage),
				passwordRequired: _elm_lang$core$Maybe$Nothing,
				errors: _Lattyware$massivedecks$MassiveDecks_Components_Errors$init,
				overlay: _Lattyware$massivedecks$MassiveDecks_Components_Overlay$init(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$OverlayMessage),
				buttonsEnabled: true,
				tabs: A3(
					_Lattyware$massivedecks$MassiveDecks_Components_Tabs$init,
					{
						ctor: '::',
						_0: A2(
							_Lattyware$massivedecks$MassiveDecks_Components_Tabs$Tab,
							_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Create,
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text('Create'),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: A2(
								_Lattyware$massivedecks$MassiveDecks_Components_Tabs$Tab,
								_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Join,
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('Join'),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}
					},
					tab,
					_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$TabsMessage),
				storage: init.existingGames
			},
			_1: A2(
				_elm_lang$core$Maybe$withDefault,
				_elm_lang$core$Platform_Cmd$none,
				A2(
					_elm_lang$core$Maybe$map,
					function (_p31) {
						return _Lattyware$massivedecks$MassiveDecks_Util$cmd(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$TryExistingGame(_p31));
					},
					path.gameCode))
		};
	});

var _Lattyware$massivedecks$MassiveDecks$locationToMessage = function (location) {
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$PathChange(
		_Lattyware$massivedecks$MassiveDecks_Models$pathFromLocation(location));
};
var _Lattyware$massivedecks$MassiveDecks$main = A2(
	_elm_lang$navigation$Navigation$programWithFlags,
	_Lattyware$massivedecks$MassiveDecks$locationToMessage,
	{init: _Lattyware$massivedecks$MassiveDecks_Scenes_Start$init, update: _Lattyware$massivedecks$MassiveDecks_Scenes_Start$update, subscriptions: _Lattyware$massivedecks$MassiveDecks_Scenes_Start$subscriptions, view: _Lattyware$massivedecks$MassiveDecks_Scenes_Start$view})(
	A2(
		_elm_lang$core$Json_Decode$andThen,
		function (browserNotificationsSupported) {
			return A2(
				_elm_lang$core$Json_Decode$andThen,
				function (existingGames) {
					return A2(
						_elm_lang$core$Json_Decode$andThen,
						function (seed) {
							return A2(
								_elm_lang$core$Json_Decode$andThen,
								function (url) {
									return A2(
										_elm_lang$core$Json_Decode$andThen,
										function (version) {
											return _elm_lang$core$Json_Decode$succeed(
												{browserNotificationsSupported: browserNotificationsSupported, existingGames: existingGames, seed: seed, url: url, version: version});
										},
										A2(_elm_lang$core$Json_Decode$field, 'version', _elm_lang$core$Json_Decode$string));
								},
								A2(_elm_lang$core$Json_Decode$field, 'url', _elm_lang$core$Json_Decode$string));
						},
						A2(_elm_lang$core$Json_Decode$field, 'seed', _elm_lang$core$Json_Decode$string));
				},
				A2(
					_elm_lang$core$Json_Decode$field,
					'existingGames',
					_elm_lang$core$Json_Decode$list(
						A2(
							_elm_lang$core$Json_Decode$andThen,
							function (gameCode) {
								return A2(
									_elm_lang$core$Json_Decode$andThen,
									function (secret) {
										return _elm_lang$core$Json_Decode$succeed(
											{gameCode: gameCode, secret: secret});
									},
									A2(
										_elm_lang$core$Json_Decode$field,
										'secret',
										A2(
											_elm_lang$core$Json_Decode$andThen,
											function (id) {
												return A2(
													_elm_lang$core$Json_Decode$andThen,
													function (secret) {
														return _elm_lang$core$Json_Decode$succeed(
															{id: id, secret: secret});
													},
													A2(_elm_lang$core$Json_Decode$field, 'secret', _elm_lang$core$Json_Decode$string));
											},
											A2(_elm_lang$core$Json_Decode$field, 'id', _elm_lang$core$Json_Decode$int))));
							},
							A2(_elm_lang$core$Json_Decode$field, 'gameCode', _elm_lang$core$Json_Decode$string)))));
		},
		A2(_elm_lang$core$Json_Decode$field, 'browserNotificationsSupported', _elm_lang$core$Json_Decode$bool)));

var Elm = {};
Elm['MassiveDecks'] = Elm['MassiveDecks'] || {};
if (typeof _Lattyware$massivedecks$MassiveDecks$main !== 'undefined') {
    _Lattyware$massivedecks$MassiveDecks$main(Elm['MassiveDecks'], 'MassiveDecks', undefined);
}

if (typeof define === "function" && define['amd'])
{
  define([], function() { return Elm; });
  return;
}

if (typeof module === "object")
{
  module['exports'] = Elm;
  return;
}

var globalElm = this['Elm'];
if (typeof globalElm === "undefined")
{
  this['Elm'] = Elm;
  return;
}

for (var publicModule in Elm)
{
  if (publicModule in globalElm)
  {
    throw new Error('There are two Elm modules called `' + publicModule + '` on this page! Rename one of them.');
  }
  globalElm[publicModule] = Elm[publicModule];
}

}).call(this);

