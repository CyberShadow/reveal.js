import std.format, std.stdio; // SKIP

struct S {
    void toString(
		scope void delegate(const(char)[]) sink,
        FormatSpec!char fmt) const
    {
        sink([fmt.spec]);
    }
}
 
void main() {
    S s;
    writefln("%i", s);
	writefln("%j", s);
	writefln("%k", s);
	writefln("%l", s);
}
