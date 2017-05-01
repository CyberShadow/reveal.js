# Part 1

### Serialization

---

```d
{ 
	"name" : "John Doe",
	"age" : 42
}
```
## ⇕
```d
struct Person
{
	string name;
	int age;
}
```

---

```d
string toJson(T)(T v)
{
   static if (is(T : const(char)[]))
      return format("%(%s%)", v.only);
   else
   static if (is(T : long))
      return format("%d", v);
   else
      ...
   else
      static assert(0, "Can't serialize " 
         ~ T.stringof ~ " to JSON");
}
```

Notes:

- I cheat here by using std.format to serialize a JSON string like a D literal
- You can also use std.traits or __traits

---

```d
...
else
static if (is(T==struct))
{
   string s;
   foreach (i, field; v.tupleof)
   {
      enum name = __traits(identifier, 
	     v.tupleof[i])
      s ~= format(`"%s":%s`,
         name, toJson(field));
      if (i+1 != v.tupleof.length)
         s ~= ",";
   }
   return "{" ~ s ~ "}";
}
```

Notes:

- not very efficient because of memory allocations
- other than tupleof there is `__traits(getMembers)`
- must use `v.tupleof[i]` to get identifier

---

```d
T jsonParse(T)(ref string s)
{
   static if (is(T : const(char)[]))
      return parseJsonString(s);
   else
   static if (is(T : long))
      return parse!T(s);
   else
      ...
   else
      static assert(0, "Can't parse " ~ 
         T.stringof ~ " from JSON");
}
```

Notes:

- parsing is essentially the same as in reverse
- `T` is specified explicitly here
- not shown: checking if s is empty at the end

---

```d
string jsonField = parseJsonString(s);
enforce(s.skipOver(":"), ": expected");

bool found; T v;
foreach (i, ref field; v.tupleof) {
   enum name = __traits(identifier, 
	  v.tupleof[i]);
   if (name == jsonField) {
      alias F = typeof(field);
      field = jsonParse!F(s);
      found = true;
      break;
   }
}
enforce(found, "Unknown field " ~ 
   jsonField);
```

Notes:
- there's a better way to do this

---

```d
sw: 
switch (jsonField) {
   foreach (i, ref field; v.tupleof) {
      enum name = __traits(identifier, 
        v.tupleof[i]);
      case name:
        alias F = typeof(field);
        v.tupleof[i] = jsonParse!F(s);
        break sw;
   }
   default:
     throw new Exception(
	   "Unknown field " ~ jsonField);
}
```

Notes:
- must use label for break

---

```d
case "refs.json":
{
    struct Refs 
    { 
        string[] branches, tags; 
    }

    auto refs = Refs(
        diggerQuery("branches"),
        diggerQuery("tags"),
    );

    return conn.sendResponse(
        resp.serveJson(refs));
}
```

Notes:

This is a fragment from the digger-web source code
