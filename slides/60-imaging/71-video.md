```d
auto pipes = pipe();
output = pipes.readEnd();
pid = spawnProcess([
	"ffmpeg",
	"-loglevel", "panic",
	"-i", "-",
	"-an",
	"-vcodec", "bmp",
	"-f", "image2pipe",
	] ~ ffmpegArgs ~ [
	fn
], f, pipes.writeEnd);
```

Notes:
- This is reading

----

```d
auto pipes = pipe();
output = pipes.writeEnd;
pid = spawnProcess([
	"ffmpeg",
	] ~ inputArgs ~ [
	"-f", "image2pipe",
	"-i", "-",
	] ~ ffmpegArgs ~ [
	fn
], pipes.readEnd, f);
```

Notes:
- This is writing
- There are actually advantages to using piping, in that this distributes the work among different processes
- You could do std.concurrency message passing, but this is much easier

----

```d
auto decoder = VideoInputStream("input.mp4");
auto encoder = VideoOutputStream("output.mp4");

while (!encoder.empty)
{
	encoder.put(decoder.front);
	decoder.popFront();
}
```

<style> <ID> pre { font-size: 50%; } </style>

----

```d
auto p = pipe();
auto youtubeDl = spawnProcess([
		"youtube-dl", "-o", "-",
		"https://www.youtube.com/" ~ 
			"user/sociomantic/live",
	], stdin, p.writeEnd);
auto decoder = streamVideo(p.readEnd);
auto encoder = VideoOutputStream(
	"output.mp4", ["-y", 
		"-framerate", "29.97"]);
```

----

```d
auto dman = dmen[frameNumber / 10 % $];
auto bx = frame.w-dman.w;
auto by = frame.h-dman.h;
frame
	.blend(
		dman      .border(0, by, bx, 0, BGRA.init),
		dman.hflip.border(bx, by, 0, 0, BGRA.init),
	)
	.copy(frame);
```

<style> <ID> pre { font-size: 45%; } </style>

Notes:

- We fit the d-man to the frame size
- Since blend is lazy, we have to copy the result somewhere, so we copy it back over the frame itself

----

```d
"/home/vladimir/irclogs/freenode/#d/%s.log"
	.format(Clock.currTime().formatTime!"Y-m-d")
	.readText()
	.splitLines()
	.retro
	.take(10)
	.enumerate
	.each!((index, line) => frame.drawBWText(
			0, frame.h - (1 + index) * font8x8.height,
			line, font8x8, BGR.white));
```

<style> <ID> pre { font-size: 45%; } </style>

----

<video controls src="slides/70-imaging/live-/video.mp4">
