import std.algorithm;
import std.exception;
import std.string, std.range;
import std.conv;

string toJson(T)(T v)
{
	static if (is(T : const(char)[]))
		return format("%(%s%)", v.only);
	else
	static if (is(T : long))
		return format("%d", v);
	else
	static if (is(T==struct))
	{
		string s;
		foreach (i, field; v.tupleof)
		{
			s ~= format(`"%s":%s`,
				__traits(identifier, T.tupleof[i]),
				toJson(field));
			if (i+1 != v.tupleof.length)
				s ~= ",";
		}
		return "{" ~ s ~ "}";
	}
	else
		static assert(0, "Can't serialize " ~ T.stringof ~ " to JSON");
}

string parseJsonString(ref string s)
{
	enforce(s.skipOver('"'));
	auto parts = s.findSplit(`"`);
	s = parts[2];
	return parts[0];
}

T jsonParse(T)(ref string s)
{
   static if (is(T : const(char)[]))
      return parseJsonString(s);
   else
   static if (is(T : long))
      return parse!T(s);
   else
   static if (is(T==struct))
   {
	   T v;
	   enforce(s.skipOver("{"));
	   while (s[0] != '}')
	   {
string jsonField = parseJsonString(s);
enforce(s.skipOver(":"), ": expected");

bool found;
foreach (i, ref field; v.tupleof) {
   enum name = __traits(identifier, 
	  T.tupleof[i]);
   if (name == jsonField) {
      alias F = typeof(field);
      field = jsonParse!F(s);
      found = true;
      break;
   }
}
enforce(found, "Unknown field " ~ 
   jsonField);
		if (s[0] == ',') // hack
			s.skipOver(",");
	   }
	   return v;
   }
   else
      static assert(0, "Can't parse " ~ 
         T.stringof ~ " from JSON");
}

T jsonParse2(T)(ref string s)
{
   static if (is(T : const(char)[]))
      return parseJsonString(s);
   else
   static if (is(T : long))
      return parse!T(s);
   else
   static if (is(T==struct))
   {
	   T v;
	   enforce(s.skipOver("{"));
	   while (s[0] != '}')
	   {
string jsonField = parseJsonString(s);
enforce(s.skipOver(":"), ": expected");

sw: 
switch (jsonField) {
   foreach (i, ref field; v.tupleof) {
      enum name = __traits(identifier, 
        T.tupleof[i]);
      case name:
        alias F = typeof(field);
        v.tupleof[i] = jsonParse!F(s);
        break sw;
   }
   default:
     throw new Exception(
	   "Unknown field " ~ jsonField);
}
		if (s[0] == ',') // hack
			s.skipOver(",");
	   }
	   return v;
   }
   else
      static assert(0, "Can't parse " ~ 
         T.stringof ~ " from JSON");
}

unittest
{
	struct X { int a; string b; }
	X x = {17, "aoeu"};
	assert(toJson(x) == `{"a":17,"b":"aoeu"}`, toJson(x));
	string s = toJson(x);
	assert(jsonParse!X(s) == x);
	s = toJson(x);
	assert(jsonParse2!X(s) == x);
}
