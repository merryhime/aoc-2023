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

struct Coord {
    long x, y;
    Coord opBinary(string op : "+")(Coord rhs) { return Coord(x + rhs.x, y + rhs.y); }
    Coord opBinary(string op : "-")(Coord rhs) { return Coord(x - rhs.x, y - rhs.y); }
    Coord[] neighbours() { return [Coord(x, y - 1), Coord(x, y + 1), Coord(x - 1, y), Coord(x + 1, y)]; }
    long norm() { return abs(x) + abs(y); }
}

Coord findTile(string[] m, dchar s) {
    for (int y = 0; y < m.length; y++) {
        for (int x = 0; x < m[y].length; x++) {
            if (m[y][x] == s) return Coord(x, y);
        }
    }
    assert(false);
}

long mod(long m, long d) {
    long result = ((m % d) + d) % d;
    return result;
}

dchar wrapRead(string[] m, Coord c) {
    return m[mod(c.y, m.length)][mod(c.x, m[0].length)];
}

bool isInBoundsOf(Coord c, string[] m) {
    dchar ch = m.wrapRead(c);
    return ch == '.' || ch == 'S';
}

long roundUp(long x, long d) {
    return x + d - mod(x, d);
}

long roundDown(long x, long d) {
    return x - mod(x, d);
}

void printMap(string[] m, bool[Coord] prev) {
    long minx = roundDown(prev.byKey.minElement!"a.x".x, m[0].length);
    long maxx = roundUp(prev.byKey.maxElement!"a.x".x, m[0].length);
    long miny = roundDown(prev.byKey.minElement!"a.y".y, m.length);
    long maxy = roundUp(prev.byKey.maxElement!"a.y".y, m.length);
    for (long y = miny; y <= maxy; y++) {
        for (long x = minx; x <= maxx; x++) {
            Coord c = Coord(x, y);
            if (c in prev) {
                write('O');
            } else {
                write(m.wrapRead(c));
            }
        }
        writeln();
    }
    writeln();
}

long part1(string mstr, long steps) {
    string[] m = mstr.splitLines.map!(r => r.chomp).array;
    bool[Coord] prev;
    prev[m.findTile('S')] = true;
    for (long i = 0; i < steps; i++) {
        bool[Coord] next;
        foreach (p; prev.byKey)
            foreach(t; p.neighbours.filter!(t => t.isInBoundsOf(m)))
                next[t] = true;
        prev = next;
    }
    return prev.byKey.count;
}

long calcPos(long[] diffs, long i) {
    auto mul = (long x, long y) => x * y;
    auto choose = (long n, long p) => iota(n - (p - 1), n + 1).fold!mul / iota(1, p + 1).fold!mul;
    return diffs.enumerate.map!(x => choose(i, x[0] + 1) * x[1]).sum;
}

long[] calcDiffs(long[] seq) {
    long[] diffs;
    for (long i = 1; i < seq.length; i++) {
        long d = seq[i] - (seq[0] + calcPos(diffs, i));
        diffs ~= d;
    }
    return diffs;
}

void part2(string str, long index) {
    auto next = (long[] seq, long index) {
        long[] diffs = calcDiffs(seq);
        return seq[0] + calcPos(diffs, index);
    };
    auto calc = (long i) { return part1(str, 131 * i + 65); };
    
    long[] seq = [calc(0), calc(1), calc(2), calc(3)];
    assert(calc(seq, 4) == calc(4));

    writeln(next(seq, index));
}

void main() {
    string example1 = `...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........`;

    writeln(part1(example1, 6));
    writeln(part1(readText("input"), 64));
    writeln(readText("input").splitLines.length);
    part2(readText("input"), (26501365 - 65) / 131);
}
