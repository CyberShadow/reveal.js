import std.algorithm;
import std.array;
import std.file;
import std.path;
import std.stdio;

void main()
{
	string html;
	foreach (fn; "slides".dirEntries(SpanMode.depth).filter!(de => de.isFile).map!(de => de.name).array.sort())
		switch (fn.extension)
		{
			case ".md":
				html ~= `<section data-markdown data-separator="^\n---\n$" data-separator-vertical="^\n--\n$`;
				html ~= `<script type="text/template">`;
				html ~= fn.readText();
				html ~= `</script></section>`;
				break;
			case ".html":
				html ~= fn.readText();
				break;
			default:
				stderr.writeln("Unknown file extension ", fn);
				break;
		}
	std.file.write("index.html", "index-template.html".readText.replace("<!-- SLIDES -->", html));
}
