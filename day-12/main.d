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
    Int128 mask;
    Int128 set;
    long[] expect;
}

Row parseRow(string str) {
    Row result;
    string[] s = str.split(' ');
    foreach (dchar ch; s[0]) {
        result.mask <<= 1;
        result.set <<= 1;
        switch (ch) {
        case '.': break;
        case '#': result.set |= 1; break;
        case '?': result.mask |= 1; break;
        default: assert(false);
        }
    }
    result.expect = s[1].split(',').map!(a => parse!long(a)).array;
    return result;
}

Row[] parseRows(string str) {
    return str.splitLines.map!(parseRow).array;
}

long[] bitSeq(Int128 set) {
    long[] result = [0];
    while (set) {
        if (set >> 127) {
            result[$ - 1]++;
        } else if (result[$ - 1]) {
            result ~= 0;
        }
        set <<= 1;
    }
    return result.filter!"a!=0".array;
}

long countValid(Row row) {
    long count = 0;
    Int128 x = row.set;
    do {
        if (bitSeq(x) == row.expect) {
            count++;
        }
        x = ((x | ~row.mask) + 1) & row.mask;
        x |= row.set;
    } while (x != row.set);
    return count;
}

long part1(Row[] rows) {
    return rows.map!(countValid).sum;
}

void main() {
    string example1 = `???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1`;

    writeln(part1(parseRows(example1)));
    writeln(part1(parseRows(readText("input"))));
}
