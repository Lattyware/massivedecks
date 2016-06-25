
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

function eq(rootX, rootY)
{
	var stack = [{ x: rootX, y: rootY }];
	while (stack.length > 0)
	{
		var front = stack.pop();
		var x = front.x;
		var y = front.y;
		if (x === y)
		{
			continue;
		}
		if (typeof x === 'object')
		{
			var c = 0;
			for (var key in x)
			{
				++c;
				if (!(key in y))
				{
					return false;
				}
				if (key === 'ctor')
				{
					continue;
				}
				stack.push({ x: x[key], y: y[key] });
			}
			if ('ctor' in x)
			{
				stack.push({ x: x.ctor, y: y.ctor});
			}
			if (c !== Object.keys(y).length)
			{
				return false;
			}
		}
		else if (typeof x === 'function')
		{
			throw new Error('Equality error: general function equality is ' +
							'undecidable, and therefore, unsupported');
		}
		else
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
	var ord;
	if (typeof x !== 'object')
	{
		return x === y ? EQ : x < y ? LT : GT;
	}
	else if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b
			? EQ
			: a < b
				? LT
				: GT;
	}
	else if (x.ctor === '::' || x.ctor === '[]')
	{
		while (true)
		{
			if (x.ctor === '[]' && y.ctor === '[]')
			{
				return EQ;
			}
			if (x.ctor !== y.ctor)
			{
				return x.ctor === '[]' ? LT : GT;
			}
			ord = cmp(x._0, y._0);
			if (ord !== EQ)
			{
				return ord;
			}
			x = x._1;
			y = y._1;
		}
	}
	else if (x.ctor.slice(0, 6) === '_Tuple')
	{
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
	else
	{
		throw new Error('Comparison error: comparison is only defined on ints, ' +
						'floats, times, chars, strings, lists of comparable values, ' +
						'and tuples of comparable values.');
	}
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
		var value = (key in updatedFields) ? updatedFields[key] : oldRecord[key];
		newRecord[key] = value;
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
		var name = v.func ? v.func.name : v.name;
		return '<function' + (name === '' ? '' : ':') + name + '>';
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

		if (v.ctor === 'RBNode_elm_builtin' || v.ctor === 'RBEmpty_elm_builtin' || v.ctor === 'Set_elm_builtin')
		{
			var name, list;
			if (v.ctor === 'Set_elm_builtin')
			{
				name = 'Set';
				list = A2(
					_elm_lang$core$List$map,
					function(x) {return x._0; },
					_elm_lang$core$Dict$toList(v._0)
				);
			}
			else
			{
				name = 'Dict';
				list = _elm_lang$core$Dict$toList(v);
			}
			return name + '.fromList ' + toString(list);
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
var _elm_lang$core$Basics$uncurry = F2(
	function (f, _p0) {
		var _p1 = _p0;
		return A2(f, _p1._0, _p1._1);
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
var _elm_lang$core$Basics$snd = function (_p2) {
	var _p3 = _p2;
	return _p3._1;
};
var _elm_lang$core$Basics$fst = function (_p4) {
	var _p5 = _p4;
	return _p5._0;
};
var _elm_lang$core$Basics$always = F2(
	function (a, _p6) {
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
var _elm_lang$core$Basics$Never = function (a) {
	return {ctor: 'Never', _0: a};
};

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
var _elm_lang$core$Debug$crash = _elm_lang$core$Native_Debug.crash;
var _elm_lang$core$Debug$log = _elm_lang$core$Native_Debug.log;

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
var _elm_lang$core$Maybe$oneOf = function (maybes) {
	oneOf:
	while (true) {
		var _p1 = maybes;
		if (_p1.ctor === '[]') {
			return _elm_lang$core$Maybe$Nothing;
		} else {
			var _p3 = _p1._0;
			var _p2 = _p3;
			if (_p2.ctor === 'Nothing') {
				var _v3 = _p1._1;
				maybes = _v3;
				continue oneOf;
			} else {
				return _p3;
			}
		}
	}
};
var _elm_lang$core$Maybe$andThen = F2(
	function (maybeValue, callback) {
		var _p4 = maybeValue;
		if (_p4.ctor === 'Just') {
			return callback(_p4._0);
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$Just = function (a) {
	return {ctor: 'Just', _0: a};
};
var _elm_lang$core$Maybe$map = F2(
	function (f, maybe) {
		var _p5 = maybe;
		if (_p5.ctor === 'Just') {
			return _elm_lang$core$Maybe$Just(
				f(_p5._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map2 = F3(
	function (func, ma, mb) {
		var _p6 = {ctor: '_Tuple2', _0: ma, _1: mb};
		if (((_p6.ctor === '_Tuple2') && (_p6._0.ctor === 'Just')) && (_p6._1.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A2(func, _p6._0._0, _p6._1._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map3 = F4(
	function (func, ma, mb, mc) {
		var _p7 = {ctor: '_Tuple3', _0: ma, _1: mb, _2: mc};
		if ((((_p7.ctor === '_Tuple3') && (_p7._0.ctor === 'Just')) && (_p7._1.ctor === 'Just')) && (_p7._2.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A3(func, _p7._0._0, _p7._1._0, _p7._2._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map4 = F5(
	function (func, ma, mb, mc, md) {
		var _p8 = {ctor: '_Tuple4', _0: ma, _1: mb, _2: mc, _3: md};
		if (((((_p8.ctor === '_Tuple4') && (_p8._0.ctor === 'Just')) && (_p8._1.ctor === 'Just')) && (_p8._2.ctor === 'Just')) && (_p8._3.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A4(func, _p8._0._0, _p8._1._0, _p8._2._0, _p8._3._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map5 = F6(
	function (func, ma, mb, mc, md, me) {
		var _p9 = {ctor: '_Tuple5', _0: ma, _1: mb, _2: mc, _3: md, _4: me};
		if ((((((_p9.ctor === '_Tuple5') && (_p9._0.ctor === 'Just')) && (_p9._1.ctor === 'Just')) && (_p9._2.ctor === 'Just')) && (_p9._3.ctor === 'Just')) && (_p9._4.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A5(func, _p9._0._0, _p9._1._0, _p9._2._0, _p9._3._0, _p9._4._0));
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


function range(lo, hi)
{
	var list = Nil;
	if (lo <= hi)
	{
		do
		{
			list = Cons(hi, list);
		}
		while (hi-- > lo);
	}
	return list;
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
	range: range,

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
		return _elm_lang$core$Basics$not(
			A2(
				_elm_lang$core$List$any,
				function (_p2) {
					return _elm_lang$core$Basics$not(
						isOkay(_p2));
				},
				list));
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
var _elm_lang$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$map2,
			f,
			_elm_lang$core$Native_List.range(
				0,
				_elm_lang$core$List$length(xs) - 1),
			xs);
	});
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
					return A2(
						_elm_lang$core$List_ops['::'],
						f(x),
						acc);
				}),
			_elm_lang$core$Native_List.fromArray(
				[]),
			xs);
	});
var _elm_lang$core$List$filter = F2(
	function (pred, xs) {
		var conditionalCons = F2(
			function (x, xs$) {
				return pred(x) ? A2(_elm_lang$core$List_ops['::'], x, xs$) : xs$;
			});
		return A3(
			_elm_lang$core$List$foldr,
			conditionalCons,
			_elm_lang$core$Native_List.fromArray(
				[]),
			xs);
	});
var _elm_lang$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _p10 = f(mx);
		if (_p10.ctor === 'Just') {
			return A2(_elm_lang$core$List_ops['::'], _p10._0, xs);
		} else {
			return xs;
		}
	});
var _elm_lang$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$foldr,
			_elm_lang$core$List$maybeCons(f),
			_elm_lang$core$Native_List.fromArray(
				[]),
			xs);
	});
var _elm_lang$core$List$reverse = function (list) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return A2(_elm_lang$core$List_ops['::'], x, y);
			}),
		_elm_lang$core$Native_List.fromArray(
			[]),
		list);
};
var _elm_lang$core$List$scanl = F3(
	function (f, b, xs) {
		var scan1 = F2(
			function (x, accAcc) {
				var _p11 = accAcc;
				if (_p11.ctor === '::') {
					return A2(
						_elm_lang$core$List_ops['::'],
						A2(f, x, _p11._0),
						accAcc);
				} else {
					return _elm_lang$core$Native_List.fromArray(
						[]);
				}
			});
		return _elm_lang$core$List$reverse(
			A3(
				_elm_lang$core$List$foldl,
				scan1,
				_elm_lang$core$Native_List.fromArray(
					[b]),
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
						return A2(_elm_lang$core$List_ops['::'], x, y);
					}),
				ys,
				xs);
		}
	});
var _elm_lang$core$List$concat = function (lists) {
	return A3(
		_elm_lang$core$List$foldr,
		_elm_lang$core$List$append,
		_elm_lang$core$Native_List.fromArray(
			[]),
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
					_0: A2(_elm_lang$core$List_ops['::'], x, _p16),
					_1: _p15
				} : {
					ctor: '_Tuple2',
					_0: _p16,
					_1: A2(_elm_lang$core$List_ops['::'], x, _p15)
				};
			});
		return A3(
			_elm_lang$core$List$foldr,
			step,
			{
				ctor: '_Tuple2',
				_0: _elm_lang$core$Native_List.fromArray(
					[]),
				_1: _elm_lang$core$Native_List.fromArray(
					[])
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
				_0: A2(_elm_lang$core$List_ops['::'], _p19._0, _p20._0),
				_1: A2(_elm_lang$core$List_ops['::'], _p19._1, _p20._1)
			};
		});
	return A3(
		_elm_lang$core$List$foldr,
		step,
		{
			ctor: '_Tuple2',
			_0: _elm_lang$core$Native_List.fromArray(
				[]),
			_1: _elm_lang$core$Native_List.fromArray(
				[])
		},
		pairs);
};
var _elm_lang$core$List$intersperse = F2(
	function (sep, xs) {
		var _p21 = xs;
		if (_p21.ctor === '[]') {
			return _elm_lang$core$Native_List.fromArray(
				[]);
		} else {
			var step = F2(
				function (x, rest) {
					return A2(
						_elm_lang$core$List_ops['::'],
						sep,
						A2(_elm_lang$core$List_ops['::'], x, rest));
				});
			var spersed = A3(
				_elm_lang$core$List$foldr,
				step,
				_elm_lang$core$Native_List.fromArray(
					[]),
				_p21._1);
			return A2(_elm_lang$core$List_ops['::'], _p21._0, spersed);
		}
	});
var _elm_lang$core$List$take = F2(
	function (n, list) {
		if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
			return _elm_lang$core$Native_List.fromArray(
				[]);
		} else {
			var _p22 = list;
			if (_p22.ctor === '[]') {
				return list;
			} else {
				return A2(
					_elm_lang$core$List_ops['::'],
					_p22._0,
					A2(_elm_lang$core$List$take, n - 1, _p22._1));
			}
		}
	});
var _elm_lang$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return result;
			} else {
				var _v23 = A2(_elm_lang$core$List_ops['::'], value, result),
					_v24 = n - 1,
					_v25 = value;
				result = _v23;
				n = _v24;
				value = _v25;
				continue repeatHelp;
			}
		}
	});
var _elm_lang$core$List$repeat = F2(
	function (n, value) {
		return A3(
			_elm_lang$core$List$repeatHelp,
			_elm_lang$core$Native_List.fromArray(
				[]),
			n,
			value);
	});

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
	function (result, callback) {
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
var _elm_lang$core$Result$formatError = F2(
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

//import //

var _elm_lang$core$Native_Platform = function() {


// PROGRAMS

function addPublicModule(object, name, main)
{
	var init = main ? makeEmbed(name, main) : mainIsUndefined(name);

	object['worker'] = function worker(flags)
	{
		return init(undefined, flags, false);
	}

	object['embed'] = function embed(domNode, flags)
	{
		return init(domNode, flags, true);
	}

	object['fullscreen'] = function fullscreen(flags)
	{
		return init(document.body, flags, true);
	};
}


// PROGRAM FAIL

function mainIsUndefined(name)
{
	return function(domNode)
	{
		var message = 'Cannot initialize module `' + name +
			'` because it has no `main` value!\nWhat should I show on screen?';
		domNode.innerHTML = errorHtml(message);
		throw new Error(message);
	};
}

function errorHtml(message)
{
	return '<div style="padding-left:1em;">'
		+ '<h2 style="font-weight:normal;"><b>Oops!</b> Something went wrong when starting your Elm program.</h2>'
		+ '<pre style="padding-left:1em;">' + message + '</pre>'
		+ '</div>';
}


// PROGRAM SUCCESS

function makeEmbed(moduleName, main)
{
	return function embed(rootDomNode, flags, withRenderer)
	{
		try
		{
			var program = mainToProgram(moduleName, main);
			if (!withRenderer)
			{
				program.renderer = dummyRenderer;
			}
			return makeEmbedHelp(moduleName, program, rootDomNode, flags);
		}
		catch (e)
		{
			rootDomNode.innerHTML = errorHtml(e.message);
			throw e;
		}
	};
}

function dummyRenderer()
{
	return { update: function() {} };
}


// MAIN TO PROGRAM

function mainToProgram(moduleName, wrappedMain)
{
	var main = wrappedMain.main;

	if (typeof main.init === 'undefined')
	{
		var emptyBag = batch(_elm_lang$core$Native_List.Nil);
		var noChange = _elm_lang$core$Native_Utils.Tuple2(
			_elm_lang$core$Native_Utils.Tuple0,
			emptyBag
		);

		return _elm_lang$virtual_dom$VirtualDom$programWithFlags({
			init: function() { return noChange; },
			view: function() { return main; },
			update: F2(function() { return noChange; }),
			subscriptions: function () { return emptyBag; }
		});
	}

	var flags = wrappedMain.flags;
	var init = flags
		? initWithFlags(moduleName, main.init, flags)
		: initWithoutFlags(moduleName, main.init);

	return _elm_lang$virtual_dom$VirtualDom$programWithFlags({
		init: init,
		view: main.view,
		update: main.update,
		subscriptions: main.subscriptions,
	});
}

function initWithoutFlags(moduleName, realInit)
{
	return function init(flags)
	{
		if (typeof flags !== 'undefined')
		{
			throw new Error(
				'You are giving module `' + moduleName + '` an argument in JavaScript.\n'
				+ 'This module does not take arguments though! You probably need to change the\n'
				+ 'initialization code to something like `Elm.' + moduleName + '.fullscreen()`'
			);
		}
		return realInit();
	};
}

function initWithFlags(moduleName, realInit, flagDecoder)
{
	return function init(flags)
	{
		var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
		if (result.ctor === 'Err')
		{
			throw new Error(
				'You are trying to initialize module `' + moduleName + '` with an unexpected argument.\n'
				+ 'When trying to convert it to a usable Elm value, I run into this problem:\n\n'
				+ result._0
			);
		}
		return realInit(result._0);
	};
}


// SETUP RUNTIME SYSTEM

function makeEmbedHelp(moduleName, program, rootDomNode, flags)
{
	var init = program.init;
	var update = program.update;
	var subscriptions = program.subscriptions;
	var view = program.view;
	var makeRenderer = program.renderer;

	// ambient state
	var managers = {};
	var renderer;

	// init and update state in main process
	var initApp = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		var results = init(flags);
		var model = results._0;
		renderer = makeRenderer(rootDomNode, enqueue, view(model));
		var cmds = results._1;
		var subs = subscriptions(model);
		dispatchEffects(managers, cmds, subs);
		callback(_elm_lang$core$Native_Scheduler.succeed(model));
	});

	function onMessage(msg, model)
	{
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
			var results = A2(update, msg, model);
			model = results._0;
			renderer.update(view(model));
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
		return A2(andThen, handleMsg, loop);
	}

	var task = A2(andThen, init, loop);

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
			var value = converter(cmdList._0);
			for (var i = 0; i < subs.length; i++)
			{
				subs[i](value);
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
	var subs = _elm_lang$core$Native_List.Nil;
	var converter = effectManagers[name].converter;

	// CREATE MANAGER

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function onEffects(router, subList, state)
	{
		subs = subList;
		return init;
	}

	effectManagers[name].init = init;
	effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function send(value)
	{
		var result = A2(_elm_lang$core$Json_Decode$decodeValue, converter, value);
		if (result.ctor === 'Err')
		{
			throw new Error('Trying to send an unexpected type of value through port `' + name + '`:\n' + result._0);
		}

		var value = result._0;
		var temp = subs;
		while (temp.ctor !== '[]')
		{
			callback(temp._0(value));
			temp = temp._1;
		}
	}

	return { send: send };
}

return {
	// routers
	sendToApp: F2(sendToApp),
	sendToSelf: F2(sendToSelf),

	// global setup
	mainToProgram: mainToProgram,
	effectManagers: effectManagers,
	outgoingPort: outgoingPort,
	incomingPort: incomingPort,
	addPublicModule: addPublicModule,

	// effect bags
	leaf: leaf,
	batch: batch,
	map: F2(map)
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

function andThen(task, callback)
{
	return {
		ctor: '_Task_andThen',
		task: task,
		callback: callback
	};
}

function onError(task, callback)
{
	return {
		ctor: '_Task_onError',
		task: task,
		callback: callback
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
		numSteps = step(numSteps, process);
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
var _elm_lang$core$Platform$hack = _elm_lang$core$Native_Scheduler.succeed;
var _elm_lang$core$Platform$sendToSelf = _elm_lang$core$Native_Platform.sendToSelf;
var _elm_lang$core$Platform$sendToApp = _elm_lang$core$Native_Platform.sendToApp;
var _elm_lang$core$Platform$Program = {ctor: 'Program'};
var _elm_lang$core$Platform$Task = {ctor: 'Task'};
var _elm_lang$core$Platform$ProcessId = {ctor: 'ProcessId'};
var _elm_lang$core$Platform$Router = {ctor: 'Router'};

var _elm_lang$core$Platform_Cmd$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Cmd$none = _elm_lang$core$Platform_Cmd$batch(
	_elm_lang$core$Native_List.fromArray(
		[]));
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
	_elm_lang$core$Native_List.fromArray(
		[]));
var _elm_lang$core$Platform_Sub$map = _elm_lang$core$Native_Platform.map;
var _elm_lang$core$Platform_Sub$Sub = {ctor: 'Sub'};

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
		_elm_lang$core$Native_List.range(
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
	if (len === 0)
	{
		return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int" );
	}
	var start = 0;
	if (s[0] === '-')
	{
		if (len === 1)
		{
			return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int" );
		}
		start = 1;
	}
	for (var i = start; i < len; ++i)
	{
		var c = s[i];
		if (c < '0' || '9' < c)
		{
			return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int" );
		}
	}
	return _elm_lang$core$Result$Ok(parseInt(s, 10));
}

function toFloat(s)
{
	var len = s.length;
	if (len === 0)
	{
		return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float" );
	}
	var start = 0;
	if (s[0] === '-')
	{
		if (len === 1)
		{
			return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float" );
		}
		start = 1;
	}
	var dotCount = 0;
	for (var i = start; i < len; ++i)
	{
		var c = s[i];
		if ('0' <= c && c <= '9')
		{
			continue;
		}
		if (c === '.')
		{
			dotCount += 1;
			if (dotCount <= 1)
			{
				continue;
			}
		}
		return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float" );
	}
	return _elm_lang$core$Result$Ok(parseFloat(s));
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
				return A2(_elm_lang$core$List_ops['::'], key, keyList);
			}),
		_elm_lang$core$Native_List.fromArray(
			[]),
		dict);
};
var _elm_lang$core$Dict$values = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return A2(_elm_lang$core$List_ops['::'], value, valueList);
			}),
		_elm_lang$core$Native_List.fromArray(
			[]),
		dict);
};
var _elm_lang$core$Dict$toList = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					_elm_lang$core$List_ops['::'],
					{ctor: '_Tuple2', _0: key, _1: value},
					list);
			}),
		_elm_lang$core$Native_List.fromArray(
			[]),
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
					return (_elm_lang$core$Native_Utils.cmp(_p5, rKey) < 0) ? {
						ctor: '_Tuple2',
						_0: _p7,
						_1: A3(leftStep, _p5, _p6, _p9)
					} : ((_elm_lang$core$Native_Utils.cmp(_p5, rKey) > 0) ? {
						ctor: '_Tuple2',
						_0: _p8,
						_1: A3(rightStep, rKey, rValue, _p9)
					} : {
						ctor: '_Tuple2',
						_0: _p7,
						_1: A4(bothStep, _p5, _p6, rValue, _p9)
					});
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
				_elm_lang$core$Native_List.fromArray(
					[
						'Internal red-black tree invariant violated, expected ',
						msg,
						' and got ',
						_elm_lang$core$Basics$toString(c),
						'/',
						lgot,
						'/',
						rgot,
						'\nPlease report this bug to <https://github.com/elm-lang/core/issues>'
					])));
	});
var _elm_lang$core$Dict$isBBlack = function (dict) {
	var _p13 = dict;
	_v11_2:
	do {
		if (_p13.ctor === 'RBNode_elm_builtin') {
			if (_p13._0.ctor === 'BBlack') {
				return true;
			} else {
				break _v11_2;
			}
		} else {
			if (_p13._0.ctor === 'LBBlack') {
				return true;
			} else {
				break _v11_2;
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
				var _v13 = A2(_elm_lang$core$Dict$sizeHelp, n + 1, _p14._4),
					_v14 = _p14._3;
				n = _v13;
				dict = _v14;
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
						var _v17 = targetKey,
							_v18 = _p15._3;
						targetKey = _v17;
						dict = _v18;
						continue get;
					case 'EQ':
						return _elm_lang$core$Maybe$Just(_p15._2);
					default:
						var _v19 = targetKey,
							_v20 = _p15._4;
						targetKey = _v19;
						dict = _v20;
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
				var _v23 = _p18._1,
					_v24 = _p18._2,
					_v25 = _p18._4;
				k = _v23;
				v = _v24;
				r = _v25;
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
	_v33_6:
	do {
		_v33_5:
		do {
			_v33_4:
			do {
				_v33_3:
				do {
					_v33_2:
					do {
						_v33_1:
						do {
							_v33_0:
							do {
								if (_p27.ctor === 'RBNode_elm_builtin') {
									if (_p27._3.ctor === 'RBNode_elm_builtin') {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._3._0.ctor) {
												case 'Red':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v33_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v33_1;
																} else {
																	if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																		break _v33_2;
																	} else {
																		if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																			break _v33_3;
																		} else {
																			break _v33_6;
																		}
																	}
																}
															}
														case 'NBlack':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v33_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v33_1;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																		break _v33_4;
																	} else {
																		break _v33_6;
																	}
																}
															}
														default:
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v33_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v33_1;
																} else {
																	break _v33_6;
																}
															}
													}
												case 'NBlack':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v33_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v33_3;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v33_5;
																	} else {
																		break _v33_6;
																	}
																}
															}
														case 'NBlack':
															if (_p27._0.ctor === 'BBlack') {
																if ((((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																	break _v33_4;
																} else {
																	if ((((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v33_5;
																	} else {
																		break _v33_6;
																	}
																}
															} else {
																break _v33_6;
															}
														default:
															if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																break _v33_5;
															} else {
																break _v33_6;
															}
													}
												default:
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v33_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v33_3;
																} else {
																	break _v33_6;
																}
															}
														case 'NBlack':
															if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																break _v33_4;
															} else {
																break _v33_6;
															}
														default:
															break _v33_6;
													}
											}
										} else {
											switch (_p27._3._0.ctor) {
												case 'Red':
													if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
														break _v33_0;
													} else {
														if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
															break _v33_1;
														} else {
															break _v33_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
														break _v33_5;
													} else {
														break _v33_6;
													}
												default:
													break _v33_6;
											}
										}
									} else {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._4._0.ctor) {
												case 'Red':
													if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
														break _v33_2;
													} else {
														if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
															break _v33_3;
														} else {
															break _v33_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
														break _v33_4;
													} else {
														break _v33_6;
													}
												default:
													break _v33_6;
											}
										} else {
											break _v33_6;
										}
									}
								} else {
									break _v33_6;
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
	function (c, l, r) {
		var _p29 = {ctor: '_Tuple2', _0: l, _1: r};
		if (_p29._0.ctor === 'RBEmpty_elm_builtin') {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p30 = c;
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
				var _p31 = {ctor: '_Tuple3', _0: c, _1: _p32, _2: _p33};
				if ((((_p31.ctor === '_Tuple3') && (_p31._0.ctor === 'Black')) && (_p31._1.ctor === 'LBlack')) && (_p31._2.ctor === 'Red')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._1._1, _p29._1._2, _p29._1._3, _p29._1._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/LBlack/Red',
						c,
						_elm_lang$core$Basics$toString(_p32),
						_elm_lang$core$Basics$toString(_p33));
				}
			}
		} else {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p36 = _p29._1._0;
				var _p35 = _p29._0._0;
				var _p34 = {ctor: '_Tuple3', _0: c, _1: _p35, _2: _p36};
				if ((((_p34.ctor === '_Tuple3') && (_p34._0.ctor === 'Black')) && (_p34._1.ctor === 'Red')) && (_p34._2.ctor === 'LBlack')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._0._1, _p29._0._2, _p29._0._3, _p29._0._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/Red/LBlack',
						c,
						_elm_lang$core$Basics$toString(_p35),
						_elm_lang$core$Basics$toString(_p36));
				}
			} else {
				var _p40 = _p29._0._2;
				var _p39 = _p29._0._4;
				var _p38 = _p29._0._1;
				var l$ = A5(_elm_lang$core$Dict$removeMax, _p29._0._0, _p38, _p40, _p29._0._3, _p39);
				var _p37 = A3(_elm_lang$core$Dict$maxWithDefault, _p38, _p40, _p39);
				var k = _p37._0;
				var v = _p37._1;
				return A5(_elm_lang$core$Dict$bubble, c, k, v, l$, r);
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

function decodeKeyValuePairs(decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'key-value',
		decoder: decoder
	};
}

function decodeObject(f, decoders)
{
	return {
		ctor: '<decoder>',
		tag: 'map-many',
		func: f,
		decoders: decoders
	};
}

function decodeTuple(f, decoders)
{
	return {
		ctor: '<decoder>',
		tag: 'tuple',
		func: f,
		decoders: decoders
	};
}

function andThen(decoder, callback)
{
	return {
		ctor: '<decoder>',
		tag: 'andThen',
		decoder: decoder,
		callback: callback
	};
}

function customAndThen(decoder, callback)
{
	return {
		ctor: '<decoder>',
		tag: 'customAndThen',
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

function decodeObject1(f, d1)
{
	return decodeObject(f, [d1]);
}

function decodeObject2(f, d1, d2)
{
	return decodeObject(f, [d1, d2]);
}

function decodeObject3(f, d1, d2, d3)
{
	return decodeObject(f, [d1, d2, d3]);
}

function decodeObject4(f, d1, d2, d3, d4)
{
	return decodeObject(f, [d1, d2, d3, d4]);
}

function decodeObject5(f, d1, d2, d3, d4, d5)
{
	return decodeObject(f, [d1, d2, d3, d4, d5]);
}

function decodeObject6(f, d1, d2, d3, d4, d5, d6)
{
	return decodeObject(f, [d1, d2, d3, d4, d5, d6]);
}

function decodeObject7(f, d1, d2, d3, d4, d5, d6, d7)
{
	return decodeObject(f, [d1, d2, d3, d4, d5, d6, d7]);
}

function decodeObject8(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return decodeObject(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
}


// DECODING TUPLES

function decodeTuple1(f, d1)
{
	return decodeTuple(f, [d1]);
}

function decodeTuple2(f, d1, d2)
{
	return decodeTuple(f, [d1, d2]);
}

function decodeTuple3(f, d1, d2, d3)
{
	return decodeTuple(f, [d1, d2, d3]);
}

function decodeTuple4(f, d1, d2, d3, d4)
{
	return decodeTuple(f, [d1, d2, d3, d4]);
}

function decodeTuple5(f, d1, d2, d3, d4, d5)
{
	return decodeTuple(f, [d1, d2, d3, d4, d5]);
}

function decodeTuple6(f, d1, d2, d3, d4, d5, d6)
{
	return decodeTuple(f, [d1, d2, d3, d4, d5, d6]);
}

function decodeTuple7(f, d1, d2, d3, d4, d5, d6, d7)
{
	return decodeTuple(f, [d1, d2, d3, d4, d5, d6, d7]);
}

function decodeTuple8(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return decodeTuple(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
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
			return (result.tag === 'ok')
				? result
				: badField(field, result);

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

		case 'tuple':
			var decoders = decoder.decoders;
			var len = decoders.length;

			if ( !(value instanceof Array) || value.length !== len )
			{
				return badPrimitive('a Tuple with ' + len + ' entries', value);
			}

			var answer = decoder.func;
			for (var i = 0; i < len; i++)
			{
				var result = runHelp(decoders[i], value[i]);
				if (result.tag !== 'ok')
				{
					return badIndex(i, result);
				}
				answer = answer(result.value);
			}
			return ok(answer);

		case 'customAndThen':
			var result = runHelp(decoder.decoder, value);
			if (result.tag !== 'ok')
			{
				return result;
			}
			var realResult = decoder.callback(result.value);
			if (realResult.ctor === 'Err')
			{
				return badPrimitive('something custom', value);
			}
			return ok(realResult._0);

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

		case 'map-many':
		case 'tuple':
			if (a.func !== b.func)
			{
				return false;
			}
			return listEquality(a.decoders, b.decoders);

		case 'andThen':
		case 'customAndThen':
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

	decodeObject1: F2(decodeObject1),
	decodeObject2: F3(decodeObject2),
	decodeObject3: F4(decodeObject3),
	decodeObject4: F5(decodeObject4),
	decodeObject5: F6(decodeObject5),
	decodeObject6: F7(decodeObject6),
	decodeObject7: F8(decodeObject7),
	decodeObject8: F9(decodeObject8),
	decodeKeyValuePairs: decodeKeyValuePairs,

	decodeTuple1: F2(decodeTuple1),
	decodeTuple2: F3(decodeTuple2),
	decodeTuple3: F4(decodeTuple3),
	decodeTuple4: F5(decodeTuple4),
	decodeTuple5: F6(decodeTuple5),
	decodeTuple6: F7(decodeTuple6),
	decodeTuple7: F8(decodeTuple7),
	decodeTuple8: F9(decodeTuple8),

	andThen: F2(andThen),
	customAndThen: F2(customAndThen),
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

var _elm_lang$core$Json_Decode$tuple8 = _elm_lang$core$Native_Json.decodeTuple8;
var _elm_lang$core$Json_Decode$tuple7 = _elm_lang$core$Native_Json.decodeTuple7;
var _elm_lang$core$Json_Decode$tuple6 = _elm_lang$core$Native_Json.decodeTuple6;
var _elm_lang$core$Json_Decode$tuple5 = _elm_lang$core$Native_Json.decodeTuple5;
var _elm_lang$core$Json_Decode$tuple4 = _elm_lang$core$Native_Json.decodeTuple4;
var _elm_lang$core$Json_Decode$tuple3 = _elm_lang$core$Native_Json.decodeTuple3;
var _elm_lang$core$Json_Decode$tuple2 = _elm_lang$core$Native_Json.decodeTuple2;
var _elm_lang$core$Json_Decode$tuple1 = _elm_lang$core$Native_Json.decodeTuple1;
var _elm_lang$core$Json_Decode$succeed = _elm_lang$core$Native_Json.succeed;
var _elm_lang$core$Json_Decode$fail = _elm_lang$core$Native_Json.fail;
var _elm_lang$core$Json_Decode$andThen = _elm_lang$core$Native_Json.andThen;
var _elm_lang$core$Json_Decode$customDecoder = _elm_lang$core$Native_Json.customAndThen;
var _elm_lang$core$Json_Decode$decodeValue = _elm_lang$core$Native_Json.run;
var _elm_lang$core$Json_Decode$value = _elm_lang$core$Native_Json.decodePrimitive('value');
var _elm_lang$core$Json_Decode$maybe = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'maybe', decoder);
};
var _elm_lang$core$Json_Decode$null = _elm_lang$core$Native_Json.decodeNull;
var _elm_lang$core$Json_Decode$array = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'array', decoder);
};
var _elm_lang$core$Json_Decode$list = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'list', decoder);
};
var _elm_lang$core$Json_Decode$bool = _elm_lang$core$Native_Json.decodePrimitive('bool');
var _elm_lang$core$Json_Decode$int = _elm_lang$core$Native_Json.decodePrimitive('int');
var _elm_lang$core$Json_Decode$float = _elm_lang$core$Native_Json.decodePrimitive('float');
var _elm_lang$core$Json_Decode$string = _elm_lang$core$Native_Json.decodePrimitive('string');
var _elm_lang$core$Json_Decode$oneOf = _elm_lang$core$Native_Json.oneOf;
var _elm_lang$core$Json_Decode$keyValuePairs = _elm_lang$core$Native_Json.decodeKeyValuePairs;
var _elm_lang$core$Json_Decode$object8 = _elm_lang$core$Native_Json.decodeObject8;
var _elm_lang$core$Json_Decode$object7 = _elm_lang$core$Native_Json.decodeObject7;
var _elm_lang$core$Json_Decode$object6 = _elm_lang$core$Native_Json.decodeObject6;
var _elm_lang$core$Json_Decode$object5 = _elm_lang$core$Native_Json.decodeObject5;
var _elm_lang$core$Json_Decode$object4 = _elm_lang$core$Native_Json.decodeObject4;
var _elm_lang$core$Json_Decode$object3 = _elm_lang$core$Native_Json.decodeObject3;
var _elm_lang$core$Json_Decode$object2 = _elm_lang$core$Native_Json.decodeObject2;
var _elm_lang$core$Json_Decode$object1 = _elm_lang$core$Native_Json.decodeObject1;
var _elm_lang$core$Json_Decode_ops = _elm_lang$core$Json_Decode_ops || {};
_elm_lang$core$Json_Decode_ops[':='] = _elm_lang$core$Native_Json.decodeField;
var _elm_lang$core$Json_Decode$at = F2(
	function (fields, decoder) {
		return A3(
			_elm_lang$core$List$foldr,
			F2(
				function (x, y) {
					return A2(_elm_lang$core$Json_Decode_ops[':='], x, y);
				}),
			decoder,
			fields);
	});
var _elm_lang$core$Json_Decode$decodeString = _elm_lang$core$Native_Json.runOnString;
var _elm_lang$core$Json_Decode$map = _elm_lang$core$Native_Json.decodeObject1;
var _elm_lang$core$Json_Decode$dict = function (decoder) {
	return A2(
		_elm_lang$core$Json_Decode$map,
		_elm_lang$core$Dict$fromList,
		_elm_lang$core$Json_Decode$keyValuePairs(decoder));
};
var _elm_lang$core$Json_Decode$Decoder = {ctor: 'Decoder'};

//import Native.Json //

var _elm_lang$virtual_dom$Native_VirtualDom = function() {

var STYLE_KEY = 'STYLE';
var EVENT_KEY = 'EVENT';
var ATTR_KEY = 'ATTR';
var ATTR_NS_KEY = 'ATTR_NS';



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
		node: null
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
	if (!a.options === b.options)
	{
		if (a.stopPropagation !== b.stopPropagation || a.preventDefault !== b.preventDefault)
		{
			return false;
		}
	}
	return _elm_lang$core$Native_Json.equality(a.decoder, b.decoder);
}



////////////  RENDERER  ////////////


function renderer(parent, tagger, initialVirtualNode)
{
	var eventNode = { tagger: tagger, parent: null };

	var domNode = render(initialVirtualNode, eventNode);
	parent.appendChild(domNode);

	var state = 'NO_REQUEST';
	var currentVirtualNode = initialVirtualNode;
	var nextVirtualNode = initialVirtualNode;

	function registerVirtualNode(vNode)
	{
		if (state === 'NO_REQUEST')
		{
			rAF(updateIfNeeded);
		}
		state = 'PENDING_REQUEST';
		nextVirtualNode = vNode;
	}

	function updateIfNeeded()
	{
		switch (state)
		{
			case 'NO_REQUEST':
				throw new Error(
					'Unexpected draw callback.\n' +
					'Please report this to <https://github.com/elm-lang/core/issues>.'
				);

			case 'PENDING_REQUEST':
				rAF(updateIfNeeded);
				state = 'EXTRA_REQUEST';

				var patches = diff(currentVirtualNode, nextVirtualNode);
				domNode = applyPatches(domNode, currentVirtualNode, patches, eventNode);
				currentVirtualNode = nextVirtualNode;

				return;

			case 'EXTRA_REQUEST':
				state = 'NO_REQUEST';
				return;
		}
	}

	return { update: registerVirtualNode };
}


var rAF =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(cb) { setTimeout(cb, 1000 / 60); };



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
            
			var subEventRoot = {
				tagger: tagger,
				parent: eventNode
			};
			
			var domNode = render(subNode, subEventRoot);
			domNode.elm_event_node_ref = subEventRoot;
			return domNode;

		case 'text':
			return document.createTextNode(vNode.text);

		case 'node':
			var domNode = vNode.namespace
				? document.createElementNS(vNode.namespace, vNode.tag)
				: document.createElement(vNode.tag);

			applyFacts(domNode, eventNode, vNode.facts);

			var children = vNode.children;

			for (var i = 0; i < children.length; i++)
			{
				domNode.appendChild(render(children[i], eventNode));
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
		domNode: null,
		eventNode: null
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
		patches.push(makePatch('p-remove', rootIndex, aLen - bLen));
	}
	else if (aLen < bLen)
	{
		patches.push(makePatch('p-insert', rootIndex, bChildren.slice(aLen)));
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
			return redraw(domNode, patch.data, patch.eventNode);

		case 'p-facts':
			applyFacts(domNode, patch.eventNode, patch.data);
			return domNode;

		case 'p-text':
			domNode.replaceData(0, domNode.length, patch.data);
			return domNode;

		case 'p-thunk':
			return applyPatchesHelp(domNode, patch.data);

		case 'p-tagger':
			domNode.elm_event_node_ref.tagger = patch.data;
			return domNode;

		case 'p-remove':
			var i = patch.data;
			while (i--)
			{
				domNode.removeChild(domNode.lastChild);
			}
			return domNode;

		case 'p-insert':
			var newNodes = patch.data;
			for (var i = 0; i < newNodes.length; i++)
			{
				domNode.appendChild(render(newNodes[i], patch.eventNode));
			}
			return domNode;

		case 'p-custom':
			var impl = patch.data;
			return impl.applyPatch(domNode, impl.data);

		default:
			throw new Error('Ran into an unknown patch!');
	}
}


function redraw(domNode, vNode, eventNode)
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



////////////  PROGRAMS  ////////////


function programWithFlags(details)
{
	return {
		init: details.init,
		update: details.update,
		subscriptions: details.subscriptions,
		view: details.view,
		renderer: renderer
	};
}


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

	lazy: F2(lazy),
	lazy2: F3(lazy2),
	lazy3: F4(lazy3),

	programWithFlags: programWithFlags
};

}();
var _elm_lang$virtual_dom$VirtualDom$programWithFlags = _elm_lang$virtual_dom$Native_VirtualDom.programWithFlags;
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
var _elm_lang$html$Html$main$ = _elm_lang$html$Html$node('main');
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
var _elm_lang$html$Html$svg = _elm_lang$html$Html$node('svg');
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

var _elm_lang$html$Html_App$programWithFlags = _elm_lang$virtual_dom$VirtualDom$programWithFlags;
var _elm_lang$html$Html_App$program = function (app) {
	return _elm_lang$html$Html_App$programWithFlags(
		_elm_lang$core$Native_Utils.update(
			app,
			{
				init: function (_p0) {
					return app.init;
				}
			}));
};
var _elm_lang$html$Html_App$beginnerProgram = function (_p1) {
	var _p2 = _p1;
	return _elm_lang$html$Html_App$programWithFlags(
		{
			init: function (_p3) {
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_p2.model,
					_elm_lang$core$Native_List.fromArray(
						[]));
			},
			update: F2(
				function (msg, model) {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						A2(_p2.update, msg, model),
						_elm_lang$core$Native_List.fromArray(
							[]));
				}),
			view: _p2.view,
			subscriptions: function (_p4) {
				return _elm_lang$core$Platform_Sub$none;
			}
		});
};
var _elm_lang$html$Html_App$map = _elm_lang$virtual_dom$VirtualDom$map;

var _elm_lang$core$Task$onError = _elm_lang$core$Native_Scheduler.onError;
var _elm_lang$core$Task$andThen = _elm_lang$core$Native_Scheduler.andThen;
var _elm_lang$core$Task$spawnCmd = F2(
	function (router, _p0) {
		var _p1 = _p0;
		return _elm_lang$core$Native_Scheduler.spawn(
			A2(
				_elm_lang$core$Task$andThen,
				_p1._0,
				_elm_lang$core$Platform$sendToApp(router)));
	});
var _elm_lang$core$Task$fail = _elm_lang$core$Native_Scheduler.fail;
var _elm_lang$core$Task$mapError = F2(
	function (f, task) {
		return A2(
			_elm_lang$core$Task$onError,
			task,
			function (err) {
				return _elm_lang$core$Task$fail(
					f(err));
			});
	});
var _elm_lang$core$Task$succeed = _elm_lang$core$Native_Scheduler.succeed;
var _elm_lang$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			_elm_lang$core$Task$andThen,
			taskA,
			function (a) {
				return _elm_lang$core$Task$succeed(
					func(a));
			});
	});
var _elm_lang$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			_elm_lang$core$Task$andThen,
			taskA,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					taskB,
					function (b) {
						return _elm_lang$core$Task$succeed(
							A2(func, a, b));
					});
			});
	});
var _elm_lang$core$Task$map3 = F4(
	function (func, taskA, taskB, taskC) {
		return A2(
			_elm_lang$core$Task$andThen,
			taskA,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					taskB,
					function (b) {
						return A2(
							_elm_lang$core$Task$andThen,
							taskC,
							function (c) {
								return _elm_lang$core$Task$succeed(
									A3(func, a, b, c));
							});
					});
			});
	});
var _elm_lang$core$Task$map4 = F5(
	function (func, taskA, taskB, taskC, taskD) {
		return A2(
			_elm_lang$core$Task$andThen,
			taskA,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					taskB,
					function (b) {
						return A2(
							_elm_lang$core$Task$andThen,
							taskC,
							function (c) {
								return A2(
									_elm_lang$core$Task$andThen,
									taskD,
									function (d) {
										return _elm_lang$core$Task$succeed(
											A4(func, a, b, c, d));
									});
							});
					});
			});
	});
var _elm_lang$core$Task$map5 = F6(
	function (func, taskA, taskB, taskC, taskD, taskE) {
		return A2(
			_elm_lang$core$Task$andThen,
			taskA,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					taskB,
					function (b) {
						return A2(
							_elm_lang$core$Task$andThen,
							taskC,
							function (c) {
								return A2(
									_elm_lang$core$Task$andThen,
									taskD,
									function (d) {
										return A2(
											_elm_lang$core$Task$andThen,
											taskE,
											function (e) {
												return _elm_lang$core$Task$succeed(
													A5(func, a, b, c, d, e));
											});
									});
							});
					});
			});
	});
var _elm_lang$core$Task$andMap = F2(
	function (taskFunc, taskValue) {
		return A2(
			_elm_lang$core$Task$andThen,
			taskFunc,
			function (func) {
				return A2(
					_elm_lang$core$Task$andThen,
					taskValue,
					function (value) {
						return _elm_lang$core$Task$succeed(
							func(value));
					});
			});
	});
var _elm_lang$core$Task$sequence = function (tasks) {
	var _p2 = tasks;
	if (_p2.ctor === '[]') {
		return _elm_lang$core$Task$succeed(
			_elm_lang$core$Native_List.fromArray(
				[]));
	} else {
		return A3(
			_elm_lang$core$Task$map2,
			F2(
				function (x, y) {
					return A2(_elm_lang$core$List_ops['::'], x, y);
				}),
			_p2._0,
			_elm_lang$core$Task$sequence(_p2._1));
	}
};
var _elm_lang$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			_elm_lang$core$Task$map,
			function (_p3) {
				return {ctor: '_Tuple0'};
			},
			_elm_lang$core$Task$sequence(
				A2(
					_elm_lang$core$List$map,
					_elm_lang$core$Task$spawnCmd(router),
					commands)));
	});
var _elm_lang$core$Task$toMaybe = function (task) {
	return A2(
		_elm_lang$core$Task$onError,
		A2(_elm_lang$core$Task$map, _elm_lang$core$Maybe$Just, task),
		function (_p4) {
			return _elm_lang$core$Task$succeed(_elm_lang$core$Maybe$Nothing);
		});
};
var _elm_lang$core$Task$fromMaybe = F2(
	function ($default, maybe) {
		var _p5 = maybe;
		if (_p5.ctor === 'Just') {
			return _elm_lang$core$Task$succeed(_p5._0);
		} else {
			return _elm_lang$core$Task$fail($default);
		}
	});
var _elm_lang$core$Task$toResult = function (task) {
	return A2(
		_elm_lang$core$Task$onError,
		A2(_elm_lang$core$Task$map, _elm_lang$core$Result$Ok, task),
		function (msg) {
			return _elm_lang$core$Task$succeed(
				_elm_lang$core$Result$Err(msg));
		});
};
var _elm_lang$core$Task$fromResult = function (result) {
	var _p6 = result;
	if (_p6.ctor === 'Ok') {
		return _elm_lang$core$Task$succeed(_p6._0);
	} else {
		return _elm_lang$core$Task$fail(_p6._0);
	}
};
var _elm_lang$core$Task$init = _elm_lang$core$Task$succeed(
	{ctor: '_Tuple0'});
var _elm_lang$core$Task$onSelfMsg = F3(
	function (_p9, _p8, _p7) {
		return _elm_lang$core$Task$succeed(
			{ctor: '_Tuple0'});
	});
var _elm_lang$core$Task$command = _elm_lang$core$Native_Platform.leaf('Task');
var _elm_lang$core$Task$T = function (a) {
	return {ctor: 'T', _0: a};
};
var _elm_lang$core$Task$perform = F3(
	function (onFail, onSuccess, task) {
		return _elm_lang$core$Task$command(
			_elm_lang$core$Task$T(
				A2(
					_elm_lang$core$Task$onError,
					A2(_elm_lang$core$Task$map, onSuccess, task),
					function (x) {
						return _elm_lang$core$Task$succeed(
							onFail(x));
					})));
	});
var _elm_lang$core$Task$cmdMap = F2(
	function (tagger, _p10) {
		var _p11 = _p10;
		return _elm_lang$core$Task$T(
			A2(_elm_lang$core$Task$map, tagger, _p11._0));
	});
_elm_lang$core$Native_Platform.effectManagers['Task'] = {pkg: 'elm-lang/core', init: _elm_lang$core$Task$init, onEffects: _elm_lang$core$Task$onEffects, onSelfMsg: _elm_lang$core$Task$onSelfMsg, tag: 'cmd', cmdMap: _elm_lang$core$Task$cmdMap};

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
			return A2(
				_elm_lang$core$Task$andThen,
				_elm_lang$core$Native_Scheduler.spawn(
					A2(
						_elm_lang$core$Time$setInterval,
						_p1,
						A2(_elm_lang$core$Platform$sendToSelf, router, _p1))),
				function (id) {
					return A3(
						_elm_lang$core$Time$spawnHelp,
						router,
						_p0._1,
						A3(_elm_lang$core$Dict$insert, _p1, id, processes));
				});
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
				_elm_lang$core$Native_List.fromArray(
					[_p6]),
				state);
		} else {
			return A3(
				_elm_lang$core$Dict$insert,
				_p5,
				A2(_elm_lang$core$List_ops['::'], _p6, _p4._0),
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
			return A2(
				_elm_lang$core$Task$andThen,
				_elm_lang$core$Time$now,
				function (time) {
					return A2(
						_elm_lang$core$Task$andThen,
						_elm_lang$core$Task$sequence(
							A2(
								_elm_lang$core$List$map,
								function (tagger) {
									return A2(
										_elm_lang$core$Platform$sendToApp,
										router,
										tagger(time));
								},
								_p7._0)),
						function (_p8) {
							return _elm_lang$core$Task$succeed(state);
						});
				});
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
						_elm_lang$core$Native_Scheduler.kill(id),
						function (_p14) {
							return _p13._2;
						})
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
					_0: A2(_elm_lang$core$List_ops['::'], interval, _p18._0),
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
				_0: _elm_lang$core$Native_List.fromArray(
					[]),
				_1: _elm_lang$core$Dict$empty,
				_2: _elm_lang$core$Task$succeed(
					{ctor: '_Tuple0'})
			});
		var spawnList = _p19._0;
		var existingDict = _p19._1;
		var killTask = _p19._2;
		return A2(
			_elm_lang$core$Task$andThen,
			killTask,
			function (_p20) {
				return A2(
					_elm_lang$core$Task$andThen,
					A3(_elm_lang$core$Time$spawnHelp, router, spawnList, existingDict),
					function (newProcesses) {
						return _elm_lang$core$Task$succeed(
							A2(_elm_lang$core$Time$State, newTaggers, newProcesses));
					});
			});
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

var _elm_lang$html$Html_Events$keyCode = A2(_elm_lang$core$Json_Decode_ops[':='], 'keyCode', _elm_lang$core$Json_Decode$int);
var _elm_lang$html$Html_Events$targetChecked = A2(
	_elm_lang$core$Json_Decode$at,
	_elm_lang$core$Native_List.fromArray(
		['target', 'checked']),
	_elm_lang$core$Json_Decode$bool);
var _elm_lang$html$Html_Events$targetValue = A2(
	_elm_lang$core$Json_Decode$at,
	_elm_lang$core$Native_List.fromArray(
		['target', 'value']),
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
					_elm_lang$core$Native_List.fromArray(
						['key']),
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
			_elm_lang$core$Process$sleep(waitFor),
			function (_p1) {
				return task;
			});
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
			_elm_lang$core$Native_List.fromArray(
				[aMsg, bMsg]));
	});
var _Lattyware$massivedecks$MassiveDecks_Util$cmd = function (message) {
	return A3(
		_elm_lang$core$Task$perform,
		_elm_lang$core$Basics$identity,
		function (_p7) {
			return message;
		},
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
		var _p8 = list1;
		if (_p8.ctor === '[]') {
			return list2;
		} else {
			var _p9 = list2;
			if (_p9.ctor === '[]') {
				return list1;
			} else {
				return A2(
					_elm_lang$core$List_ops['::'],
					_p9._0,
					A2(
						_elm_lang$core$List_ops['::'],
						_p8._0,
						A2(_Lattyware$massivedecks$MassiveDecks_Util$interleave, _p8._1, _p9._1)));
			}
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Util$find = F2(
	function (check, items) {
		return _elm_lang$core$List$head(
			A2(_elm_lang$core$List$filter, check, items));
	});
var _Lattyware$massivedecks$MassiveDecks_Util$andMaybe = F2(
	function (values, maybeExtra) {
		return A2(
			_elm_lang$core$List$append,
			values,
			A2(
				_elm_lang$core$Maybe$withDefault,
				_elm_lang$core$Native_List.fromArray(
					[]),
				A2(
					_elm_lang$core$Maybe$map,
					function (value) {
						return _elm_lang$core$Native_List.fromArray(
							[value]);
					},
					maybeExtra)));
	});
var _Lattyware$massivedecks$MassiveDecks_Util$impossible = function (n) {
	impossible:
	while (true) {
		var _v6 = n;
		n = _v6;
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
var _Lattyware$massivedecks$MassiveDecks_Models_Card$RevealedResponses = F2(
	function (a, b) {
		return {cards: a, playedByAndWinner: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Card$Hand = function (a) {
	return {hand: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Card$Revealed = function (a) {
	return {ctor: 'Revealed', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Card$Hidden = function (a) {
	return {ctor: 'Hidden', _0: a};
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$toString = function (id) {
	var _p0 = id;
	return 'reboot';
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$Reboot = {ctor: 'Reboot'};

var _Lattyware$massivedecks$MassiveDecks_Models_Game$GameCodeAndSecret = F2(
	function (a, b) {
		return {gameCode: a, secret: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game$Config = F2(
	function (a, b) {
		return {decks: a, houseRules: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game$DeckInfo = F4(
	function (a, b, c, d) {
		return {id: a, name: b, calls: c, responses: d};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game$Round = F3(
	function (a, b, c) {
		return {czar: a, call: b, responses: c};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game$FinishedRound = F4(
	function (a, b, c, d) {
		return {czar: a, call: b, responses: c, playedByAndWinner: d};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game$Lobby = F4(
	function (a, b, c, d) {
		return {gameCode: a, config: b, players: c, round: d};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_Game$LobbyAndHand = F2(
	function (a, b) {
		return {lobby: a, hand: b};
	});

var _Lattyware$massivedecks$MassiveDecks_Models$Init = F5(
	function (a, b, c, d, e) {
		return {url: a, gameCode: b, existingGame: c, seed: d, browserNotificationsSupported: e};
	});

var _elm_lang$html$Html_Attributes$attribute = _elm_lang$virtual_dom$VirtualDom$attribute;
var _elm_lang$html$Html_Attributes$contextmenu = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'contextmenu', value);
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
var _elm_lang$html$Html_Attributes$draggable = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'draggable', value);
};
var _elm_lang$html$Html_Attributes$dropzone = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'dropzone', value);
};
var _elm_lang$html$Html_Attributes$itemprop = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'itemprop', value);
};
var _elm_lang$html$Html_Attributes$lang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'lang', value);
};
var _elm_lang$html$Html_Attributes$tabindex = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'tabIndex',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$charset = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'charset', value);
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
var _elm_lang$html$Html_Attributes$height = function (value) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'height',
		_elm_lang$core$Basics$toString(value));
};
var _elm_lang$html$Html_Attributes$width = function (value) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'width',
		_elm_lang$core$Basics$toString(value));
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
var _elm_lang$html$Html_Attributes$type$ = function (value) {
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
var _elm_lang$html$Html_Attributes$autosave = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'autosave', value);
};
var _elm_lang$html$Html_Attributes$enctype = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'enctype', value);
};
var _elm_lang$html$Html_Attributes$formaction = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'formAction', value);
};
var _elm_lang$html$Html_Attributes$list = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'list', value);
};
var _elm_lang$html$Html_Attributes$minlength = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'minLength',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$maxlength = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'maxLength',
		_elm_lang$core$Basics$toString(n));
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
var _elm_lang$html$Html_Attributes$size = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'size',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$for = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'htmlFor', value);
};
var _elm_lang$html$Html_Attributes$form = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'form', value);
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
var _elm_lang$html$Html_Attributes$cols = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'cols',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$rows = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'rows',
		_elm_lang$core$Basics$toString(n));
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
var _elm_lang$html$Html_Attributes$challenge = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'challenge', value);
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
var _elm_lang$html$Html_Attributes$media = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'media', value);
};
var _elm_lang$html$Html_Attributes$ping = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'ping', value);
};
var _elm_lang$html$Html_Attributes$rel = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'rel', value);
};
var _elm_lang$html$Html_Attributes$datetime = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'datetime', value);
};
var _elm_lang$html$Html_Attributes$pubdate = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'pubdate', value);
};
var _elm_lang$html$Html_Attributes$start = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'start',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$colspan = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'colSpan',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$headers = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'headers', value);
};
var _elm_lang$html$Html_Attributes$rowspan = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'rowSpan',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$scope = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'scope', value);
};
var _elm_lang$html$Html_Attributes$manifest = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'manifest', value);
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
				_elm_lang$core$Basics$fst,
				A2(_elm_lang$core$List$filter, _elm_lang$core$Basics$snd, list))));
};
var _elm_lang$html$Html_Attributes$style = _elm_lang$virtual_dom$VirtualDom$style;

var _Lattyware$massivedecks$MassiveDecks_Components_Tabs$viewPane = F3(
	function (current, renderer, model) {
		return A2(
			_elm_lang$html$Html$div,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$classList(
					_elm_lang$core$Native_List.fromArray(
						[
							{ctor: '_Tuple2', _0: 'mui-tabs__pane', _1: true},
							{
							ctor: '_Tuple2',
							_0: 'mui--is-active',
							_1: _elm_lang$core$Native_Utils.eq(current, model.id)
						}
						]))
				]),
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
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$classList(
					_elm_lang$core$Native_List.fromArray(
						[
							{
							ctor: '_Tuple2',
							_0: 'mui--is-active',
							_1: _elm_lang$core$Native_Utils.eq(current, model.id)
						}
						]))
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$a,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Events$onClick(
							tagger(
								_Lattyware$massivedecks$MassiveDecks_Components_Tabs$SetTab(model.id)))
						]),
					model.title)
				]));
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Tabs$view = F2(
	function (renderer, model) {
		return A2(
			_elm_lang$core$Basics_ops['++'],
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$ul,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$class('mui-tabs__bar mui-tabs__bar--justified')
						]),
					A2(
						_elm_lang$core$List$map,
						A2(_Lattyware$massivedecks$MassiveDecks_Components_Tabs$viewTab, model.tagger, model.current),
						model.tabs))
				]),
			A2(
				_elm_lang$core$List$map,
				A2(_Lattyware$massivedecks$MassiveDecks_Components_Tabs$viewPane, model.current, renderer),
				model.tabs));
	});

var _Lattyware$massivedecks$MassiveDecks_Components_Storage$existingGame = _elm_lang$core$Native_Platform.outgoingPort(
	'existingGame',
	function (v) {
		return (v.ctor === 'Nothing') ? null : {
			gameCode: v._0.gameCode,
			secret: {id: v._0.secret.id, secret: v._0.secret.secret}
		};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Storage$storeInGame = function (gameCodeAndSecret) {
	return _Lattyware$massivedecks$MassiveDecks_Components_Storage$existingGame(
		_elm_lang$core$Maybe$Just(gameCodeAndSecret));
};
var _Lattyware$massivedecks$MassiveDecks_Components_Storage$storeLeftGame = _Lattyware$massivedecks$MassiveDecks_Components_Storage$existingGame(_elm_lang$core$Maybe$Nothing);

var _Lattyware$massivedecks$MassiveDecks_Components_Icon$spinner = A2(
	_elm_lang$html$Html$i,
	_elm_lang$core$Native_List.fromArray(
		[
			_elm_lang$html$Html_Attributes$class('fa fa-circle-o-notch fa-spin')
		]),
	_elm_lang$core$Native_List.fromArray(
		[]));
var _Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon = function (name) {
	return A2(
		_elm_lang$html$Html$i,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class(
				A2(_elm_lang$core$Basics_ops['++'], 'fa fa-fw fa-', name))
			]),
		_elm_lang$core$Native_List.fromArray(
			[]));
};
var _Lattyware$massivedecks$MassiveDecks_Components_Icon$icon = function (name) {
	return A2(
		_elm_lang$html$Html$i,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class(
				A2(_elm_lang$core$Basics_ops['++'], 'fa fa-', name))
			]),
		_elm_lang$core$Native_List.fromArray(
			[]));
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
							{value: _p1._0}),
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
					return {ctor: '_Tuple2', _0: model, _1: model.submit};
				case 'SetEnabled':
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Native_Utils.update(
							model,
							{enabled: _p1._0}),
						_1: _elm_lang$core$Platform_Cmd$none
					};
				default:
					return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
			}
		} else {
			return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Input$error = function (message) {
	return A2(
		_elm_lang$core$Maybe$map,
		function (error) {
			return A2(
				_elm_lang$html$Html$span,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('input-error')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('exclamation'),
						_elm_lang$html$Html$text(' '),
						_elm_lang$html$Html$text(error)
					]));
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
				return _elm_lang$core$Native_List.fromArray(
					[]);
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
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class(model.$class)
			]),
		A2(
			_elm_lang$core$Basics_ops['++'],
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$div,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$class('mui-textfield')
						]),
					A2(
						_Lattyware$massivedecks$MassiveDecks_Util$andMaybe,
						_elm_lang$core$Native_List.fromArray(
							[
								A2(
								_elm_lang$html$Html$input,
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html_Attributes$type$('text'),
										_elm_lang$html$Html_Attributes$defaultValue(model.value),
										_elm_lang$html$Html_Attributes$placeholder(model.placeholder),
										_elm_lang$html$Html_Attributes$disabled(
										_elm_lang$core$Basics$not(model.enabled)),
										A2(
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
										A3(
										_Lattyware$massivedecks$MassiveDecks_Util$onKeyDown,
										'Enter',
										model.embedMethod(
											{ctor: '_Tuple2', _0: model.identity, _1: _Lattyware$massivedecks$MassiveDecks_Components_Input$Submit}),
										model.embedMethod(
											{ctor: '_Tuple2', _0: model.identity, _1: _Lattyware$massivedecks$MassiveDecks_Components_Input$NoOp}))
									]),
								_elm_lang$core$Native_List.fromArray(
									[])),
								A2(
								_elm_lang$html$Html$label,
								_elm_lang$core$Native_List.fromArray(
									[]),
								A2(
									_elm_lang$core$List$append,
									_elm_lang$core$Native_List.fromArray(
										[
											_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('info-circle'),
											_elm_lang$html$Html$text(' ')
										]),
									model.label))
							]),
						_Lattyware$massivedecks$MassiveDecks_Components_Input$error(model.error)))
				]),
			model.extra(model.value)));
};

//import Dict, List, Maybe, Native.Scheduler //

var _evancz$elm_http$Native_Http = function() {

function send(settings, request)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		var req = new XMLHttpRequest();

		// start
		if (settings.onStart.ctor === 'Just')
		{
			req.addEventListener('loadStart', function() {
				var task = settings.onStart._0;
				_elm_lang$core$Native_Scheduler.rawSpawn(task);
			});
		}

		// progress
		if (settings.onProgress.ctor === 'Just')
		{
			req.addEventListener('progress', function(event) {
				var progress = !event.lengthComputable
					? _elm_lang$core$Maybe$Nothing
					: _elm_lang$core$Maybe$Just({
						loaded: event.loaded,
						total: event.total
					});
				var task = settings.onProgress._0(progress);
				_elm_lang$core$Native_Scheduler.rawSpawn(task);
			});
		}

		// end
		req.addEventListener('error', function() {
			return callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'RawNetworkError' }));
		});

		req.addEventListener('timeout', function() {
			return callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'RawTimeout' }));
		});

		req.addEventListener('load', function() {
			return callback(_elm_lang$core$Native_Scheduler.succeed(toResponse(req)));
		});

		req.open(request.verb, request.url, true);

		// set all the headers
		function setHeader(pair) {
			req.setRequestHeader(pair._0, pair._1);
		}
		A2(_elm_lang$core$List$map, setHeader, request.headers);

		// set the timeout
		req.timeout = settings.timeout;

		// enable this withCredentials thing
		req.withCredentials = settings.withCredentials;

		// ask for a specific MIME type for the response
		if (settings.desiredResponseType.ctor === 'Just')
		{
			req.overrideMimeType(settings.desiredResponseType._0);
		}

		// actuall send the request
		if(request.body.ctor === "BodyFormData")
		{
			req.send(request.body.formData)
		}
		else
		{
			req.send(request.body._0);
		}

		return function() {
			req.abort();
		};
	});
}


// deal with responses

function toResponse(req)
{
	var tag = req.responseType === 'blob' ? 'Blob' : 'Text'
	var response = tag === 'Blob' ? req.response : req.responseText;
	return {
		status: req.status,
		statusText: req.statusText,
		headers: parseHeaders(req.getAllResponseHeaders()),
		url: req.responseURL,
		value: { ctor: tag, _0: response }
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


function multipart(dataList)
{
	var formData = new FormData();

	while (dataList.ctor !== '[]')
	{
		var data = dataList._0;
		if (data.ctor === 'StringData')
		{
			formData.append(data._0, data._1);
		}
		else
		{
			var fileName = data._1.ctor === 'Nothing'
				? undefined
				: data._1._0;
			formData.append(data._0, data._2, fileName);
		}
		dataList = dataList._1;
	}

	return { ctor: 'BodyFormData', formData: formData };
}


function uriEncode(string)
{
	return encodeURIComponent(string);
}

function uriDecode(string)
{
	return decodeURIComponent(string);
}

return {
	send: F2(send),
	multipart: multipart,
	uriEncode: uriEncode,
	uriDecode: uriDecode
};

}();

var _evancz$elm_http$Http$send = _evancz$elm_http$Native_Http.send;
var _evancz$elm_http$Http$defaultSettings = {timeout: 0, onStart: _elm_lang$core$Maybe$Nothing, onProgress: _elm_lang$core$Maybe$Nothing, desiredResponseType: _elm_lang$core$Maybe$Nothing, withCredentials: false};
var _evancz$elm_http$Http$multipart = _evancz$elm_http$Native_Http.multipart;
var _evancz$elm_http$Http$uriDecode = _evancz$elm_http$Native_Http.uriDecode;
var _evancz$elm_http$Http$uriEncode = _evancz$elm_http$Native_Http.uriEncode;
var _evancz$elm_http$Http$queryEscape = function (string) {
	return A2(
		_elm_lang$core$String$join,
		'+',
		A2(
			_elm_lang$core$String$split,
			'%20',
			_evancz$elm_http$Http$uriEncode(string)));
};
var _evancz$elm_http$Http$queryPair = function (_p0) {
	var _p1 = _p0;
	return A2(
		_elm_lang$core$Basics_ops['++'],
		_evancz$elm_http$Http$queryEscape(_p1._0),
		A2(
			_elm_lang$core$Basics_ops['++'],
			'=',
			_evancz$elm_http$Http$queryEscape(_p1._1)));
};
var _evancz$elm_http$Http$url = F2(
	function (baseUrl, args) {
		var _p2 = args;
		if (_p2.ctor === '[]') {
			return baseUrl;
		} else {
			return A2(
				_elm_lang$core$Basics_ops['++'],
				baseUrl,
				A2(
					_elm_lang$core$Basics_ops['++'],
					'?',
					A2(
						_elm_lang$core$String$join,
						'&',
						A2(_elm_lang$core$List$map, _evancz$elm_http$Http$queryPair, args))));
		}
	});
var _evancz$elm_http$Http$Request = F4(
	function (a, b, c, d) {
		return {verb: a, headers: b, url: c, body: d};
	});
var _evancz$elm_http$Http$Settings = F5(
	function (a, b, c, d, e) {
		return {timeout: a, onStart: b, onProgress: c, desiredResponseType: d, withCredentials: e};
	});
var _evancz$elm_http$Http$Response = F5(
	function (a, b, c, d, e) {
		return {status: a, statusText: b, headers: c, url: d, value: e};
	});
var _evancz$elm_http$Http$TODO_implement_blob_in_another_library = {ctor: 'TODO_implement_blob_in_another_library'};
var _evancz$elm_http$Http$TODO_implement_file_in_another_library = {ctor: 'TODO_implement_file_in_another_library'};
var _evancz$elm_http$Http$BodyBlob = function (a) {
	return {ctor: 'BodyBlob', _0: a};
};
var _evancz$elm_http$Http$BodyFormData = {ctor: 'BodyFormData'};
var _evancz$elm_http$Http$ArrayBuffer = {ctor: 'ArrayBuffer'};
var _evancz$elm_http$Http$BodyString = function (a) {
	return {ctor: 'BodyString', _0: a};
};
var _evancz$elm_http$Http$string = _evancz$elm_http$Http$BodyString;
var _evancz$elm_http$Http$Empty = {ctor: 'Empty'};
var _evancz$elm_http$Http$empty = _evancz$elm_http$Http$Empty;
var _evancz$elm_http$Http$FileData = F3(
	function (a, b, c) {
		return {ctor: 'FileData', _0: a, _1: b, _2: c};
	});
var _evancz$elm_http$Http$BlobData = F3(
	function (a, b, c) {
		return {ctor: 'BlobData', _0: a, _1: b, _2: c};
	});
var _evancz$elm_http$Http$blobData = _evancz$elm_http$Http$BlobData;
var _evancz$elm_http$Http$StringData = F2(
	function (a, b) {
		return {ctor: 'StringData', _0: a, _1: b};
	});
var _evancz$elm_http$Http$stringData = _evancz$elm_http$Http$StringData;
var _evancz$elm_http$Http$Blob = function (a) {
	return {ctor: 'Blob', _0: a};
};
var _evancz$elm_http$Http$Text = function (a) {
	return {ctor: 'Text', _0: a};
};
var _evancz$elm_http$Http$RawNetworkError = {ctor: 'RawNetworkError'};
var _evancz$elm_http$Http$RawTimeout = {ctor: 'RawTimeout'};
var _evancz$elm_http$Http$BadResponse = F2(
	function (a, b) {
		return {ctor: 'BadResponse', _0: a, _1: b};
	});
var _evancz$elm_http$Http$UnexpectedPayload = function (a) {
	return {ctor: 'UnexpectedPayload', _0: a};
};
var _evancz$elm_http$Http$handleResponse = F2(
	function (handle, response) {
		if ((_elm_lang$core$Native_Utils.cmp(200, response.status) < 1) && (_elm_lang$core$Native_Utils.cmp(response.status, 300) < 0)) {
			var _p3 = response.value;
			if (_p3.ctor === 'Text') {
				return handle(_p3._0);
			} else {
				return _elm_lang$core$Task$fail(
					_evancz$elm_http$Http$UnexpectedPayload('Response body is a blob, expecting a string.'));
			}
		} else {
			return _elm_lang$core$Task$fail(
				A2(_evancz$elm_http$Http$BadResponse, response.status, response.statusText));
		}
	});
var _evancz$elm_http$Http$NetworkError = {ctor: 'NetworkError'};
var _evancz$elm_http$Http$Timeout = {ctor: 'Timeout'};
var _evancz$elm_http$Http$promoteError = function (rawError) {
	var _p4 = rawError;
	if (_p4.ctor === 'RawTimeout') {
		return _evancz$elm_http$Http$Timeout;
	} else {
		return _evancz$elm_http$Http$NetworkError;
	}
};
var _evancz$elm_http$Http$getString = function (url) {
	var request = {
		verb: 'GET',
		headers: _elm_lang$core$Native_List.fromArray(
			[]),
		url: url,
		body: _evancz$elm_http$Http$empty
	};
	return A2(
		_elm_lang$core$Task$andThen,
		A2(
			_elm_lang$core$Task$mapError,
			_evancz$elm_http$Http$promoteError,
			A2(_evancz$elm_http$Http$send, _evancz$elm_http$Http$defaultSettings, request)),
		_evancz$elm_http$Http$handleResponse(_elm_lang$core$Task$succeed));
};
var _evancz$elm_http$Http$fromJson = F2(
	function (decoder, response) {
		var decode = function (str) {
			var _p5 = A2(_elm_lang$core$Json_Decode$decodeString, decoder, str);
			if (_p5.ctor === 'Ok') {
				return _elm_lang$core$Task$succeed(_p5._0);
			} else {
				return _elm_lang$core$Task$fail(
					_evancz$elm_http$Http$UnexpectedPayload(_p5._0));
			}
		};
		return A2(
			_elm_lang$core$Task$andThen,
			A2(_elm_lang$core$Task$mapError, _evancz$elm_http$Http$promoteError, response),
			_evancz$elm_http$Http$handleResponse(decode));
	});
var _evancz$elm_http$Http$get = F2(
	function (decoder, url) {
		var request = {
			verb: 'GET',
			headers: _elm_lang$core$Native_List.fromArray(
				[]),
			url: url,
			body: _evancz$elm_http$Http$empty
		};
		return A2(
			_evancz$elm_http$Http$fromJson,
			decoder,
			A2(_evancz$elm_http$Http$send, _evancz$elm_http$Http$defaultSettings, request));
	});
var _evancz$elm_http$Http$post = F3(
	function (decoder, url, body) {
		var request = {
			verb: 'POST',
			headers: _elm_lang$core$Native_List.fromArray(
				[]),
			url: url,
			body: body
		};
		return A2(
			_evancz$elm_http$Http$fromJson,
			decoder,
			A2(_evancz$elm_http$Http$send, _evancz$elm_http$Http$defaultSettings, request));
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
							_elm_lang$core$Native_List.fromArray(
								[$new])),
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
	errors: _elm_lang$core$Native_List.fromArray(
		[])
};
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$Model = F2(
	function (a, b) {
		return {currentId: a, errors: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$Error = F3(
	function (a, b, c) {
		return {id: a, message: b, bugReport: c};
	});
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$Remove = function (a) {
	return {ctor: 'Remove', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$errorMessage = function (error) {
	var reportUrl = A2(
		_evancz$elm_http$Http$url,
		'https://github.com/Lattyware/massivedecks/issues/new',
		_elm_lang$core$Native_List.fromArray(
			[
				{
				ctor: '_Tuple2',
				_0: 'body',
				_1: _Lattyware$massivedecks$MassiveDecks_Components_Errors$reportText(error.message)
			}
			]));
	var bugReportLink = error.bugReport ? _elm_lang$core$Maybe$Just(
		A2(
			_elm_lang$html$Html$p,
			_elm_lang$core$Native_List.fromArray(
				[]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$a,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$href(reportUrl),
							_elm_lang$html$Html_Attributes$target('_blank')
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('bug'),
							_elm_lang$html$Html$text(' Report this as a bug.')
						]))
				]))) : _elm_lang$core$Maybe$Nothing;
	return A2(
		_elm_lang$html$Html$li,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('error')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[]),
				A2(
					_Lattyware$massivedecks$MassiveDecks_Util$andMaybe,
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$a,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$class('link'),
									A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
									A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
									_elm_lang$html$Html_Events$onClick(
									_Lattyware$massivedecks$MassiveDecks_Components_Errors$Remove(error.id))
								]),
							_elm_lang$core$Native_List.fromArray(
								[
									_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('times')
								])),
							A2(
							_elm_lang$html$Html$h5,
							_elm_lang$core$Native_List.fromArray(
								[]),
							_elm_lang$core$Native_List.fromArray(
								[
									_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('exclamation-triangle'),
									_elm_lang$html$Html$text(' Error')
								])),
							A2(
							_elm_lang$html$Html$div,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$class('mui-divider')
								]),
							_elm_lang$core$Native_List.fromArray(
								[])),
							A2(
							_elm_lang$html$Html$p,
							_elm_lang$core$Native_List.fromArray(
								[]),
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html$text(error.message)
								]))
						]),
					bugReportLink))
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$view = function (model) {
	return A2(
		_elm_lang$html$Html$ol,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$id('error-panel')
			]),
		A2(_elm_lang$core$List$map, _Lattyware$massivedecks$MassiveDecks_Components_Errors$errorMessage, model.errors));
};
var _Lattyware$massivedecks$MassiveDecks_Components_Errors$New = F2(
	function (a, b) {
		return {ctor: 'New', _0: a, _1: b};
	});

var _Lattyware$massivedecks$MassiveDecks_Components_Overlay$ifIdDecoder = A2(
	_elm_lang$core$Json_Decode$at,
	_elm_lang$core$Native_List.fromArray(
		['target', 'id']),
	_elm_lang$core$Json_Decode$string);
var _Lattyware$massivedecks$MassiveDecks_Components_Overlay$onClickIfId = F3(
	function (targetId, message, noOp) {
		return A2(
			_elm_lang$html$Html_Events$on,
			'click',
			A2(
				_elm_lang$core$Json_Decode$map,
				function (clickedId) {
					return _elm_lang$core$Native_Utils.eq(clickedId, targetId) ? message : noOp;
				},
				_Lattyware$massivedecks$MassiveDecks_Components_Overlay$ifIdDecoder));
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
		return _elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$id('mui-overlay'),
						A3(
						_Lattyware$massivedecks$MassiveDecks_Components_Overlay$onClickIfId,
						'mui-overlay',
						model.wrap(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Hide),
						model.wrap(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$NoOp)),
						A3(
						_Lattyware$massivedecks$MassiveDecks_Util$onKeyDown,
						'Escape',
						model.wrap(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Hide),
						model.wrap(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$NoOp)),
						_elm_lang$html$Html_Attributes$tabindex(0)
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						A2(
						_elm_lang$html$Html$div,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html_Attributes$class('overlay mui-panel')
							]),
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Native_List.fromArray(
								[
									A2(
									_elm_lang$html$Html$h1,
									_elm_lang$core$Native_List.fromArray(
										[]),
									_elm_lang$core$Native_List.fromArray(
										[
											_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon(_p2.icon),
											_elm_lang$html$Html$text(' '),
											_elm_lang$html$Html$text(_p2.title)
										]))
								]),
							A2(
								_elm_lang$core$Basics_ops['++'],
								_p2.contents,
								_elm_lang$core$Native_List.fromArray(
									[
										A2(
										_elm_lang$html$Html$p,
										_elm_lang$core$Native_List.fromArray(
											[
												_elm_lang$html$Html_Attributes$class('close-link')
											]),
										_elm_lang$core$Native_List.fromArray(
											[
												A2(
												_elm_lang$html$Html$a,
												_elm_lang$core$Native_List.fromArray(
													[
														_elm_lang$html$Html_Attributes$class('link'),
														A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
														A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
														_elm_lang$html$Html_Events$onClick(
														model.wrap(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Hide))
													]),
												_elm_lang$core$Native_List.fromArray(
													[
														_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('times'),
														_elm_lang$html$Html$text(' Close')
													]))
											]))
									]))))
					]))
			]);
	} else {
		return _elm_lang$core$Native_List.fromArray(
			[]);
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
							_elm_lang$html$Html_App$map(mapper),
							_p4.contents)));
			case 'Hide':
				return _Lattyware$massivedecks$MassiveDecks_Components_Overlay$Hide;
			default:
				return _Lattyware$massivedecks$MassiveDecks_Components_Overlay$NoOp;
		}
	});

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
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$DeckId = {ctor: 'DeckId'};

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
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ClearExistingGame = {ctor: 'ClearExistingGame'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobby = F2(
	function (a, b) {
		return {ctor: 'JoinLobby', _0: a, _1: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsExistingPlayer = F2(
	function (a, b) {
		return {ctor: 'JoinLobbyAsExistingPlayer', _0: a, _1: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinGivenLobbyAsNewPlayer = function (a) {
	return {ctor: 'JoinGivenLobbyAsNewPlayer', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsNewPlayer = {ctor: 'JoinLobbyAsNewPlayer'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ShowInfoMessage = function (a) {
	return {ctor: 'ShowInfoMessage', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$SetButtonsEnabled = function (a) {
	return {ctor: 'SetButtonsEnabled', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$CreateLobby = {ctor: 'CreateLobby'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$SubmitCurrentTab = {ctor: 'SubmitCurrentTab'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$GameCode = {ctor: 'GameCode'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Name = {ctor: 'Name'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Join = {ctor: 'Join'};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Create = {ctor: 'Create'};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Models$Model = F3(
	function (a, b, c) {
		return {decks: a, deckIdInput: b, loadingDecks: c};
	});

var _elm_lang$core$Random$onSelfMsg = F3(
	function (_p1, _p0, seed) {
		return _elm_lang$core$Task$succeed(seed);
	});
var _elm_lang$core$Random$magicNum8 = 2147483562;
var _elm_lang$core$Random$range = function (_p2) {
	return {ctor: '_Tuple2', _0: 0, _1: _elm_lang$core$Random$magicNum8};
};
var _elm_lang$core$Random$magicNum7 = 2137383399;
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
				A2(_elm_lang$core$Platform$sendToApp, router, value),
				function (_p7) {
					return A3(_elm_lang$core$Random$onEffects, router, _p5._1, newSeed);
				});
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
				var _v2 = A2(_elm_lang$core$List_ops['::'], value, list),
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
					_elm_lang$core$Native_List.fromArray(
						[]),
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
	function (_p56, callback) {
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
var _elm_lang$core$Random$initState = function (s$) {
	var s = A2(_elm_lang$core$Basics$max, s$, 0 - s$);
	var q = (s / (_elm_lang$core$Random$magicNum6 - 1)) | 0;
	var s2 = A2(_elm_lang$core$Basics_ops['%'], q, _elm_lang$core$Random$magicNum7 - 1);
	var s1 = A2(_elm_lang$core$Basics_ops['%'], s, _elm_lang$core$Random$magicNum6 - 1);
	return A2(_elm_lang$core$Random$State, s1 + 1, s2 + 1);
};
var _elm_lang$core$Random$next = function (_p60) {
	var _p61 = _p60;
	var _p63 = _p61._1;
	var _p62 = _p61._0;
	var k$ = (_p63 / _elm_lang$core$Random$magicNum3) | 0;
	var s2$ = (_elm_lang$core$Random$magicNum4 * (_p63 - (k$ * _elm_lang$core$Random$magicNum3))) - (k$ * _elm_lang$core$Random$magicNum5);
	var s2$$ = (_elm_lang$core$Native_Utils.cmp(s2$, 0) < 0) ? (s2$ + _elm_lang$core$Random$magicNum7) : s2$;
	var k = (_p62 / _elm_lang$core$Random$magicNum1) | 0;
	var s1$ = (_elm_lang$core$Random$magicNum0 * (_p62 - (k * _elm_lang$core$Random$magicNum1))) - (k * _elm_lang$core$Random$magicNum2);
	var s1$$ = (_elm_lang$core$Native_Utils.cmp(s1$, 0) < 0) ? (s1$ + _elm_lang$core$Random$magicNum6) : s1$;
	var z = s1$$ - s2$$;
	var z$ = (_elm_lang$core$Native_Utils.cmp(z, 1) < 0) ? (z + _elm_lang$core$Random$magicNum8) : z;
	return {
		ctor: '_Tuple2',
		_0: z$,
		_1: A2(_elm_lang$core$Random$State, s1$$, s2$$)
	};
};
var _elm_lang$core$Random$split = function (_p64) {
	var _p65 = _p64;
	var _p68 = _p65._1;
	var _p67 = _p65._0;
	var _p66 = _elm_lang$core$Basics$snd(
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
								var state$ = _p72._1;
								var _v27 = n - 1,
									_v28 = x + (acc * base),
									_v29 = state$;
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
				var state$ = _p74._1;
				return {
					ctor: '_Tuple2',
					_0: lo + A2(_elm_lang$core$Basics_ops['%'], v, k),
					_1: _elm_lang$core$Random$Seed(
						_elm_lang$core$Native_Utils.update(
							_p75,
							{state: state$}))
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
	_elm_lang$core$Time$now,
	function (t) {
		return _elm_lang$core$Task$succeed(
			_elm_lang$core$Random$initialSeed(
				_elm_lang$core$Basics$round(t)));
	});
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

var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Models$Model = F9(
	function (a, b, c, d, e, f, g, h, i) {
		return {lobby: a, hand: b, config: c, playing: d, browserNotifications: e, secret: f, init: g, notification: h, qrNeedsRendering: i};
	});

var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Models$Model = F9(
	function (a, b, c, d, e, f, g, h, i) {
		return {lobby: a, init: b, nameInput: c, gameCodeInput: d, info: e, errors: f, overlay: g, buttonsEnabled: h, tabs: i};
	});

var _Lattyware$massivedecks$MassiveDecks_Components_About$contents = _elm_lang$core$Native_List.fromArray(
	[
		A2(
		_elm_lang$html$Html$p,
		_elm_lang$core$Native_List.fromArray(
			[]),
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html$text('Massive Decks is a web game based on the excellent '),
				A2(
				_elm_lang$html$Html$a,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$href('https://cardsagainsthumanity.com/'),
						_elm_lang$html$Html_Attributes$target('_blank')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('Cards against Humanity')
					])),
				_elm_lang$html$Html$text(' - a party game where you play white cards to try and produce the most amusing outcome when '),
				_elm_lang$html$Html$text('combined with the given black card.')
			])),
		A2(
		_elm_lang$html$Html$p,
		_elm_lang$core$Native_List.fromArray(
			[]),
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html$text('Massive Decks is also inspired by: '),
				A2(
				_elm_lang$html$Html$ul,
				_elm_lang$core$Native_List.fromArray(
					[]),
				_elm_lang$core$Native_List.fromArray(
					[
						A2(
						_elm_lang$html$Html$li,
						_elm_lang$core$Native_List.fromArray(
							[]),
						_elm_lang$core$Native_List.fromArray(
							[
								A2(
								_elm_lang$html$Html$a,
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html_Attributes$href('https://www.cardcastgame.com/'),
										_elm_lang$html$Html_Attributes$target('_blank')
									]),
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html$text('Cardcast')
									])),
								_elm_lang$html$Html$text(' - an app that allows you to play on a ChromeCast.')
							])),
						A2(
						_elm_lang$html$Html$li,
						_elm_lang$core$Native_List.fromArray(
							[]),
						_elm_lang$core$Native_List.fromArray(
							[
								A2(
								_elm_lang$html$Html$a,
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html_Attributes$href('http://pretendyoure.xyz/zy/'),
										_elm_lang$html$Html_Attributes$target('_blank')
									]),
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html$text('Pretend You\'re Xyzzy')
									])),
								_elm_lang$html$Html$text(' - a web game where you can jump in with people you don\'t know.')
							]))
					]))
			])),
		A2(
		_elm_lang$html$Html$p,
		_elm_lang$core$Native_List.fromArray(
			[]),
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html$text('This is an open source game developed in '),
				A2(
				_elm_lang$html$Html$a,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$href('http://elm-lang.org/'),
						_elm_lang$html$Html_Attributes$target('_blank')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('Elm')
					])),
				_elm_lang$html$Html$text(' for the client and '),
				A2(
				_elm_lang$html$Html$a,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$href('http://www.scala-lang.org/'),
						_elm_lang$html$Html_Attributes$target('_blank')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('Scala')
					])),
				_elm_lang$html$Html$text(' for the server.')
			])),
		A2(
		_elm_lang$html$Html$p,
		_elm_lang$core$Native_List.fromArray(
			[]),
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html$text('We also use: '),
				A2(
				_elm_lang$html$Html$ul,
				_elm_lang$core$Native_List.fromArray(
					[]),
				_elm_lang$core$Native_List.fromArray(
					[
						A2(
						_elm_lang$html$Html$li,
						_elm_lang$core$Native_List.fromArray(
							[]),
						_elm_lang$core$Native_List.fromArray(
							[
								A2(
								_elm_lang$html$Html$a,
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html_Attributes$href('https://www.cardcastgame.com/'),
										_elm_lang$html$Html_Attributes$target('_blank')
									]),
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html$text('Cardcast')
									])),
								_elm_lang$html$Html$text('\'s APIs for getting decks of cards (you can go there to make your own!).')
							])),
						A2(
						_elm_lang$html$Html$li,
						_elm_lang$core$Native_List.fromArray(
							[]),
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html$text('The '),
								A2(
								_elm_lang$html$Html$a,
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html_Attributes$href('https://www.playframework.com/'),
										_elm_lang$html$Html_Attributes$target('_blank')
									]),
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html$text('Play framework')
									]))
							])),
						A2(
						_elm_lang$html$Html$li,
						_elm_lang$core$Native_List.fromArray(
							[]),
						_elm_lang$core$Native_List.fromArray(
							[
								A2(
								_elm_lang$html$Html$a,
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html_Attributes$href('http://lesscss.org/'),
										_elm_lang$html$Html_Attributes$target('_blank')
									]),
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html$text('Less')
									]))
							])),
						A2(
						_elm_lang$html$Html$li,
						_elm_lang$core$Native_List.fromArray(
							[]),
						_elm_lang$core$Native_List.fromArray(
							[
								A2(
								_elm_lang$html$Html$a,
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html_Attributes$href('https://fortawesome.github.io/Font-Awesome/'),
										_elm_lang$html$Html_Attributes$target('_blank')
									]),
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html$text('Font Awesome')
									]))
							])),
						A2(
						_elm_lang$html$Html$li,
						_elm_lang$core$Native_List.fromArray(
							[]),
						_elm_lang$core$Native_List.fromArray(
							[
								A2(
								_elm_lang$html$Html$a,
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html_Attributes$href('https://www.muicss.com'),
										_elm_lang$html$Html_Attributes$target('_blank')
									]),
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html$text('MUI')
									]))
							]))
					]))
			])),
		A2(
		_elm_lang$html$Html$p,
		_elm_lang$core$Native_List.fromArray(
			[]),
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html$text('Bug reports and contributions are welcome on the '),
				A2(
				_elm_lang$html$Html$a,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$href('https://github.com/Lattyware/massivedecks'),
						_elm_lang$html$Html_Attributes$target('_blank')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('GitHub repository')
					])),
				_elm_lang$html$Html$text(', where you can find the complete source to the game, under the GPLv3 license. The game concept '),
				_elm_lang$html$Html$text('\'Cards against Humanity\' is used under a '),
				A2(
				_elm_lang$html$Html$a,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$href('https://creativecommons.org/licenses/by-nc-sa/2.0/'),
						_elm_lang$html$Html_Attributes$target('_blank')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('Creative Commons BY-NC-SA 2.0 license')
					])),
				_elm_lang$html$Html$text(' granted by '),
				A2(
				_elm_lang$html$Html$a,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$href('https://cardsagainsthumanity.com/'),
						_elm_lang$html$Html_Attributes$target('_blank')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('Cards against Humanity')
					]))
			]))
	]);
var _Lattyware$massivedecks$MassiveDecks_Components_About$title = 'About';
var _Lattyware$massivedecks$MassiveDecks_Components_About$icon = 'info-circle';
var _Lattyware$massivedecks$MassiveDecks_Components_About$show = _Lattyware$massivedecks$MassiveDecks_Components_Overlay$Show(
	A3(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$Overlay, _Lattyware$massivedecks$MassiveDecks_Components_About$icon, _Lattyware$massivedecks$MassiveDecks_Components_About$title, _Lattyware$massivedecks$MassiveDecks_Components_About$contents));

var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$createLobbyButton = function (enabled) {
	return A2(
		_elm_lang$html$Html$button,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--large mui-btn--primary'),
				_elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$CreateLobby),
				_elm_lang$html$Html_Attributes$disabled(
				_elm_lang$core$Basics$not(enabled))
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html$text('Create Game')
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$joinLobbyButton = function (enabled) {
	return A2(
		_elm_lang$html$Html$button,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--large mui-btn--primary'),
				_elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsNewPlayer),
				_elm_lang$html$Html_Attributes$disabled(
				_elm_lang$core$Basics$not(enabled))
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html$text('Join Game')
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$renderTab = F4(
	function (nameEntered, gameCodeEntered, model, tab) {
		var _p0 = tab;
		if (_p0.ctor === 'Create') {
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$createLobbyButton(nameEntered && model.buttonsEnabled)
				]);
		} else {
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Components_Input$view(model.gameCodeInput),
					_Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$joinLobbyButton(nameEntered && (gameCodeEntered && model.buttonsEnabled))
				]);
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$view = function (model) {
	var inactive = {
		ctor: '_Tuple2',
		_0: _elm_lang$core$Native_List.fromArray(
			[]),
		_1: ''
	};
	var active = {
		ctor: '_Tuple2',
		_0: _elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('mui--is-active')
			]),
		_1: ' mui--is-active'
	};
	var _p1 = (!_elm_lang$core$Native_Utils.eq(model.init.gameCode, _elm_lang$core$Maybe$Nothing)) ? {ctor: '_Tuple2', _0: inactive, _1: active} : {ctor: '_Tuple2', _0: active, _1: inactive};
	var createLiClass = _p1._0._0;
	var createDivClass = _p1._0._1;
	var joinLiClass = _p1._1._0;
	var joinDivClass = _p1._1._1;
	var gameCodeEntered = _elm_lang$core$Basics$not(
		_elm_lang$core$String$isEmpty(model.gameCodeInput.value));
	var nameEntered = _elm_lang$core$Basics$not(
		_elm_lang$core$String$isEmpty(model.nameInput.value));
	return A2(
		_elm_lang$html$Html$div,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$id('start-screen')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$id('start-screen-content'),
						_elm_lang$html$Html_Attributes$class('mui-panel')
					]),
				A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$h1,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$class('mui--divider-bottom')
								]),
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html$text('Massive Decks')
								]))
						]),
					A2(
						_elm_lang$core$Basics_ops['++'],
						A2(
							_elm_lang$core$Maybe$withDefault,
							_elm_lang$core$Native_List.fromArray(
								[]),
							A2(
								_elm_lang$core$Maybe$map,
								function (message) {
									return _elm_lang$core$Native_List.fromArray(
										[
											A2(
											_elm_lang$html$Html$div,
											_elm_lang$core$Native_List.fromArray(
												[
													_elm_lang$html$Html_Attributes$class('info-message mui--divider-bottom')
												]),
											_elm_lang$core$Native_List.fromArray(
												[
													_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('info-circle'),
													_elm_lang$html$Html$text(' '),
													_elm_lang$html$Html$text(message)
												]))
										]);
								},
								model.info)),
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Native_List.fromArray(
								[
									_Lattyware$massivedecks$MassiveDecks_Components_Input$view(model.nameInput)
								]),
							A2(
								_elm_lang$core$Basics_ops['++'],
								A2(
									_Lattyware$massivedecks$MassiveDecks_Components_Tabs$view,
									A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$renderTab, nameEntered, gameCodeEntered, model),
									model.tabs),
								_elm_lang$core$Native_List.fromArray(
									[
										A2(
										_elm_lang$html$Html$a,
										_elm_lang$core$Native_List.fromArray(
											[
												_elm_lang$html$Html_Attributes$class('about-link mui--divider-top link'),
												A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
												A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
												_elm_lang$html$Html_Events$onClick(
												_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$OverlayMessage(_Lattyware$massivedecks$MassiveDecks_Components_About$show))
											]),
										_elm_lang$core$Native_List.fromArray(
											[
												_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('question-circle'),
												_elm_lang$html$Html$text(' About')
											])),
										A2(
										_elm_lang$html$Html$div,
										_elm_lang$core$Native_List.fromArray(
											[
												_elm_lang$html$Html_Attributes$id('forkongithub')
											]),
										_elm_lang$core$Native_List.fromArray(
											[
												A2(
												_elm_lang$html$Html$div,
												_elm_lang$core$Native_List.fromArray(
													[]),
												_elm_lang$core$Native_List.fromArray(
													[
														A2(
														_elm_lang$html$Html$a,
														_elm_lang$core$Native_List.fromArray(
															[
																_elm_lang$html$Html_Attributes$href('https://github.com/lattyware/massivedecks'),
																_elm_lang$html$Html_Attributes$target('_blank')
															]),
														_elm_lang$core$Native_List.fromArray(
															[
																_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('github'),
																_elm_lang$html$Html$text(' Fork me on GitHub')
															]))
													]))
											]))
									]))))))
			]));
};

var _elm_lang$websocket$Native_WebSocket = function() {

function open(url, settings)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		try
		{
			var socket = new WebSocket(url);
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
				_elm_lang$core$Native_List.fromArray(
					[value]));
		} else {
			return _elm_lang$core$Maybe$Just(
				A2(_elm_lang$core$List_ops['::'], value, _p1._0));
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
									_elm_lang$core$Native_List.fromArray(
										[]),
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
			t1,
			function (_p4) {
				return t2;
			});
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
			A2(
				_elm_lang$core$Task$andThen,
				A2(_elm_lang$websocket$WebSocket$open, name, router),
				goodOpen),
			badOpen);
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
						getNewSockets,
						function (newSockets) {
							return A2(
								_elm_lang$core$Task$andThen,
								A3(_elm_lang$websocket$WebSocket$attemptOpen, router, 0, name),
								function (pid) {
									return _elm_lang$core$Task$succeed(
										A3(
											_elm_lang$core$Dict$insert,
											name,
											A2(_elm_lang$websocket$WebSocket$Opening, 0, pid),
											newSockets));
								});
						});
				});
			var newEntries = A2(
				_elm_lang$core$Dict$union,
				newQueues,
				A2(
					_elm_lang$core$Dict$map,
					F2(
						function (k, v) {
							return _elm_lang$core$Native_List.fromArray(
								[]);
						}),
					newSubs));
			return A2(
				_elm_lang$core$Task$andThen,
				A6(
					_elm_lang$core$Dict$merge,
					leftStep,
					bothStep,
					rightStep,
					newEntries,
					state.sockets,
					_elm_lang$core$Task$succeed(_elm_lang$core$Dict$empty)),
				function (newSockets) {
					return _elm_lang$core$Task$succeed(
						A3(_elm_lang$websocket$WebSocket$State, newSockets, newQueues, newSubs));
				});
		};
		var sendMessagesGetNewQueues = A3(_elm_lang$websocket$WebSocket$sendMessagesHelp, cmds, state.sockets, state.queues);
		return A2(_elm_lang$core$Task$andThen, sendMessagesGetNewQueues, cleanup);
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
						_elm_lang$core$Native_List.fromArray(
							[]),
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
						A3(_elm_lang$websocket$WebSocket$attemptOpen, router, 0, _p21),
						function (pid) {
							return _elm_lang$core$Task$succeed(
								A3(
									_elm_lang$websocket$WebSocket$updateSocket,
									_p21,
									A2(_elm_lang$websocket$WebSocket$Opening, 0, pid),
									state));
						});
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
							A3(_elm_lang$websocket$WebSocket$attemptOpen, router, _p26 + 1, _p27),
							function (pid) {
								return _elm_lang$core$Task$succeed(
									A3(
										_elm_lang$websocket$WebSocket$updateSocket,
										_p27,
										A2(_elm_lang$websocket$WebSocket$Opening, _p26 + 1, pid),
										state));
							});
					} else {
						return _elm_lang$core$Task$succeed(state);
					}
				}
		}
	});
_elm_lang$core$Native_Platform.effectManagers['WebSocket'] = {pkg: 'elm-lang/websocket', init: _elm_lang$websocket$WebSocket$init, onEffects: _elm_lang$websocket$WebSocket$onEffects, onSelfMsg: _elm_lang$websocket$WebSocket$onSelfMsg, tag: 'fx', cmdMap: _elm_lang$websocket$WebSocket$cmdMap, subMap: _elm_lang$websocket$WebSocket$subMap};

var _elm_lang$animation_frame$Native_AnimationFrame = function()
{

var hasStartTime =
	window.performance &&
	window.performance.timing &&
	window.performance.timing.navigationStart;

var navStart = hasStartTime
	? window.performance.timing.navigationStart
	: Date.now();

var rAF = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
{
	var id = requestAnimationFrame(function(time) {
		var timeNow = time
			? (time > navStart ? time : time + navStart)
			: Date.now();

		callback(_elm_lang$core$Native_Scheduler.succeed(timeNow));
	});

	return function() {
		cancelAnimationFrame(id);
	};
});

return {
	rAF: rAF
};

}();

var _elm_lang$animation_frame$AnimationFrame$rAF = _elm_lang$animation_frame$Native_AnimationFrame.rAF;
var _elm_lang$animation_frame$AnimationFrame$subscription = _elm_lang$core$Native_Platform.leaf('AnimationFrame');
var _elm_lang$animation_frame$AnimationFrame$State = F3(
	function (a, b, c) {
		return {subs: a, request: b, oldTime: c};
	});
var _elm_lang$animation_frame$AnimationFrame$init = _elm_lang$core$Task$succeed(
	A3(
		_elm_lang$animation_frame$AnimationFrame$State,
		_elm_lang$core$Native_List.fromArray(
			[]),
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
						_elm_lang$core$Native_List.fromArray(
							[]),
						_elm_lang$core$Maybe$Nothing,
						_p4));
			} else {
				return A2(
					_elm_lang$core$Task$andThen,
					_elm_lang$core$Process$spawn(
						A2(
							_elm_lang$core$Task$andThen,
							_elm_lang$animation_frame$AnimationFrame$rAF,
							_elm_lang$core$Platform$sendToSelf(router))),
					function (pid) {
						return A2(
							_elm_lang$core$Task$andThen,
							_elm_lang$core$Time$now,
							function (time) {
								return _elm_lang$core$Task$succeed(
									A3(
										_elm_lang$animation_frame$AnimationFrame$State,
										subs,
										_elm_lang$core$Maybe$Just(pid),
										time));
							});
					});
			}
		} else {
			if (_p2._1.ctor === '[]') {
				return A2(
					_elm_lang$core$Task$andThen,
					_elm_lang$core$Process$kill(_p2._0._0),
					function (_p3) {
						return _elm_lang$core$Task$succeed(
							A3(
								_elm_lang$animation_frame$AnimationFrame$State,
								_elm_lang$core$Native_List.fromArray(
									[]),
								_elm_lang$core$Maybe$Nothing,
								_p4));
					});
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
			_elm_lang$core$Process$spawn(
				A2(
					_elm_lang$core$Task$andThen,
					_elm_lang$animation_frame$AnimationFrame$rAF,
					_elm_lang$core$Platform$sendToSelf(router))),
			function (pid) {
				return A2(
					_elm_lang$core$Task$andThen,
					_elm_lang$core$Task$sequence(
						A2(_elm_lang$core$List$map, send, _p10)),
					function (_p9) {
						return _elm_lang$core$Task$succeed(
							A3(
								_elm_lang$animation_frame$AnimationFrame$State,
								_p10,
								_elm_lang$core$Maybe$Just(pid),
								newTime));
					});
			});
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
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$id(containerId)
			]),
		_elm_lang$core$Native_List.fromArray(
			[]));
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

var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$ruleNameToId = function (name) {
	var _p0 = name;
	if (_p0 === 'reboot') {
		return _elm_lang$core$Maybe$Just(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$Reboot);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$houseRuleDecoder = A2(
	_elm_lang$core$Json_Decode$customDecoder,
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
	_elm_lang$core$Json_Decode$object2,
	_Lattyware$massivedecks$MassiveDecks_Models_Player$Secret,
	A2(_elm_lang$core$Json_Decode_ops[':='], 'id', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'secret', _elm_lang$core$Json_Decode$string));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responseDecoder = A3(
	_elm_lang$core$Json_Decode$object2,
	_Lattyware$massivedecks$MassiveDecks_Models_Card$Response,
	A2(_elm_lang$core$Json_Decode_ops[':='], 'id', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'text', _elm_lang$core$Json_Decode$string));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$callDecoder = A3(
	_elm_lang$core$Json_Decode$object2,
	_Lattyware$massivedecks$MassiveDecks_Models_Card$Call,
	A2(_elm_lang$core$Json_Decode_ops[':='], 'id', _elm_lang$core$Json_Decode$string),
	A2(
		_elm_lang$core$Json_Decode_ops[':='],
		'parts',
		_elm_lang$core$Json_Decode$list(_elm_lang$core$Json_Decode$string)));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playedByAndWinnerDecoder = A3(
	_elm_lang$core$Json_Decode$object2,
	_Lattyware$massivedecks$MassiveDecks_Models_Player$PlayedByAndWinner,
	A2(
		_elm_lang$core$Json_Decode_ops[':='],
		'playedBy',
		_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder)),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'winner', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$revealedResponsesDecoder = A3(
	_elm_lang$core$Json_Decode$object2,
	_Lattyware$massivedecks$MassiveDecks_Models_Card$RevealedResponses,
	A2(
		_elm_lang$core$Json_Decode_ops[':='],
		'cards',
		_elm_lang$core$Json_Decode$list(
			_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responseDecoder))),
	_elm_lang$core$Json_Decode$maybe(
		A2(_elm_lang$core$Json_Decode_ops[':='], 'playedByAndWinner', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playedByAndWinnerDecoder)));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$finishedRoundDecoder = A5(
	_elm_lang$core$Json_Decode$object4,
	_Lattyware$massivedecks$MassiveDecks_Models_Game$FinishedRound,
	A2(_elm_lang$core$Json_Decode_ops[':='], 'czar', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'call', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$callDecoder),
	A2(
		_elm_lang$core$Json_Decode_ops[':='],
		'cards',
		_elm_lang$core$Json_Decode$list(
			_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responseDecoder))),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'playedByAndWinner', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playedByAndWinnerDecoder));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerStatusDecoder = A2(
	_elm_lang$core$Json_Decode$customDecoder,
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
	_elm_lang$core$Json_Decode$object6,
	_Lattyware$massivedecks$MassiveDecks_Models_Player$Player,
	A2(_elm_lang$core$Json_Decode_ops[':='], 'id', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'name', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'status', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerStatusDecoder),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'score', _elm_lang$core$Json_Decode$int),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'disconnected', _elm_lang$core$Json_Decode$bool),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'left', _elm_lang$core$Json_Decode$bool));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder = A2(
	_elm_lang$core$Json_Decode$object1,
	_Lattyware$massivedecks$MassiveDecks_Models_Card$Hand,
	A2(
		_elm_lang$core$Json_Decode_ops[':='],
		'hand',
		_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responseDecoder)));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$deckInfoDecoder = A5(
	_elm_lang$core$Json_Decode$object4,
	_Lattyware$massivedecks$MassiveDecks_Models_Game$DeckInfo,
	A2(_elm_lang$core$Json_Decode_ops[':='], 'id', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'name', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'calls', _elm_lang$core$Json_Decode$int),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'responses', _elm_lang$core$Json_Decode$int));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$configDecoder = A3(
	_elm_lang$core$Json_Decode$object2,
	_Lattyware$massivedecks$MassiveDecks_Models_Game$Config,
	A2(
		_elm_lang$core$Json_Decode_ops[':='],
		'decks',
		_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$deckInfoDecoder)),
	A2(
		_elm_lang$core$Json_Decode_ops[':='],
		'houseRules',
		_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$houseRuleDecoder)));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$ResponsesTransport = F2(
	function (a, b) {
		return {hidden: a, revealed: b};
	});
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responsesTransportDecoder = A3(
	_elm_lang$core$Json_Decode$object2,
	_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$ResponsesTransport,
	_elm_lang$core$Json_Decode$maybe(
		A2(_elm_lang$core$Json_Decode_ops[':='], 'hidden', _elm_lang$core$Json_Decode$int)),
	_elm_lang$core$Json_Decode$maybe(
		A2(_elm_lang$core$Json_Decode_ops[':='], 'revealed', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$revealedResponsesDecoder)));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responsesDecoder = A2(
	_elm_lang$core$Json_Decode$customDecoder,
	_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responsesTransportDecoder,
	function (transport) {
		var _p1 = transport.hidden;
		if (_p1.ctor === 'Just') {
			var _p2 = transport.revealed;
			if (_p2.ctor === 'Just') {
				return _elm_lang$core$Result$Err('Got both count and cards.');
			} else {
				return _elm_lang$core$Result$Ok(
					_Lattyware$massivedecks$MassiveDecks_Models_Card$Hidden(_p1._0));
			}
		} else {
			var _p3 = transport.revealed;
			if (_p3.ctor === 'Just') {
				return _elm_lang$core$Result$Ok(
					_Lattyware$massivedecks$MassiveDecks_Models_Card$Revealed(_p3._0));
			} else {
				return _elm_lang$core$Result$Err('Got neither count nor cards.');
			}
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$roundDecoder = A4(
	_elm_lang$core$Json_Decode$object3,
	_Lattyware$massivedecks$MassiveDecks_Models_Game$Round,
	A2(_elm_lang$core$Json_Decode_ops[':='], 'czar', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'call', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$callDecoder),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'responses', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responsesDecoder));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$lobbyDecoder = A5(
	_elm_lang$core$Json_Decode$object4,
	_Lattyware$massivedecks$MassiveDecks_Models_Game$Lobby,
	A2(_elm_lang$core$Json_Decode_ops[':='], 'gameCode', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'config', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$configDecoder),
	A2(
		_elm_lang$core$Json_Decode_ops[':='],
		'players',
		_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerDecoder)),
	_elm_lang$core$Json_Decode$maybe(
		A2(_elm_lang$core$Json_Decode_ops[':='], 'round', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$roundDecoder)));
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$lobbyAndHandDecoder = A3(
	_elm_lang$core$Json_Decode$object2,
	_Lattyware$massivedecks$MassiveDecks_Models_Game$LobbyAndHand,
	A2(_elm_lang$core$Json_Decode_ops[':='], 'lobby', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$lobbyDecoder),
	A2(_elm_lang$core$Json_Decode_ops[':='], 'hand', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder));

var _Lattyware$massivedecks$MassiveDecks_Models_Event$ConfigChange = function (a) {
	return {ctor: 'ConfigChange', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$GameEnd = {ctor: 'GameEnd'};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$GameStart = {ctor: 'GameStart'};
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
				_elm_lang$core$Json_Decode$object1,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$Sync,
				A2(_elm_lang$core$Json_Decode_ops[':='], 'lobbyAndHand', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$lobbyAndHandDecoder));
		case 'PlayerJoin':
			return A2(
				_elm_lang$core$Json_Decode$object1,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerJoin,
				A2(_elm_lang$core$Json_Decode_ops[':='], 'player', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerDecoder));
		case 'PlayerStatus':
			return A3(
				_elm_lang$core$Json_Decode$object2,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerStatus,
				A2(_elm_lang$core$Json_Decode_ops[':='], 'player', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
				A2(_elm_lang$core$Json_Decode_ops[':='], 'status', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerStatusDecoder));
		case 'PlayerLeft':
			return A2(
				_elm_lang$core$Json_Decode$object1,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerLeft,
				A2(_elm_lang$core$Json_Decode_ops[':='], 'player', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder));
		case 'PlayerDisconnect':
			return A2(
				_elm_lang$core$Json_Decode$object1,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerDisconnect,
				A2(_elm_lang$core$Json_Decode_ops[':='], 'player', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder));
		case 'PlayerReconnect':
			return A2(
				_elm_lang$core$Json_Decode$object1,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerReconnect,
				A2(_elm_lang$core$Json_Decode_ops[':='], 'player', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder));
		case 'PlayerScoreChange':
			return A3(
				_elm_lang$core$Json_Decode$object2,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$PlayerScoreChange,
				A2(_elm_lang$core$Json_Decode_ops[':='], 'player', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
				A2(_elm_lang$core$Json_Decode_ops[':='], 'score', _elm_lang$core$Json_Decode$int));
		case 'HandChange':
			return A2(
				_elm_lang$core$Json_Decode$object1,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$HandChange,
				A2(_elm_lang$core$Json_Decode_ops[':='], 'hand', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder));
		case 'RoundStart':
			return A3(
				_elm_lang$core$Json_Decode$object2,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$RoundStart,
				A2(_elm_lang$core$Json_Decode_ops[':='], 'czar', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerIdDecoder),
				A2(_elm_lang$core$Json_Decode_ops[':='], 'call', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$callDecoder));
		case 'RoundPlayed':
			return A2(
				_elm_lang$core$Json_Decode$object1,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$RoundPlayed,
				A2(_elm_lang$core$Json_Decode_ops[':='], 'playedCards', _elm_lang$core$Json_Decode$int));
		case 'RoundJudging':
			return A2(
				_elm_lang$core$Json_Decode$object1,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$RoundJudging,
				A2(
					_elm_lang$core$Json_Decode_ops[':='],
					'playedCards',
					_elm_lang$core$Json_Decode$list(
						_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$responseDecoder))));
		case 'RoundEnd':
			return A2(
				_elm_lang$core$Json_Decode$object1,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$RoundEnd,
				A2(_elm_lang$core$Json_Decode_ops[':='], 'finishedRound', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$finishedRoundDecoder));
		case 'GameStart':
			return _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_Models_Event$GameStart);
		case 'GameEnd':
			return _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_Models_Event$GameEnd);
		case 'ConfigChange':
			return A2(
				_elm_lang$core$Json_Decode$object1,
				_Lattyware$massivedecks$MassiveDecks_Models_Event$ConfigChange,
				A2(_elm_lang$core$Json_Decode_ops[':='], 'config', _Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$configDecoder));
		default:
			return _elm_lang$core$Json_Decode$fail(
				A2(_elm_lang$core$Basics_ops['++'], _p0, ' is not a recognised event.'));
	}
};
var _Lattyware$massivedecks$MassiveDecks_Models_Event$eventDecoder = A2(
	_elm_lang$core$Json_Decode$andThen,
	A2(_elm_lang$core$Json_Decode_ops[':='], 'event', _elm_lang$core$Json_Decode$string),
	_Lattyware$massivedecks$MassiveDecks_Models_Event$specificEventDecoder);
var _Lattyware$massivedecks$MassiveDecks_Models_Event$fromJson = function (json) {
	return A2(_elm_lang$core$Json_Decode$decodeString, _Lattyware$massivedecks$MassiveDecks_Models_Event$eventDecoder, json);
};

var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodeName = function (name) {
	return _elm_lang$core$Json_Encode$object(
		_elm_lang$core$Native_List.fromArray(
			[
				{
				ctor: '_Tuple2',
				_0: 'name',
				_1: _elm_lang$core$Json_Encode$string(name)
			}
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerId = function (playerId) {
	return _elm_lang$core$Json_Encode$int(playerId);
};
var _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerSecret = function (playerSecret) {
	return _elm_lang$core$Json_Encode$object(
		_elm_lang$core$Native_List.fromArray(
			[
				{
				ctor: '_Tuple2',
				_0: 'id',
				_1: _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerId(playerSecret.id)
			},
				{
				ctor: '_Tuple2',
				_0: 'secret',
				_1: _elm_lang$core$Json_Encode$string(playerSecret.secret)
			}
			]));
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
				_elm_lang$core$Native_List.fromArray(
					[
						{
						ctor: '_Tuple2',
						_0: 'command',
						_1: _elm_lang$core$Json_Encode$string(action)
					},
						{
						ctor: '_Tuple2',
						_0: 'secret',
						_1: _Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerSecret(playerSecret)
					}
					]),
				rest));
	});

var _Lattyware$massivedecks$MassiveDecks_API_Request$errorKeyDecoder = A2(
	_elm_lang$core$Json_Decode$at,
	_elm_lang$core$Native_List.fromArray(
		['error']),
	_elm_lang$core$Json_Decode$string);
var _Lattyware$massivedecks$MassiveDecks_API_Request$jsonBody = function (value) {
	return _evancz$elm_http$Http$string(
		A2(_elm_lang$core$Json_Encode$encode, 0, value));
};
var _Lattyware$massivedecks$MassiveDecks_API_Request$jsonContentType = _elm_lang$core$Native_List.fromArray(
	[
		{ctor: '_Tuple2', _0: 'Content-Type', _1: 'application/json'}
	]);
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
		case 'Communication':
			if (_p0._0.ctor === 'RawTimeout') {
				return A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$New, 'Timed out trying to connect to the server.', false);
			} else {
				return A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$New, 'There was a network error trying to connect to the server.', false);
			}
		case 'Malformed':
			return A2(
				_Lattyware$massivedecks$MassiveDecks_Components_Errors$New,
				A2(_elm_lang$core$Basics_ops['++'], 'The response recieved from the server was incorrect: ', _p0._0),
				true);
		default:
			return A2(
				_Lattyware$massivedecks$MassiveDecks_Components_Errors$New,
				A2(
					_elm_lang$core$Basics_ops['++'],
					'Recieved an unexpected response (',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(_p0._0),
						A2(_elm_lang$core$Basics_ops['++'], ') from the server: ', _p0._1))),
				true);
	}
};
var _Lattyware$massivedecks$MassiveDecks_API_Request$errorHandler = F3(
	function (knownHandler, errorMessageWrapper, error) {
		var _p1 = error;
		if (_p1.ctor === 'Known') {
			return knownHandler(_p1._0);
		} else {
			return errorMessageWrapper(
				_Lattyware$massivedecks$MassiveDecks_API_Request$genericErrorHandler(error));
		}
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$Request = F5(
	function (a, b, c, d, e) {
		return {verb: a, url: b, body: c, errors: d, resultDecoder: e};
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
var _Lattyware$massivedecks$MassiveDecks_API_Request$Unknown = F2(
	function (a, b) {
		return {ctor: 'Unknown', _0: a, _1: b};
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$Known = function (a) {
	return {ctor: 'Known', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_API_Request$Malformed = function (a) {
	return {ctor: 'Malformed', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_API_Request$handleSuccess = F2(
	function (resultDecoder, response) {
		var _p2 = response.value;
		if (_p2.ctor === 'Text') {
			return A2(
				_elm_lang$core$Result$formatError,
				_Lattyware$massivedecks$MassiveDecks_API_Request$Malformed,
				A2(_elm_lang$core$Json_Decode$decodeString, resultDecoder, _p2._0));
		} else {
			return _elm_lang$core$Result$Err(
				_Lattyware$massivedecks$MassiveDecks_API_Request$Malformed('Recieved binary data instead of expected JSON.'));
		}
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$handleFailure = F2(
	function (errors, response) {
		var _p3 = response.value;
		if (_p3.ctor === 'Text') {
			var _p7 = _p3._0;
			var _p4 = A2(_elm_lang$core$Json_Decode$decodeString, _Lattyware$massivedecks$MassiveDecks_API_Request$errorKeyDecoder, _p7);
			if (_p4.ctor === 'Ok') {
				var decoder = A2(
					_elm_lang$core$Dict$get,
					{ctor: '_Tuple2', _0: response.status, _1: _p4._0},
					errors);
				var _p5 = decoder;
				if (_p5.ctor === 'Just') {
					var _p6 = A2(_elm_lang$core$Json_Decode$decodeString, _p5._0, _p7);
					if (_p6.ctor === 'Ok') {
						return _Lattyware$massivedecks$MassiveDecks_API_Request$Known(_p6._0);
					} else {
						return _Lattyware$massivedecks$MassiveDecks_API_Request$Malformed(_p6._0);
					}
				} else {
					return A2(_Lattyware$massivedecks$MassiveDecks_API_Request$Unknown, response.status, _p7);
				}
			} else {
				return _Lattyware$massivedecks$MassiveDecks_API_Request$Malformed(_p4._0);
			}
		} else {
			return _Lattyware$massivedecks$MassiveDecks_API_Request$Malformed('Recieved binary data instead of expected JSON in error.');
		}
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$handleResponse = F3(
	function (errors, resultDecoder, response) {
		return ((_elm_lang$core$Native_Utils.cmp(response.status, 200) > -1) && (_elm_lang$core$Native_Utils.cmp(response.status, 300) < 0)) ? A2(_Lattyware$massivedecks$MassiveDecks_API_Request$handleSuccess, resultDecoder, response) : _elm_lang$core$Result$Err(
			A2(_Lattyware$massivedecks$MassiveDecks_API_Request$handleFailure, errors, response));
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$Communication = function (a) {
	return {ctor: 'Communication', _0: a};
};
var _Lattyware$massivedecks$MassiveDecks_API_Request$send = F4(
	function (request, onSpecificError, onGeneralError, onSuccess) {
		var task = A2(
			_elm_lang$core$Task$map,
			A2(_Lattyware$massivedecks$MassiveDecks_API_Request$handleResponse, request.errors, request.resultDecoder),
			A2(
				_evancz$elm_http$Http$send,
				_evancz$elm_http$Http$defaultSettings,
				{
					verb: request.verb,
					url: request.url,
					headers: _elm_lang$core$Native_Utils.eq(request.body, _elm_lang$core$Maybe$Nothing) ? _elm_lang$core$Native_List.fromArray(
						[]) : _Lattyware$massivedecks$MassiveDecks_API_Request$jsonContentType,
					body: function () {
						var _p8 = request.body;
						if (_p8.ctor === 'Just') {
							return _Lattyware$massivedecks$MassiveDecks_API_Request$jsonBody(_p8._0);
						} else {
							return _evancz$elm_http$Http$empty;
						}
					}()
				}));
		var errorMapped = A2(
			_elm_lang$core$Task$andThen,
			A2(_elm_lang$core$Task$mapError, _Lattyware$massivedecks$MassiveDecks_API_Request$Communication, task),
			_elm_lang$core$Task$fromResult);
		var errorToMessage = A2(_Lattyware$massivedecks$MassiveDecks_API_Request$errorHandler, onSpecificError, onGeneralError);
		return A3(_elm_lang$core$Task$perform, errorToMessage, onSuccess, errorMapped);
	});
var _Lattyware$massivedecks$MassiveDecks_API_Request$send$ = F3(
	function (request, onGeneralError, onSuccess) {
		return A4(_Lattyware$massivedecks$MassiveDecks_API_Request$send, request, _Lattyware$massivedecks$MassiveDecks_Util$impossible, onGeneralError, onSuccess);
	});

var _Lattyware$massivedecks$MassiveDecks_API$commandRequest = F6(
	function (name, args, errors, decoder, gameCode, secret) {
		return A5(
			_Lattyware$massivedecks$MassiveDecks_API_Request$request,
			'POST',
			A2(_elm_lang$core$Basics_ops['++'], '/lobbies/', gameCode),
			_elm_lang$core$Maybe$Just(
				A3(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodeCommand, name, secret, args)),
			errors,
			decoder);
	});
var _Lattyware$massivedecks$MassiveDecks_API$disableRule = F3(
	function (rule, gameCode, secret) {
		return A6(
			_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
			'disableRule',
			_elm_lang$core$Native_List.fromArray(
				[
					{
					ctor: '_Tuple2',
					_0: 'rule',
					_1: _elm_lang$core$Json_Encode$string(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$toString(rule))
				}
				]),
			_elm_lang$core$Native_List.fromArray(
				[]),
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
			_elm_lang$core$Native_List.fromArray(
				[
					{
					ctor: '_Tuple2',
					_0: 'rule',
					_1: _elm_lang$core$Json_Encode$string(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$toString(rule))
				}
				]),
			_elm_lang$core$Native_List.fromArray(
				[]),
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
				'/lobbies/',
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
			_elm_lang$core$Native_List.fromArray(
				[]),
			_elm_lang$core$Json_Decode$succeed(
				{ctor: '_Tuple0'}));
	});
var _Lattyware$massivedecks$MassiveDecks_API$back = A4(
	_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
	'back',
	_elm_lang$core$Native_List.fromArray(
		[]),
	_elm_lang$core$Native_List.fromArray(
		[]),
	_elm_lang$core$Json_Decode$succeed(
		{ctor: '_Tuple0'}));
var _Lattyware$massivedecks$MassiveDecks_API$newAi = F2(
	function (gameCode, secret) {
		return A5(
			_Lattyware$massivedecks$MassiveDecks_API_Request$request,
			'POST',
			A2(
				_elm_lang$core$Basics_ops['++'],
				'/lobbies/',
				A2(_elm_lang$core$Basics_ops['++'], gameCode, '/players/newAi')),
			_elm_lang$core$Maybe$Just(
				_Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerSecret(secret)),
			_elm_lang$core$Native_List.fromArray(
				[]),
			_elm_lang$core$Json_Decode$succeed(
				{ctor: '_Tuple0'}));
	});
var _Lattyware$massivedecks$MassiveDecks_API$getHistory = function (gameCode) {
	return A5(
		_Lattyware$massivedecks$MassiveDecks_API_Request$request,
		'GET',
		A2(
			_elm_lang$core$Basics_ops['++'],
			'/lobbies/',
			A2(_elm_lang$core$Basics_ops['++'], gameCode, '/history')),
		_elm_lang$core$Maybe$Nothing,
		_elm_lang$core$Native_List.fromArray(
			[]),
		_elm_lang$core$Json_Decode$list(_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$finishedRoundDecoder));
};
var _Lattyware$massivedecks$MassiveDecks_API$getHand = F2(
	function (gameCode, secret) {
		return A5(
			_Lattyware$massivedecks$MassiveDecks_API_Request$request,
			'POST',
			A2(
				_elm_lang$core$Basics_ops['++'],
				'/lobbies/',
				A2(
					_elm_lang$core$Basics_ops['++'],
					gameCode,
					A2(
						_elm_lang$core$Basics_ops['++'],
						'/players/',
						_elm_lang$core$Basics$toString(secret.id)))),
			_elm_lang$core$Maybe$Just(
				_Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodePlayerSecret(secret)),
			_elm_lang$core$Native_List.fromArray(
				[]),
			_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder);
	});
var _Lattyware$massivedecks$MassiveDecks_API$createLobby = A5(
	_Lattyware$massivedecks$MassiveDecks_API_Request$request,
	'POST',
	'/lobbies',
	_elm_lang$core$Maybe$Nothing,
	_elm_lang$core$Native_List.fromArray(
		[]),
	_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$lobbyDecoder);
var _Lattyware$massivedecks$MassiveDecks_API$NewPlayerLobbyNotFound = {ctor: 'NewPlayerLobbyNotFound'};
var _Lattyware$massivedecks$MassiveDecks_API$NameInUse = {ctor: 'NameInUse'};
var _Lattyware$massivedecks$MassiveDecks_API$newPlayer = F2(
	function (gameCode, name) {
		return A5(
			_Lattyware$massivedecks$MassiveDecks_API_Request$request,
			'POST',
			A2(
				_elm_lang$core$Basics_ops['++'],
				'/lobbies/',
				A2(_elm_lang$core$Basics_ops['++'], gameCode, '/players')),
			_elm_lang$core$Maybe$Just(
				_Lattyware$massivedecks$MassiveDecks_Models_JSON_Encode$encodeName(name)),
			_elm_lang$core$Native_List.fromArray(
				[
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'name-in-use'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$NameInUse)
				},
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 404, _1: 'lobby-not-found'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$NewPlayerLobbyNotFound)
				}
				]),
			_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$playerSecretDecoder);
	});
var _Lattyware$massivedecks$MassiveDecks_API$LobbyNotFound = {ctor: 'LobbyNotFound'};
var _Lattyware$massivedecks$MassiveDecks_API$getLobbyAndHand = A4(
	_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
	'getLobbyAndHand',
	_elm_lang$core$Native_List.fromArray(
		[]),
	_elm_lang$core$Native_List.fromArray(
		[
			{
			ctor: '_Tuple2',
			_0: {ctor: '_Tuple2', _0: 404, _1: 'lobby-not-found'},
			_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$LobbyNotFound)
		}
		]),
	_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$lobbyAndHandDecoder);
var _Lattyware$massivedecks$MassiveDecks_API$DeckNotFound = {ctor: 'DeckNotFound'};
var _Lattyware$massivedecks$MassiveDecks_API$CardcastTimeout = {ctor: 'CardcastTimeout'};
var _Lattyware$massivedecks$MassiveDecks_API$addDeck = F3(
	function (gameCode, secret, playCode) {
		return A6(
			_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
			'addDeck',
			_elm_lang$core$Native_List.fromArray(
				[
					{
					ctor: '_Tuple2',
					_0: 'playCode',
					_1: _elm_lang$core$Json_Encode$string(playCode)
				}
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 502, _1: 'cardcast-timeout'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$CardcastTimeout)
				},
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'deck-not-found'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$DeckNotFound)
				}
				]),
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
			_elm_lang$core$Native_List.fromArray(
				[]),
			_elm_lang$core$Native_List.fromArray(
				[
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'game-in-progress'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$GameInProgress)
				},
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'not-enough-players'},
					_1: A2(
						_elm_lang$core$Json_Decode$object1,
						_Lattyware$massivedecks$MassiveDecks_API$NotEnoughPlayers,
						A2(_elm_lang$core$Json_Decode_ops[':='], 'required', _elm_lang$core$Json_Decode$int))
				}
				]),
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
			_elm_lang$core$Native_List.fromArray(
				[
					{
					ctor: '_Tuple2',
					_0: 'winner',
					_1: _elm_lang$core$Json_Encode$int(winner)
				}
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'not-czar'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$NotCzar)
				}
				]),
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
			_elm_lang$core$Native_List.fromArray(
				[
					{
					ctor: '_Tuple2',
					_0: 'ids',
					_1: _elm_lang$core$Json_Encode$list(
						A2(_elm_lang$core$List$map, _elm_lang$core$Json_Encode$string, ids))
				}
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'not-in-round'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$NotInRound)
				},
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'already-played'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$AlreadyPlayed)
				},
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'already-judging'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$AlreadyJudging)
				},
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'wrong-number-of-cards-played'},
					_1: A3(
						_elm_lang$core$Json_Decode$object2,
						_Lattyware$massivedecks$MassiveDecks_API$WrongNumberOfCards,
						A2(_elm_lang$core$Json_Decode_ops[':='], 'got', _elm_lang$core$Json_Decode$int),
						A2(_elm_lang$core$Json_Decode_ops[':='], 'expected', _elm_lang$core$Json_Decode$int))
				}
				]),
			_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder,
			gameCode,
			secret);
	});
var _Lattyware$massivedecks$MassiveDecks_API$PlayersNotSkippable = {ctor: 'PlayersNotSkippable'};
var _Lattyware$massivedecks$MassiveDecks_API$NotEnoughPlayersToSkip = {ctor: 'NotEnoughPlayersToSkip'};
var _Lattyware$massivedecks$MassiveDecks_API$skip = F3(
	function (gameCode, secret, players) {
		return A6(
			_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
			'skip',
			_elm_lang$core$Native_List.fromArray(
				[
					{
					ctor: '_Tuple2',
					_0: 'players',
					_1: _elm_lang$core$Json_Encode$list(
						A2(_elm_lang$core$List$map, _elm_lang$core$Json_Encode$int, players))
				}
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'not-enough-players-to-skip'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$NotEnoughPlayersToSkip)
				},
					{
					ctor: '_Tuple2',
					_0: {ctor: '_Tuple2', _0: 400, _1: 'players-must-be-skippable'},
					_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$PlayersNotSkippable)
				}
				]),
			_elm_lang$core$Json_Decode$succeed(
				{ctor: '_Tuple0'}),
			gameCode,
			secret);
	});
var _Lattyware$massivedecks$MassiveDecks_API$NotEnoughPoints = {ctor: 'NotEnoughPoints'};
var _Lattyware$massivedecks$MassiveDecks_API$redraw = A4(
	_Lattyware$massivedecks$MassiveDecks_API$commandRequest,
	'redraw',
	_elm_lang$core$Native_List.fromArray(
		[]),
	_elm_lang$core$Native_List.fromArray(
		[
			{
			ctor: '_Tuple2',
			_0: {ctor: '_Tuple2', _0: 400, _1: 'not-enough-points-to-redraw'},
			_1: _elm_lang$core$Json_Decode$succeed(_Lattyware$massivedecks$MassiveDecks_API$NotEnoughPoints)
		}
		]),
	_Lattyware$massivedecks$MassiveDecks_Models_JSON_Decode$handDecoder);

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$response = F3(
	function (picked, attributes, response) {
		var classes = _elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$classList(
				_elm_lang$core$Native_List.fromArray(
					[
						{ctor: '_Tuple2', _0: 'card', _1: true},
						{ctor: '_Tuple2', _0: 'response', _1: true},
						{ctor: '_Tuple2', _0: 'mui-panel', _1: true},
						{ctor: '_Tuple2', _0: 'picked', _1: picked}
					]))
			]);
		return A2(
			_elm_lang$html$Html$div,
			_elm_lang$core$List$concat(
				_elm_lang$core$Native_List.fromArray(
					[classes, attributes])),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$div,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$class('response-text')
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html$text(
							_Lattyware$massivedecks$MassiveDecks_Util$firstLetterToUpper(response.text)),
							_elm_lang$html$Html$text('.')
						]))
				]));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$slot = function (value) {
	return A2(
		_elm_lang$html$Html$span,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('slot')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html$text(value)
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$slots = F3(
	function (count, placeholder, picked) {
		var extra = count - _elm_lang$core$List$length(picked);
		return A2(
			_elm_lang$core$List$map,
			_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$slot,
			_elm_lang$core$List$concat(
				_elm_lang$core$Native_List.fromArray(
					[
						picked,
						A2(_elm_lang$core$List$repeat, extra, placeholder)
					])));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$call = F2(
	function (call, picked) {
		var spanned = A2(
			_elm_lang$core$List$map,
			function (part) {
				return A2(
					_elm_lang$html$Html$span,
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html$text(part)
						]));
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
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$class('card call mui-panel')
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$div,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$class('call-text')
						]),
					callContents)
				]));
	});

var _Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$closeButton = A2(
	_elm_lang$html$Html$button,
	_elm_lang$core$Native_List.fromArray(
		[
			_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--fab'),
			_elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_History_Messages$Close)
		]),
	_elm_lang$core$Native_List.fromArray(
		[
			_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('times')
		]));
var _Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$responses = F3(
	function (players, winnerId, idAndResponses) {
		var _p0 = idAndResponses;
		var playerId = _p0._0;
		var responses = _p0._1;
		var winner = _elm_lang$core$Native_Utils.eq(playerId, winnerId);
		var winnerPrefix = winner ? _elm_lang$core$Native_List.fromArray(
			[
				_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('trophy'),
				_elm_lang$html$Html$text(' ')
			]) : _elm_lang$core$Native_List.fromArray(
			[]);
		var player = A2(
			_elm_lang$core$Maybe$withDefault,
			_elm_lang$core$Native_List.fromArray(
				[]),
			A2(
				_elm_lang$core$Maybe$map,
				function (player) {
					return A2(
						_elm_lang$core$Basics_ops['++'],
						winnerPrefix,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html$text(player.name)
							]));
				},
				A2(_Lattyware$massivedecks$MassiveDecks_Models_Player$byId, playerId, players)));
		return A2(
			_elm_lang$html$Html$li,
			_elm_lang$core$Native_List.fromArray(
				[]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$div,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$class('responses')
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$div,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$classList(
									_elm_lang$core$Native_List.fromArray(
										[
											{ctor: '_Tuple2', _0: 'who', _1: true},
											{ctor: '_Tuple2', _0: 'won', _1: winner}
										]))
								]),
							player),
							A2(
							_elm_lang$html$Html$ul,
							_elm_lang$core$Native_List.fromArray(
								[]),
							A2(
								_elm_lang$core$List$map,
								function (r) {
									return A2(
										_elm_lang$html$Html$li,
										_elm_lang$core$Native_List.fromArray(
											[]),
										_elm_lang$core$Native_List.fromArray(
											[
												A3(
												_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$response,
												false,
												_elm_lang$core$Native_List.fromArray(
													[]),
												r)
											]));
								},
								responses))
						]))
				]));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$finishedRound = F2(
	function (players, round) {
		var playedCardsByPlayer = _elm_lang$core$Dict$toList(
			A2(_Lattyware$massivedecks$MassiveDecks_Models_Card$playedCardsByPlayer, round.playedByAndWinner.playedBy, round.responses));
		var czar = A2(
			_elm_lang$core$Maybe$withDefault,
			_elm_lang$core$Native_List.fromArray(
				[]),
			A2(
				_elm_lang$core$Maybe$map,
				function (player) {
					return _elm_lang$core$Native_List.fromArray(
						[
							_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('gavel'),
							_elm_lang$html$Html$text(' '),
							_elm_lang$html$Html$text(player.name)
						]);
				},
				A2(_Lattyware$massivedecks$MassiveDecks_Models_Player$byId, round.czar, players)));
		return A2(
			_elm_lang$html$Html$li,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$class('round')
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$div,
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$div,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$class('who')
								]),
							czar),
							A2(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$call,
							round.call,
							_elm_lang$core$Native_List.fromArray(
								[]))
						])),
					A2(
					_elm_lang$html$Html$ul,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$class('plays')
						]),
					A2(
						_elm_lang$core$List$map,
						A2(_Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$responses, players, round.playedByAndWinner.winner),
						playedCardsByPlayer))
				]));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$view = F2(
	function (model, players) {
		var content = function () {
			var _p1 = model.rounds;
			if (_p1.ctor === 'Just') {
				return A2(
					_elm_lang$html$Html$ul,
					_elm_lang$core$Native_List.fromArray(
						[]),
					A2(
						_elm_lang$core$List$map,
						_Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$finishedRound(players),
						_p1._0));
			} else {
				return _Lattyware$massivedecks$MassiveDecks_Components_Icon$spinner;
			}
		}();
		return A2(
			_elm_lang$html$Html$div,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$id('history')
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$h1,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$class('mui--divider-bottom')
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html$text('Previous Rounds')
						])),
					_Lattyware$massivedecks$MassiveDecks_Scenes_History_UI$closeButton,
					content
				]));
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
			_Lattyware$massivedecks$MassiveDecks_API_Request$send$,
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
	actions: _elm_lang$core$Native_List.fromArray(
		[_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Reboot$rebootAction])
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Available$houseRules = _elm_lang$core$Native_List.fromArray(
	[_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Reboot$rule]);

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$renderDisconnectedNotice = F3(
	function (ids, has, disconnectedNames) {
		return A2(
			_elm_lang$html$Html$div,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$class('notice')
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$h3,
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$Native_List.fromArray(
						[
							_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('minus-circle')
						])),
					A2(
					_elm_lang$html$Html$span,
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html$text(disconnectedNames),
							_elm_lang$html$Html$text(' '),
							_elm_lang$html$Html$text(has),
							_elm_lang$html$Html$text(' disconnected from the game.')
						])),
					A2(
					_elm_lang$html$Html$div,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$class('actions')
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$button,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small'),
									_elm_lang$html$Html_Events$onClick(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Skip(ids)),
									_elm_lang$html$Html_Attributes$title('They will be removed from this round, and won\'t be in future rounds until they reconnect.')
								]),
							_elm_lang$core$Native_List.fromArray(
								[
									_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('fast-forward'),
									_elm_lang$html$Html$text(' Skip')
								]))
						]))
				]));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$disconnectedNotice = function (players) {
	var disconnected = A2(
		_elm_lang$core$List$filter,
		function (player) {
			return player.disconnected && _elm_lang$core$Basics$not(
				_elm_lang$core$Native_Utils.eq(player.status, _Lattyware$massivedecks$MassiveDecks_Models_Player$Skipping));
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
		_elm_lang$core$Native_List.fromArray(
			[]),
		A2(
			_elm_lang$core$Maybe$map,
			function (item) {
				return _elm_lang$core$Native_List.fromArray(
					[item]);
			},
			A2(
				_elm_lang$core$Maybe$map,
				A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$renderDisconnectedNotice,
					disconnectedIds,
					_Lattyware$massivedecks$MassiveDecks_Util$pluralHas(disconnected)),
				disconnectedNames)));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$renderTimeoutNotice = F3(
	function (ids, has, names) {
		return A2(
			_elm_lang$html$Html$div,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$class('notice')
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$h3,
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$Native_List.fromArray(
						[
							_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('minus-circle')
						])),
					A2(
					_elm_lang$html$Html$span,
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html$text(names),
							_elm_lang$html$Html$text(' '),
							_elm_lang$html$Html$text(has),
							_elm_lang$html$Html$text(' not played into the round before the round timer ran out.')
						])),
					A2(
					_elm_lang$html$Html$div,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$class('actions')
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$button,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small'),
									_elm_lang$html$Html_Events$onClick(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Skip(ids)),
									_elm_lang$html$Html_Attributes$title('They will be removed from this round, and won\'t be in future rounds until they come back.')
								]),
							_elm_lang$core$Native_List.fromArray(
								[
									_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('fast-forward'),
									_elm_lang$html$Html$text(' Skip')
								]))
						]))
				]));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$timeoutNotice = F2(
	function (players, timeout) {
		var timedOutPlayers = A2(
			_elm_lang$core$List$filter,
			function (player) {
				return _elm_lang$core$Native_Utils.eq(player.status, _Lattyware$massivedecks$MassiveDecks_Models_Player$NotPlayed);
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
		return timeout ? A2(
			_elm_lang$core$Maybe$withDefault,
			_elm_lang$core$Native_List.fromArray(
				[]),
			A2(
				_elm_lang$core$Maybe$map,
				function (item) {
					return _elm_lang$core$Native_List.fromArray(
						[item]);
				},
				A2(
					_elm_lang$core$Maybe$map,
					A2(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$renderTimeoutNotice,
						timedOutIds,
						_Lattyware$massivedecks$MassiveDecks_Util$pluralHas(timedOutPlayers)),
					timedOutNames))) : _elm_lang$core$Native_List.fromArray(
			[]);
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$renderSkippingNotice = _elm_lang$core$Native_List.fromArray(
	[
		A2(
		_elm_lang$html$Html$div,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('notice')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$h3,
				_elm_lang$core$Native_List.fromArray(
					[]),
				_elm_lang$core$Native_List.fromArray(
					[
						_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('fast-forward')
					])),
				A2(
				_elm_lang$html$Html$span,
				_elm_lang$core$Native_List.fromArray(
					[]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('You are currently being skipped because you took too long to play. '),
						A2(
						_elm_lang$html$Html$a,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html_Attributes$class('link'),
								A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
								A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button')
							]),
						_elm_lang$core$Native_List.fromArray(
							[
								_Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('bell'),
								_elm_lang$html$Html$text('Enable Notifications?')
							]))
					])),
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('actions')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						A2(
						_elm_lang$html$Html$button,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small'),
								_elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Back),
								_elm_lang$html$Html_Attributes$title('Rejoin the game.')
							]),
						_elm_lang$core$Native_List.fromArray(
							[
								_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('sign-in'),
								_elm_lang$html$Html$text(' Rejoin')
							]))
					]))
			]))
	]);
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$skippingNotice = F2(
	function (players, id) {
		var renderSkippingNoticeIfSkipping = function (status) {
			var _p0 = status;
			if (_p0.ctor === 'Skipping') {
				return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$renderSkippingNotice;
			} else {
				return _elm_lang$core$Native_List.fromArray(
					[]);
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
			_elm_lang$core$Native_List.fromArray(
				[]),
			A2(_elm_lang$core$Maybe$map, renderSkippingNoticeIfSkipping, status));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$warningDrawer = function (contents) {
	var hidden = _elm_lang$core$List$isEmpty(contents);
	var classes = _elm_lang$core$Native_List.fromArray(
		[
			{ctor: '_Tuple2', _0: 'hidden', _1: hidden}
		]);
	return A2(
		_elm_lang$html$Html$div,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$id('warning-drawer'),
				_elm_lang$html$Html_Attributes$classList(classes)
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$button,
				_elm_lang$core$Native_List.fromArray(
					[
						A2(_elm_lang$html$Html_Attributes$attribute, 'onClick', 'toggleWarningDrawer()'),
						_elm_lang$html$Html_Attributes$class('toggle mui-btn mui-btn--small mui-btn--fab'),
						_elm_lang$html$Html_Attributes$title('Warning notices.')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('exclamation-triangle')
					])),
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('top')
					]),
				_elm_lang$core$Native_List.fromArray(
					[])),
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('contents')
					]),
				contents)
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$stateInfo = function (round) {
	return A2(
		_elm_lang$core$Maybe$andThen,
		round,
		function (round) {
			var _p1 = round.responses;
			if (_p1.ctor === 'Hidden') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				return _elm_lang$core$Maybe$Just('The card czar is now picking a winner.');
			}
		});
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$statusInfo = F2(
	function (players, id) {
		var _p2 = A2(
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
		if (_p2.ctor === 'Just') {
			var _p3 = _p2._0;
			switch (_p3.ctor) {
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
		var content = _elm_lang$core$Maybe$oneOf(
			_elm_lang$core$Native_List.fromArray(
				[
					A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$statusInfo, lobby.players, secret.id),
					_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$stateInfo(lobby.round)
				]));
		var _p4 = content;
		if (_p4.ctor === 'Just') {
			return _elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$div,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$id('info-bar')
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('info-circle'),
							_elm_lang$html$Html$text(' '),
							_elm_lang$html$Html$text(_p4._0)
						]))
				]);
		} else {
			return _elm_lang$core$Native_List.fromArray(
				[]);
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$chooseButton = function (playedId) {
	return A2(
		_elm_lang$html$Html$li,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('choose-button')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$button,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--accent mui-btn--fab'),
						_elm_lang$html$Html_Events$onClick(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Choose(playedId))
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('trophy')
					]))
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedResponse = function (response) {
	return A2(
		_elm_lang$html$Html$div,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('card response mui-panel')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('response-text')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text(
						_Lattyware$massivedecks$MassiveDecks_Util$firstLetterToUpper(response.text)),
						_elm_lang$html$Html$text('.')
					]))
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedCards = F3(
	function (isCzar, playedId, cards) {
		return A2(
			_elm_lang$html$Html$ol,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Events$onClick(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Consider(playedId))
				]),
			A2(
				_elm_lang$core$List$map,
				function (card) {
					return A2(
						_elm_lang$html$Html$li,
						_elm_lang$core$Native_List.fromArray(
							[]),
						_elm_lang$core$Native_List.fromArray(
							[
								_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedResponse(card)
							]));
				},
				cards));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedView = F2(
	function (isCzar, responses) {
		return A2(
			_elm_lang$html$Html$ol,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$class('played mui--divider-top')
				]),
			A2(
				_elm_lang$core$List$indexedMap,
				F2(
					function (index, pc) {
						return A2(
							_elm_lang$html$Html$li,
							_elm_lang$core$Native_List.fromArray(
								[]),
							_elm_lang$core$Native_List.fromArray(
								[
									A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedCards, isCzar, index, pc)
								]));
					}),
				responses.cards));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playButton = A2(
	_elm_lang$html$Html$li,
	_elm_lang$core$Native_List.fromArray(
		[
			_elm_lang$html$Html_Attributes$class('play-button')
		]),
	_elm_lang$core$Native_List.fromArray(
		[
			A2(
			_elm_lang$html$Html$button,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--accent mui-btn--fab'),
					_elm_lang$html$Html_Attributes$title('Play these responses.'),
					_elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Play)
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('check')
				]))
		]));
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$withdrawButton = function (id) {
	return A2(
		_elm_lang$html$Html$button,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('withdraw-button mui-btn mui-btn--small mui-btn--danger mui-btn--fab'),
				_elm_lang$html$Html_Attributes$title('Take back this response.'),
				_elm_lang$html$Html_Events$onClick(
				_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Withdraw(id))
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('times')
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$pickedResponse = function (response) {
	return A2(
		_elm_lang$html$Html$li,
		_elm_lang$core$Native_List.fromArray(
			[]),
		_elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('card response mui-panel')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						A2(
						_elm_lang$html$Html$div,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html_Attributes$class('response-text')
							]),
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html$text(
								_Lattyware$massivedecks$MassiveDecks_Util$firstLetterToUpper(response.text)),
								_elm_lang$html$Html$text('.')
							])),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$withdrawButton(response.id)
					]))
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$handRender = F2(
	function (disabled, contents) {
		var classes = A2(
			_elm_lang$core$Basics_ops['++'],
			'hand mui--divider-top',
			disabled ? ' disabled' : '');
		return A2(
			_elm_lang$html$Html$ul,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$class(classes)
				]),
			A2(
				_elm_lang$core$List$map,
				function (item) {
					return A2(
						_elm_lang$html$Html$li,
						_elm_lang$core$Native_List.fromArray(
							[]),
						_elm_lang$core$Native_List.fromArray(
							[item]));
				},
				contents));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$positioning = function (shownCard) {
	var horizontalDirection = shownCard.isLeft ? 'left' : 'right';
	return _elm_lang$html$Html_Attributes$style(
		_elm_lang$core$Native_List.fromArray(
			[
				{
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
				{
				ctor: '_Tuple2',
				_0: horizontalDirection,
				_1: A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(shownCard.horizontalPos),
					'%')
			},
				{
				ctor: '_Tuple2',
				_0: 'top',
				_1: A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(shownCard.verticalPos),
					'%')
			}
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$blankResponse = function (shownCard) {
	return A2(
		_elm_lang$html$Html$div,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('card mui-panel'),
				_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$positioning(shownCard)
			]),
		_elm_lang$core$Native_List.fromArray(
			[]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$pickedView = F3(
	function (picked, slots, shownPlayed) {
		var pickedResponses = A2(_elm_lang$core$List$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$pickedResponse, picked);
		var numberPicked = _elm_lang$core$List$length(picked);
		var pb = (_elm_lang$core$Native_Utils.cmp(numberPicked, slots) < 0) ? _elm_lang$core$Native_List.fromArray(
			[]) : _elm_lang$core$Native_List.fromArray(
			[_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playButton]);
		return _elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$ol,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('picked')
					]),
				_elm_lang$core$List$concat(
					_elm_lang$core$Native_List.fromArray(
						[pickedResponses, pb]))),
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('others-picked')
					]),
				A2(_elm_lang$core$List$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$blankResponse, shownPlayed))
			]);
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$response = F3(
	function (picked, disabled, response) {
		var isPicked = A2(_elm_lang$core$List$member, response.id, picked);
		var clickHandler = (isPicked || disabled) ? _elm_lang$core$Native_List.fromArray(
			[]) : _elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Events$onClick(
				_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$Pick(response.id))
			]);
		return A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$response, isPicked, clickHandler, response);
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
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('play-area')
			]),
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
				A2(_Lattyware$massivedecks$MassiveDecks_Util$get, players, round.playedByAndWinner.winner)));
		var cards = round.responses;
		var winning = A2(
			_elm_lang$core$Maybe$withDefault,
			_elm_lang$core$Native_List.fromArray(
				[]),
			A2(_Lattyware$massivedecks$MassiveDecks_Models_Card$winningCards, cards, round.playedByAndWinner));
		return {
			ctor: '_Tuple2',
			_0: _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('trophy'),
					_elm_lang$html$Html$text(
					A2(_elm_lang$core$Basics_ops['++'], ' ', winner))
				]),
			_1: _elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$div,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$class('winner mui-panel')
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$h1,
							_elm_lang$core$Native_List.fromArray(
								[]),
							_elm_lang$core$Native_List.fromArray(
								[
									_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('trophy')
								])),
							A2(
							_elm_lang$html$Html$h2,
							_elm_lang$core$Native_List.fromArray(
								[]),
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html$text(
									A2(
										_elm_lang$core$Basics_ops['++'],
										' ',
										A2(_Lattyware$massivedecks$MassiveDecks_Models_Card$filled, round.call, winning)))
								])),
							A2(
							_elm_lang$html$Html$h3,
							_elm_lang$core$Native_List.fromArray(
								[]),
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html$text(
									A2(_elm_lang$core$Basics_ops['++'], '- ', winner))
								]))
						])),
					A2(
					_elm_lang$html$Html$button,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$id('next-round-button'),
							_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--primary mui-btn--raised'),
							_elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$NextRound)
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html$text('Next Round')
						]))
				])
		};
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$consideringView = F3(
	function (considering, consideringCards, isCzar) {
		var extra = isCzar ? _elm_lang$core$Native_List.fromArray(
			[
				_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$chooseButton(considering)
			]) : _elm_lang$core$Native_List.fromArray(
			[]);
		return A2(
			_elm_lang$html$Html$ol,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$class('considering')
				]),
			A2(
				_elm_lang$core$List$append,
				A2(
					_elm_lang$core$List$map,
					function (card) {
						return A2(
							_elm_lang$html$Html$li,
							_elm_lang$core$Native_List.fromArray(
								[]),
							_elm_lang$core$Native_List.fromArray(
								[
									_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedResponse(card)
								]));
					},
					consideringCards),
				extra));
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
			_elm_lang$core$Native_List.fromArray(
				[]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$a,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$classList(
							_elm_lang$core$Native_List.fromArray(
								[
									{ctor: '_Tuple2', _0: 'link', _1: true},
									{
									ctor: '_Tuple2',
									_0: 'disabled',
									_1: _elm_lang$core$Basics$not(enabled)
								}
								])),
							_elm_lang$html$Html_Attributes$title(action.description),
							A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
							A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
							_elm_lang$html$Html_Events$onClick(message)
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							_Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon(action.icon),
							_elm_lang$html$Html$text(' '),
							_elm_lang$html$Html$text(action.text)
						]))
				]));
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
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('action-menu mui-dropdown')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$button,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--fab'),
						_elm_lang$html$Html_Attributes$title('Game actions.'),
						A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-toggle', 'dropdown')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('bars')
					])),
				A2(
				_elm_lang$html$Html$ul,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('mui-dropdown__menu mui-dropdown__menu--right')
					]),
				A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$li,
							_elm_lang$core$Native_List.fromArray(
								[]),
							_elm_lang$core$Native_List.fromArray(
								[
									A2(
									_elm_lang$html$Html$a,
									_elm_lang$core$Native_List.fromArray(
										[
											_elm_lang$html$Html_Attributes$classList(
											_elm_lang$core$Native_List.fromArray(
												[
													{ctor: '_Tuple2', _0: 'link', _1: true}
												])),
											_elm_lang$html$Html_Attributes$title('View previous rounds from the game.'),
											A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
											A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
											_elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ViewHistory)
										]),
									_elm_lang$core$Native_List.fromArray(
										[
											_Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('history'),
											_elm_lang$html$Html$text(' '),
											_elm_lang$html$Html$text('Game History')
										]))
								]))
						]),
					A2(
						_elm_lang$core$List$concatMap,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$gameMenuItems(lobbyModel),
						enabled)))
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$roundContents = F2(
	function (lobbyModel, round) {
		var id = lobbyModel.secret.id;
		var isCzar = _elm_lang$core$Native_Utils.eq(round.czar, id);
		var model = lobbyModel.playing;
		var hand = lobbyModel.hand.hand;
		var picked = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$getAllById, model.picked, hand);
		var callFill = function () {
			var _p5 = round.responses;
			if (_p5.ctor === 'Revealed') {
				return A2(
					_elm_lang$core$Maybe$withDefault,
					_elm_lang$core$Native_List.fromArray(
						[]),
					A2(
						_elm_lang$core$Maybe$andThen,
						model.considering,
						_Lattyware$massivedecks$MassiveDecks_Util$get(_p5._0.cards)));
			} else {
				return picked;
			}
		}();
		var pickedOrChosen = function () {
			var _p6 = round.responses;
			if (_p6.ctor === 'Revealed') {
				var _p7 = model.considering;
				if (_p7.ctor === 'Just') {
					var _p9 = _p7._0;
					var _p8 = A2(_Lattyware$massivedecks$MassiveDecks_Util$get, _p6._0.cards, _p9);
					if (_p8.ctor === 'Just') {
						return _elm_lang$core$Native_List.fromArray(
							[
								A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$consideringView, _p9, _p8._0, isCzar)
							]);
					} else {
						return _elm_lang$core$Native_List.fromArray(
							[]);
					}
				} else {
					return _elm_lang$core$Native_List.fromArray(
						[]);
				}
			} else {
				return A3(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$pickedView,
					picked,
					_Lattyware$massivedecks$MassiveDecks_Models_Card$slots(round.call),
					A2(_elm_lang$core$Basics_ops['++'], model.shownPlayed.animated, model.shownPlayed.toAnimate));
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
			var _p10 = round.responses;
			if (_p10.ctor === 'Revealed') {
				return A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playedView, isCzar, _p10._0);
			} else {
				return A3(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$handView,
					model.picked,
					_elm_lang$core$Basics$not(canPlay),
					hand);
			}
		}();
		return _elm_lang$core$Native_List.fromArray(
			[
				_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$playArea(
				_elm_lang$core$Native_List.fromArray(
					[
						A2(
						_elm_lang$html$Html$div,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html_Attributes$class('round-area')
							]),
						_elm_lang$core$List$concat(
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$core$Native_List.fromArray(
									[
										A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI_Cards$call, round.call, callFill)
									]),
									pickedOrChosen
								]))),
						playedOrHand,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$gameMenu(lobbyModel)
					]))
			]);
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$view = function (lobbyModel) {
	var lobby = lobbyModel.lobby;
	var model = lobbyModel.playing;
	var _p11 = function () {
		var _p12 = model.finishedRound;
		if (_p12.ctor === 'Just') {
			return A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$winnerHeaderAndContents, _p12._0, lobby.players);
		} else {
			var _p13 = lobby.round;
			if (_p13.ctor === 'Just') {
				var _p14 = _p13._0;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_List.fromArray(
						[
							_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('gavel'),
							_elm_lang$html$Html$text(
							A2(
								_elm_lang$core$Basics_ops['++'],
								' ',
								A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$czarName, lobby.players, _p14.czar)))
						]),
					_1: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$roundContents, lobbyModel, _p14)
				};
			} else {
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_List.fromArray(
						[]),
					_1: _elm_lang$core$Native_List.fromArray(
						[])
				};
			}
		}
	}();
	var header = _p11._0;
	var content = _p11._1;
	var _p15 = model.history;
	if (_p15.ctor === 'Nothing') {
		return {
			ctor: '_Tuple2',
			_0: header,
			_1: _elm_lang$core$List$concat(
				_elm_lang$core$Native_List.fromArray(
					[
						A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$infoBar, lobby, lobbyModel.secret),
						content,
						_elm_lang$core$Native_List.fromArray(
						[
							_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$warningDrawer(
							_elm_lang$core$List$concat(
								_elm_lang$core$Native_List.fromArray(
									[
										A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$skippingNotice, lobby.players, lobbyModel.secret.id),
										_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$disconnectedNotice(lobby.players)
									])))
						])
					]))
		};
	} else {
		return {
			ctor: '_Tuple2',
			_0: _elm_lang$core$Native_List.fromArray(
				[]),
			_1: _elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html_App$map,
					_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$HistoryMessage,
					A2(_Lattyware$massivedecks$MassiveDecks_Scenes_History$view, _p15._0, lobbyModel.lobby.players))
				])
		};
	}
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$initialRandomPositioning = A4(
	_elm_lang$core$Random$map3,
	F3(
		function (r, h, l) {
			return A4(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Models$ShownCard, r, h, l, -100);
		}),
	A2(_elm_lang$core$Random$int, -75, 75),
	A2(_elm_lang$core$Random$int, 0, 50),
	_elm_lang$core$Random$bool);
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$randomPositioning = A5(
	_elm_lang$core$Random$map4,
	_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Models$ShownCard,
	A2(_elm_lang$core$Random$int, -90, 90),
	A2(_elm_lang$core$Random$int, 0, 50),
	_elm_lang$core$Random$bool,
	A2(_elm_lang$core$Random$int, -5, 1));
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
				_elm_lang$core$Native_List.fromArray(
					[])),
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
			A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$New, 'There are not enough players in the game to skip.', false));
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
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$lobbyAndHandUpdated = function (lobbyModel) {
	var model = lobbyModel.playing;
	var shownPlayed = model.shownPlayed;
	var lobby = lobbyModel.lobby;
	var playedCards = A2(
		_elm_lang$core$Maybe$andThen,
		lobby.round,
		function (round) {
			var _p5 = round.responses;
			if (_p5.ctor === 'Hidden') {
				return _elm_lang$core$Maybe$Just(_p5._0);
			} else {
				return _elm_lang$core$Maybe$Nothing;
			}
		});
	var _p6 = function () {
		var _p7 = playedCards;
		if (_p7.ctor === 'Just') {
			var existing = _elm_lang$core$List$length(shownPlayed.animated) + _elm_lang$core$List$length(shownPlayed.toAnimate);
			var _p8 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$addShownPlayed, _p7._0 - existing, model.seed);
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
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$Native_List.fromArray(
						[])),
				_1: model.seed
			};
		}
	}();
	var newShownPlayed = _p6._0;
	var seed = _p6._1;
	var newModel = _elm_lang$core$Native_Utils.update(
		model,
		{shownPlayed: newShownPlayed, seed: seed});
	return {ctor: '_Tuple2', _0: newModel, _1: _elm_lang$core$Platform_Cmd$none};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$ignore = function (_p9) {
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$NoOp);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$update = F2(
	function (message, lobbyModel) {
		var secret = lobbyModel.secret;
		var lobby = lobbyModel.lobby;
		var gameCode = lobby.gameCode;
		var model = lobbyModel.playing;
		var _p10 = message;
		switch (_p10.ctor) {
			case 'Pick':
				var playing = A2(
					_elm_lang$core$Maybe$withDefault,
					false,
					A2(
						_elm_lang$core$Maybe$map,
						function (round) {
							var _p11 = round.responses;
							if (_p11.ctor === 'Revealed') {
								return false;
							} else {
								return true;
							}
						},
						lobby.round));
				var slots = A2(
					_elm_lang$core$Maybe$withDefault,
					0,
					A2(
						_elm_lang$core$Maybe$map,
						function (round) {
							return _Lattyware$massivedecks$MassiveDecks_Models_Card$slots(round.call);
						},
						lobby.round));
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
								_elm_lang$core$Native_List.fromArray(
									[_p10._0]))
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
							picked: _elm_lang$core$Native_List.fromArray(
								[])
						}),
					_1: A4(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send,
						A3(_Lattyware$massivedecks$MassiveDecks_API$play, gameCode, secret, model.picked),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$playErrorHandler,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$HandUpdate)
				};
			case 'Consider':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							considering: _elm_lang$core$Maybe$Just(_p10._0)
						}),
					_1: _elm_lang$core$Platform_Cmd$none
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
				var _p12 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$updatePositioning, model.shownPlayed, model.seed);
				var shownPlayed = _p12._0;
				var seed = _p12._1;
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
						_Lattyware$massivedecks$MassiveDecks_API_Request$send$,
						A2(_Lattyware$massivedecks$MassiveDecks_API$back, gameCode, secret),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$ignore)
				};
			case 'LobbyAndHandUpdated':
				return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$lobbyAndHandUpdated(lobbyModel);
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
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							finishedRound: _elm_lang$core$Maybe$Just(_p10._0)
						}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'HistoryMessage':
				var _p13 = model.history;
				if (_p13.ctor === 'Just') {
					var _p14 = _p10._0;
					switch (_p14.ctor) {
						case 'ErrorMessage':
							return {
								ctor: '_Tuple2',
								_0: model,
								_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$ErrorMessage(_p14._0))
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
							var _p15 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_History$update, _p14._0, _p13._0);
							var newHistory = _p15._0;
							var cmd = _p15._1;
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Native_Utils.update(
									model,
									{
										history: _elm_lang$core$Maybe$Just(newHistory)
									}),
								_1: A2(
									_elm_lang$core$Platform_Cmd$map,
									function (_p16) {
										return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage(
											_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$HistoryMessage(_p16));
									},
									cmd)
							};
					}
				} else {
					return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
				}
			case 'ViewHistory':
				var _p17 = _Lattyware$massivedecks$MassiveDecks_Scenes_History$init(lobbyModel.lobby.gameCode);
				var historyModel = _p17._0;
				var command = _p17._1;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							history: _elm_lang$core$Maybe$Just(historyModel)
						}),
					_1: A2(
						_elm_lang$core$Platform_Cmd$map,
						function (_p18) {
							return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$HistoryMessage(_p18));
						},
						command)
				};
			default:
				return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$view = function (model) {
	var _p19 = _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_UI$view(model);
	var header = _p19._0;
	var content = _p19._1;
	return {
		ctor: '_Tuple2',
		_0: A2(
			_elm_lang$core$List$map,
			_elm_lang$html$Html_App$map(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage),
			header),
		_1: A2(
			_elm_lang$core$List$map,
			_elm_lang$html$Html_App$map(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage),
			content)
	};
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$subscriptions = function (model) {
	return _elm_lang$core$List$isEmpty(model.shownPlayed.toAnimate) ? _elm_lang$core$Platform_Sub$none : _elm_lang$animation_frame$AnimationFrame$diffs(
		function (_p20) {
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
	var _p21 = id;
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Reboot$rule;
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$init = function (init) {
	return {
		picked: _elm_lang$core$Native_List.fromArray(
			[]),
		considering: _elm_lang$core$Maybe$Nothing,
		finishedRound: _elm_lang$core$Maybe$Nothing,
		shownPlayed: {
			animated: _elm_lang$core$Native_List.fromArray(
				[]),
			toAnimate: _elm_lang$core$Native_List.fromArray(
				[])
		},
		seed: _elm_lang$core$Random$initialSeed(
			_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$hack(init.seed)),
		history: _elm_lang$core$Maybe$Nothing
	};
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$startGameWarning = function (canStart) {
	return canStart ? _elm_lang$html$Html$text('') : A2(
		_elm_lang$html$Html$span,
		_elm_lang$core$Native_List.fromArray(
			[]),
		_elm_lang$core$Native_List.fromArray(
			[
				_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('info-circle'),
				_elm_lang$html$Html$text(' You will need at least two players to start the game.')
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$startGameButton = F2(
	function (enoughPlayers, enoughCards) {
		return A2(
			_elm_lang$html$Html$div,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$id('start-game')
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$startGameWarning(enoughPlayers),
					A2(
					_elm_lang$html$Html$button,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--primary mui-btn--raised'),
							_elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$StartGame),
							_elm_lang$html$Html_Attributes$disabled(
							_elm_lang$core$Basics$not(enoughPlayers && enoughCards))
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html$text('Start Game')
						]))
				]));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$houseRuleTemplate = F6(
	function (id$, title, icon, description, buttonText, message) {
		return A2(
			_elm_lang$html$Html$div,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$id(id$),
					_elm_lang$html$Html_Attributes$class('house-rule')
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$div,
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$h3,
							_elm_lang$core$Native_List.fromArray(
								[]),
							_elm_lang$core$Native_List.fromArray(
								[
									_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon(icon),
									_elm_lang$html$Html$text(' '),
									_elm_lang$html$Html$text(title)
								])),
							A2(
							_elm_lang$html$Html$button,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--primary'),
									_elm_lang$html$Html_Events$onClick(message)
								]),
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html$text(buttonText)
								]))
						])),
					A2(
					_elm_lang$html$Html$p,
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html$text(description)
						]))
				]));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$rando = A6(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$houseRuleTemplate, 'rando', 'Rando Cardrissian', 'cogs', 'Every round, one random card will be played for an imaginary player named Rando Cardrissian, if he wins, all players go home in a state of everlasting shame.', 'Add an AI player', _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$AddAi);
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$houseRule = F2(
	function (enabled, rule) {
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
		return A6(
			_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$houseRuleTemplate,
			_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Id$toString(rule.id),
			rule.name,
			rule.icon,
			rule.description,
			buttonText,
			command);
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$emptyDeckListInfo = function (display) {
	return display ? _elm_lang$core$Native_List.fromArray(
		[
			A2(
			_elm_lang$html$Html$tr,
			_elm_lang$core$Native_List.fromArray(
				[]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$td,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$colspan(4)
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('info-circle'),
							_elm_lang$html$Html$text(' You will need to add at least one '),
							A2(
							_elm_lang$html$Html$a,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$href('https://www.cardcastgame.com/browse'),
									_elm_lang$html$Html_Attributes$target('_blank')
								]),
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html$text('Cardcast deck')
								])),
							_elm_lang$html$Html$text(' to the game.'),
							_elm_lang$html$Html$text(' Not sure? Try '),
							A2(
							_elm_lang$html$Html$a,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$class('link'),
									A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
									A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
									_elm_lang$html$Html_Events$onClick(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ConfigureDecks(
										_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Request('CAHBS')))
								]),
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html$text('clicking here to add the Cards Against Humanity base set')
								])),
							_elm_lang$html$Html$text('.')
						]))
				]))
		]) : _elm_lang$core$Native_List.fromArray(
		[]);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckLink = function (id) {
	return A2(
		_elm_lang$html$Html$a,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$href(
				A2(_elm_lang$core$Basics_ops['++'], 'https://www.cardcastgame.com/browse/deck/', id)),
				_elm_lang$html$Html_Attributes$target('_blank')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html$text(id)
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckList = F3(
	function (decks, loadingDecks, deckId) {
		return A2(
			_elm_lang$html$Html$table,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$class('decks mui-table')
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$thead,
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$tr,
							_elm_lang$core$Native_List.fromArray(
								[]),
							_elm_lang$core$Native_List.fromArray(
								[
									A2(
									_elm_lang$html$Html$th,
									_elm_lang$core$Native_List.fromArray(
										[]),
									_elm_lang$core$Native_List.fromArray(
										[
											_elm_lang$html$Html$text('Id')
										])),
									A2(
									_elm_lang$html$Html$th,
									_elm_lang$core$Native_List.fromArray(
										[]),
									_elm_lang$core$Native_List.fromArray(
										[
											_elm_lang$html$Html$text('Name')
										])),
									A2(
									_elm_lang$html$Html$th,
									_elm_lang$core$Native_List.fromArray(
										[
											_elm_lang$html$Html_Attributes$title('Calls')
										]),
									_elm_lang$core$Native_List.fromArray(
										[
											_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('square')
										])),
									A2(
									_elm_lang$html$Html$th,
									_elm_lang$core$Native_List.fromArray(
										[
											_elm_lang$html$Html_Attributes$title('Responses')
										]),
									_elm_lang$core$Native_List.fromArray(
										[
											_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('square-o')
										]))
								]))
						])),
					A2(
					_elm_lang$html$Html$tbody,
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$List$concat(
						_elm_lang$core$Native_List.fromArray(
							[
								_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$emptyDeckListInfo(
								_elm_lang$core$List$isEmpty(decks) && _elm_lang$core$List$isEmpty(loadingDecks)),
								A2(
								_elm_lang$core$List$map,
								function (deck) {
									return A2(
										_elm_lang$html$Html$tr,
										_elm_lang$core$Native_List.fromArray(
											[]),
										_elm_lang$core$Native_List.fromArray(
											[
												A2(
												_elm_lang$html$Html$td,
												_elm_lang$core$Native_List.fromArray(
													[]),
												_elm_lang$core$Native_List.fromArray(
													[
														_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckLink(deck.id)
													])),
												A2(
												_elm_lang$html$Html$td,
												_elm_lang$core$Native_List.fromArray(
													[
														_elm_lang$html$Html_Attributes$title(deck.name)
													]),
												_elm_lang$core$Native_List.fromArray(
													[
														_elm_lang$html$Html$text(deck.name)
													])),
												A2(
												_elm_lang$html$Html$td,
												_elm_lang$core$Native_List.fromArray(
													[]),
												_elm_lang$core$Native_List.fromArray(
													[
														_elm_lang$html$Html$text(
														_elm_lang$core$Basics$toString(deck.calls))
													])),
												A2(
												_elm_lang$html$Html$td,
												_elm_lang$core$Native_List.fromArray(
													[]),
												_elm_lang$core$Native_List.fromArray(
													[
														_elm_lang$html$Html$text(
														_elm_lang$core$Basics$toString(deck.responses))
													]))
											]));
								},
								decks),
								A2(
								_elm_lang$core$List$map,
								function (deck) {
									return A2(
										_elm_lang$html$Html$tr,
										_elm_lang$core$Native_List.fromArray(
											[]),
										_elm_lang$core$Native_List.fromArray(
											[
												A2(
												_elm_lang$html$Html$td,
												_elm_lang$core$Native_List.fromArray(
													[]),
												_elm_lang$core$Native_List.fromArray(
													[
														_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckLink(deck)
													])),
												A2(
												_elm_lang$html$Html$td,
												_elm_lang$core$Native_List.fromArray(
													[
														_elm_lang$html$Html_Attributes$colspan(3)
													]),
												_elm_lang$core$Native_List.fromArray(
													[_Lattyware$massivedecks$MassiveDecks_Components_Icon$spinner]))
											]));
								},
								loadingDecks),
								_elm_lang$core$Native_List.fromArray(
								[
									A2(
									_elm_lang$html$Html$tr,
									_elm_lang$core$Native_List.fromArray(
										[]),
									_elm_lang$core$Native_List.fromArray(
										[
											A2(
											_elm_lang$html$Html$td,
											_elm_lang$core$Native_List.fromArray(
												[
													_elm_lang$html$Html_Attributes$colspan(4)
												]),
											_elm_lang$core$Native_List.fromArray(
												[
													_Lattyware$massivedecks$MassiveDecks_Components_Input$view(deckId)
												]))
										]))
								])
							])))
				]));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$addDeckButton = function (deckId) {
	return _elm_lang$core$Native_List.fromArray(
		[
			A2(
			_elm_lang$html$Html$button,
			_elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--primary mui-btn--fab'),
					_elm_lang$html$Html_Attributes$disabled(
					_elm_lang$core$String$isEmpty(deckId)),
					_elm_lang$html$Html_Events$onClick(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ConfigureDecks(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Request(deckId))),
					_elm_lang$html$Html_Attributes$title('Add deck to game.')
				]),
			_elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('plus')
				]))
		]);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckIdInputLabel = _elm_lang$core$Native_List.fromArray(
	[
		_elm_lang$html$Html$text(' A '),
		A2(
		_elm_lang$html$Html$a,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$href('https://www.cardcastgame.com/browse'),
				_elm_lang$html$Html_Attributes$target('_blank')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html$text('Cardcast')
			])),
		_elm_lang$html$Html$text(' Play Code')
	]);
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$invite = F2(
	function (appUrl, lobbyId) {
		var url = A2(_Lattyware$massivedecks$MassiveDecks_Util$lobbyUrl, appUrl, lobbyId);
		return A2(
			_elm_lang$html$Html$div,
			_elm_lang$core$Native_List.fromArray(
				[]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$p,
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html$text('Invite others to the game with the code \''),
							A2(
							_elm_lang$html$Html$strong,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$class('game-code')
								]),
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html$text(lobbyId)
								])),
							_elm_lang$html$Html$text('\' to enter on the main page, or give them this link: ')
						])),
					A2(
					_elm_lang$html$Html$p,
					_elm_lang$core$Native_List.fromArray(
						[]),
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$a,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$href(url)
								]),
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html$text(url)
								]))
						]))
				]));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$view = function (lobbyModel) {
	var lobby = lobbyModel.lobby;
	var decks = lobby.config.decks;
	var enoughCards = _elm_lang$core$Basics$not(
		_elm_lang$core$List$isEmpty(decks));
	var enoughPlayers = _elm_lang$core$Native_Utils.cmp(
		_elm_lang$core$List$length(lobby.players),
		1) > 0;
	var model = lobbyModel.config;
	return A2(
		_elm_lang$html$Html$div,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$id('config')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$id('config-content'),
						_elm_lang$html$Html_Attributes$class('mui-panel')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$invite, lobbyModel.init.url, lobby.gameCode),
						A2(
						_elm_lang$html$Html$div,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html_Attributes$class('mui-divider')
							]),
						_elm_lang$core$Native_List.fromArray(
							[])),
						A2(
						_elm_lang$html$Html$h1,
						_elm_lang$core$Native_List.fromArray(
							[]),
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html$text('Game Setup')
							])),
						A2(
						_elm_lang$html$Html$ul,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html_Attributes$class('mui-tabs__bar')
							]),
						_elm_lang$core$Native_List.fromArray(
							[
								A2(
								_elm_lang$html$Html$li,
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html_Attributes$class('mui--is-active')
									]),
								_elm_lang$core$Native_List.fromArray(
									[
										A2(
										_elm_lang$html$Html$a,
										_elm_lang$core$Native_List.fromArray(
											[
												A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-toggle', 'tab'),
												A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-controls', 'decks')
											]),
										_elm_lang$core$Native_List.fromArray(
											[
												_elm_lang$html$Html$text('Decks')
											]))
									])),
								A2(
								_elm_lang$html$Html$li,
								_elm_lang$core$Native_List.fromArray(
									[]),
								_elm_lang$core$Native_List.fromArray(
									[
										A2(
										_elm_lang$html$Html$a,
										_elm_lang$core$Native_List.fromArray(
											[
												A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-toggle', 'tab'),
												A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-controls', 'house-rules')
											]),
										_elm_lang$core$Native_List.fromArray(
											[
												_elm_lang$html$Html$text('House Rules')
											]))
									]))
							])),
						A2(
						_elm_lang$html$Html$div,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html_Attributes$id('decks'),
								_elm_lang$html$Html_Attributes$class('mui-tabs__pane mui--is-active')
							]),
						_elm_lang$core$Native_List.fromArray(
							[
								A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckList, decks, model.loadingDecks, model.deckIdInput)
							])),
						A2(
						_elm_lang$html$Html$div,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html_Attributes$id('house-rules'),
								_elm_lang$html$Html_Attributes$class('mui-tabs__pane')
							]),
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Native_List.fromArray(
								[_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$rando]),
							A2(
								_elm_lang$core$List$map,
								function (rule) {
									return A2(
										_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$houseRule,
										A2(_elm_lang$core$List$member, rule.id, lobbyModel.lobby.config.houseRules),
										rule);
								},
								_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_HouseRule_Available$houseRules))),
						A2(
						_elm_lang$html$Html$div,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html_Attributes$class('mui-divider')
							]),
						_elm_lang$core$Native_List.fromArray(
							[])),
						A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$startGameButton, enoughPlayers, enoughCards)
					]))
			]));
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
										_elm_lang$core$Native_List.fromArray(
											[deckId]))
								}),
							_elm_lang$core$Native_List.fromArray(
								[
									A4(
									_Lattyware$massivedecks$MassiveDecks_API_Request$send,
									A3(_Lattyware$massivedecks$MassiveDecks_API$addDeck, gameCode, secret, deckId),
									_Lattyware$massivedecks$MassiveDecks_Scenes_Config$addDeckErrorHandler(deckId),
									_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage,
									function (_p4) {
										return _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage(
											_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ConfigureDecks(
												_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$Add(deckId)));
									}),
									_Lattyware$massivedecks$MassiveDecks_Scenes_Config$inputClearErrorCmd(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$DeckId)
								]));
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
				var _p5 = A2(_Lattyware$massivedecks$MassiveDecks_Components_Input$update, _p3._0, lobbyModel.config.deckIdInput);
				var deckIdInput = _p5._0;
				var msg = _p5._1;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{deckIdInput: deckIdInput}),
					_1: A2(_elm_lang$core$Platform_Cmd$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage, msg)
				};
			case 'AddAi':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A3(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send$,
						A2(_Lattyware$massivedecks$MassiveDecks_API$newAi, gameCode, secret),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage,
						function (_p6) {
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
						_Lattyware$massivedecks$MassiveDecks_API_Request$send$,
						A3(_Lattyware$massivedecks$MassiveDecks_API$enableRule, _p3._0, gameCode, secret),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config$ignore)
				};
			case 'DisableRule':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A3(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send$,
						A3(_Lattyware$massivedecks$MassiveDecks_API$disableRule, _p3._0, gameCode, secret),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$ErrorMessage,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config$ignore)
				};
			default:
				return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$view = function (lobbyModel) {
	return A2(
		_elm_lang$html$Html_App$map,
		_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$LocalMessage,
		_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$view(lobbyModel));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$subscriptions = function (model) {
	return _elm_lang$core$Platform_Sub$none;
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Config$init = {
	decks: _elm_lang$core$Native_List.fromArray(
		[]),
	deckIdInput: A8(
		_Lattyware$massivedecks$MassiveDecks_Components_Input$initWithExtra,
		_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$DeckId,
		'deck-id-input',
		_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$deckIdInputLabel,
		'',
		'Play Code',
		_Lattyware$massivedecks$MassiveDecks_Scenes_Config_UI$addDeckButton,
		_Lattyware$massivedecks$MassiveDecks_Util$cmd(_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$AddDeck),
		_Lattyware$massivedecks$MassiveDecks_Scenes_Config_Messages$InputMessage),
	loadingDecks: _elm_lang$core$Native_List.fromArray(
		[])
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$notificationsMenuItem = function (model) {
	var _p0 = _elm_lang$core$Basics$not(model.supported) ? {
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
		_elm_lang$core$Native_List.fromArray(
			[
				{ctor: '_Tuple2', _0: 'link', _1: true},
				{
				ctor: '_Tuple2',
				_0: 'disabled',
				_1: _elm_lang$core$Basics$not(
					_Lattyware$massivedecks$MassiveDecks_Util$isNothing(notClickable))
			}
			]));
	var extraAttrs = function () {
		var _p1 = notClickable;
		if (_p1.ctor === 'Nothing') {
			return _elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Events$onClick(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationsMessage(
							enabled ? _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$disable : _Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$enable)))
				]);
		} else {
			return _elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$html$Html_Attributes$title(_p1._0)
				]);
		}
	}();
	var attributes = A2(
		_elm_lang$core$Basics_ops['++'],
		_elm_lang$core$Native_List.fromArray(
			[
				classes,
				A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
				A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button')
			]),
		extraAttrs);
	var description = A2(
		_elm_lang$core$Basics_ops['++'],
		' ',
		A2(
			_elm_lang$core$Basics_ops['++'],
			enabled ? 'Disable' : 'Enable',
			' Notifications'));
	return _elm_lang$core$Native_List.fromArray(
		[
			A2(
			_elm_lang$html$Html$li,
			_elm_lang$core$Native_List.fromArray(
				[]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$a,
					attributes,
					_elm_lang$core$Native_List.fromArray(
						[
							_Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon(
							enabled ? 'bell-slash' : 'bell'),
							_elm_lang$html$Html$text(description)
						]))
				]))
		]);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$gameMenu = function (model) {
	return A2(
		_elm_lang$html$Html$div,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('menu mui-dropdown')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$button,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('mui-btn mui-btn--small mui-btn--primary'),
						A2(_elm_lang$html$Html_Attributes$attribute, 'data-mui-toggle', 'dropdown'),
						_elm_lang$html$Html_Attributes$title('Game menu.')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('ellipsis-h')
					])),
				A2(
				_elm_lang$html$Html$ul,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('mui-dropdown__menu mui-dropdown__menu--right')
					]),
				A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$li,
							_elm_lang$core$Native_List.fromArray(
								[]),
							_elm_lang$core$Native_List.fromArray(
								[
									A2(
									_elm_lang$html$Html$a,
									_elm_lang$core$Native_List.fromArray(
										[
											_elm_lang$html$Html_Attributes$class('link'),
											A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
											A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
											_elm_lang$html$Html_Events$onClick(
											_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$DisplayInviteOverlay))
										]),
									_elm_lang$core$Native_List.fromArray(
										[
											_Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('bullhorn'),
											_elm_lang$html$Html$text(' Invite Players')
										]))
								]))
						]),
					A2(
						_elm_lang$core$Basics_ops['++'],
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$notificationsMenuItem(model.browserNotifications),
						_elm_lang$core$Native_List.fromArray(
							[
								A2(
								_elm_lang$html$Html$li,
								_elm_lang$core$Native_List.fromArray(
									[]),
								_elm_lang$core$Native_List.fromArray(
									[
										A2(
										_elm_lang$html$Html$a,
										_elm_lang$core$Native_List.fromArray(
											[
												_elm_lang$html$Html_Attributes$class('link'),
												A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
												A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
												_elm_lang$html$Html_Events$onClick(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$Leave)
											]),
										_elm_lang$core$Native_List.fromArray(
											[
												_Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('sign-out'),
												_elm_lang$html$Html$text(' Leave Game')
											]))
									])),
								A2(
								_elm_lang$html$Html$li,
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$html$Html_Attributes$class('mui-divider')
									]),
								_elm_lang$core$Native_List.fromArray(
									[])),
								A2(
								_elm_lang$html$Html$li,
								_elm_lang$core$Native_List.fromArray(
									[]),
								_elm_lang$core$Native_List.fromArray(
									[
										A2(
										_elm_lang$html$Html$a,
										_elm_lang$core$Native_List.fromArray(
											[
												_elm_lang$html$Html_Attributes$class('link'),
												A2(_elm_lang$html$Html_Attributes$attribute, 'tabindex', '0'),
												A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'button'),
												_elm_lang$html$Html_Events$onClick(
												_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$OverlayMessage(_Lattyware$massivedecks$MassiveDecks_Components_About$show))
											]),
										_elm_lang$core$Native_List.fromArray(
											[
												_Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('info-circle'),
												_elm_lang$html$Html$text(' About')
											]))
									])),
								A2(
								_elm_lang$html$Html$li,
								_elm_lang$core$Native_List.fromArray(
									[]),
								_elm_lang$core$Native_List.fromArray(
									[
										A2(
										_elm_lang$html$Html$a,
										_elm_lang$core$Native_List.fromArray(
											[
												_elm_lang$html$Html_Attributes$href('https://github.com/Lattyware/massivedecks/issues/new'),
												_elm_lang$html$Html_Attributes$target('_blank')
											]),
										_elm_lang$core$Native_List.fromArray(
											[
												_Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('bug'),
												_elm_lang$html$Html$text(' Report a bug')
											]))
									]))
							]))))
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$inviteOverlay = F2(
	function (appUrl, gameCode) {
		var url = A2(_Lattyware$massivedecks$MassiveDecks_Util$lobbyUrl, appUrl, gameCode);
		var contents = _elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$p,
				_elm_lang$core$Native_List.fromArray(
					[]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('To invite other players, simply send them this link: ')
					])),
				A2(
				_elm_lang$html$Html$p,
				_elm_lang$core$Native_List.fromArray(
					[]),
				_elm_lang$core$Native_List.fromArray(
					[
						A2(
						_elm_lang$html$Html$a,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html_Attributes$href(url)
							]),
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html$text(url)
							]))
					])),
				A2(
				_elm_lang$html$Html$p,
				_elm_lang$core$Native_List.fromArray(
					[]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('Have them scan this QR code: ')
					])),
				_Lattyware$massivedecks$MassiveDecks_Components_QR$view('invite-qr-code'),
				A2(
				_elm_lang$html$Html$p,
				_elm_lang$core$Native_List.fromArray(
					[]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('Or give them this game code to enter on the start page: ')
					])),
				A2(
				_elm_lang$html$Html$p,
				_elm_lang$core$Native_List.fromArray(
					[]),
				_elm_lang$core$Native_List.fromArray(
					[
						A2(
						_elm_lang$html$Html$input,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html_Attributes$readonly(true),
								_elm_lang$html$Html_Attributes$value(gameCode)
							]),
						_elm_lang$core$Native_List.fromArray(
							[]))
					]))
			]);
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
	return A2(
		_elm_lang$core$Basics_ops['++'],
		function () {
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
		}(),
		player.disconnected ? ' (Disconnected)' : '');
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$notificationPopup = function (notification) {
	var _p4 = notification;
	if (_p4.ctor === 'Just') {
		var _p5 = _p4._0;
		var hidden = _p5.visible ? '' : 'hide';
		return _elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class(
						A2(_elm_lang$core$Basics_ops['++'], 'badge mui--z2 ', hidden)),
						_elm_lang$html$Html_Attributes$title(_p5.description),
						_elm_lang$html$Html_Events$onClick(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$DismissNotification(_p5)))
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon(_p5.icon),
						_elm_lang$html$Html$text(
						A2(_elm_lang$core$Basics_ops['++'], ' ', _p5.name))
					]))
			]);
	} else {
		return _elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('badge mui--z2 hide')
					]),
				_elm_lang$core$Native_List.fromArray(
					[]))
			]);
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$scoresButton = function (shown) {
	var showHideClasses = shown ? ' mui--hidden-xs js-hide-scores' : ' mui--visible-xs-inline-block js-show-scores';
	return A2(
		_elm_lang$html$Html$button,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class(
				A2(_elm_lang$core$Basics_ops['++'], 'scores-toggle mui-btn mui-btn--small mui-btn--primary badged', showHideClasses)),
				_elm_lang$html$Html_Attributes$title('Players.')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				_Lattyware$massivedecks$MassiveDecks_Components_Icon$fwIcon('users')
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$appHeader = F2(
	function (contents, model) {
		return A2(
			_elm_lang$html$Html$header,
			_elm_lang$core$Native_List.fromArray(
				[]),
			_elm_lang$core$Native_List.fromArray(
				[
					A2(
					_elm_lang$html$Html$div,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html_Attributes$class('mui-appbar mui--appbar-line-height')
						]),
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$html$Html$div,
							_elm_lang$core$Native_List.fromArray(
								[
									_elm_lang$html$Html_Attributes$class('mui--appbar-line-height')
								]),
							_elm_lang$core$Native_List.fromArray(
								[
									A2(
									_elm_lang$html$Html$span,
									_elm_lang$core$Native_List.fromArray(
										[
											_elm_lang$html$Html_Attributes$class('score-buttons')
										]),
									A2(
										_elm_lang$core$List$append,
										_elm_lang$core$Native_List.fromArray(
											[
												_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$scoresButton(true),
												_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$scoresButton(false)
											]),
										_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$notificationPopup(model.notification))),
									A2(
									_elm_lang$html$Html$span,
									_elm_lang$core$Native_List.fromArray(
										[
											_elm_lang$html$Html_Attributes$id('title'),
											_elm_lang$html$Html_Attributes$class('mui--text-title mui--visible-xs-inline-block')
										]),
									contents),
									_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$gameMenu(model)
								]))
						]))
				]));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$score = function (player) {
	var prename = player.disconnected ? _elm_lang$core$Native_List.fromArray(
		[
			_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('minus-circle'),
			_elm_lang$html$Html$text(' ')
		]) : _elm_lang$core$Native_List.fromArray(
		[]);
	var classes = _elm_lang$html$Html_Attributes$classList(
		_elm_lang$core$Native_List.fromArray(
			[
				{
				ctor: '_Tuple2',
				_0: _Lattyware$massivedecks$MassiveDecks_Models_Player$statusName(player.status),
				_1: true
			},
				{ctor: '_Tuple2', _0: 'disconnected', _1: player.disconnected},
				{ctor: '_Tuple2', _0: 'left', _1: player.left}
			]));
	return A2(
		_elm_lang$html$Html$tr,
		_elm_lang$core$Native_List.fromArray(
			[classes]),
		_elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$td,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('state'),
						_elm_lang$html$Html_Attributes$title(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$statusDescription(player))
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$playerIcon(player)
					])),
				A2(
				_elm_lang$html$Html$td,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('name'),
						_elm_lang$html$Html_Attributes$title(player.name)
					]),
				A2(
					_elm_lang$core$List$append,
					prename,
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html$text(player.name)
						]))),
				A2(
				_elm_lang$html$Html$td,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('score')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text(
						_elm_lang$core$Basics$toString(player.score))
					]))
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$scores = function (players) {
	return A2(
		_elm_lang$html$Html$div,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$id('scores')
			]),
		_elm_lang$core$Native_List.fromArray(
			[
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$id('scores-title'),
						_elm_lang$html$Html_Attributes$class('mui--appbar-line-height mui--text-title')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('Players')
					])),
				A2(
				_elm_lang$html$Html$div,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('mui-divider')
					]),
				_elm_lang$core$Native_List.fromArray(
					[])),
				A2(
				_elm_lang$html$Html$table,
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html_Attributes$class('mui-table')
					]),
				_elm_lang$core$Native_List.fromArray(
					[
						A2(
						_elm_lang$html$Html$thead,
						_elm_lang$core$Native_List.fromArray(
							[]),
						_elm_lang$core$Native_List.fromArray(
							[
								A2(
								_elm_lang$html$Html$tr,
								_elm_lang$core$Native_List.fromArray(
									[]),
								_elm_lang$core$Native_List.fromArray(
									[
										A2(
										_elm_lang$html$Html$th,
										_elm_lang$core$Native_List.fromArray(
											[
												_elm_lang$html$Html_Attributes$class('state'),
												_elm_lang$html$Html_Attributes$title('State')
											]),
										_elm_lang$core$Native_List.fromArray(
											[
												_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('tasks')
											])),
										A2(
										_elm_lang$html$Html$th,
										_elm_lang$core$Native_List.fromArray(
											[
												_elm_lang$html$Html_Attributes$class('name')
											]),
										_elm_lang$core$Native_List.fromArray(
											[
												_elm_lang$html$Html$text('Player')
											])),
										A2(
										_elm_lang$html$Html$th,
										_elm_lang$core$Native_List.fromArray(
											[
												_elm_lang$html$Html_Attributes$class('score'),
												_elm_lang$html$Html_Attributes$title('Score')
											]),
										_elm_lang$core$Native_List.fromArray(
											[
												_Lattyware$massivedecks$MassiveDecks_Components_Icon$icon('star')
											]))
									]))
							])),
						A2(
						_elm_lang$html$Html$tbody,
						_elm_lang$core$Native_List.fromArray(
							[]),
						A2(_elm_lang$core$List$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$score, players))
					]))
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$spacer = A2(
	_elm_lang$html$Html$div,
	_elm_lang$core$Native_List.fromArray(
		[
			_elm_lang$html$Html_Attributes$class('mui--appbar-height')
		]),
	_elm_lang$core$Native_List.fromArray(
		[]));
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$contentWrapper = function (contents) {
	return A2(
		_elm_lang$html$Html$div,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$id('content-wrapper')
			]),
		contents);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$root = function (contents) {
	return A2(
		_elm_lang$html$Html$div,
		_elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$html$Html_Attributes$class('content')
			]),
		contents);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$view = function (model) {
	var url = model.init.url;
	var lobby = model.lobby;
	var gameCode = lobby.gameCode;
	var players = lobby.players;
	var _p6 = function () {
		var _p7 = lobby.round;
		if (_p7.ctor === 'Nothing') {
			return {
				ctor: '_Tuple2',
				_0: _elm_lang$core$Native_List.fromArray(
					[]),
				_1: _elm_lang$core$Native_List.fromArray(
					[
						A2(
						_elm_lang$html$Html_App$map,
						function (_p8) {
							return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ConfigMessage(_p8));
						},
						_Lattyware$massivedecks$MassiveDecks_Scenes_Config$view(model))
					])
			};
		} else {
			var _p9 = _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$view(model);
			var h = _p9._0;
			var c = _p9._1;
			return {
				ctor: '_Tuple2',
				_0: A2(
					_elm_lang$core$List$map,
					_elm_lang$html$Html_App$map(
						function (_p10) {
							return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage(_p10));
						}),
					h),
				_1: A2(
					_elm_lang$core$List$map,
					_elm_lang$html$Html_App$map(
						function (_p11) {
							return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage(_p11));
						}),
					c)
			};
		}
	}();
	var header = _p6._0;
	var contents = _p6._1;
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$root(
		_elm_lang$core$Native_List.fromArray(
			[
				A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$appHeader, header, model),
				_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$spacer,
				_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$scores(players),
				_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$contentWrapper(contents)
			]));
};

var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$notificationChange = F2(
	function (model, notification) {
		var newNotification = _elm_lang$core$Maybe$oneOf(
			_elm_lang$core$Native_List.fromArray(
				[notification, model.notification]));
		var cmd = function () {
			var _p0 = newNotification;
			if (_p0.ctor === 'Just') {
				var dismiss = A2(
					_Lattyware$massivedecks$MassiveDecks_Util$after,
					_elm_lang$core$Time$second * 5,
					_elm_lang$core$Task$succeed(_p0._0));
				return A3(
					_elm_lang$core$Task$perform,
					_Lattyware$massivedecks$MassiveDecks_Util$impossible,
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
			_elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Util$cmd(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LobbyAndHandUpdated))))
				]));
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
					_elm_lang$core$Native_List.fromArray(
						[
							_elm_lang$html$Html$text('You did not give Massive Decks permission to give you desktop notifications.')
						]))));
	} else {
		return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$NoOp);
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateRound = function (roundUpdate) {
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby(
		function (lobby) {
			return _elm_lang$core$Native_Utils.update(
				lobby,
				{
					round: A2(_elm_lang$core$Maybe$map, roundUpdate, lobby.round)
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
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$handleEvent = function (event) {
	var _p4 = event;
	switch (_p4.ctor) {
		case 'Sync':
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobbyAndHand(_p4._0)
				]);
		case 'PlayerJoin':
			var _p5 = _p4._0;
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SetNotification(
					_Lattyware$massivedecks$MassiveDecks_Models_Notification$playerJoin(_p5.id)),
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby(
					function (lobby) {
						return _elm_lang$core$Native_Utils.update(
							lobby,
							{
								players: A2(
									_elm_lang$core$Basics_ops['++'],
									lobby.players,
									_elm_lang$core$Native_List.fromArray(
										[_p5]))
							});
					})
				]);
		case 'PlayerStatus':
			var _p10 = _p4._1;
			var _p9 = _p4._0;
			var browserNotification = function () {
				var _p6 = _p10;
				switch (_p6.ctor) {
					case 'NotPlayed':
						return _elm_lang$core$Native_List.fromArray(
							[
								A3(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationForUser,
								function (_p7) {
									return _elm_lang$core$Maybe$Just(_p9);
								},
								'You need to play a card for the round.',
								'hourglass')
							]);
					case 'Skipping':
						return _elm_lang$core$Native_List.fromArray(
							[
								A3(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationForUser,
								function (_p8) {
									return _elm_lang$core$Maybe$Just(_p9);
								},
								'You are being skipped due to inactivity.',
								'fast-forward')
							]);
					default:
						return _elm_lang$core$Native_List.fromArray(
							[]);
				}
			}();
			return A2(
				_elm_lang$core$Basics_ops['++'],
				_elm_lang$core$Native_List.fromArray(
					[
						A2(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updatePlayer,
						_p9,
						function (player) {
							return _elm_lang$core$Native_Utils.update(
								player,
								{status: _p10});
						})
					]),
				browserNotification);
		case 'PlayerLeft':
			var _p11 = _p4._0;
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SetNotification(
					_Lattyware$massivedecks$MassiveDecks_Models_Notification$playerLeft(_p11)),
					A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updatePlayer,
					_p11,
					function (player) {
						return _elm_lang$core$Native_Utils.update(
							player,
							{left: true});
					})
				]);
		case 'PlayerDisconnect':
			var _p12 = _p4._0;
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SetNotification(
					_Lattyware$massivedecks$MassiveDecks_Models_Notification$playerDisconnect(_p12)),
					A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updatePlayer,
					_p12,
					function (player) {
						return _elm_lang$core$Native_Utils.update(
							player,
							{disconnected: true});
					})
				]);
		case 'PlayerReconnect':
			var _p13 = _p4._0;
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$SetNotification(
					_Lattyware$massivedecks$MassiveDecks_Models_Notification$playerReconnect(_p13)),
					A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updatePlayer,
					_p13,
					function (player) {
						return _elm_lang$core$Native_Utils.update(
							player,
							{disconnected: false});
					})
				]);
		case 'PlayerScoreChange':
			return _elm_lang$core$Native_List.fromArray(
				[
					A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updatePlayer,
					_p4._0,
					function (player) {
						return _elm_lang$core$Native_Utils.update(
							player,
							{score: _p4._1});
					})
				]);
		case 'HandChange':
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateHand(_p4._0)
				]);
		case 'RoundStart':
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby(
					function (lobby) {
						return _elm_lang$core$Native_Utils.update(
							lobby,
							{
								round: _elm_lang$core$Maybe$Just(
									A3(
										_Lattyware$massivedecks$MassiveDecks_Models_Game$Round,
										_p4._0,
										_p4._1,
										_Lattyware$massivedecks$MassiveDecks_Models_Card$Hidden(0)))
							});
					})
				]);
		case 'RoundPlayed':
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateRound(
					function (round) {
						return _elm_lang$core$Native_Utils.update(
							round,
							{
								responses: _Lattyware$massivedecks$MassiveDecks_Models_Card$Hidden(_p4._0)
							});
					})
				]);
		case 'RoundJudging':
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateRound(
					function (round) {
						return _elm_lang$core$Native_Utils.update(
							round,
							{
								responses: _Lattyware$massivedecks$MassiveDecks_Models_Card$Revealed(
									A2(_Lattyware$massivedecks$MassiveDecks_Models_Card$RevealedResponses, _p4._0, _elm_lang$core$Maybe$Nothing))
							});
					}),
					A3(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationForUser,
					function (lobby) {
						return A2(
							_elm_lang$core$Maybe$map,
							function (_) {
								return _.czar;
							},
							lobby.round);
					},
					'You need to pick a winner for the round.',
					'gavel')
				]);
		case 'RoundEnd':
			var _p14 = _p4._0;
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateRound(
					function (round) {
						return _elm_lang$core$Native_Utils.update(
							round,
							{
								responses: _Lattyware$massivedecks$MassiveDecks_Models_Card$Revealed(
									A2(
										_Lattyware$massivedecks$MassiveDecks_Models_Card$RevealedResponses,
										_p14.responses,
										_elm_lang$core$Maybe$Just(_p14.playedByAndWinner)))
							});
					}),
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$LocalMessage(
						_Lattyware$massivedecks$MassiveDecks_Scenes_Playing_Messages$FinishRound(_p14)))
				]);
		case 'GameStart':
			return _elm_lang$core$Native_List.fromArray(
				[]);
		case 'GameEnd':
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby(
					function (lobby) {
						return _elm_lang$core$Native_Utils.update(
							lobby,
							{round: _elm_lang$core$Maybe$Nothing});
					}),
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateHand(
					{
						hand: _elm_lang$core$Native_List.fromArray(
							[])
					})
				]);
		default:
			return _elm_lang$core$Native_List.fromArray(
				[
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$UpdateLobby(
					function (lobby) {
						return _elm_lang$core$Native_Utils.update(
							lobby,
							{config: _p4._0});
					})
				]);
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$view = function (model) {
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$view(model);
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$webSocketResponseDecoder = function (response) {
	if (_elm_lang$core$Native_Utils.eq(response, 'identify')) {
		return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$Identify);
	} else {
		var _p15 = _Lattyware$massivedecks$MassiveDecks_Models_Event$fromJson(response);
		if (_p15.ctor === 'Ok') {
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
				_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$Batch(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$handleEvent(_p15._0)));
		} else {
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ErrorMessage(
				A2(
					_Lattyware$massivedecks$MassiveDecks_Components_Errors$New,
					A2(_elm_lang$core$Basics_ops['++'], 'Error handling notification: ', _p15._0),
					true));
		}
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$webSocketUrl = F2(
	function (url, gameCode) {
		var _p16 = function () {
			var _p17 = A2(_elm_lang$core$String$split, ':', url);
			if (_p17.ctor === '[]') {
				return {
					ctor: '_Tuple2',
					_0: 'No protocol.',
					_1: _elm_lang$core$Native_List.fromArray(
						[])
				};
			} else {
				return {ctor: '_Tuple2', _0: _p17._0, _1: _p17._1};
			}
		}();
		var protocol = _p16._0;
		var rest = _p16._1;
		var host = A2(_elm_lang$core$String$join, ':', rest);
		var baseUrl = function () {
			var _p18 = protocol;
			switch (_p18) {
				case 'http':
					return A2(_elm_lang$core$Basics_ops['++'], 'ws:', host);
				case 'https':
					return A2(_elm_lang$core$Basics_ops['++'], 'wss:', host);
				default:
					var _p19 = A2(_elm_lang$core$Debug$log, 'Assuming https due to unknown protocol for URL', _p18);
					return A2(_elm_lang$core$Basics_ops['++'], 'wss:', host);
			}
		}();
		return A2(
			_elm_lang$core$Basics_ops['++'],
			baseUrl,
			A2(
				_elm_lang$core$Basics_ops['++'],
				'lobbies/',
				A2(_elm_lang$core$Basics_ops['++'], gameCode, '/notifications')));
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$update = F2(
	function (message, model) {
		var lobby = model.lobby;
		var _p20 = message;
		switch (_p20.ctor) {
			case 'ConfigMessage':
				var _p21 = _p20._0;
				switch (_p21.ctor) {
					case 'ErrorMessage':
						return {
							ctor: '_Tuple2',
							_0: model,
							_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ErrorMessage(_p21._0))
						};
					case 'HandUpdate':
						return A2(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateLobbyAndHand,
							A2(_Lattyware$massivedecks$MassiveDecks_Models_Game$LobbyAndHand, model.lobby, _p21._0),
							model);
					default:
						var _p22 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Config$update, _p21._0, model);
						var config = _p22._0;
						var cmd = _p22._1;
						return {
							ctor: '_Tuple2',
							_0: _elm_lang$core$Native_Utils.update(
								model,
								{config: config}),
							_1: A2(
								_elm_lang$core$Platform_Cmd$map,
								function (_p23) {
									return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
										_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ConfigMessage(_p23));
								},
								cmd)
						};
				}
			case 'PlayingMessage':
				var _p24 = _p20._0;
				switch (_p24.ctor) {
					case 'ErrorMessage':
						return {
							ctor: '_Tuple2',
							_0: model,
							_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ErrorMessage(_p24._0))
						};
					case 'HandUpdate':
						return A2(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateLobbyAndHand,
							A2(_Lattyware$massivedecks$MassiveDecks_Models_Game$LobbyAndHand, model.lobby, _p24._0),
							model);
					default:
						var _p25 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$update, _p24._0, model);
						var playing = _p25._0;
						var cmd = _p25._1;
						return {
							ctor: '_Tuple2',
							_0: _elm_lang$core$Native_Utils.update(
								model,
								{playing: playing}),
							_1: A2(
								_elm_lang$core$Platform_Cmd$map,
								function (_p26) {
									return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
										_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage(_p26));
								},
								cmd)
						};
				}
			case 'BrowserNotificationsMessage':
				var _p27 = A2(_Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$update, _p20._0, model.browserNotifications);
				var browserNotifications = _p27._0;
				var localCmd = _p27._1;
				var cmd = _p27._2;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{browserNotifications: browserNotifications}),
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_elm_lang$core$Platform_Cmd$map,
							function (_p28) {
								return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
									_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationsMessage(_p28));
							},
							localCmd),
							A2(_elm_lang$core$Platform_Cmd$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$overlayAlert, cmd)
						]));
			case 'BrowserNotificationForUser':
				var cmd = function () {
					var _p29 = _p20._0(lobby);
					if (_p29.ctor === 'Just') {
						return _elm_lang$core$Native_Utils.eq(_p29._0, model.secret.id) ? _Lattyware$massivedecks$MassiveDecks_Util$cmd(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationsMessage(
									_Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$notify(
										{
											title: _p20._1,
											icon: A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$icon, model, _p20._2)
										})))) : _elm_lang$core$Platform_Cmd$none;
					} else {
						return _elm_lang$core$Platform_Cmd$none;
					}
				}();
				return {ctor: '_Tuple2', _0: model, _1: cmd};
			case 'UpdateLobbyAndHand':
				return A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateLobbyAndHand, _p20._0, model);
			case 'UpdateLobby':
				return A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateLobbyAndHand,
					A2(
						_Lattyware$massivedecks$MassiveDecks_Models_Game$LobbyAndHand,
						_p20._0(lobby),
						model.hand),
					model);
			case 'UpdateHand':
				return A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$updateLobbyAndHand,
					A2(_Lattyware$massivedecks$MassiveDecks_Models_Game$LobbyAndHand, model.lobby, _p20._0),
					model);
			case 'SetNotification':
				return A2(
					_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$notificationChange,
					model,
					_p20._0(lobby.players));
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
					_elm_lang$core$Native_List.fromArray(
						[
							_Lattyware$massivedecks$MassiveDecks_Util$cmd(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$OverlayMessage(
								A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_UI$inviteOverlay, model.init.url, model.lobby.gameCode)))
						]));
			case 'RenderQr':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{qrNeedsRendering: false}),
					_elm_lang$core$Native_List.fromArray(
						[
							A2(
							_Lattyware$massivedecks$MassiveDecks_Components_QR$encodeAndRender,
							'invite-qr-code',
							A2(_Lattyware$massivedecks$MassiveDecks_Util$lobbyUrl, model.init.url, model.lobby.gameCode))
						]));
			case 'DismissNotification':
				var newModel = _elm_lang$core$Native_Utils.eq(
					model.notification,
					_elm_lang$core$Maybe$Just(_p20._0)) ? _elm_lang$core$Native_Utils.update(
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
						function (_p30) {
							return _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_p30));
						},
						_p20._0));
			default:
				return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$subscriptions = function (model) {
	var render = model.qrNeedsRendering ? _elm_lang$core$Native_List.fromArray(
		[
			_elm_lang$animation_frame$AnimationFrame$diffs(
			function (_p31) {
				return _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$RenderQr);
			})
		]) : _elm_lang$core$Native_List.fromArray(
		[]);
	var browserNotifications = A2(
		_elm_lang$core$Platform_Sub$map,
		_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$BrowserNotificationsMessage,
		_Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$subscriptions(model.browserNotifications));
	var websocket = A2(
		_elm_lang$websocket$WebSocket$listen,
		A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$webSocketUrl, model.init.url, model.lobby.gameCode),
		_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$webSocketResponseDecoder);
	var delegated = function () {
		var _p32 = model.lobby.round;
		if (_p32.ctor === 'Nothing') {
			return A2(
				_elm_lang$core$Platform_Sub$map,
				_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$ConfigMessage,
				_Lattyware$massivedecks$MassiveDecks_Scenes_Config$subscriptions(model.config));
		} else {
			return A2(
				_elm_lang$core$Platform_Sub$map,
				_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$PlayingMessage,
				_Lattyware$massivedecks$MassiveDecks_Scenes_Playing$subscriptions(model.playing));
		}
	}();
	return _elm_lang$core$Platform_Sub$batch(
		A2(
			_elm_lang$core$Basics_ops['++'],
			_elm_lang$core$Native_List.fromArray(
				[
					A2(_elm_lang$core$Platform_Sub$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage, delegated),
					websocket,
					A2(_elm_lang$core$Platform_Sub$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage, browserNotifications)
				]),
			render));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$init = F3(
	function (init, lobbyAndHand, secret) {
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			{
				lobby: lobbyAndHand.lobby,
				hand: lobbyAndHand.hand,
				config: _Lattyware$massivedecks$MassiveDecks_Scenes_Config$init,
				playing: _Lattyware$massivedecks$MassiveDecks_Scenes_Playing$init(init),
				browserNotifications: A2(_Lattyware$massivedecks$MassiveDecks_Components_BrowserNotifications$init, init.browserNotificationsSupported, false),
				secret: secret,
				init: init,
				notification: _elm_lang$core$Maybe$Nothing,
				qrNeedsRendering: false
			},
			_elm_lang$core$Native_List.fromArray(
				[]));
	});

var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$getLobbyAndHandErrorHandler = function (error) {
	var errorMessage = function () {
		var _p0 = error;
		return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ClearExistingGame;
	}();
	return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Batch(
		_elm_lang$core$Native_List.fromArray(
			[
				_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$SetButtonsEnabled(true),
				errorMessage
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$newPlayerErrorHandler = function (error) {
	var errorMessage = function () {
		var _p1 = error;
		if (_p1.ctor === 'NameInUse') {
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$InputMessage(
				{
					ctor: '_Tuple2',
					_0: _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Name,
					_1: _Lattyware$massivedecks$MassiveDecks_Components_Input$Error(
						_elm_lang$core$Maybe$Just('This name is already in use in this game, try something else.'))
				});
		} else {
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
		_elm_lang$core$Native_List.fromArray(
			[
				_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$SetButtonsEnabled(true),
				errorMessage
			]));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$update = F2(
	function (message, model) {
		var _p2 = message;
		switch (_p2.ctor) {
			case 'ErrorMessage':
				var _p3 = A2(_Lattyware$massivedecks$MassiveDecks_Components_Errors$update, _p2._0, model.errors);
				var newErrors = _p3._0;
				var cmd = _p3._1;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{errors: newErrors}),
					_1: A2(_elm_lang$core$Platform_Cmd$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage, cmd)
				};
			case 'TabsMessage':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							tabs: A2(_Lattyware$massivedecks$MassiveDecks_Components_Tabs$update, _p2._0, model.tabs)
						}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'ShowInfoMessage':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							info: _elm_lang$core$Maybe$Just(_p2._0)
						}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'ClearExistingGame':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					_elm_lang$core$Native_List.fromArray(
						[
							_Lattyware$massivedecks$MassiveDecks_Util$cmd(
							_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ShowInfoMessage('The game you were in has ended.')),
							_Lattyware$massivedecks$MassiveDecks_Components_Storage$storeLeftGame
						]));
			case 'CreateLobby':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{buttonsEnabled: false}),
					_1: A3(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send$,
						_Lattyware$massivedecks$MassiveDecks_API$createLobby,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage,
						function (lobby) {
							return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinGivenLobbyAsNewPlayer(lobby.gameCode);
						})
				};
			case 'SubmitCurrentTab':
				var _p4 = model.tabs.current;
				if (_p4.ctor === 'Create') {
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
						{buttonsEnabled: _p2._0}),
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
				var _p5 = _p2._0;
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: A4(
						_Lattyware$massivedecks$MassiveDecks_API_Request$send,
						A2(_Lattyware$massivedecks$MassiveDecks_API$newPlayer, _p5, model.nameInput.value),
						_Lattyware$massivedecks$MassiveDecks_Scenes_Start$newPlayerErrorHandler,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage,
						function (secret) {
							return A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsExistingPlayer, secret, _p5);
						})
				};
			case 'JoinLobbyAsExistingPlayer':
				var _p7 = _p2._0;
				var _p6 = _p2._1;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					_elm_lang$core$Native_List.fromArray(
						[
							A4(
							_Lattyware$massivedecks$MassiveDecks_API_Request$send,
							A2(_Lattyware$massivedecks$MassiveDecks_API$getLobbyAndHand, _p6, _p7),
							_Lattyware$massivedecks$MassiveDecks_Scenes_Start$getLobbyAndHandErrorHandler,
							_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage,
							_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobby(_p7)),
							_Lattyware$massivedecks$MassiveDecks_Components_Storage$storeInGame(
							A2(_Lattyware$massivedecks$MassiveDecks_Models_Game$GameCodeAndSecret, _p6, _p7))
						]));
			case 'JoinLobby':
				var _p8 = A3(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$init, model.init, _p2._1, _p2._0);
				var lobby = _p8._0;
				var cmd = _p8._1;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							lobby: _elm_lang$core$Maybe$Just(lobby)
						}),
					_1: A2(_elm_lang$core$Platform_Cmd$map, _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$LobbyMessage, cmd)
				};
			case 'InputMessage':
				var _p11 = _p2._0;
				var _p9 = A2(_Lattyware$massivedecks$MassiveDecks_Components_Input$update, _p11, model.gameCodeInput);
				var gameCodeInput = _p9._0;
				var gameCodeCmd = _p9._1;
				var _p10 = A2(_Lattyware$massivedecks$MassiveDecks_Components_Input$update, _p11, model.nameInput);
				var nameInput = _p10._0;
				var nameCmd = _p10._1;
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{nameInput: nameInput, gameCodeInput: gameCodeInput}),
					_1: _elm_lang$core$Platform_Cmd$batch(
						_elm_lang$core$Native_List.fromArray(
							[nameCmd, gameCodeCmd]))
				};
			case 'OverlayMessage':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							overlay: A2(_Lattyware$massivedecks$MassiveDecks_Components_Overlay$update, _p2._0, model.overlay)
						}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'LobbyMessage':
				var _p12 = _p2._0;
				switch (_p12.ctor) {
					case 'ErrorMessage':
						return {
							ctor: '_Tuple2',
							_0: model,
							_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage(_p12._0))
						};
					case 'OverlayMessage':
						return {
							ctor: '_Tuple2',
							_0: model,
							_1: _Lattyware$massivedecks$MassiveDecks_Util$cmd(
								_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$OverlayMessage(
									A2(
										_Lattyware$massivedecks$MassiveDecks_Components_Overlay$map,
										function (_p13) {
											return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$LobbyMessage(
												_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby_Messages$LocalMessage(_p13));
										},
										_p12._0)))
						};
					case 'Leave':
						var leave = function () {
							var _p14 = model.lobby;
							if (_p14.ctor === 'Nothing') {
								return _elm_lang$core$Native_List.fromArray(
									[]);
							} else {
								var _p16 = _p14._0;
								return _elm_lang$core$Native_List.fromArray(
									[
										A3(
										_Lattyware$massivedecks$MassiveDecks_API_Request$send$,
										A2(_Lattyware$massivedecks$MassiveDecks_API$leave, _p16.lobby.gameCode, _p16.secret),
										_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage,
										function (_p15) {
											return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$NoOp;
										})
									]);
							}
						}();
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								model,
								{lobby: _elm_lang$core$Maybe$Nothing, buttonsEnabled: true}),
							A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Native_List.fromArray(
									[_Lattyware$massivedecks$MassiveDecks_Components_Storage$storeLeftGame]),
								leave));
					default:
						var _p17 = model.lobby;
						if (_p17.ctor === 'Nothing') {
							return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
						} else {
							var _p18 = A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$update, _p12._0, _p17._0);
							var newLobby = _p18._0;
							var cmd = _p18._1;
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
						A2(_elm_lang$core$List$map, _Lattyware$massivedecks$MassiveDecks_Util$cmd, _p2._0))
				};
			default:
				return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
		}
	});
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$view = function (model) {
	var contents = function () {
		var _p19 = model.lobby;
		if (_p19.ctor === 'Nothing') {
			return _Lattyware$massivedecks$MassiveDecks_Scenes_Start_UI$view(model);
		} else {
			return A2(
				_elm_lang$html$Html_App$map,
				_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$LobbyMessage,
				_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$view(_p19._0));
		}
	}();
	return A2(
		_elm_lang$html$Html$div,
		_elm_lang$core$Native_List.fromArray(
			[]),
		A2(
			_elm_lang$core$Basics_ops['++'],
			_elm_lang$core$Native_List.fromArray(
				[
					contents,
					A2(
					_elm_lang$html$Html_App$map,
					_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$ErrorMessage,
					_Lattyware$massivedecks$MassiveDecks_Components_Errors$view(model.errors))
				]),
			_Lattyware$massivedecks$MassiveDecks_Components_Overlay$view(model.overlay)));
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$subscriptions = function (model) {
	var _p20 = model.lobby;
	if (_p20.ctor === 'Nothing') {
		return _elm_lang$core$Platform_Sub$none;
	} else {
		return A2(
			_elm_lang$core$Platform_Sub$map,
			_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$LobbyMessage,
			_Lattyware$massivedecks$MassiveDecks_Scenes_Lobby$subscriptions(_p20._0));
	}
};
var _Lattyware$massivedecks$MassiveDecks_Scenes_Start$init = function (init) {
	var command = function () {
		var _p21 = init.existingGame;
		if (_p21.ctor === 'Just') {
			var _p22 = _p21._0;
			return _Lattyware$massivedecks$MassiveDecks_Util$cmd(
				A2(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsExistingPlayer, _p22.secret, _p22.gameCode));
		} else {
			return _elm_lang$core$Platform_Cmd$none;
		}
	}();
	return {
		ctor: '_Tuple2',
		_0: {
			lobby: _elm_lang$core$Maybe$Nothing,
			init: init,
			nameInput: A7(
				_Lattyware$massivedecks$MassiveDecks_Components_Input$init,
				_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Name,
				'name-input',
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('Your name in the game.')
					]),
				'',
				'Nickname',
				_Lattyware$massivedecks$MassiveDecks_Util$cmd(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$SubmitCurrentTab),
				_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$InputMessage),
			gameCodeInput: A7(
				_Lattyware$massivedecks$MassiveDecks_Components_Input$init,
				_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$GameCode,
				'game-code-input',
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$html$Html$text('The code for the game to join.')
					]),
				A2(_elm_lang$core$Maybe$withDefault, '', init.gameCode),
				'',
				_Lattyware$massivedecks$MassiveDecks_Util$cmd(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$JoinLobbyAsNewPlayer),
				_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$InputMessage),
			info: _elm_lang$core$Maybe$Nothing,
			errors: _Lattyware$massivedecks$MassiveDecks_Components_Errors$init,
			overlay: _Lattyware$massivedecks$MassiveDecks_Components_Overlay$init(_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$OverlayMessage),
			buttonsEnabled: true,
			tabs: A3(
				_Lattyware$massivedecks$MassiveDecks_Components_Tabs$init,
				_elm_lang$core$Native_List.fromArray(
					[
						A2(
						_Lattyware$massivedecks$MassiveDecks_Components_Tabs$Tab,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Create,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html$text('Create')
							])),
						A2(
						_Lattyware$massivedecks$MassiveDecks_Components_Tabs$Tab,
						_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Join,
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$html$Html$text('Join')
							]))
					]),
				_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$Create,
				_Lattyware$massivedecks$MassiveDecks_Scenes_Start_Messages$TabsMessage)
		},
		_1: command
	};
};

var _Lattyware$massivedecks$MassiveDecks$main = {
	main: _elm_lang$html$Html_App$programWithFlags(
		{init: _Lattyware$massivedecks$MassiveDecks_Scenes_Start$init, update: _Lattyware$massivedecks$MassiveDecks_Scenes_Start$update, subscriptions: _Lattyware$massivedecks$MassiveDecks_Scenes_Start$subscriptions, view: _Lattyware$massivedecks$MassiveDecks_Scenes_Start$view}),
	flags: A2(
		_elm_lang$core$Json_Decode$andThen,
		A2(_elm_lang$core$Json_Decode_ops[':='], 'browserNotificationsSupported', _elm_lang$core$Json_Decode$bool),
		function (browserNotificationsSupported) {
			return A2(
				_elm_lang$core$Json_Decode$andThen,
				A2(
					_elm_lang$core$Json_Decode_ops[':='],
					'existingGame',
					_elm_lang$core$Json_Decode$oneOf(
						_elm_lang$core$Native_List.fromArray(
							[
								_elm_lang$core$Json_Decode$null(_elm_lang$core$Maybe$Nothing),
								A2(
								_elm_lang$core$Json_Decode$map,
								_elm_lang$core$Maybe$Just,
								A2(
									_elm_lang$core$Json_Decode$andThen,
									A2(_elm_lang$core$Json_Decode_ops[':='], 'gameCode', _elm_lang$core$Json_Decode$string),
									function (gameCode) {
										return A2(
											_elm_lang$core$Json_Decode$andThen,
											A2(
												_elm_lang$core$Json_Decode_ops[':='],
												'secret',
												A2(
													_elm_lang$core$Json_Decode$andThen,
													A2(_elm_lang$core$Json_Decode_ops[':='], 'id', _elm_lang$core$Json_Decode$int),
													function (id) {
														return A2(
															_elm_lang$core$Json_Decode$andThen,
															A2(_elm_lang$core$Json_Decode_ops[':='], 'secret', _elm_lang$core$Json_Decode$string),
															function (secret) {
																return _elm_lang$core$Json_Decode$succeed(
																	{id: id, secret: secret});
															});
													})),
											function (secret) {
												return _elm_lang$core$Json_Decode$succeed(
													{gameCode: gameCode, secret: secret});
											});
									}))
							]))),
				function (existingGame) {
					return A2(
						_elm_lang$core$Json_Decode$andThen,
						A2(
							_elm_lang$core$Json_Decode_ops[':='],
							'gameCode',
							_elm_lang$core$Json_Decode$oneOf(
								_elm_lang$core$Native_List.fromArray(
									[
										_elm_lang$core$Json_Decode$null(_elm_lang$core$Maybe$Nothing),
										A2(_elm_lang$core$Json_Decode$map, _elm_lang$core$Maybe$Just, _elm_lang$core$Json_Decode$string)
									]))),
						function (gameCode) {
							return A2(
								_elm_lang$core$Json_Decode$andThen,
								A2(_elm_lang$core$Json_Decode_ops[':='], 'seed', _elm_lang$core$Json_Decode$string),
								function (seed) {
									return A2(
										_elm_lang$core$Json_Decode$andThen,
										A2(_elm_lang$core$Json_Decode_ops[':='], 'url', _elm_lang$core$Json_Decode$string),
										function (url) {
											return _elm_lang$core$Json_Decode$succeed(
												{browserNotificationsSupported: browserNotificationsSupported, existingGame: existingGame, gameCode: gameCode, seed: seed, url: url});
										});
								});
						});
				});
		})
};

var Elm = {};
Elm['MassiveDecks'] = Elm['MassiveDecks'] || {};
_elm_lang$core$Native_Platform.addPublicModule(Elm['MassiveDecks'], 'MassiveDecks', typeof _Lattyware$massivedecks$MassiveDecks$main === 'undefined' ? null : _Lattyware$massivedecks$MassiveDecks$main);

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

