##### Mixin templates

```d
int foo() { return 42; }

mixin template T() {
	// ???
}

void main() {
	mixin T;
	writeln(x);
}
```

---

##### Mixin templates

```d
int foo() { return 42; }

mixin template T() {
	foo();
}

void main() {
	mixin T;
	writeln(x);
}
```

---

##### Mixin templates

<codemixin.d>
