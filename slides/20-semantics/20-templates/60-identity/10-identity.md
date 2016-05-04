##### `Identity` template

```d
alias Identity(alias X) = X;
```

Notes:

- available in `std.traits`

---

##### `Identity` template

```d
template Identity(alias X) {
    alias Identity = X;
}
```

---

##### `Identity` template

<identity_traits_test.d>

Notes:
- and 3 more errors

---

##### `Identity` template

<identity_traits_test2.d>

<!-- useful for __traits -->

