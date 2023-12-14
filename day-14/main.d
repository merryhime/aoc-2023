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
import std.int128;
import std.range.interfaces;

char[][] parseMap(string str) {
    return str.splitLines.map!(s => s.dup).array;
}

char[][] shift(char[][] m, InputRange!ulong dir, InputRange!ulong other, int delta) {
    foreach (ulong y; dir) {
        foreach (ulong x; other) {
            if (m[y][x] == 'O') {
                long j = y + delta;
                while (j >= 0 && j < m.length && m[j][x] == '.') j += delta;
                m[y][x] = '.';
                m[j - delta][x] = 'O';
            }
        }
    }
    return m;
}
char[][] shiftT(char[][] m, InputRange!ulong dir, InputRange!ulong other, int delta) {
    foreach (ulong y; dir) {
        foreach (ulong x; other) {
            if (m[x][y] == 'O') {
                long j = y + delta;
                while (j >= 0 && j < m[0].length && m[x][j] == '.') j += delta;
                m[x][y] = '.';
                m[x][j - delta] = 'O';
            }
        }
    }
    return m;
}

char[][] shiftNorth(char[][] m) { return shift(m, iota(1, m.length).inputRangeObject, iota(0, m[0].length).inputRangeObject, -1); }
char[][] shiftSouth(char[][] m) { return shift(m, iota(0, m.length - 1).retro.inputRangeObject, iota(0, m[0].length).inputRangeObject, +1); }
char[][] shiftWest(char[][] m) { return shiftT(m, iota(1, m[0].length).inputRangeObject, iota(0, m.length).inputRangeObject, -1); }
char[][] shiftEast(char[][] m) { return shiftT(m, iota(0, m[0].length - 1).retro.inputRangeObject, iota(0, m.length).inputRangeObject, +1); }

long scoreNorth(char[][] m) {
    long result = 0;
    foreach (long y; iota(0, m.length)) {
        foreach (long x; iota(0, m[y].length)) {
            if (m[y][x] == 'O') result += m.length - y;
        }
    }
    return result;
}

long part2(char[][] m) {
    long[string] lastCycle;
    bool tracking = true;
    for (long cycle = 0; cycle < 1000000000; cycle++) {
        if (tracking) {
            string mstr = m.map!(r => r.text).join(",");
            if (mstr in lastCycle) {
                long last = lastCycle[mstr];
                long diff = cycle - last;
                writeln(cycle, " ", last, " ", diff);
                while (cycle + diff < 1000000000) cycle += diff;
                tracking = false;
            }
            lastCycle[mstr] = cycle;
        }
        m = shiftNorth(m);
        m = shiftWest(m);
        m = shiftSouth(m);
        m = shiftEast(m);
    }
    return scoreNorth(m);
}

void main() {
    string example1 = `O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....`;

    writeln(scoreNorth(shiftNorth(parseMap(example1))));
    writeln(scoreNorth(shiftNorth(parseMap(readText("input")))));
    writeln(part2(parseMap(example1)));
    writeln(part2(parseMap(readText("input"))));
}