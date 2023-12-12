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
    string s;
    Int128 mask;
    Int128 set;
    long[] expect;
    long setCount;
    long width;
}

Row parseRow(string str) {
    Row result;
    result.s = str;
    string[] s = str.split(' ');
    foreach (dchar ch; s[0]) {
        result.mask <<= 1;
        result.set <<= 1;
        switch (ch) {
        case '.': break;
        case '#': result.set |= 1; result.setCount++; break;
        case '?': result.mask |= 1; break;
        default: assert(false);
        }
    }
    result.width = s[0].length;
    result.expect = s[1].split(',').map!(a => parse!long(a)).array;
    return result;
}

Row[] parseRows(string str) {
    return str.splitLines.map!(parseRow).array;
}

Row[] expandRows(Row[] rs) {
    return rs.map!((Row r) {
        Row newr = r;
        for (int i = 0; i < 4; i++) {
            newr.mask <<= 1;
            newr.set <<= 1;
            newr.mask |= 1;
            newr.set |= 0;
            newr.mask <<= r.width;
            newr.set <<= r.width;
            newr.mask |= r.mask;
            newr.set |= r.set;
            newr.expect ~= r.expect;
        }
        return newr;
    }).array;
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

Int128 pext(Int128 x, Int128 mask) {
    Int128 res = 0uL;
    for (Int128 bb = 1uL; mask != 0uL; bb += bb) {
        if (x & mask & -mask) {
            res |= bb;
        }
        mask &= (mask - 1);
    }
    return res;
}

Int128 pdep(Int128 val, Int128 mask) {
  Int128 res = 0uL;
  for (Int128 bb = 1uL; mask; bb += bb) {
    if (val & bb)
      res |= mask & -mask;
    mask &= mask - 1;
  }
  return res;
}


Int128 next(Int128 x, Int128 mask) {
    x = pext(x, mask);
    Int128 a = x & -x;
    Int128 b = x +  a;
    Int128 c = x & ~b;
    if (c != 0uL) {
        while (!(c & 1)) {
            c >>= 1;
        }
        c >>= 1;
    }
    x = b ^ c;
    x = pdep(x, mask);
    return x;
}

long countValid(Row row) {
    write(row.s);
    long count = 0;
    Int128 x = row.set | pdep(Int128((1uL << (row.expect.sum - row.setCount)) - 1uL), row.mask);
    do {
        if (bitSeq(x) == row.expect) {
            count++;
        }
        x = next(x, row.mask) | row.set;
    } while (x != row.set);
    writeln(" -> ", count);
    return count;
}

long sumValid(Row[] rows) {
    return rows.map!(countValid).sum;
}

void main() {
    string example1 = `???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1`;

    assert(parseRows(example1).map!(r => r.width).maxElement + 1 < 128 / 5);
    assert(parseRows(readText("input")).map!(r => r.width).maxElement + 1 < 128 / 5);

    writeln(sumValid(parseRows(example1)));
    writeln(sumValid(parseRows(readText("input"))));
    // writeln(sumValid(expandRows(parseRows(example1))));
}
