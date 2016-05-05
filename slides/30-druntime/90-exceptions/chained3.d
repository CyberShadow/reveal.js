import std.stdio; // SKIP

void main() {
	try {
		throw new Exception("a");
	} finally {
		throw new Exception("b");
	}
}
