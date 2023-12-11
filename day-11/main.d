import std.string;
import std.stdio;
import std.range;
import std.algorithm.sorting;
import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.setops;
import std.conv;
import std.typecons;
import std.file;
import std.math.algebraic;

struct Coord {
    long x, y;
    Coord opBinary(string op : "+")(Coord rhs) { return Coord(x + rhs.x, y + rhs.y); }
    Coord opBinary(string op : "-")(Coord rhs) { return Coord(x - rhs.x, y - rhs.y); }
    long norm() { return abs(x) + abs(y); }
};

Coord[] parseMap(string str) {
    Coord[] result;
    string[] s = splitLines(str);
    for (int y = 0; y < s.length; y++)
    for (int x = 0; x < s[y].length; x++) {
        Coord c = Coord(x, y);
        dchar ch = s[y][x];
        if (ch == '#') {
            result ~= c;
        }
    }
    return result;
}

long dist(Coord[] m, long expansionFactor) {
    long minx = m.map!"a.x".minElement;
    long maxx = m.map!"a.x".maxElement;
    long miny = m.map!"a.y".minElement;
    long maxy = m.map!"a.y".maxElement;
    long[] emptyx = iota(minx, maxx).filter!(x => !m.any!(c => c.x == x)).array;
    long[] emptyy = iota(miny, maxy).filter!(y => !m.any!(c => c.y == y)).array;
    for (int i = 0; i < m.length; i++) {
        m[i].x += emptyx.filter!(x => x < m[i].x).count * (expansionFactor - 1);
        m[i].y += emptyy.filter!(y => y < m[i].y).count * (expansionFactor - 1);
    }
    return cartesianProduct(m, m).map!(i => (i[0] - i[1]).norm()).sum / 2;
}

void main() {
    string example1 = `...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....`;
    writeln(dist(parseMap(example1), 2));
    writeln(dist(parseMap(readText("input")), 2));
    writeln(dist(parseMap(example1), 10));
    writeln(dist(parseMap(example1), 100));
    writeln(dist(parseMap(readText("input")), 1000000));
}