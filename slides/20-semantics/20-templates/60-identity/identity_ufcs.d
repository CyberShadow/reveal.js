import std.algorithm; // SKIP
alias I(X) = X; // SKIP
void main() { // SKIP
    auto arr = [1, 2, 3];
    alias incrementAll = map!(n => n+1);
    auto incremented =
	    arr.incrementAll;
    // Error: no property 'incrementAll'
    //        for type 'int[]'
} // SKIP
