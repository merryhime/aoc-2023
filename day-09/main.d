import std.string;
import std.stdio;
import std.range;
import std.algorithm.sorting;
import std.algorithm.iteration;
import std.algorithm.searching;
import std.conv;
import std.file;

long[][] parseInput(string str) {
    return splitLines(str).map!(s => s.split(' ').map!(x => parse!long(x)).array).array;
}

long calcPos(long[] diffs, long i) {
    auto mul = (long x, long y) => x * y;
    auto choose = (long n, long p) => iota(n - (p - 1), n + 1).fold!mul / iota(1, p + 1).fold!mul;
    return diffs.enumerate.map!(x => choose(i, x[0] + 1) * x[1]).sum;
}

long[] calcDiffs(long[] seq) {
    long[] diffs;
    for (long i = 1; i < seq.length; i++) {
        long d = seq[i] - (seq[0] + calcPos(diffs, i));
        diffs ~= d;
    }
    return diffs;
}

long part1(long[][] seqs) {
    return seqs.map!((long[] seq) {
        long[] diffs = calcDiffs(seq);
        return seq[0] + calcPos(diffs, seq.length);
    }).sum;
}

long part2(long[][] seqs) {
    return seqs.map!((long[] seq) {
        long[] diffs = calcDiffs(seq);
        return seq[0] + calcPos(diffs, -1);
    }).sum;
}

void main() {
    const string example1 = `0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45`;
    writeln(part1(parseInput(example1)));
    writeln(part1(parseInput(readText("input"))));
    writeln(part2(parseInput(example1)));
    writeln(part2(parseInput(readText("input"))));
}