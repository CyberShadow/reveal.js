# Part 2

### alias binding

Notes:
- Talk about my attempt to write a serialization library here
- "I need a real serialization library" -> "A week later, I was up to my neck in DMD code, I had 5 open DMD pull requests and I was trying to fix a bug in DMD's code generation backend"
- I never did complete it, but I did come up with a few cool ideas along the way, which I'd like to show you
- Before I get to that, I need to explain a few concepts first

----

<test_alias_basic.d>

Notes:
`alias` works with many things (functions, types, other templates) but here I'm interested in variables

----

<test_alias_context.d>

Notes:
- context binding

----

<!--
<test_alias_context_ro.d>

----
-->

<test_alias_context_2.d>

Notes:
- Ask audience if they think this compiles

----

```d
struct S
{
	...

	static template T(alias a)
	{
		...
	}
}
```

Notes:
- Ask audience what they think `static` does here

----

<test_alias_static.d tabsize=3>

Notes:
- This does not use the value of `i`, only its properties

----

```d
struct S
{
	...

	/*static*/ template T(alias a)
	{
		/*static*/ void fun()
		{
			...
		}
	}
}
```

----

<!--
<test_alias_static_2.d tabsize=3>

----
-->

<test_alias_NC.d>

Notes:
- I mentioned this briefly last year
- Ask audience if they think this compiles

----

<test_alias.d>

Notes:
- Quirk #1
- Method aliases used to have context before 2.061

----

<test_ambig_static_tpl.d>

Notes:
- Quirk #2
- No matter if `static` is present or not, this won't compile

----

<!-- Kenji's proposal TODO

----
-->

##### The missing operator:<br>`__traits(child)`

```d

struct S { string a, b, c; }

void main()
{
	printField!(S.b)();
}

static void printField(alias field)()
{
	S s = getS();
	writeln(s ??? field);
}
```

Notes:
- tie in context-less aliases to this
- generally, when we want to tell a function which field in a struct to use, we use either
    - pointers
    - inefficient
        - the name of the field as a string, so that it gets glued together with a mixin
          - hacky
          - problems with overloads
          - an alias refer to either an overload set or a specific overload, so they're strictly better

----

```d
static void printField(alias field)()
{
	S s = getS();
	writeln(__traits(child, s, field));
}
```

----

```d
static void printField(alias field)()
{
	S s = getS();
	writeln(s.(field));
}
```
