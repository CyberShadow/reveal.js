##### `TypeInfo`

```d
TypeInfo x = typeid(int);
```

Notes:
- first order types (like Delphi's "class of")
- entire tree of clasess
- ClassInfo
  - defaultConstructor

---

<!--
##### `TypeInfo`
* `getHash`
* `equals`
* `compare`
* `tsize`
* `swap`
next
initializer
flags
-->

##### `RTInfo`

```d
template RTInfo(T) {
    enum RTInfo = ...;
}

typeid(T).rtInfo == RTInfo!T
```
