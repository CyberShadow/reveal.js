import std.algorithm;
import std.parallelism;
import std.range;
import std.stdio;
import std.string;
 
import ae.utils.geometry;
import ae.utils.graphics.color;
import ae.utils.graphics.draw;
import ae.utils.graphics.gamma;
import ae.utils.graphics.image;
 
void main()
{
    enum W = 4096;
 
    const FG = L16(0);
    const BG = L16(ushort.max);
 
    auto image = Image!L16(W, W);
    image.fill(BG);
 
    enum OUTER = W/2 * 16/16;
    enum INNER = W/2 * 13/16;
    enum THICK = W/2 *  3/16;
 
    image.fillCircle(W/2, W/2, OUTER, FG);
    image.fillCircle(W/2, W/2, INNER, BG);
    image.fillRect(0, W/2-INNER, W/2, W/2+INNER, BG);
    image.fillRect(W/2-THICK/2, W/2-INNER, W/2+THICK/2, W/2+INNER, FG);
 
    enum frames = 32;
    foreach (n; frames.iota.parallel)
        image
        .rotate(TAU * n / frames, BG)
        .copy
        .downscale!(W/256)
        .lum2pix(gammaRamp!(ushort, ubyte, ColorSpace.sRGB))
        .toPNG
        .toFile("loading-%02d.png".format(n++));
}
