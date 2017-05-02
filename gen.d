import std.algorithm;
import std.array;
import std.conv;
import std.file;
import std.path;
import std.range;
import std.stdio;
import std.string;
import std.regex;

void main()
{
	string html, css;
	foreach (fn; "slides".dirEntries(SpanMode.depth).filter!(de => de.isFile).map!(de => de.name).array.sort())
	{
		if (fn.canFind("TODO"))
			continue;

		string processMarkdown(string markdown)
		{
			return markdown
				.replaceAll(regex(`<!--.*-->`, "s"), "")
				.splitter("\n----\n")
				.enumerate
				.map!((pair)
					{
						auto id = "slide-%s-%d".format(fn.replaceAll(regex(`[^a-z0-9]+`), "-"), pair.index);
						return pair.value
							.strip
							.replaceAll!(m =>
								"```d\n" ~
								buildPath(fn.dirName, m[1])
								.readText()
								.processD(m[3].length ? m[3].to!int : 4)
								.strip('\n') ~
								"\n```"
							)(regex(`^<(.*?\.d)( tabsize=(\d+))?>$`, "m"))
							.replaceAll!(m =>
								"![](" ~ buildPath(fn.dirName, m[1]) ~ ")"
							)(regex(`<(.*?\.(png|svg))>`, "m"))
							.replaceAll!((m) {
								css ~= m[1].replace(`<ID>`, "." ~ id);
								writeln(m[1]);
								return string.init;
							})(regex(`<style>(.*?)</style>`, "s"))
							.I!(html =>
								`<section class="` ~ id ~ `" data-markdown data-separator="^\n---\n$" data-separator-vertical="^\n--\n$" data-separator-notes="^Notes:">` ~
								`<script type="text/template">` ~
								html ~
								`</script></section>`
							)
						;
					})
				.join("\n<!-- ------------------------------ -->\n")
			;
		}

		switch (fn.extension)
		{
			case ".md":
				html ~= processMarkdown(fn.readText());
				break;
			case ".html":
				html ~= fn.readText();
				break;
			case ".d":
				break;
			default:
				stderr.writeln("Unknown file extension ", fn);
				break;
		}
	}
	html = "index-template.html"
		.readText
		.replace("<!-- SLIDES -->", html)
		.replace("/* STYLES */", css)
	;
	std.file.write("index.html", html);
}

alias I(alias X) = X;

string processD(string d, int tabSize)
{
	auto lines = d
		.replace("/*...*/", "...")
		.replace("\t", " ".replicate(tabSize))
		.splitLines
		.filter!(line => !line.canFind("SKIP"))
	;
	auto indent = lines
		.filter!(line => line.strip.length)
		.map!(line => line.countUntil!(c => c != ' ').I!(x => x<0 ? 100 : x))
		.fold!min(long(100));
	return lines
		.map!(line => line[min(indent, $)..$])
		.join("\n");
}
