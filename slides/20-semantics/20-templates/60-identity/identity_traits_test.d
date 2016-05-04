alias parentOf(alias sym) = 
	__traits(parent, sym);
// basic type expected, not __traits
