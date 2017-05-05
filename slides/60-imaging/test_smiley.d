/*SKIP*/ import std.algorithm.iteration;
/*SKIP*/ import std.range;
/*SKIP*/ import std.math;
/*SKIP*/ import std.stdio;

/*SKIP*/ import ae.utils.graphics.draw;
/*SKIP*/ import ae.utils.graphics.image;

/*SKIP*/ void main()
/*SKIP*/ {
	auto img = Image!char(20, 20);
	img.fill(' ');
	img.fillCircle(10, 10, 10, '#');
	img.fillCircle( 6, 6, 2, ' ');
	img.fillCircle(14, 6, 2, ' ');
	img.fillSector(10, 10, 6, 8, 0, PI, ' ');

	img.h
		.iota
		.map!(y => img.scanline(y))
		.each!writeln;
/*SKIP*/ }
