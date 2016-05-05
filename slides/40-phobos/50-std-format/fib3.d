import std.range, std.stdio; // SKIP

void main() { // SKIP
	auto fib = recurrence!(`a[n-1]+a[n-2]`)(1, 1); // SKIP
	writef("First 10 Fibonacci numbers:\n" ~
		"%(* %d\n%|%)",
		fib.take(10));
} // SKIP
