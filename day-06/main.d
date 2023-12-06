import std.stdio;
import std.range;
import std.file;
import std.algorithm.searching;
import std.algorithm.iteration;
import std.conv;
import std.string;

struct Race {
    long time;
    long distance;
};

Race[] parseData(string s) {
    string[] p = splitLines(s);
    auto parseLine = (string x) => x.drop(10).split(' ').filter!"!a.empty".map!(a => parse!long(a));
    return zip(parseLine(p[0]), parseLine(p[1])).map!(a => Race(a[0], a[1])).array;
}

long part1(Race[] rs) {
    auto winCount = (Race r) => iota(1, r.time).map!(t => t * (r.time - t)).count!(d => d > r.distance);
    return rs.map!(winCount).fold!((a, b) => a * b);
}

void main() {
    const string example1 = `Time:      7  15   30
Distance:  9  40  200`;
    writeln(part1(parseData(example1)));
    writeln(part1(parseData(readText("input"))));
}
