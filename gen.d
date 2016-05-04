import std.algorithm;
import std.array;
import std.file;
import std.path;
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
		auto id = "slide-" ~ fn.replaceAll(regex(`[^a-z0-9]+`), "-");

		string processMarkdown(string markdown)
		{
			return markdown
				.replaceAll!(m =>
					"```d\n" ~
					buildPath(fn.dirName, m[1])
					.readText()
					.processD()
					.strip('\n') ~
					"\n```"
				)(regex(`^<(.*?\.d)>$`, "m"))
				.replaceAll!(m =>
					"![](" ~ buildPath(fn.dirName, m[1]) ~ ")"
				)(regex(`<(.*?\.png)>`, "m"))
				.replaceAll!((m) {
					css ~= m[1].replace(`<ID>`, "." ~ id);
					writeln(m[1]);
					return string.init;
				})(regex(`<style>(.*?)</style>`, "s"))
			;
		}

		switch (fn.extension)
		{
			case ".md":
			{
				auto markdown = fn.readText();
				markdown = processMarkdown(markdown);
				html ~= `<section class="` ~ id ~ `" data-markdown data-separator="^\n---\n$" data-separator-vertical="^\n--\n$" data-separator-notes="^Notes:">`;
				html ~= `<script type="text/template">`;
				html ~= markdown;
				html ~= `</script></section>`;
				break;
			}
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

string processD(string d)
{
	return d
		.replace("/*...*/", "...")
		.splitLines
		.filter!(line => !line.canFind("SKIP"))
		.join("\n")
	;
}
