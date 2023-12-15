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
import std.range.interfaces;

char hash(string s) {
    char result = 0;
    foreach (char ch; s.dup) {
        result += ch;
        result *= 17;
    }
    return result;
}

struct Lens {
    string name;
    int power;
}

long part2(string[] cmds) {
    Lens[][char] hashmap;
    foreach (string c; cmds) {
        if (c.endsWith('-')) {
            string s = c.chop;
            char h = hash(s);
            if (h in hashmap)
                hashmap[h] = hashmap[h].filter!(l => l.name != s).array;
        } else {
            string[] s = c.split('=');
            char h = hash(s[0]);
            int p = parse!int(s[1]);
            if (h in hashmap) {
                long index = hashmap[h].countUntil!(l => l.name == s[0]);
                if (index != -1) {
                    hashmap[h][index].power = p;
                    continue;
                }
            }
            hashmap[h] ~= Lens(s[0], p);
        }
    }
    long result;
    foreach (p; hashmap.byPair) {
        long box = 1 + cast(long)p[0];
        Lens[] ls = p[1];
        for (int i = 0; i < ls.length; i++) {
            result += box * (i + 1) * ls[i].power;
        }
    }
    return result;
}

void main() {
    assert(hash("HASH") == 52);
    string example1 = `rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7`;
    writeln(example1.chomp.split(',').map!(s => cast(long)hash(s)).sum);
    writeln(readText("input").chomp.split(',').map!(s => cast(long)hash(s)).sum);
    writeln(part2(example1.split(',')));
    writeln(part2(readText("input").chomp.split(',')));
}