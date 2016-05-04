##### `Identity` + UFCS

<identity_ufcs.d>

---

##### `Identity` + UFCS

<identity_ufcs2.d>

---

##### `Identity` + UFCS

```d
return site ~ "/somepage"
    .get()
    .match(regex(`<a href="(.*?)">`))
	.front[1]
	. ??? // site ~ s
	.get()
	...
```

---

##### `Identity` + UFCS

```d
return site ~ "/somepage"
    .get()
    .match(regex(`<a href="(.*?)">`))
	.front[1]
	.I!(s => site ~ s)
	.get()
	...
```
