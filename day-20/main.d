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

struct Network {
    Module[string] modules;
    string[][string] conjunctionInputs;
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

Network parseNetwork(string str) {
    Network n;
    n.modules = parseModules(str);
    foreach (string conj; n.modules.byPair.filter!(p => p[1].type == '&').map!(p => p[0])) {
        string[] inputs = n.modules.byPair.filter!(p => p[1].output.canFind(conj)).map!(p => p[0]).array;
        assert(conj !in n.conjunctionInputs);
        n.conjunctionInputs[conj] = inputs;
    }
    return n;
}

struct NetworkState {
    bool[][string] conjunctions;
    bool[string] flipFlops;

    long lowPulses = 0;
    long highPulses = 0;
}

NetworkState initState(Network n) {
    return NetworkState(
            n.conjunctionInputs.byPair.map!(p => tuple(p[0], new bool[p[1].length])).assocArray,
            n.modules.byPair.filter!(p => p[1].type == '%').map!(p => tuple(p[0], false)).assocArray);
}

struct Pulse {
    string source;
    string destination;
    bool level;
}

Pulse[] step(const ref Network n, ref NetworkState s) {
    Pulse[] rxPulses = [];
    Pulse[] next = [Pulse("button", "broadcaster", false)];
    while (!next.empty) {
        Pulse pulse = next.front;
        next.popFront;

        final switch (pulse.level) {
        case false: s.lowPulses++; break;
        case true: s.highPulses++; break;
        }

        string current = pulse.destination;

        if (current == "rx") {
            rxPulses ~= pulse;
        }

        if (current !in n.modules) continue;

        const Module m = n.modules[current];
        switch (m.type) {
        case '=':
            next ~= m.output.map!(o => Pulse(current, o, pulse.level)).array;
            continue;
        case '%':
            if (pulse.level == false) {
                s.flipFlops[current] = !s.flipFlops[current];
                next ~= m.output.map!(o => Pulse(current, o, s.flipFlops[current])).array;
            }
            continue;
        case '&':
            long inputIndex = n.conjunctionInputs[current].countUntil!(i => i == pulse.source);
            s.conjunctions[current][inputIndex] = pulse.level;
            bool outputLevel = !s.conjunctions[current].all;
            next ~= m.output.map!(o => Pulse(current, o, outputLevel)).array;
            continue;
        default:
            assert(false);
        }
    }
    return rxPulses;
}

long part1(string str) {
    Network n = parseNetwork(str);
    NetworkState s = initState(n);
    for (long i = 0; i < 1000; i++) {
        step(n, s);
    }
    return s.lowPulses * s.highPulses;
}

long part2(string str) {
    Network n = parseNetwork(str);
    NetworkState s = initState(n);
    long count = 0;
    while (true) {
        count++;
        Pulse[] rxPulses = step(n, s);
        if (rxPulses.any!(p => p.level == false))
            break;
    }
    return count;
}

void main() {
    string example1 = `broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a`;
    string example2 = `broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output`;

    writeln(part1(example1));
    writeln(part1(example2));
    writeln(part1(readText("input")));
    writeln(part2(readText("input")));
}
