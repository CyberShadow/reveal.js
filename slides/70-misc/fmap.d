/// Map a composite type's values using func
inout(R) fmap(alias func, R, T)(ref inout(T) v)
{
	static if (is(T == struct))
	{
		R result;
		foreach (i, ref f; v.tupleof)
			result.tupleof[i] = cast(DeepUnqual!(typeof(func(f))))func(f);
		return cast(inout)result;
	}
	else
	static if (is(T U : U*))
		return v ? [func(*v)].ptr : null;
	else
	static if (is(T : A[n], A, size_t n))
	{
		R result;
		foreach (i, ref inout(A) a; v)
			result[i] = cast()func(a);
		return result;
	}
	else
	static if (is(T A : A[]))
	{
		alias E = typeof(R.init[0]);
		R result = new E[v.length];
		foreach (i, ref inout(A) a; v)
			result[i] = cast(DeepUnqual!(typeof(func(a))))func(a);
		return cast(inout)result;
	}
	else
		static assert(false, "Don't know how to fmap " ~ T.stringof
			~ " (to " ~ R.stringof ~ ")");
}
