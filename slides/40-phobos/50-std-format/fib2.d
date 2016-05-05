import std.range, std.stdio; // SKIP

void main() { // SKIP
	auto fib = recurrence!(`a[n-1]+a[n-2]`)(1, 1); // SKIP
	writefln("First 10 Fibonacci numbers:\n" ~
		"%(%d, %)",
		fib.take(10));
} // SKIP
