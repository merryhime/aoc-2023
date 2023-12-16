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

const int UP      = 0b0001;
const int DOWN    = 0b0010;
const int LEFT    = 0b0100;
const int RIGHT   = 0b1000;

struct Coord {
    long x, y;
    Coord opBinary(string op : "+")(Coord rhs) { return Coord(x + rhs.x, y + rhs.y); }
    Coord opBinary(string op : "-")(Coord rhs) { return Coord(x - rhs.x, y - rhs.y); }
    Coord step(int dir) {
        switch(dir) {
            case UP: return Coord(x, y - 1);
            case DOWN: return Coord(x, y + 1);
            case LEFT: return Coord(x - 1, y);
            case RIGHT: return Coord(x + 1, y);
            default: assert(false);
        }
    }
};

int[] newDir(dchar tile, int currentDir) {
    switch (tile) {
    case '.':
        break;
    case '/':
        switch (currentDir) {
            case UP: return [RIGHT];
            case DOWN: return [LEFT];
            case LEFT: return [DOWN];
            case RIGHT: return [UP];
            default: assert(false);
        }
    case '\\':
        switch (currentDir) {
            case UP: return [LEFT];
            case DOWN: return [RIGHT];
            case LEFT: return [UP];
            case RIGHT: return [DOWN];
            default: assert(false);
        }
    case '-':
        if (currentDir & (UP | DOWN)) return [LEFT, RIGHT];
        break;
    case '|':
        if (currentDir & (LEFT | RIGHT)) return [UP, DOWN];
        break;
    default:
        assert(false);
    }
    return [currentDir];
}

struct Tile {
    dchar ch;
    int dir;
};

struct Light {
    Coord loc;
    int dir;
};

Tile[][] parseMap(string str) {
    return str.splitLines.map!(s => s.map!(ch => Tile(ch, 0)).array).array;
}

Tile[][] energize(Tile[][] m_in, Light start) {
    Tile[][] m = m_in.map!(r => r.dup).array;
    Light[] next = [start];
    while (!next.empty) {
        Light l = next.front;
        next.popFront;
        if (l.loc.x < 0 || l.loc.y < 0 || l.loc.y >= m.length || l.loc.x >= m[0].length)
            continue;
        int[] dirs = newDir(m[l.loc.y][l.loc.x].ch, l.dir);
        foreach (int dir; dirs) {
            if (dir & m[l.loc.y][l.loc.x].dir)
                continue;
            m[l.loc.y][l.loc.x].dir |= dir;
            next ~= Light(l.loc.step(dir), dir);
        }
    }
    return m;
}

long countEnergized(Tile[][] m) {
    return m.map!(r => r.map!(t => t.dir ? 1 : 0).sum).sum;
}

void printMap(Tile[][] m) {
    foreach (Tile[] r; m) {
        writeln(r.map!(t => t.dir ? '#' : t.ch));
    }
}

long part1(Tile[][] m) {
    return countEnergized(energize(m, Light(Coord(0, 0), RIGHT)));
}

long part2(Tile[][] m) {
    long result = 0;
    for (int y = 0; y < m.length; y++) {
        long currentA = countEnergized(energize(m, Light(Coord(0, y), RIGHT)));
        long currentB = countEnergized(energize(m, Light(Coord(m[y].length - 1, y), LEFT)));
        result = max(result, max(currentA, currentB));
    }
    for (int x = 0; x < m[0].length; x++) {
        long currentA = countEnergized(energize(m, Light(Coord(x, 0), DOWN)));
        long currentB = countEnergized(energize(m, Light(Coord(x, m.length - 1), UP)));
        result = max(result, max(currentA, currentB));
    }
    return result;
}

void main() {
    string example1 = `.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....`;

    writeln(part1(parseMap(example1)));
    writeln(part1(parseMap(readText("input"))));
    writeln(part2(parseMap(example1)));
    writeln(part2(parseMap(readText("input"))));
}
