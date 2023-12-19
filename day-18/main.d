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
    string colour;
}

Cmd[] parseCmds(string str) {
    return str.splitLines.map!((string c) {
        string[] p = c.split(' ');
        return Cmd(p[0][0], parse!long(p[1]), p[2]);
    }).array;
}

struct Coord {
    long x, y;
    Coord opBinary(string op : "+")(Coord rhs) { return Coord(x + rhs.x, y + rhs.y); }
    Coord opBinary(string op : "-")(Coord rhs) { return Coord(x - rhs.x, y - rhs.y); }
    Coord step(dchar dir) {
        switch(dir) {
            case 'U': return Coord(x, y - 1);
            case 'D': return Coord(x, y + 1);
            case 'L': return Coord(x - 1, y);
            case 'R': return Coord(x + 1, y);
            default: assert(false);
        }
    }
}

struct Map {
    long[][long] outline;
    dchar[Coord] type;
}

void set(ref long[][long] m, Coord c) {
    if (c.x !in m) {
        m[c.x] = [c.y];
   } else {
        m[c.x] ~= c.y;
   }
}

Map drawOutline(Cmd[] cmds) {
    Map m;
    Coord current = Coord(0, 0);
    set(m.outline, current);

    dchar lastdir = cmds[$-1].dir;
    foreach (Cmd cmd; cmds) {
        for (long i = 0; i < cmd.count; i++) {
            switch ([lastdir, cmd.dir]) {
            case ['U', 'U']: case ['D', 'D']: m.type[current] = '|'; break;
            case ['L', 'L']: case ['R', 'R']: m.type[current] = '-'; break;
            case ['U', 'L']: case ['L', 'U']: m.type[current] = '\\'; break;
            case ['D', 'R']: case ['R', 'D']: m.type[current] = '\\'; break;
            case ['U', 'R']: case ['R', 'U']: m.type[current] = '/'; break;
            case ['D', 'L']: case ['L', 'D']: m.type[current] = '/'; break;
            default: assert(false);
            }
            lastdir = cmd.dir;

            current = current.step(cmd.dir);
            set(m.outline, current);
        }
    }
    return m;
}

void printMap(Map m) {
    long minx = m.outline.byKey.minElement;
    long maxx = m.outline.byKey.maxElement;
    long miny = m.outline.byValue.joiner.minElement;
    long maxy = m.outline.byValue.joiner.maxElement;

    for (long y = miny; y <= maxy; y++) {
        for (long x = minx; x <= maxx; x++) {
            if (x in m.outline && m.outline[x].canFind(y)) {
                write(m.type[Coord(x, y)]);
            } else {
                write('.');
            }
        }
        writeln("");
    }
}

long countFill(Map m) {
    long minx = m.outline.byKey.minElement;
    long maxx = m.outline.byKey.maxElement;
    long miny = m.outline.byValue.joiner.minElement;
    long maxy = m.outline.byValue.joiner.maxElement;

    long result = 0;
    for (long x = minx; x <= maxx; x++) {
        bool isinside = false;
        dchar lastborderedge = '.';
        for (long y = miny; y <= maxy; y++) {
            Coord c = Coord(x, y);
            if (c !in m.type) {
                if (isinside) result++;
            } else switch (m.type[c]) {
                case '-':
                    result++;
                    isinside = !isinside;
                    break;
                case '/': case '\\':
                    result++;
                    if (lastborderedge == '.') {
                        lastborderedge = m.type[c];
                    } else {
                        if (lastborderedge == m.type[c]) {
                            isinside = !isinside;
                        }
                        lastborderedge = '.';
                    }
                    break;
                case '|':
                    result++;
                    break;
                default:
                    assert(false);
            }
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

    printMap(drawOutline(parseCmds(example1)));
    writeln(countFill(drawOutline(parseCmds(example1))));
    printMap(drawOutline(parseCmds(readText("input"))));
    writeln(countFill(drawOutline(parseCmds(readText("input")))));
}
