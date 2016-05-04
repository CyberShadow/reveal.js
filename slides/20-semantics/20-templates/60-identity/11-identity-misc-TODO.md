##### `Identity` template

```d
import std.algorithm;
import std.range;
 
template mapN(Functions...)
{
    auto mapN(Range)(Range range)
    {
        static if (Functions.length == 0)
            return range;
        else
            return range
                .map!(Functions[0])
                .map!(.mapN!(Functions[1..$]));
    }
}
```

<!--
As this is an eponymous template, the instantiation is replaced with X (the only template parameter). Thus, Identity!(anything) is aliased away to anything.

So, what use is a template which does nothing?

I’ve found a number of interesting uses for it:

One obvious use case, as with a function which returns its only argument, is as an identity transform. For example, ->

Notes:

- the `map` function transforms a range by applying a function to each element of the range. 
- Sometimes, you may need a null transform
- Let’s write an N-dimensional map, which applies a transformation per dimension of its input:

 - - -

##### `Identity` template

```d
void main()
{
    auto matrix = [[1, 2, 3],
                   [4, 5, 6],
                   [7, 8, 9]];
    auto transformed = matrix.mapN!(row => row.retro, n => n-1);
    assert(transformed.equal!equal([[2, 1, 0],
                                    [5, 4, 3],
                                    [8, 7, 6]]));
}
```

<!--
What if we don’t want a transformation for a certain dimension? In this case, we could simply pass the n => n predicate (which is a shorthand for auto delegate(T)(T n) { return n; }, i.e. a nested anonymous function template which returns the value of its only parameter).

The Identity template can satisfy the same role – however, as we’re dealing with templates (which, unlike functions, can operate not just on values, but also on types, or any other D declarations through aliases), staticMap would be used instead of map. Since templates can accept other templates via alias parameters and instantiate them as needed, staticMap can apply a transformation upon a tuple of symbols, e.g. Unqual or, in our case, Identity when no transformation is needed.

That’s the obvious way to use Identity. Some less obvious uses for it stem from how templates allows us to circumvent certain aspects of D’s grammar. In fact, I found this trait so useful, that I’ve redefined the template with the short name I, which I will use hereafter.

For instance, the following declaration is invalid according to D’s grammar:
alias parentOf(alias sym) = __traits(parent, sym);

The compiler complains: Error: basic type expected, not __traits. This is because TraitsExpression is an expression, but in this context, the grammar expects a type.

However, the following code works, because as far as the grammar is concerned, a TemplateInstance is a Type:
alias parentOf(alias sym) = I!(__traits(parent, sym));

This is how the Identity template is mainly used within Phobos.

Another use is declaring lambdas to later use them as predicates. Have you ever tried writing the following code:
alias pred = a => a+1;
auto range2 = range.map!pred;

This will not work due to limitations similar to the above example. The workaround? Wrap it in an Identity instantiation:
alias pred = I!(a => a+1);

Another place where the Identity template becomes useful is UFCS. Specifically, UFCS symbol lookup rules differ from normal lookup rules, so the following code won’t compile:

void fun()
{
    auto arr = [1, 2, 3];
    alias incrementAll = map!(n => n+1);
    auto incremented = arr.incrementAll;
}

This is because incrementAll is a local declaration, and local declarations are not considered for UFCS to avoid unexpected name conflicts. The limitation applies not only to function-local declarations, but also class and struct methods, even if they’re static.

The workaround? Prepend the magic I!
auto incremented = arr.I!incrementAll;

Because I is declared at global scope, and template parameters do not have the same limitations for symbol lookup as UFCS, the above expression is rewritten as I!(incrementAll)(arr), and becomes incrementAll(arr) after instantiation and substitution.

Here’s an example in practice: saveAs and unpackTo are helper methods declared in the Installer super-class, and buildZipUrl is a method declared just below.

Finally, my most recent discovery for another way to use Identity is perhaps the most useful one. Consider the following task:
/// Search a website for something, and parse the
/// first search result's webpage.
auto getItemInfo(string itemName)
{
    // Let's go! First, construct the URL.
    return ("http://www.example.com/search?q=" ~ encodeComponent(itemName))
        // Download the URL...
        .download // returns the local filename
        // Read it back in
        .readText
        // Find the sought item's relative URL
        .match(regex(`<a class="result" href="(.*?)">`)).front[1]
        // Prepend site root to convert the relative URL to a full one...
        // Wait, crap. How do I prepend a string with UFCS?

When building a UFCS chain (in the style of component programming), you will often run into situations where a certain operation is not UFCS-able. There are multiple obvious ways to prepend the string, but neither are very satisfactory:

1. Break the UFCS chain and use a local temporary variable, i.e. auto temp = ufcs.chain.part1; return (prefix ~ temp).ufcs.chain.part2;. This becomes even more inconvenient when the entire chain is expected to be an expression, as you’ll need to move the variable declaration and first half of the chain entirely outside the expression.

2. Simply write (prefix ~ ufcs.chain.goes.here).ufcs.chain.continues. Not only is this ugly, it confuses the order of operations: the concatenation is declared at the beginning of the expression, but will occur halfway through. Needless to say, this doesn’t stack up.

3. Declare a function whose only role is to prepend the prefix, and use that in the UFCS chain.

The Identity template offers us a new way:
// (continued)
// Prepend site root to convert the relative URL to a full one...
.I!(s => "http://www.example.com/" ~ s)
// Download the new URL...
.download // returns the local filename
// ...

Are you amazed?

The code looks just like the lambda example above. That’s because we are declaring a lambda (s => "http://www.example.com/" ~ s). However, we’re also immediately calling it via UFCS!

Because parens are optional for function calls when there are no explicit arguments, the call becomes implicit, and the lambda’s return value (the result of the concatenation) is passed further on to the download function.

That’s all the uses for the amazing Identity template I found so far. Perhaps some of these will become irrelevant should the language grammar be relaxed to allow some of the above cases without template wrappers.


-->
