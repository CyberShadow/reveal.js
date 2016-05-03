template sqr(int n)
{
	enum sqr = n * n;
}

// Equivalent to:

enum sqr(int n) = n*n;

pragma(msg, sqr!3);  // 9
