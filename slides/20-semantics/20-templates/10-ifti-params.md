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

two

splitting explicit/optional template parameters from IFTI template parameters by using a nested function
