import std.parallelism; // SKIP
import std.range; // SKIP

void main() // SKIP
{ // SKIP
	int[] nums = 1000.iota.array;
	int increment = 5;
	auto nums2 = std.parallelism.taskPool
		.map!(n => n + increment)(nums);
} // SKIP
