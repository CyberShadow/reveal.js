void foo() {}

void main() {
	auto a = delegate int() { return 1; };
	auto b = delegate int { return 2; };
	auto c = delegate() { return 3; };
	auto d = delegate { return 4; };
	auto e = () { return 5; };
	auto f = { return 6; };
	auto g = delegate int() => 7;
	auto h = delegate int => 8;
	auto i = delegate() => 9;
	auto k = () => 10;
	auto n = () => { return "wrong"; };
}
