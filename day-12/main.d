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

struct Row {
    char[] s;
    long[] expect;
    long maxHashCount;
    long startingHashCount;
}

Row parseRow(string str) {
    string[] s = str.split(' ');
    auto expect = s[1].split(',').map!(a => parse!long(a)).array;
    return Row(s[0].dup, expect, expect.sum, s[0].count!(a => a == '#'));
}

Row[] parseRows(string str) {
    return str.splitLines.map!(parseRow).array;
}

Row[] expandRows(Row[] rs) {
    return rs.map!((r) {
        Row newr = r;
        char[] s = r.s.dup;
        long[] expect = r.expect.dup;
        for (int i = 0; i < 4; i++) {
            newr.s ~= '?';
            newr.s ~= s;
            newr.expect ~= expect;
        }
        newr.maxHashCount *= 5;
        newr.startingHashCount *= 5;
        return newr;
    }).array;
}

struct State {
    long i;
    long hashCount;
    long[] current = [0];
};

long[State] cache;

long countValid(Row row, State state) {
    if (state in cache) {
        return cache[state];
    }

    if (state.current.length >= row.expect.length) {
        if (state.current == row.expect) {
            for (long i = state.i; i < row.s.length; i++) {
                switch (row.s[i]) {
                case '.': break;
                case '?': break;
                case '#': return 0;
                default: assert(false);
                }
            }
            return 1;
        }
        if (state.current.length > row.expect.length) {
            return 0;
        }
    }

    if (state.i >= row.s.length) {
        return 0;
    }

    /+Row modRow(char ch) {
        Row newr = row;
        newr.s = row.s.dup;
        newr.s[state.i] = ch;
        return newr;
    }+/
    long addZero() {
        if (state.current[$ - 1] != 0) {
            if (state.current[$ - 1] != row.expect[state.current.length - 1])
                return 0;
            return cache[state] = countValid(row, State(state.i + 1, state.hashCount, state.current ~ 0));
        }
        return cache[state] = countValid(row, State(state.i + 1, state.hashCount, state.current));
    }
    long addOne(int incr = 0) {
        long[] newC = state.current.dup;
        newC[$ - 1]++;
        if (newC[$ - 1] > row.expect[state.current.length - 1])
            return 0;
        if (state.hashCount + incr > row.maxHashCount)
            return 0;
        return cache[state] = countValid(row, State(state.i + 1, state.hashCount + incr, newC));
    }

    // writeln("walk: ", state.i, " ", row.s[state.i], " - ", row.s.text, " ", state.current, "=", state.hashCount);

    switch (row.s[state.i]) {
    case '.':
        return addZero();
    case '#':
        return addOne();
    case '?':
        long result = 0;
        result += addZero();
        result += addOne(1);
        return cache[state] = result;
    default:
        assert(false);
    }
}

long sumValid(Row[] rows) {
    return rows.map!((r) { writeln("==> ", r.s.text, " ", r.expect); cache.clear; long c = countValid(r, State(0, r.startingHashCount, [0])); writeln("==> ", c); return c; }).sum;
}

void main() {
    string example1 = `???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1`;

    writeln(sumValid(parseRows(example1)));
    writeln(sumValid(parseRows(readText("input"))));
    writeln(sumValid(expandRows(parseRows(example1))));
    writeln(sumValid(expandRows(parseRows(readText("input")))));
}
