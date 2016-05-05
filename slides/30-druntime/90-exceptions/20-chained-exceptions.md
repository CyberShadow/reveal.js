##### Chained exceptions

<chained2.d>

---

##### Chained exceptions

```text
object.Exception@test.d(5): a
----------------
.../test.d:5 _Dmain [0x423469]
[...]

object.Exception@test.d(7): b
----------------
.../test.d:7 _Dmain [0x4234c1]
[...]
```

---

```d
foreach (line; stdin.byLine) {
	// process line...                ⁣
}
```

```text
Error: Unexpected ',' when converting 
       from type string to type int
```

---

```d
foreach (line; stdin.byLine) {
	scope(failure) stderr.writeln(
		"Error with line: " ~ line);
	// process line...
}
```

---

```d
foreach (line; stdin.byLine) {
    try {
        numbers ~= to!int(line);
    } catch (Exception e) {
        throw new Exception(
		    "Error with line: "~line, e);
    }
}
```

---

```d
foreach (line; stdin.byLine) {
    try {
        numbers ~= to!int(line);
    } catch (Exception e) {
	    e.msg = "Error with line "
			~ line ~ ":\n" ~ msg;
	    throw e;
    }
}
```

Notes:
- automatic chaining only happens with `finally`
- `finally` not applicable here

---

<inflight2.d>

---

<inflight3.d>

```text
object.Exception@test.d(5): Line three:  ⁣
Enforcement failed
```
