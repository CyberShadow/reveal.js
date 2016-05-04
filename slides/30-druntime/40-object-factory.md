##### `Object.factory`

```
module foo.bar;

class C {
    this() { x = 10; }
    int x;
}

void main() {
    auto c = cast(C)
	    Object.factory("foo.bar.C");
    assert(c !is null && c.x == 10);
}
```
