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

struct AntiPipe {
    Coord[2] n;
    bool straight;
    Coord[] jmp;
};

struct Position {
    Coord pipe;
    Coord query;
    Coord prev;
};

long part2(Map m) {
    Coord[] loop = findLoop(m).byKey.array;
    long minx = loop.map!"a.x".minElement;
    long maxx = loop.map!"a.x".maxElement;
    long miny = loop.map!"a.y".minElement;
    long maxy = loop.map!"a.y".maxElement;

    AntiPipe[dchar] ANTIPIPES = [
        '|': AntiPipe([Coord(-1, 0), Coord(+1, 0)], true, []),
        '-': AntiPipe([Coord(0, -1), Coord(0, +1)], true, []),
        'L': AntiPipe([Coord(-1, 0), Coord(0, +1)], false, [Coord(+1, -1)]),
        '7': AntiPipe([Coord(0, -1), Coord(+1, 0)], false, [Coord(-1, +1)]),
        'F': AntiPipe([Coord(0, -1), Coord(-1, 0)], false, [Coord(+1, +1)]),
        'J': AntiPipe([Coord(+1, 0), Coord(0, +1)], false, [Coord(-1, -1)]),
    ];

    int[Coord] isInsideCache;
    Coord[] uncertain;
    int depth = 0;
    int isInside(Coord c) {
        // if (c in isInsideCache) return isInsideCache[c];
        if (c.x < minx || c.x > maxx || c.y < miny || c.y > maxy) return -1;
        if (loop.canFind(c)) return 0;
        // We are in uncertainty mode
        if (uncertain.canFind(c)) return 0;
        const bool isRoot = uncertain.empty;
        uncertain ~= c;
        int result = (){
            auto neighbours = [Coord(0, -1), Coord(0, +1), Coord(-1, 0), Coord(+1, 0)].map!(i => i + c).array;
            neighbours.partition!(i => !loop.canFind(i));
            foreach(Coord neighbour; neighbours) {
                if (loop.canFind(neighbour)) {
                    Coord pipe = neighbour;
                    Coord query = c;
                    Coord prev = (){
                        dchar ch = m.pipes[pipe].ch;
                        AntiPipe ap = ANTIPIPES[ch];
                        Coord[] expectedQuery = ap.n[].map!(n => n + pipe).array;
                        long i = expectedQuery.countUntil(query);
                        return m.pipes[pipe].neighbours[i];
                    }();
                    writeln(depth, " neighbour on loop: ", pipe, query, prev);
                    do {
                        int r2 = isInside(query); if (r2 != 0) return r2;
                        dchar ch = m.pipes[pipe].ch;
                        writeln(ch, ' ', pipe, query);
                        AntiPipe ap = ANTIPIPES[ch];
                        if (!ap.straight) {
                            Coord[] expectedQuery = ap.n[].map!(n => n + pipe).array;
                            if (expectedQuery.canFind(query)) {
                                Coord query2 = expectedQuery.filter!(n => n != query).array[0];
                                // int r = isInside(query2); if (r != 0) return -r;
                                Coord nextPipe = m.pipes[pipe].neighbours[].filter!(p => p != prev).array[0];
                                query = query2 + (nextPipe - pipe);
                                prev = pipe;
                                pipe = nextPipe;
                            } else {
                                Coord nextPipe = m.pipes[pipe].neighbours[].filter!(p => p != prev).array[0];
                                query = pipe + ap.jmp[0];
                                prev = pipe;
                                pipe = nextPipe;
                            }
                        } else {
                            Coord[] expectedQuery = ap.n[].map!(n => n + pipe).array;
                            assert(expectedQuery.canFind(query));
                            Coord query2 = expectedQuery.filter!(n => n != query).array[0];
                            // int r = isInside(query2); if (r != 0) return r;
                            Coord nextPipe = m.pipes[pipe].neighbours[].filter!(p => p != prev).array[0];
                            query = query + (nextPipe - pipe);
                            prev = pipe;
                            pipe = nextPipe;
                        }
                        writeln(depth, " traversing loop: ", pipe, query, prev);
                    } while(pipe != neighbour);
                    assert(false);
                }
                int r = isInside(neighbour); if (r != 0) return r;
            }
            return 0;
        }();
        if (isRoot) {
            if (result != 0) {
                foreach (Coord u; uncertain) { isInsideCache[u] = result; }
            }
            uncertain = [];
        }
        return result;
    }
    long result = cartesianProduct(iota(minx, maxx + 1), iota(miny, maxy + 1)).map!(i => isInside(Coord(i[0], i[1])) == +1).filter!"a".count;
    for (long y = 0; y <= maxy; y++) {
        for (long x = 0; x <= maxx; x++) {
            if (loop.canFind(Coord(x, y))) {
                write(m.pipes[Coord(x, y)].ch);
                continue;
            }
            switch (isInside(Coord(x, y))) {
            case -1: write(' '); break;
            case +1: write('.'); break;
            case 0: write('X'); break;
            default: assert(false);
            }
        }
        writeln();
    }
    return result;
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
    const string example4 = `...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........`;
    const string example5 = `.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...`;
    const string example6 = `FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L`;

    writeln(findLoop(parseMap(example1)).byValue.maxElement);
    writeln(findLoop(parseMap(example2)).byValue.maxElement);
    writeln(findLoop(parseMap(example3)).byValue.maxElement);
    writeln(findLoop(parseMap(readText("input"))).byValue.maxElement);
    writeln(part2(parseMap(example4)));
    // writeln(part2(parseMap(example5)));
    // writeln(part2(parseMap(example6)));
    // writeln(part2(parseMap(readText("input"))));
}
