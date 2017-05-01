// Need static either here or on Impl
/*static*/ template Variable(T)
{
	struct Data
	{
		T value;
	}

	static template Impl(alias data)
	{
		T get() { return data.value; }
	}
}

template Adder(alias a, alias b)
{
	// dummy argument to set context
	static template Impl(alias a=a)
	{
		auto get()
		{
			return a.get() + b.get();
		}
	}
}

struct Formula
{
	Variable!int.Data xData;
	Variable!int.Data yData;
	Variable!int.Data zData;

	alias Variable!int.Impl!xData x;
	alias Variable!int.Impl!yData y;
	alias Variable!int.Impl!zData z;

	alias Adder!(x, y).Impl!() a1;
	alias Adder!(y, z).Impl!() a2;
	alias Adder!(a1, a2).Impl!() a3;
}

void main()
{
	Formula formula;
	formula.xData.value = 2;
	formula.yData.value = 3;
	formula.zData.value = 4;
	assert(formula.a3.get() == 12);
}
