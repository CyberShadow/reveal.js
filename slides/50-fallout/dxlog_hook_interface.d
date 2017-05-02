void hookInterface(I)(I intf)
{
	void** vtable = *cast(void***)intf;
	void hookMethods(J)()
	{
		static if (is(J S == super) && S.length)
		{
			static assert(S.length == 1, 
				"Multiple interface inheritance");
			hookMethods!S();
		}

		foreach (member; __traits(derivedMembers, J))
			hookMethod!(I, member)(vtable[index++]);
	}

	hookMethods!I();
}
