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

int[][] parseMap(string str) {
    return str.splitLines.map!(r => r.map!(c => cast(int)(c - '0')).array).array;
}

struct Coord {
    long x, y;
    Coord opBinary(string op : "+")(Coord rhs) { return Coord(x + rhs.x, y + rhs.y); }
    Coord opBinary(string op : "-")(Coord rhs) { return Coord(x - rhs.x, y - rhs.y); }
    Coord opUnary(string op : "-")() { return Coord(-x, -y); }
    long oneNorm(Coord other) { return abs(x - other.x) + abs(y - other.y); }
};

struct Descriptor {
    Coord loc;
    Coord dir;
    int dirRem;
};

Descriptor[] getNeighbours(Descriptor d, int[][] m) {
    return [Coord(-1, 0), Coord(+1, 0), Coord(0, -1), Coord(0, +1)]
        .filter!(step => step != -d.dir)
        .map!((Coord step) {
            if (d.dir == step)
                return Descriptor(d.loc + step, step, d.dirRem - 1);
            return Descriptor(d.loc + step, step, 2);
        })
        .filter!(d2 => d2.dirRem >= 0)
        .filter!(d2 => d2.loc.x >= 0 && d2.loc.y >= 0 && d2.loc.x < m[0].length && d2.loc.y < m.length)
        .array;
}

long search(int[][] m) {
    Descriptor startDesc = Descriptor(Coord(0, 0), Coord(0, 0), -1);
    bool[Descriptor] openSet;
    openSet[startDesc] = true;
    const Coord goal = Coord(m[0].length - 1, m.length - 1);
    int[Descriptor] gscore;
    gscore[startDesc] = 0;
    while (!openSet.empty) {
        Descriptor current = openSet.byKey.minElement!(d => gscore[d] + d.loc.oneNorm(goal));
        openSet.remove(current);
        if (current.loc == goal)
            return gscore[current];

        Descriptor[] neighbours = getNeighbours(current, m);
        foreach (Descriptor n; neighbours) {
            int score = gscore[current] + m[n.loc.x][n.loc.y];
            if (n !in gscore || score < gscore[n]) {
                gscore[n] = score;
                openSet[n] = true;
            }
        }
    }
    return -1;
}

void main() {
    string example1 = `2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533`;

    writeln(search(parseMap(example1)));
    writeln(search(parseMap(readText("input"))));
}
