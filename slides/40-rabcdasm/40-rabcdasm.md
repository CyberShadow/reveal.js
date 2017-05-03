# Part 4

### RABCDAsm

Notes:
- Who here likes **video games**?
  - I like video games too,
  - and if I particularly like a game, I will sometimes **tinker** with it
  - This is one of my first D projects concerning game modding
- Who here remembers **Newgrounds**?

----

### RABCDAsm

<div style="text-align: left; display: inline-block">
**R**obust  
**A**ctionScript  
**B**yte-  
**C**ode  
**D**is-  
**As**se**m**bler
</div>

Notes:
- This targets specifically the bytecode for the AVM
- AS3 was released with Flash Player 9 in 2006
- RABCDAsm appeared in 2010
- Explain what R means

----

```d
class Multiname
{
	ASType kind;
	union
	{
		QName vQName;
		RTQName vRTQName;
		RTQNameL vRTQNameL;
		Multiname vMultiname;
		MultinameL vMultinameL;
		TypeName vTypeName;
	}
}
```

Notes:
- I won't go into much detail of the file format
- There are many types and data structures involved

----

```d
struct Value
{
	ASType vkind;
	union
	{
		long vint;
		ulong vuint;
		double vdouble;
		string vstring;
		Namespace vnamespace;
	}
}
```

----

```d
struct Trait
{
	Multiname name;
	TraitKind kind;
	ubyte attr;

	union
	{
		Slot vSlot;
		Class vClass;
		Function vFunction;
		Method vMethod;
	}
	Metadata[] metadata;
}
```

Notes:
- These are just a few examples
- There are many types involved

----

- `opEquals`
- `opCmp`
- `toHash`
- `toString`

Notes:
- I needed to test for equality
- I needed to build constant pool tables
- I needed sorting (to optimize compression)

----

```d
static class Multiname
{
	...

	mixin AutoCompare;
	mixin AutoToString;

	R processData(R, string prolog, string epilog, H)
		(ref H handler) const
	{
		mixin(prolog);
		mixin(addAutoField("kind"));
		switch (kind)
		{
			case ASType.QName:
			case ASType.QNameA:
				mixin(addAutoField("vQName.ns"));
				mixin(addAutoField("vQName.name"));
				break;
			...
		}
		mixin(epilog);
	}
}
```

<style> <ID> pre { font-size: 36%; } </style>

Notes:
- `AutoCompare` generates the `opEquals` / `opCmp` / `toHash` trinity
- `AutoToString` generates ...
- You could also use `processData` for serialization if you wanted to
- I won't show the implementation because it is basically D1 code
    - today you could also use attributes, but declarative approaches are more limited than imperative ones
- `__cmp` - previously, it was difficult to partially calculate an object's hash - there wasn't even a way to call the hash function that the compiler used

----

#### RECT

| Field | Type	    | Comment								    |
| ----- | --------- | ----------------------------------------- |
| Nbits | UB[5]	    | Bits used for each subsequent field	    |
| Xmin  | SB[Nbits] | x minimum position for rectangle in twips |
| Xmax  | SB[Nbits] | x maximum position for rectangle in twips |
| Ymin  | SB[Nbits] | y minimum position for rectangle in twips |
| Ymax  | SB[Nbits] | y maximum position for rectangle in twips |

<style>
<ID> table { font-size: 60%; margin: 0 3.5em !important; }
</style>

----

```d
RECT readRect()
{
	auto nBits = readBits(5);
	RECT r;
	r.Xmin = readBits(nBits);
	r.Xmax = readBits(nBits);
	r.Ymin = readBits(nBits);
	r.Ymax = readBits(nBits);
}
```

Notes:
- Normally you'd do something like this, but then you have to **repeat it for writing**
- more complexity if you want to implement something like the **visitor pattern**

----

```d
mixin(makeStruct!("RECT", [
    FieldDef("Nbits",   "UB[5]"),
    FieldDef("Xmin",    "SB[Nbits]"),
    FieldDef("Xmax",    "SB[Nbits]"),
    FieldDef("Ymin",    "SB[Nbits]"),
    FieldDef("Ymax",    "SB[Nbits]"),
]));
```

Notes:
- D allows us to define a DSL which allows defining the file format in a declarative manner using syntax that's very close to the specification
- I could almost copy and paste from the specification for many types

----

#### MATRIX

| Field				| Type								| Comment								    |
| -----				| ---------							| ----------------------------------------- |
| HasScale			| UB[1]								| Has scale values if equal to 1			|
| NScaleBits		| If HasScale = 1, UB[5]			| Bits in each scale value field			|
| ScaleX			| If HasScale = 1, FB[NScaleBits]	| x scale value								|
| ScaleY			| If HasScale = 1, FB[NScaleBits]	| y scale value								|
| HasRotate			| UB[1]								| Has rotate and skew values if equal to 1	|
| NRotateBits		| If HasRotate = 1, UB[5]			| Bits in each rotate value field			|
| RotateSkew0		| If HasRotate = 1, FB[NRotateBits]	| First rotate and skew value				|
| RotateSkew1		| If HasRotate = 1, FB[NRotateBits] | Second rotate and skew value				|
| NTranslateBits	| UB[5]								| Bits in each translate value field		|
| TranslateX		| SB[NTranslateBits]				| x translate value in twips				|
| TranslateY		| SB[NTranslateBits]				| y translate value in twips				|

<style>
<ID> table { font-size: 35%; margin: 0 3.5em !important; }
</style>

----

```d
mixin(makeStruct!("MATRIX", [
    FieldDef("HasScale",       "UB[1]"),
    FieldDef("NScaleBits",     "UB[5]",            "HasScale"),
    FieldDef("ScaleX",         "FB[NScaleBits]",   "HasScale"),
    FieldDef("ScaleY",         "FB[NScaleBits]",   "HasScale"),
    FieldDef("HasRotate",      "UB[1]"),
    FieldDef("NRotateBits",    "UB[5]",            "HasRotate"),
    FieldDef("RotateX",        "FB[NRotateBits]",  "HasRotate"),
    FieldDef("RotateY",        "FB[NRotateBits]",  "HasRotate"),
    FieldDef("NTranslateBits", "UB[5]"),
    FieldDef("TranslateX",     "FB[NTranslateBits]"),
    FieldDef("TranslateY",     "FB[NTranslateBits]"),
]));
```

<style>
<ID> pre { font-size: 35%; }
</style>

----

```d
mixin(makeStruct!("DefineButton2", [
    FieldDef("ButtonId",      "UI16"),
    FieldDef("ReservedFlags", "UB[7]"),
    FieldDef("TrackAsMenu",   "UB[1]"),
    FieldDef("ActionOffset",  "UI16"),
    FieldDef("Characters",    "BUTTONRECORD[]!"),
    FieldDef("Actions",       "BUTTONCONDACTION[]!"),
], q{
    BUTTONRECORD[] readCharacters(ref ubyte[] bytes)
    {
        ...
    }

    BUTTONCONDACTION[] readActions(ref ubyte[] bytes)
    {
        ...
    }
}));
```

<style>
<ID> pre { font-size: 45%; }
</style>

Notes:
- The file format has many inconsistencies
- Because D allows us to mix code and data easily, we can add custom behavior when needed

----

##### `makeStruct`

<makestruct.d>

<style>
<ID> pre { 
	font-size: 6%;
	height: 350px;
}
<ID> pre code { 
     -webkit-column-count: 4; /* Chrome, Safari, Opera */
    -moz-column-count: 4; /* Firefox */
    column-count: 4;
	height: 350px;
}
</style>

Notes:
- There is a lot of code but it's pretty **boring**
- It's essentially code generation using plain old **string concatenation**
  - "The basic idea is to just use basic string processing to build the struct declaration, along with the reader and writer methods"
  - "Because all the data is given to us in the FieldDefs, we don't even need to do any introspection like with JSON"
- There is so **much code** mainly because of the number of **weirdnesses** in the file format
- One thing stands out - mention **compilation time** as I kept adding structs

----

```d
static string makeStruct(...)()
{
	if (!__ctfe)
		return null;

	...
```

Notes:
- This `if` statement brought compilation time from **over an hour** to a few seconds
- Remind what `__ctfe` does

----

<a href="https://github.com/CyberShadow/RABCDAsm">https://github.com/<br>CyberShadow/RABCDAsm</a>

<table>
<tr><td>
<REMnux-logo.png>
</td><td>
<f-secure_trans.png>
</td></tr>
<tr><td>https://remnux.org/</td><td><a href="https://github.com/F-Secure/reflash">https://github.com/<br>F-Secure/reflash</a></td></tr>
</table>

<style>
<ID> img {
	vertical-align: middle;
	width: 180px;
}
<ID> table {
	width: 100%;
	table-layout: fixed;
}
<ID> td {
	text-align: center !important;
	font-size: 80%;
	border-bottom: none !important;
}
</style>

Notes:
- REMnux = Linux Toolkit for Reverse-Engineering and Analyzing Malware
- F-Secure ... which I think is pretty awesome, considering this started as a project for me to tinker with Flash games
