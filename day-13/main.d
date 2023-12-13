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

char[][][] parseMaps(string str) {
    return str.splitLines.split("").map!(m => m.map!(r => r.dup).array).array;
}

long getXSplit(char[][] m, long ignore = 0) {
    for (int i = 0; i < m.length - 1; i++) {
        if (zip(iota(i, -1, -1), iota(i + 1, m.length)).all!(j => m[j[0]] == m[j[1]])) {
            if (i + 1 != ignore) {
                return i + 1;
            }
        }
    }
    return 0;
}

long getYSplit(char[][] m, long ignore = 0) {
    for (int i = 0; i < m[0].length - 1; i++) {
        if (zip(iota(i, -1, -1), iota(i + 1, m[0].length)).all!(j => m.transversal(j[0]).array == m.transversal(j[1]).array)) {
            if (i + 1 != ignore) {
                return i + 1;
            }
        }
    }
    return 0;
}

long part1(char[][][] ms) {
    return ms.map!(m => getXSplit(m) * 100 + getYSplit(m)).sum;
}

long findDesmudged(char[][] m) {
    long oldX = getXSplit(m);
    long oldY = getYSplit(m);
    for (int i = 0; i < m.length; i++) {
        for (int j = 0; j < m[i].length; j++) {
            if (m[i][j] == '#') {
                m[i][j] = '.';
                long x = getXSplit(m, oldX);
                long y = getYSplit(m, oldY);
                // writeln(x, ",", y, ": ", m);
                m[i][j] = '#';
                long result = x * 100 + y;
                if (result != 0) return result;
            }
        }
    }
    assert(false);
}

long part2(char[][][] ms) {
    return ms.map!(findDesmudged).sum;
}

void main() {
    string example1 = `#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#`;

    writeln(part1(parseMaps(example1)));
    writeln(part1(parseMaps(readText("input"))));
    writeln(part2(parseMaps(example1)));
    writeln(part2(parseMaps(readText("input"))));
}