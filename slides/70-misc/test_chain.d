import ae.utils.meta.chain; // SKIP

void main() { // SKIP
	struct A { int x = 1; }
	struct B { enum x = 2; }
	struct C { @property int x() { return 3; } }
	struct D { static int x = -7; }

	int sum = 0;

	auto c1 = chainFunctor!((s)
		{ sum += s.x; return false; });
	auto c2 = chainFilter!(s => s.x >= 0)(c1);
	auto c3 = chainIterator(c2);

	c3(A(), B(), C(), D());

	assert(sum == 6);
} // SKIP
