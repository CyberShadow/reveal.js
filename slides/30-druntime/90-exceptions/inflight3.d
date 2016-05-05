void main() {
	auto lines = ["one", "two", "three"];
	foreach (line; lines)
		exceptionContext("Line " ~ line, {
			enforce(line.length == 3);
		});
}

import std.exception; // SKIP
import inflight2; // SKIP
