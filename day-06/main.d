import std.stdio;
import std.range;
import std.file;
import std.algorithm.searching;
import std.algorithm.iteration;
import std.conv;
import std.string;
import core.stdc.math;

struct Race {
    double time;
    double distance;
};

Race[] part1(string s) {
    string[] p = splitLines(s);
    auto parseLine = (string x) => x.drop(10).split(' ').filter!"!a.empty".map!(a => parse!double(a));
    return zip(parseLine(p[0]), parseLine(p[1])).map!(a => Race(a[0], a[1])).array;
}

Race[] part2(string s) {
    string[] p = splitLines(s);
    auto parseLine = (string x) {
        x = x.split(':')[1].replace(" ", "");
        return parse!double(x);
    };
    return [Race(parseLine(p[0]), parseLine(p[1]))];
}

auto calc(Race[] rs) {
    auto winCount = (Race r) {
        double x0 = 0.5 * r.time - sqrt(0.25 * r.time * r.time - r.distance);
        double x1 = 0.5 * r.time + sqrt(0.25 * r.time * r.time - r.distance);
        x0 = ceil(nextafter(x0, double.infinity));
        x1 = floor(nextafter(x1, -double.infinity));
        return cast(long) (x1 - x0 + 1);
    };
    return rs.map!(winCount).fold!((a, b) => a * b);
}

void main() {
    const string example1 = `Time:      7  15   30
Distance:  9  40  200`;
    writeln(calc(part1(example1)));
    writeln(calc(part1(readText("input"))));
    writeln(calc(part2(example1)));
    writeln(calc(part2(readText("input"))));
}