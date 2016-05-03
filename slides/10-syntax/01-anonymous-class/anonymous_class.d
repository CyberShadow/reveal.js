class Widget {
	/*...*/
	abstract void onClick();
}

Widget makeWidget() {
	return new class Widget {
		override void onClick() { /*...*/ }
	};
}
