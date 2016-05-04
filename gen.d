import std.algorithm;
import std.array;
import std.file;
import std.path;
import std.stdio;
import std.string;
import std.regex;

void main()
{
	string html;
	foreach (fn; "slides".dirEntries(SpanMode.depth).filter!(de => de.isFile).map!(de => de.name).array.sort())
	{
		if (fn.canFind("TODO"))
			continue;
		auto id = fn.replaceAll(regex(`[^a-z]+`), "-");
		switch (fn.extension)
		{
			case ".md":
			{
				auto markdown = fn.readText().processMarkdown(fn);
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
	std.file.write("index.html", "index-template.html".readText.replace("<!-- SLIDES -->", html));
}

string processMarkdown(string markdown, string fn = null)
{
	return markdown
		.replaceAll!(m =>
			"```d\n" ~
			buildPath(fn.dirName, m[1])
			.readText()
			.processD()
			.strip('\n') ~
			"\n```"
		)(regex(`^<(.*\.d)>$`, "m"))
		.replaceAll!(m =>
			"![](" ~ buildPath(fn.dirName, m[1]) ~ ")"
		)(regex(`<(.*\.png)>`, "m"))
	;
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
