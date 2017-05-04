import std.algorithm.iteration;
import std.file;
import std.format;
import std.process;
import std.range;
import std.stdio : stdin;

import ae.utils.graphics.color;
import ae.utils.graphics.ffmpeg;
import ae.utils.graphics.im_convert;
import ae.utils.graphics.image;
import ae.utils.graphics.view;

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
			"https://www.youtube.com/watch?v=IqiXMN03968",
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
