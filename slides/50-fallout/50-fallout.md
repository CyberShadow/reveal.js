<Fallout_4_logo.png>

----

<334-0-1447396630.png>

----

<value_per_weight_cropped.png>

----

# Part 5

### COM instrumentation

----

<ScreenShot7.jpg>

Notes:
- Describe Upscale problem here
- The game ran too slowly at the monitor's native resolution, and did not support lower resolutions
- Simply changing the resolution in the basic APIs was not enough
- The resolution was also communicated through some other API which I needed to find
- I could've spent a lot of time debugging, but I decided to write a logger
- Could've used IDLs, but decided to do it the D way

----

```d
struct IIDLookupEntry
{
	IID iid;
	void function(void*) hookFun;
}
```

----

```d
immutable IIDLookupEntry[] iidLookup = mixin("[" ~
	IIDLookupEntry.genCode!`csfo4.directx.d2d1` ~
	IIDLookupEntry.genCode!`csfo4.directx.d3d11` ~
	IIDLookupEntry.genCode!`csfo4.directx.d3d11shader` ~
	IIDLookupEntry.genCode!`csfo4.directx.dwrite` ~
	IIDLookupEntry.genCode!`csfo4.directx.dxgi` ~
	IIDLookupEntry.genCode!`csfo4.directx.dxinternal` ~
	IIDLookupEntry.genCode!`csfo4.directx.dxpublic` ~
	IIDLookupEntry.genCode!`csfo4.directx.xaudio2` ~
"]");
pragma(msg, iidLookup.length);
```

<style> <ID> pre { font-size: 40%; } </style>

----

<dxlog_gencode.d tabsize=2>

<style> <ID> pre { font-size: 35%; } </style>

Notes:
- This iterates over all members of a **module** and collects interface IIDs into a dispatch table
- The dispatch table contains a pointer to a function which **accepts an interface pointer** and hooks it

----

<dxlog_hook_interface.d tabsize=2>

<style> <ID> pre { font-size: 45%; } </style>

Notes:
- We dereference the interface pointer to get the vtable pointer
- Hook all parent types too
- COM is single-inheritance
- This calls `hookMethod`, which...

----

```d
void hookMethod(I, string methodName)(ref void* ptr)
{
	alias method = __traits(getMember, I, methodName);
	alias Fun = extern(Windows) ReturnType!method 
		function(I, Parameters!method);
	__gshared static Fun origFun = null;

	if (ptr !is &funHook && !origFun)
	{
		origFun = cast(Fun)ptr;

		DWORD old;
		VirtualProtect(&ptr, (void*).sizeof, 
			PAGE_EXECUTE_READWRITE, &old
		).wenforce("VirtualProtect");

		ptr = &funHook;
	}
}
```

<style> <ID> pre { font-size: 45%; } </style>

Notes:
- ...basically overwrites the interface pointer with our own
- Because this will be instantiated once per hooked interface method, we can use a static variable to save the old function (`origFun`)
- We need to set the page protection as the vtable is almost surely read-only

----

```d
extern(Windows) static ReturnType!method 
funHook(I self, Parameters!method args)
{
	auto result = notVoid(origFun(self, args));

	logMethod!(I, method)(self, args, result);

	foreach (arg; args)
		hookArg(arg);

	static if (methodName == "QueryInterface")
	{
		...
	}

	static if (!is(ReturnType!method == void))
		return result;
}
```

<style> <ID> pre { font-size: 45%; } </style>

----

```d
static if (methodName == "QueryInterface")
{
	auto riid = args[0];
	auto ppvObject = args[1];

	foreach (ref entry; iidLookup)
		if (entry.iid == *riid)
		{
			entry.hookFun(*ppvObject);
			break;
		}
}
```

----


```d
void hookArg(T)(T value)
{
	static if (is(typeof(*value)))
	{
		alias I = typeof(*value);
		static if (is(I == interface) &&
		 is(I : std.c.windows.com.IUnknown))
		{
			if (value && *value)
			{
				I i = *value;
				hookInterface(i);
			}
		}
	}
}
```

<style> <ID> pre { font-size: 52%; } </style>

Notes:
- The only arguments we're interested in is interface pointers

----

```d
mixin template proxyFunc(alias func)
{
	enum name = __traits(identifier, func);
	alias Return = ReturnType!func;
	alias Args = Parameters!func;

	alias ProxyFunc_t = typeof(&ProxyFunc);
	ProxyFunc_t ProxyFunc_p = null;

	extern(System)
	pragma(mangle, name)
	export
	Return ProxyFunc(Args args)
	{
		if (!ProxyFunc_p)
		{
			if (!hmTarget)
				loadTarget();
			ProxyFunc_p = cast(ProxyFunc_t)
				GetProcAddress(hmTarget, name);
		}

		auto result = ProxyFunc_p(args);
		logFunc!func(args, result);
		foreach (arg; args)
			hookArg(arg);
		return result;
	}
}

mixin proxyFunc!D3D11CreateDeviceAndSwapChain;
```

<style> <ID> pre { font-size: 25%; } </style>

Notes:
- DirectX DLLs often have very few entry points, which return interfaces 
- You can then query the interfaces or call their methods to get to the rest of the API
- We build a proxy DLL here which **intercepts one function**
- And so, starting from this point, we branch out and recursively intercept all Direct3D interfaces and methods
- thus completely **instrumenting the entire Direct3D API**

----

<dxlog.png>

Notes:

- `RSSetViewports` is the sought function

----

<upscale.png>

----

<upscale-props.png>

<style> <ID> img { height: 450px; margin-top: -30px !important; } </style>

Notes:
- To add to **Simon**'s list of thing using **-betterC**,
- it also doesn't use the D runtime, and the DLL's file size is
  just 5 and a half kilobytes. So don't let anyone tell you that you
  can't build tiny DLLs with D, because it's just plain false.

----

##### Code:

<a href="https://github.com/CyberShadow/csfo4">https://github.com/<br>CyberShadow/csfo4</a>
