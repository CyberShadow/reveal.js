import std.algorithm, std.range;

struct S {
	static auto squares = sequence!((a,n) => n * 2)();
}

unittest {
	assert(S.init.fact.drop(10) == 362880);
}
