alias B=int;
int a;

To convert(To, From)(From value) {
	/*...*/
}

//auto b = convert!B(a);        // OK

alias convertToB = convert!B; // Error
