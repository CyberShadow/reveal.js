##### Implicit Function<br/>Template Instantiation

```d
void fun(T)(T x) {
	pragma(msg, T);
}

fun(5)       => int
fun(4.2)     => double
fun("hello") => string
```

Notes:
- Like `auto` for function parameters
- BTW, `string` is a library type
  `immutable(char)[]`
  The compiler prints `string` 

---

##### Implicit Function<br/>Template Instantiation

<ifti1.d>

---

##### Implicit Function<br/>Template Instantiation

```d
To convert(To, From)(From value) {
	...
}



                                      ⁣
```

Notes:
- In this completely monochrome slide we have a different example

---

##### Implicit Function<br/>Template Instantiation

```d
To convert(To, From)(From value) {
	...
}

auto b = convert!B(a);        // OK

                                      ⁣
```

---

##### Implicit Function<br/>Template Instantiation

```d
To convert(To, From)(From value) {
	...
}

auto b = convert!B(a);        // OK

alias convertToB = convert!B; // Error
```

---

##### Implicit Function<br/>Template Instantiation

```d
template convert(To) {
	To convert(From)(From value) {
		...
	}
}

alias convertToB = convert!B; // OK
auto b = convertToB(a);       // OK
```

<!-- splitting explicit/optional template parameters from IFTI template parameters by using a nested function -->
