import std.algorithm, std.range, std.stdio;

void main() {
  enum size = 500;
  writef("P5\n%d %d %d\n", size, size, ubyte.max);

  iota(-1, 3, 2.0/size).map!(y =>
    iota(-1.5, 0.5, 2.0/size).map!(x =>
      cast(ubyte)(1+
        recurrence!((a, n) => x + y*1i + a[n-1]^^2)(0+0i)
        .take(ubyte.max)
        .countUntil!(z => z.re^^2 + z.im^^2 > 4))
    )
  )
  .copy(stdout.lockingBinaryWriter);
}
