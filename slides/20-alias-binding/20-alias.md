<test_alias_basic.d>

---

<test_alias_NC.d>

Notes:

- I mentioned this briefly last year

---

<test_alias.d>

Notes:

- Method aliases used to have context before 2.061

---

TODO: add slide which demonstrates what "static" does to alias context binding

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

- Ask audience what they think "static" does here
- 