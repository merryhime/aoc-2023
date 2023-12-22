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

struct Module {
    dchar type;
    string[] output;
}

Module[string] parseModules(string str) {
    return str.splitLines.map!((string mstr) {
        string[] p = mstr.split(" -> ");
        if (p[0] == "broadcaster") {
            return tuple("broadcaster", Module('=', p[1].split(", ")));
        }
        return tuple(p[0][1..$].text, Module(p[0][0], p[1].split(", ")));
    }).assocArray;
}

void main() {
    string example1 = `broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a`;
    writeln(parseModules(example1));
}