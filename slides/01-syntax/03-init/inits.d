unittest
{
	static assert(  int.init == 0        );
	static assert( char.init == '\xFF'   );
	static assert(float.init is float.nan);

	struct S {
		int x = 5;
	}

	S s;
	assert(s.x == 5);
}
