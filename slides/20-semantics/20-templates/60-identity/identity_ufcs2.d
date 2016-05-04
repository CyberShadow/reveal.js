import std.algorithm; // SKIP
alias I(alias X) = X; // SKIP
void main() { // SKIP
    auto arr = [1, 2, 3];
    alias incrementAll = map!(n => n+1);
    auto incremented =
	    arr.I!incrementAll; // OK
    /* SKIP
    ⁣
*/ } // SKIP
