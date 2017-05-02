static string genCode(string moduleName)()
{
	string code;
	mixin(`static import ` ~ moduleName ~ `;`);
	mixin(`alias mod = ` ~ moduleName ~ `;`);
	foreach (memberName; __traits(allMembers, mod))
	{
		enum memberFQName = moduleName ~ `.` ~ memberName;
		mixin(`alias member = ` ~ memberFQName ~ `;`);
		static if (is(typeof(member) : const(IID)) 
			&& memberName.startsWith("IID_"))
		{
			enum typeName = memberName[4..$];
			enum typeFQName = moduleName ~ `.` ~ typeName;
			static if (mixin(`is(` ~ typeFQName ~ `)`))
				code ~= `IIDLookupEntry(` ~ 
					memberFQName ~ `, ` ~ 
					`(void* ptr) { ` ~ 
						`return hookInterface(cast(` ~ typeFQName ~ `)ptr); ` ~ 
					`}),` ~ '\n';
		}
	}
	return code;
}
