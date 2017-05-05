/// Convert a composite type such that all of its direct subtypes are
/// replaced with Tpl!T
template TypeMap(T, alias Tpl)
{
	static if (is(T == Tpl!U, U)) // Almost always a mistake
		static assert(false, "Recursive TypeMap of " ~ T.stringof);
	else
	static if (is(T == struct))
		struct TypeMap { mixin(mixTypeMapStruct!(T, q{Tpl})); }
	else
	static if (is(T U : U*))
		alias TypeMap = Tpl!U*;
	else
	static if (is(T : A[n], A, size_t n))
		alias TypeMap = Tpl!A[n];
	else
	static if (is(T A : A[]))
		alias TypeMap = Tpl!A[];
	else
		static assert(false, "Don't know how to TypeMap " ~ T.stringof);
}
