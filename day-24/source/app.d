import std.string;
import std.stdio;
import std.range;
import std.algorithm;
import std.algorithm.sorting;
import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.setops;
import std.conv;
import std.typecons;
import std.file;
import std.math.algebraic;
import std.int128;
import std.range.interfaces;
import std.path;
import gmp.q;
import gmp.z;

alias Q = MpQ;

Q Z(long x) { return Q(x, 1); }

struct Vec2 {
    long x, y;
    Vec2 opBinary(string op : "+")(Vec2 rhs) { return Vec2(x + rhs.x, y + rhs.y); }
    Vec2 opBinary(string op : "-")(Vec2 rhs) { return Vec2(x - rhs.x, y - rhs.y); }
}

struct Vec3 {
    long x, y, z;
    Vec3 opBinary(string op : "+")(Vec3 rhs) { return Vec3(x + rhs.x, y + rhs.y, z + rhs.z); }
    Vec3 opBinary(string op : "-")(Vec3 rhs) { return Vec3(x - rhs.x, y - rhs.y, z - rhs.z); }
    Vec2 xy() { return Vec2(x, y); }
}

struct Particle {
    Vec3 pos, vel;
}

Particle[] parseParticles(string str) {
    return str.splitLines.map!((string l) {
        long[] p = l.split!(c => c == ',' || c == '@').map!(v => v.strip.to!long).array;
        return Particle(Vec3(p[0], p[1], p[2]), Vec3(p[3], p[4], p[5]));
    }).array;
}

bool doesIntersect(Particle one, Particle two, Vec2 minBound, Vec2 maxBound) {
	Q oneN = Z(two.vel.x) * (Z(one.pos.y) - Z(two.pos.y)) - Z(two.vel.y) * (Z(one.pos.x) - Z(two.pos.x));
	Q twoN = Z(one.vel.x) * (Z(one.pos.y) - Z(two.pos.y)) - Z(one.vel.y) * (Z(one.pos.x) - Z(two.pos.x));
	Q D = Z(one.vel.x) * Z(two.vel.y) - Z(two.vel.x) * Z(one.vel.y);
	if (D == 0)
		return false;
	Q oneT = oneN / D;
	Q twoT = twoN / D;
	if (oneT < 0 || twoT < 0)
		return false;
	Q x = Z(one.pos.x) + Z(one.vel.x) * oneT;
	Q y = Z(one.pos.y) + Z(one.vel.y) * oneT;
	if (minBound.x <= x && x <= maxBound.x && minBound.y <= y && y <= maxBound.y) {
		// writeln(one, " - ", two, " - ", x.toString, " - ", y.toString);
		return true;
	}
	return false;
}

long part1(Particle[] p, long min, long max) {
	return cartesianProduct(p, p).map!(ps => doesIntersect(ps[0], ps[1], Vec2(min,min), Vec2(max,max))).sum / 2;
}

void main()
{
	string example1 = `19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3`;
	string input = readText(buildNormalizedPath(__FILE__.dirName, "input"));

	writeln(part1(parseParticles(example1), 7, 27));
	writeln(part1(parseParticles(input), 200000000000000, 400000000000000));
}