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
    Coord[] neighbours() {
        return [Coord(x, y - 1), Coord(x, y + 1), Coord(x - 1, y), Coord(x + 1, y)];
    }
}

Coord findTile(string[] m, dchar s) {
    for (int y = 0; y < m.length; y++) {
        for (int x = 0; x < m[y].length; x++) {
            if (m[y][x] == s) return Coord(x, y);
        }
    }
    assert(false);
}

bool isInBoundsOf(Coord c, string[] m) {
    return c.y >= 0 && c.y < m.length && c.x >= 0 && c.x < m[c.y].length && (m[c.y][c.x] == '.' || m[c.y][c.x] == 'S');
}

long part1(string mstr, int steps) {
    string[] m = mstr.splitLines;
    bool[Coord] prev;
    prev[m.findTile('S')] = true;
    for (int i = 0; i < steps; i++) {
        bool[Coord] next;
        foreach (p; prev.byKey)
            foreach(t; p.neighbours.filter!(t => t.isInBoundsOf(m)))
                next[t] = true;
        prev = next;
    }
    return prev.byKey.count;
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
}
