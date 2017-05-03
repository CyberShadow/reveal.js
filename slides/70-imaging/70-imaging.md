# Part 7

### Image Processing

Notes:
- Needed a way to programmatically create and manipulate images
- For a while used POV-Ray

----

<wa.pov>

<style>
<ID> pre { 
	font-size: 15%;
	height: 350px;
}
<ID> pre code { 
     -webkit-column-count: 2; /* Chrome, Safari, Opera */
    -moz-column-count: 2; /* Firefox */
    column-count: 2;
	height: 350px;
}
</style>

Notes:
- POV-Ray is a raytracer, you write the geometry of the 3D object you want to render declaratively
- If you set up the camera right, you can also use it for 2D things

----

<wa.png>

<style> <ID> img { height: 350px; } </style>

Notes:
- The result looks something like this
- (This is the Worms Armageddon logo)
- Started working on my own image library
- Redesigned it a few years ago
- Inspired by std.algorithm and std.ragne

----

```d

/// A view is any type which provides a width,
/// height, and can be indexed to get the
/// color at a specific coordinate.
enum isView(T) =
    is(typeof(T.init.w) : size_t) && // width
    is(typeof(T.init.h) : size_t) && // height
    is(typeof(T.init[0, 0])     );   // pixels
```

<style> <ID> pre { font-size: 50%; } </style>

Notes:
- Like isInputRange

----

```d
/// Returns the color type of the specified view.
alias ViewColor(T) = typeof(T.init[0, 0]);
```

<style> <ID> pre { font-size: 50%; } </style>

Notes:
- Like std.range.ElementType

----

```d
/// Views can be read-only or writable.
enum isWritableView(T) =
    isView!T &&
    is(typeof(T.init[0, 0] = ViewColor!T.init));
 
/// Optionally, a view can also provide direct pixel
/// access. We call these "direct views".
enum isDirectView(T) =
    isView!T &&
    is(typeof(T.init.scanline(0)) : ViewColor!T[]);
```

<style> <ID> pre { font-size: 45%; } </style>

Notes:
- These are specializations
- Same as `isForwardRange`

----

```d
/// Mixin which implements view primitives on top of
/// existing direct view primitives.
mixin template DirectView()
{
    alias COLOR = typeof(scanline(0)[0]);
 
    /// Implements the view[x, y] operator.
    ref COLOR opIndex(int x, int y)
    {
        return scanline(y)[x];
    }
 
    /// Implements the view[x, y] = c operator.
    COLOR opIndexAssign(COLOR value, int x, int y)
    {
        return scanline(y)[x] = value;
    }
}
```

<style> <ID> pre { font-size: 45%; } </style>

Notes:

----

```d
/// An in-memory image.
/// Pixels are stored in a flat array.
struct Image(COLOR)
{
    int w, h;
    COLOR[] pixels;
 
    /// Returns an array for the pixels at row y.
    COLOR[] scanline(int y)
    {
        assert(y>=0 && y<h);
        return pixels[w*y..w*(y+1)];
    }
 
    mixin DirectView;
 
	...
}
```

<style> <ID> pre { font-size: 45%; } </style>

----

```d
/// Returns a view which calculates pixels
/// on-demand using the specified formula.
template procedural(alias formula)
{
    alias fun = binaryFun!(formula, "x", "y");
    alias COLOR = typeof(fun(0, 0));
 
    auto procedural(int w, int h)
    {
        struct Procedural
        {
            int w, h;
 
            auto ref COLOR opIndex(int x, int y)
            {
                return fun(x, y);
            }
        }
        return Procedural(w, h);
    }
}
```

<style> <ID> pre { font-size: 40%; } </style>

----

```d
/// Returns a view of the specified dimensions
/// and same solid color.
auto solid(COLOR)(COLOR c, int w, int h)
{
    return procedural!((x, y) => c)(w, h);
}
```

<style> <ID> pre { font-size: 45%; } </style>

----

```d
/// Mixin which implements view primitives on
/// top of another view, using a coordinate 
/// transform function.
mixin template Warp(V)
{
    V src;
 
    auto ref ViewColor!V opIndex(int x, int y)
    {
        warp(x, y);
        return src[x, y];
    }
 
    static if (isWritableView!V)
    ViewColor!V opIndexAssign(ViewColor!V 
		value, int x, int y)
    {
        warp(x, y);
        return src[x, y] = value;
    }
}
```

<style> <ID> pre { font-size: 40%; } </style>

----

```d
/// Crop a view to the specified rectangle.
auto crop(V)(auto ref V src, int x0, int y0, int x1, int y1)
    if (isView!V)
{
    static struct Crop
    {
        mixin Warp!V;

        int x0, y0, x1, y1;
        @property int w() { return x1-x0; }
        @property int h() { return y1-y0; }
 
        void warp(ref int x, ref int y)
        {
            x += x0;
            y += y0;
        }

        static if (isDirectView!V)
        ViewColor!V[] scanline(int y)
        {
            return src.scanline(y0+y)[x0..x1];
        }
    }

    static assert(isDirectView!V == isDirectView!Crop);

    return Crop(src, x0, y0, x1, y1);
}
```

<style> <ID> pre { font-size: 30%; } </style>

----

```d
/// Blits a view onto another.
/// The views must have the same size.
void blitTo(SRC, DST)(auto ref SRC src, auto ref DST dst)
    if (isView!SRC && isWritableView!DST)
{
    assert(src.w == dst.w && src.h == dst.h, 
		"View size mismatch");
    foreach (y; 0..src.h)
    {
        static if (isDirectView!SRC && isDirectView!DST)
            dst.scanline(y)[] = src.scanline(y)[];
        else
        {
            foreach (x; 0..src.w)
                dst[x, y] = src[x, y];
        }
    }
}
```

<style> <ID> pre { font-size: 40%; } </style>

----

```d
/// Return a view of src with the coordinates
/// transformed according to the given formulas
template warp(string xExpr, string yExpr)
{
    auto warp(V)(auto ref V src)
        if (isView!V)
    {
        static struct Warped
        {
			...
        }
 
        return Warped(src);
    }
}
```

<style> <ID> pre { font-size: 50%; } </style>

----

```d
static struct Warped
{
	mixin Warp!V;

	@property int w() { return src.w; }
	@property int h() { return src.h; }

	void warp(ref int x, ref int y)
	{
		auto nx = mixin(xExpr);
		auto ny = mixin(yExpr);
		x = nx; y = ny;
	}

	...
}
```

<style> <ID> pre { font-size: 50%; } </style>

----

```d
static struct Warped
{
	...

	private void testWarpY()()
	{
		int y;
		y = mixin(yExpr);
	}

	/// If the x coordinate is not affected and y does not
	/// depend on x, we can transform entire scanlines.
	static if (xExpr == "x" &&
		__traits(compiles, testWarpY()) &&
		isDirectView!V)
	ViewColor!V[] scanline(int y)
	{
		return src.scanline(mixin(yExpr));
	}
}
```

<style> <ID> pre { font-size: 40%; } </style>

----

```d
/// Return a view of src
/// with the x coordinate inverted.
alias hflip = warp!(q{w-x-1}, q{y});
 
/// Return a view of src
/// with the y coordinate inverted.
alias vflip = warp!(q{x}, q{h-y-1});
 
/// Return a view of src
/// with both coordinates inverted.
alias flip = warp!(q{w-x-1}, q{h-y-1});

/// Rotate a view 90 degrees clockwise.
auto rotateCW(V)(auto ref V src)
{
	return src.flipXY().hflip();
}
```

<style> <ID> pre { font-size: 50%; } </style>

Notes:
- because of the optimization, vflip of an image in memory will still allow scanline access

----

```d
enum W = 4096;

const FG = L16(0);
const BG = L16(ushort.max);

auto image = Image!L16(W, W);
image.fill(BG);

enum OUTER = W/2 * 16/16;
enum INNER = W/2 * 13/16;
enum THICK = W/2 *  3/16;
```

----

```d
image.fillCircle(W/2, W/2, OUTER, FG);
image.fillCircle(W/2, W/2, INNER, BG);
image.fillRect(0, W/2-INNER, W/2, W/2+INNER, BG);
image.fillRect(W/2-THICK/2, W/2-INNER, 
	W/2+THICK/2, W/2+INNER, FG);

enum frames = 32;
foreach (n; frames.iota.parallel)
	image
	.rotate(TAU * n / frames, BG)
	.copy
	.downscale!(W/256)
	.lum2pix(gammaRamp!(ushort, ubyte, ColorSpace.sRGB))
	.toPNG
	.toFile("loading-%02d.png".format(n++));
```

----

<loading.gif>
