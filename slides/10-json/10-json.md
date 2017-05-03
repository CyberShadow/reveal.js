# Part 1

### Serialization

Notes:

- I'd like to start with serialization, because it's one of the things D is really good at

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

Notes:

- For example, let's talk about JSON
- That is what it looks like as a refresher
- And let's say you want to write some code that converts between JSON like that and a D struct like this
- As far as I know it is impossible period to do in C++, 
- but in D it's really easy, and I'll quickly show you how

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

- If you want to write a function to serialize an arbitrary type, you probably want to use `static if`
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

- structs are a special case because you will want to iterate over all members
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

- Very convenient for AJAX applications
- This is a fragment from the digger-web source code
- It is very convenient to just fill a struct and send it over as JSON to the HTML/JavaScript component
