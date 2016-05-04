template Tpl(int n) {
	enum x  = n;
	enum x2 = n*n;
}

pragma(msg, Tpl!3.x);  // 3
pragma(msg, Tpl!6.x2); // 36
