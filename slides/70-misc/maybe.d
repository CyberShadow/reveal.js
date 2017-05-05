/// A recursively-converting implementation of Maybe
struct Maybe(T)
{
	private Maybify!T _maybeValue;
	private bool _maybeIsSet;

	this(ref T value)
	{
		this = value;
	}

	void opAssign()(auto ref T value)
	{
		this._maybeValue = maybify(value);
		this._maybeIsSet = true;
	}

	static if (!is(T == Maybify!T))
	void opAssign(ref Maybify!T value)
	{
		this._maybeValue = value;
		this._maybeIsSet = true;
	}

	ref inout(Maybify!T) _maybeGetValue() inout @property
	{
		assert(_maybeIsSet,
			"This %s is not set".format(T.stringof));
		return _maybeValue;
	}

	alias _maybeGetValue this;
}
