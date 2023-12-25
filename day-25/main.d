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

string[][string] parseGraph(string str) {
    string[][string] result;
    foreach (line; str.splitLines) {
        string[] p = line.split(": ");
        string a = p[0];
        foreach (b; p[1].split(' ')) {
            result[a] ~= b;
            result[b] ~= a;
        }
    }
    return result;
}

string[] findPath(string[][string] m, bool[Tuple!(string,string)] banned, string start, string end) {
    string[] open = [start];
    long[string] visited;
    string[string] previous;
    visited[start] = 0;
    while (!open.empty) {
        string current = open.front;
        open.popFront;

        if (current == end) {
            string[] path;
            path ~= end;
            while (path[$-1] != start) {
                path ~= previous[path[$-1]];
            }
            path = path.reverse;
            return path;
        }

        long dist = visited[current] + 1;
        foreach (next; m[current]) {
            if (next !in visited && tuple(next, current) !in banned && tuple(current, next) !in banned) {
                open ~= next;
                visited[next] = dist;
                previous[next] = current;
            }
        }
    }
    return [];
}

long countConnected(string[][string] m, bool[Tuple!(string,string)] banned, string start) {
    string[] open = [start];
    bool[string] visited;
    visited[start] = true;
    while (!open.empty) {
        string current = open.front;
        open.popFront;

        foreach (next; m[current]) {
            if (next !in visited && tuple(next, current) !in banned && tuple(current, next) !in banned) {
                open ~= next;
                visited[next] = true;
            }
        }
    }
    return visited.length;
}

bool[Tuple!(string,string)] tryBreak(string[][string] m) {
    foreach (sn; m.byPair) {
        string start = sn[0];
        foreach (end; sn[1]) {
            auto next = tryBreak(m, tuple(start, end), new bool[Tuple!(string, string)]);
            if (!next.empty) return next;
        }
    }
    return new bool[Tuple!(string, string)];
}

bool[Tuple!(string,string)] tryBreak(string[][string] m, Tuple!(string,string) current, bool[Tuple!(string,string)] prevbanned) {
    auto banned = prevbanned.dup;
    banned[current] = true;
    
    string[] path = findPath(m, banned, current[0], current[1]);
    if (path.empty) return banned;

    if (banned.length >= 3) return new bool[Tuple!(string, string)];
    foreach (next; zip(path[0..$-1], path[1..$])) {
        auto nextResult = tryBreak(m, next, banned);
        if (!nextResult.empty) return nextResult;
    }
    return new bool[Tuple!(string, string)];
}

long part1(string str) {
    auto m = parseGraph(str);
    auto banned = tryBreak(m);
    auto link = banned.byKey.front;
    long a = countConnected(m, banned, link[0]);
    long b = countConnected(m, banned, link[1]);
    return a * b;
}

void main() {
    string example1 = `jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr`;

    writeln(parseGraph(example1));
    writeln(tryBreak(parseGraph(example1)));
    writeln(part1(example1));
    writeln(part1(readText("input")));
}
