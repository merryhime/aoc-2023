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
    Coord opBinary(string op : "+")(Coord rhs) { return Coord(x + rhs.x, y + rhs.y); }
    Coord[] neighbours() { return [Coord(x, y - 1), Coord(x, y + 1), Coord(x - 1, y), Coord(x + 1, y)]; }
}
dchar get(string[] m, Coord c) { return m[c.y][c.x]; }
bool isInBounds(string[] m, Coord c) { return c.y >= 0 && c.y < m.length && c.x >= 0 && c.x < m[c.y].length && m.get(c) != '#'; }
bool isCorrectDirection(string[] m, Coord old, Coord new_) {
    final switch (m.get(new_)) {
    case 'v': return old == new_ + Coord(0, -1);
    case '^': return old == new_ + Coord(0, +1);
    case '<': return old == new_ + Coord(+1, 0);
    case '>': return old == new_ + Coord(-1, 0);
    case '.': return true;
    }
}
Coord start(string[] m) { return Coord(m[0].indexOf('.'), 0); }
Coord end(string[] m) { return Coord(m[m.length - 1].indexOf('.'), m.length - 1); }

long maxPath(string[] m, Coord[] path = []) {
    if (path.empty) return m.maxPath([m.start]);

    Coord current = path[$-1];
    if (current.y == m.length - 1) return path.length - 1;
    return current
            .neighbours
            .filter!(n => m.isInBounds(n) && m.isCorrectDirection(current, n) && !path.canFind(n))
            .map!(n => m.maxPath(path ~ n))
            .array
            .maxElement(-1);
}

Coord[] explore(string[] m, Coord[] path) {
    while (true) {
        Coord current = path[$-1];
        Coord[] ns = current.neighbours.filter!(n => m.isInBounds(n) && !path.canFind(n)).array;
        if (ns.length == 1) {
            path ~= ns[0];
            continue;
        }
        return path;
    }
}

Coord[] findNodes(string[] m) {
    Coord[] result;
    for (int y = 0; y < m.length; y++)
    for (int x = 0; x < m[y].length; x++) {
        Coord c = Coord(x, y);
        if (!m.isInBounds(c)) continue;
        if (c.neighbours.filter!(n => m.isInBounds(n)).count > 2) result ~= c;
    }
    result ~= m.start;
    result ~= m.end;
    return result;
}

struct Edge {
    Coord from;
    Coord to;
    long dist;
};

Edge[][Coord] findEdges(string[] m) {
    Coord[] nodes = m.findNodes;
    Edge[][Coord] result;
    foreach (Coord n; nodes) {
        result[n] = [];
        foreach (Coord dir; n.neighbours.filter!(n => m.isInBounds(n))) {
            Coord[] path = m.explore([n, dir]);
            Coord dest = path[$-1];
            long len = path.length - 1;
            if (nodes.canFind(dest)) {
                long prevEdge = result[n].countUntil!(x => x.to == dest);
                if (prevEdge == -1) {
                    result[n] ~= Edge(n, dest, len);
                } else {
                    result[n][prevEdge].dist = max(result[n][prevEdge].dist, len);
                }
            }
        }
    }
    return result;
}

long maxPath(Edge[][Coord] es, Coord[] path, Coord destination, long currentTotal) {
    Coord current = path[$-1];
    if (current == destination) return currentTotal;
    return es[current]
            .filter!(e => !path.canFind(e.to))
            .map!(n => maxPath(es, path ~ n.to, destination, currentTotal + n.dist))
            .array
            .maxElement(-1);
}

long part2(string str) {
    string[] m = str.splitLines;
    Edge[][Coord] es = findEdges(m);
    return maxPath(es, [m.start], m.end, 0);
}

void main() {
    string example1 = `#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#`;

    writeln(example1.splitLines.maxPath);
    writeln(readText("input").splitLines.maxPath);
    writeln(findEdges(example1.splitLines));
    writeln(part2(example1));
    writeln(part2(readText("input")));
}