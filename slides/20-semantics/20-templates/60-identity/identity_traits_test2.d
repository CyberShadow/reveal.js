import std.traits : Identity; // SKIP
alias I = Identity;

alias parentOf(alias sym) = 
	I!(__traits(parent, sym));

int i; pragma(msg, parentOf!i.stringof); // SKIP
