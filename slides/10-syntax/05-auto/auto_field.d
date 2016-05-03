struct S {
	auto fact10 = {
		int result = 1;
		foreach (n; 2..10+1)
			result *= n;
		return result;
	}();
}
