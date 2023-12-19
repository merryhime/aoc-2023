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

struct Cmd {
    dchar dir;
    long count;
}

Cmd[] parseCmds1(string str) {
    return str.splitLines.map!((string c) {
        string[] p = c.split(' ');
        return Cmd(p[0][0], parse!long(p[1]));
    }).array;
}

Cmd[] parseCmds2(string str) {
    dchar[dchar] dir = ['0': 'R', '1': 'D', '2': 'L', '3': 'U'];
    return str.splitLines.map!((string c) {
        string fakeCol = c.split(' ')[2];
        return Cmd(dir[fakeCol[7]], fakeCol[2 .. 7].text.to!long(16));
    }).array;
}

struct Coord {
    long x, y;
    Coord step(dchar dir, long count) {
        switch(dir) {
            case 'U': return Coord(x, y - count);
            case 'D': return Coord(x, y + count);
            case 'L': return Coord(x - count, y);
            case 'R': return Coord(x + count, y);
            default: assert(false);
        }
    }
}

struct Piece {
    long y;
    dchar type;
}

struct Map {
    Piece[][long] scanline;
}

Map drawOutline(Cmd[] cmds) {
    Map m;
    Coord current = Coord(0, 0);

    dchar lastdir = cmds[$-1].dir;
    foreach (Cmd cmd; cmds) {
        dchar type;

        switch ([lastdir, cmd.dir]) {
        case ['U', 'U']: case ['D', 'D']: type = '|'; break;
        case ['L', 'L']: case ['R', 'R']: type = '-'; break;
        case ['U', 'L']: case ['L', 'U']: case ['D', 'R']: case ['R', 'D']: type = '\\'; break;
        case ['U', 'R']: case ['R', 'U']: case ['D', 'L']: case ['L', 'D']: type = '/'; break;
        default: assert(false);
        }
        lastdir = cmd.dir;

        m.scanline[current.x] ~= Piece(current.y, type);

        current = current.step(cmd.dir, cmd.count);
    }
    return m;
}

long countFill(Map m) {
    long[] xs = m.scanline.byKey.array;
    xs = xs.sort.uniq.array;

    const long minx = xs[0];
    const long maxx = xs[$-1];

    Piece[] current = [];
    long[] remove_y = [];

    long result = 0;
    for (long x = minx; x <= maxx; x++) {
        current = current.filter!(p => !remove_y.canFind(p.y)).array;
        remove_y = [];

        foreach (ref p; current) p.type = '-';

        if (x in m.scanline) {
            foreach (s; m.scanline[x]) {
                long index = current.countUntil!(p => p.y == s.y);
                if (index == -1) {
                    current ~= s;
                } else {
                    current[index] = s;
                    remove_y ~= s.y;
                }
            }
            current.sort!((a, b) => a.y < b.y);
        }

        bool isinside = false;
        dchar lastborderedge = '.';
        long lasty = -1000000000000;
        foreach (p; current) {
            switch (p.type) {
                case '-':
                    result++;
                    if (isinside) {
                        result += p.y - lasty - 1;
                    }
                    isinside = !isinside;
                    break;
                case '/': case '\\':
                    result++;
                    if (lastborderedge == '.') {
                        if (isinside) {
                            result += p.y - lasty - 1;
                        }
                        lastborderedge = p.type;
                    } else {
                        result += p.y - lasty - 1;
                        if (lastborderedge == p.type) {
                            isinside = !isinside;
                        }
                        lastborderedge = '.';
                    }
                    break;
                default:
                    assert(false);
            }
            lasty = p.y;
        }
    }
    return result;
}

void main() {
    string example1 = `R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)`;

    writeln(countFill(drawOutline(parseCmds1(example1))));
    writeln(countFill(drawOutline(parseCmds1(readText("input")))));
    writeln(countFill(drawOutline(parseCmds2(example1))));
    writeln(countFill(drawOutline(parseCmds2(readText("input")))));
}
