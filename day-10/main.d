import std.string;
import std.stdio;
import std.range;
import std.algorithm.sorting;
import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.setops;
import std.conv;
import std.file;

struct Coord {
    long x, y;
    Coord opBinary(string op : "+")(Coord rhs) { return Coord(x + rhs.x, y + rhs.y); }
    Coord opBinary(string op : "-")(Coord rhs) { return Coord(x - rhs.x, y - rhs.y); }
};

struct Pipe {
    dchar ch;
    Coord position;
    Coord[2] neighbours;
};

struct Map {
    Coord start;
    Pipe[Coord] pipes;
};

Map parseMap(string str) {
    Coord[][dchar] PIPES = [
        '|': [Coord(0, -1), Coord(0, +1)],
        '-': [Coord(-1, 0), Coord(+1, 0)],
        'L': [Coord(0, -1), Coord(+1, 0)],
        '7': [Coord(-1, 0), Coord(0, +1)],
        'F': [Coord(+1, 0), Coord(0, +1)],
        'J': [Coord(0, -1), Coord(-1, 0)],
    ];

    Map m;
    string[] s = splitLines(str);
    for (int y = 0; y < s.length; y++)
    for (int x = 0; x < s[y].length; x++) {
        Coord c = Coord(x, y);
        dchar ch = s[y][x];
        if (ch in PIPES) {
            m.pipes[c] = Pipe(ch, c, [c + PIPES[ch][0], c + PIPES[ch][1]]);
        } else if (ch == 'S') {
            m.start = c;
        }
    }
    Coord[] start_neighbours = m.pipes.byValue.filter!(p => p.neighbours[].canFind!(n => n == m.start)).map!(p => p.position).array;
    assert(start_neighbours.length == 2);
    dchar start_ch = (){
        Coord[2] n1 = [start_neighbours[0] - m.start, start_neighbours[1] - m.start];
        Coord[2] n2 = [start_neighbours[1] - m.start, start_neighbours[0] - m.start];
        foreach (p; PIPES.byPair) if (p[1] == n1 || p[1] == n2) return p[0];
        assert(false);
    }();
    m.pipes[m.start] = Pipe(start_ch, m.start, [start_neighbours[0], start_neighbours[1]]);

    return m;
}

long[Coord] findLoop(Map m) {
    long[Coord] distance;
    Coord[] next = [m.start];
    int i = 0;
    while (!next.empty) {
        Coord[] curr = next;
        next = [];
        foreach (Coord c; curr) {
            if (c !in distance) {
                next ~= m.pipes[c].neighbours;
                distance[c] = i;
            }
        }
        i++;
    }
    return distance;
}

void main() {
    const string example1 = `.....
.S-7.
.|.|.
.L-J.
.....`;
    const string example2 = `-L|F7
7S-7|
L|7||
-L-J|
L|-JF`;
    const string example3 = `..F7.
.FJ|.
SJ.L7
|F--J
LJ...`;

    writeln(findLoop(parseMap(example1)).byValue.maxElement);
    writeln(findLoop(parseMap(example2)).byValue.maxElement);
    writeln(findLoop(parseMap(example3)).byValue.maxElement);
    writeln(findLoop(parseMap(readText("input"))).byValue.maxElement);
}
