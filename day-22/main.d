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

long sign(long x) {
    if (x > 0) return +1;
    if (x < 0) return -1;
    return 0;
}

struct Vec2 {
    long x, y;
    Vec2 opBinary(string op : "+")(Vec2 rhs) { return Vec2(x + rhs.x, y + rhs.y); }
    Vec2 opBinary(string op : "-")(Vec2 rhs) { return Vec2(x - rhs.x, y - rhs.y); }
}

struct Vec3 {
    long x, y, z;
    Vec3 opBinary(string op : "+")(Vec3 rhs) { return Vec3(x + rhs.x, y + rhs.y, z + rhs.z); }
    Vec3 opBinary(string op : "-")(Vec3 rhs) { return Vec3(x - rhs.x, y - rhs.y, z - rhs.z); }
    Vec3 normalize() { return Vec3(sign(x), sign(y), sign(z)); }
    Vec2 xy() { return Vec2(x, y); }
}

struct Brick {
    Vec3 a, b;
    Vec3[] body() {
        Vec3 d = (b - a).normalize;
        Vec3 i = a;
        Vec3[] result = [a];
        while (i != b) { i = i + d; result ~= i; }
        return result;
    }
    long minz() { return min(a.z, b.z); }
}

Brick[] parseBricks(string str) {
    return str.splitLines.map!((string l) {
        long[] p = l.split!(c => c == ',' || c == '~').map!(v => v.to!long).array;
        return Brick(Vec3(p[0], p[1], p[2]), Vec3(p[3], p[4], p[5]));
    }).array;
}

void addToHeightMap(Brick b, ref long[Vec2] m) {
    foreach (i; b.body)
        if (i.xy !in m || m[i.xy] < i.z)
            m[i.xy] = i.z;
}

Brick fall(Brick b, long[Vec2] m) {
    long floorz = b.body.map!(i => i.xy !in m ? 0 : m[i.xy]).maxElement;
    Vec3 offset = Vec3(0, 0, floorz + 1 - b.minz);
    return Brick(b.a + offset, b.b + offset);
}

Brick extractLowest(ref Brick[] bricks) {
    Brick minz = bricks.minElement!(b => b.minz);
    bricks = bricks.remove(bricks.countUntil(minz));
    return minz;
}

Brick[] sortByLowest(Brick[] bricks) {
    Brick[] result;
    while (!bricks.empty) {
        result ~= extractLowest(bricks);
    }
    return result;
}

struct Env {
    Brick[] fallen;
    long[Vec2] hm;
    long[Vec3] brickId;
}

Env doFall(Brick[] bricks) {
    Env e;
    foreach (Brick b; bricks) {
        b = b.fall(e.hm);
        b.addToHeightMap(e.hm);
        foreach (i; b.body) e.brickId[i] = e.fallen.length;
        e.fallen ~= b;
    }
    return e;
}

long[] support(Env e, long id, Vec3 offset) { return e.fallen[id].body.map!(i => i + offset).map!(i => i !in e.brickId ? -1 : e.brickId[i]).filter!(n => n != -1 && n != id).array.sort.uniq.array; }
long[] supportedBy(Env e, long id) { return e.support(id, Vec3(0,0,-1)); }
long[] supporting(Env e, long id) { return e.support(id, Vec3(0,0,+1)); }

long part1(string str) {
    Env e = doFall(sortByLowest(parseBricks(str)));
    long result = 0;
    for (long id = 0; id < e.fallen.length; id++) {
        long[] dependents = e.supporting(id);
        if (dependents.all!(did => e.supportedBy(did).length > 1)) {
            result++;
        }
    }
    return result;
}

long part2(string str) {
    Env starte = doFall(sortByLowest(parseBricks(str)));
    long result = 0;
    for (long id = 0; id < starte.fallen.length; id++) {
        Brick[] bricks = starte.fallen.dup.remove(id).array;
        Env e = doFall(bricks);
        result += e.fallen.zip(bricks).map!(p => cast(long)(p[0] != p[1])).sum;
    }
    return result;
}

void main() {
    string example1 = `1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9`;

    writeln(part1(example1));
    writeln(part1(readText("input")));
    writeln(part2(example1));
    writeln(part2(readText("input")));
}