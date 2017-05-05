/// Convert a type such that all of its subtypes are replaced with Maybe!T
private template Maybify(T)
{
	static assert(is(Unqual!T == T), "Qualified Maybify: " ~ T.stringof);
	static if (is(T == Maybe!U, U))
		static assert(false, "Can't Maybify a " ~ T.stringof);
	else
	static if (is(T == struct) || is(T == union))
	{
		struct Maybify
		{
			mixin(mixTypeMapStruct!(T, q{Maybe}));

			this(ref T value)
			{
				this = value;
			}

			void opAssign(ref T value)
			{
				foreach (i, ref f; this.tupleof)
				{
					f._maybeValue = maybify(value.tupleof[i]);
					f._maybeIsSet = true;
				}
			}
		}
	}
	else
	static if (__traits(isArithmetic, T))
		alias Maybify = T;
	else
	static if (is(T AA == AA[]) && __traits(isArithmetic, AA))
		alias Maybify = AA[];
	else
		alias Maybify = TypeMap!(T, Maybe);
}
