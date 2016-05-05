import std.stdio; // SKIP

void main() {
	try {
		throw new Exception("a");
	} catch (Exception e) {
		e.msg = "B error: " ~ e.msg;
		throw e;
	}
}
