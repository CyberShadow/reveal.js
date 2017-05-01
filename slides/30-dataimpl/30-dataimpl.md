# Part 3

### data / impl<br>composition

Notes:

---

```d
struct SomeAllocator(ParentAllocator, 
	...options...)
{
    static if (stateSize!ParentAllocator)
	{
        ParentAllocator parent;
	}
    else
	{
        alias parent = 
			ParentAllocator.instance;
	}
}
```

Notes:
- This is generally how std.experimental.allocator does compositing
  (nesting parent allocator in the object)

---

<diamond.dot.svg>

Notes:
- Obligatory GraphViz slide
- No obvious efficient way to do diamond-dependencies
- C++ can do it with multiple inheritance

---

```d
template Component(Params...)
{
	struct Data
	{
		... field declarations ...
	}

	template Impl(alias data)
	{
		... use data ...
	}
}
```

---

<adder.dot.svg>

---

```d
// Need static either here or on Impl
/*static*/ template Variable(T)
{
	struct Data
	{
		T value;
	}

	static template Impl(alias data)
	{
		T get() { return data.value; }
	}
}
```

Notes:
- you won't be able to build this with a vanilla compiler

---

```d
template Adder(alias a, alias b)
{
	// dummy argument to set context
	static template Impl(alias a=a)
	{
		auto get()
		{
			return a.get() + b.get();
		}
	}
}
```

---

```d
struct Formula
{
	Variable!int.Data xData;
	Variable!int.Data yData;
	Variable!int.Data zData;

	alias Variable!int.Impl!xData x;
	alias Variable!int.Impl!yData y;
	alias Variable!int.Impl!zData z;

	alias Adder!(x, y).Impl!() a1;
	alias Adder!(y, z).Impl!() a2;
	alias Adder!(a1, a2).Impl!() a3;
}
```

Notes:
- Note that all the implementations have the same `this` pointer

---

```d
void main()
{
	Formula formula;
	formula.aData.value = 2;
	formula.bData.value = 3;
	formula.cData.value = 4;
	assert(formula.a3.get() == 12);
}
```

---

<serialization.dot.svg>

Notes:
- Most serialization libraries use a common representation that they then use to serialize to
- Usually it's the serialized objects (same as my struct), sometimes it's a DOM (same as my Variant)
- In either case, it is some kind of in-memory state
- In my library, the common element between all these is not the state, but the protocol
- If I want to serialize to a given state, I can get a protocol which does this
- This also allows building filters for processing hierarchical data

<style>
<ID> img { height: 350px; } 
</style>

---

##### Code:

https://github.com/CyberShadow/ae/tree/master/utils/serialization
