/*SKIP*/ import std.range, std.algorithm;
/*SKIP*/ void main() {
/*SKIP*/ auto range = [1,2,4];
alias pred = a => a+1;
auto range2 = range.map!pred;
/*SKIP*/ }
