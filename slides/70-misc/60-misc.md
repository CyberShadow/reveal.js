# Part 7

### Bonus slides

Notes:
- All right! Let's go over some small unclassifiables.

----

<wa.png>

<style> <ID> img { height: 350px; } </style>

Notes:
- Who remembers this game?
- What's it called?
  - Not Worms 2: more weapons
  - Not WWP: transparent team names
- I've been the maintainer of Worms Armageddon since 2006 (which is
  almost exactly as long as I've been using D)
- We use D for a number of things in W:A, but here I'd like to mention one use case
- (configuration of build tool)
- I iterated through probably 5 designs before finally arriving at a satisfying one

----

```d
only(1, "foo").each!writeln;
```

Notes:
- Why doesn't this work?
- Have you ever wanted to have ranges with heterogeneous types?
- Essentially do range operations on tuples?

----

<test_chain.d>

<style> <ID> pre { font-size: 50%; } </style>

Notes:
- D lets you do that!
- chainFunctor and chainFilter bind a lambda to a type
- No problem! Next slide!

----

##### Code:

<a href="https://github.com/CyberShadow/ae/blob/master/utils/meta/chain.d">https://github.com/<br>CyberShadow/ae/blob/<br>master/utils/meta/chain.d</a>

----

<infinifactory.jpg>

----

<kingdomrush.jpg>

----

<ccn.jpg>

----

<unity-logo.png>

----

<fmap.d>

<style> <ID> pre { font-size: 25%; } </style>

----

<typemap.d>

<style> <ID> pre { font-size: 30%; } </style>

Notes:
- TypeMap is only really needed because of recursive types

----

<typemap.d>

<style> <ID> pre { font-size: 30%; } </style>

Notes:
- TypeMap is only really needed because of recursive types

----

<maybe.d>

<style> <ID> pre { font-size: 25%; } </style>

----

<maybify.d>

<style> <ID> pre { font-size: 22%; } </style>

----

<a href="https://github.com/CyberShadow/rclidasm">https://github.com/<br>CyberShadow/rclidasm</a>
