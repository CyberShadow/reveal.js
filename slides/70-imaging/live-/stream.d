import std.algorithm.iteration;
import std.datetime;
import std.file;
import std.format;
import std.process;
import std.range;
import std.stdio : stdin;
import std.string;

import ae.utils.graphics.color;
import ae.utils.graphics.ffmpeg;
import ae.utils.graphics.fonts.draw;
import ae.utils.graphics.fonts.font8x8;
import ae.utils.graphics.im_convert;
import ae.utils.graphics.image;
import ae.utils.graphics.view;
import ae.utils.text;
import ae.utils.time.format;

void main()
{
	auto dmen = 24.iota.map!(n =>
		"dman/alpha-%02d.png"
		.format(n)
		.read()
		.parseViaIMConvert!BGRA
	).array;

	auto p = pipe();
	auto youtubeDl = spawnProcess([
			"youtube-dl", "-o", "-",
			"https://www.youtube.com/user/sociomantic/live",
		], stdin, p.writeEnd);
	auto decoder = streamVideo(p.readEnd, ["-vf", "scale=640:360"]);
	//auto ffmpeg = | ffmpeg -i - -vf vflip -c:a copy -f nut - | mpv -
	//decoder.front.toBMP.toFile("test.bmp");
	while (true)
	{
		{
			auto encoder = VideoOutputStream("output.mp4", [
					"-y",
					"-framerate", "29.97",
				]);

			foreach (n; 0..5*30)
			{
				auto frame = decoder.front;

				"/home/vladimir/irclogs/freenode/#d/%s.log"
					.format(Clock.currTime().formatTime!"Y-m-d")
					.readText()
					.splitLines()
					.retro
					.take(10)
					.enumerate
					.each!((index, line) => frame.drawBWText(
							0, frame.h - (1 + cast(int)index) * font8x8.height,
							line, font8x8, BGR.white));

				auto dman = dmen[n / 10 % $];
				frame
					.blend(
						dman      .border(0, frame.h-dman.h, frame.w-dman.w, 0, BGRA.init),
						dman.hflip.border(frame.w-dman.w, frame.h-dman.h, 0, 0, BGRA.init),
					)
					.copy(frame);

				encoder.put(frame);
				decoder.popFront();
			}
		}

		rename("output.mp4", "video.mp4");
	}
}

void drawBWText(V, Font, Color)(auto ref V v, int x, int y, string s, Font font, Color color)
{
	foreach (dx; -1..2)
		foreach (dy; -1..2)
			v.drawText(x + dx, y + dy, s, font8x8, ~color);
	v.drawText(x, y, s, font8x8, color);
}

// Hack - avoid UTF errors
string readText(string fn) { return cast(string)read(fn); }
string[] splitLines(string s) { return splitAsciiLines(s); }
