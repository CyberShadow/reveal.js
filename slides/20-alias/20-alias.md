# Part 2

### alias binding

---

<test_alias_basic.d>

Notes:

`alias` works with many things (functions, types, other templates) but here I'm interested in variables

---

<test_alias_context.d>

Notes:
- context binding

---

<!--
<test_alias_context_ro.d>
---
-->

<test_alias_context_2.d>

Notes:
- Ask audience if they think this compiles

---

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

---

<test_alias_static.d tabsize=3>

Notes:
- This does not use the value of `i`, only its properties

---

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

---

<!--
<test_alias_static_2.d tabsize=3>

---
-->

<test_alias_NC.d>

Notes:
- I mentioned this briefly last year
- Ask audience if they think this compiles

---

<test_alias.d>

Notes:
- Quirk #1
- Method aliases used to have context before 2.061

---

<test_ambig_static_tpl.d>

Notes:
- Quirk #2
- No matter if `static` is present or not, this won't compile
