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

char[][] parseMap(string str) {
    return str.splitLines.map!(s => s.dup).array;
}

char[][] shiftNorth(char[][] m) {
    foreach (long y; iota(1, m.length)) {
        foreach (long x; iota(0, m[y].length)) {
            if (m[y][x] == 'O') {
                long j = y - 1;
                while (j >= 0 && m[j][x] == '.') j--;
                m[y][x] = '.';
                m[j + 1][x] = 'O';
            }
        }
    }
    return m;
}

long scoreNorth(char[][] m) {
    long result = 0;
    foreach (long y; iota(0, m.length)) {
        foreach (long x; iota(0, m[y].length)) {
            if (m[y][x] == 'O') result += m.length - y;
        }
    }
    return result;
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
}