import std.string;
import std.range;
import std.algorithm.iteration;
import std.algorithm.searching;
import std.stdio;
import std.conv;
import std.file;
import std.numeric;

struct Node {
    string name;
    string left;
    string right;
};

struct Map {
    string commands;
    Node[string] nodes;
};

Node[string] parseNodes(string[] strs) {
    const auto parseNode = (string s) {
        auto p = s.filter!(ch => " ()".indexOf(ch) == -1).text.split!(ch => ch == '=' || ch == ',').array;
        return Node(p[0], p[1], p[2]);
    };
    Node[string] result;
    foreach(string s; strs) {
        Node n = parseNode(s);
        result[n.name] = n;
    }
    return result;
}

Map parseMap(string str) {
    string[] s = splitLines(str);
    return Map(s[0], parseNodes(s[2 .. $]));
}

long part1(Map m) {
    string current = "AAA";
    for (long i = 0; true; i++) {
        switch (m.commands[i % m.commands.length]) {
        case 'L': current = m.nodes[current].left; break;
        case 'R': current = m.nodes[current].right; break;
        default: assert(false);
        }
        if (current == "ZZZ") return i + 1;
    }
    assert(false);
}

struct CycleInfo {
    string[] sequence;
    string loopStart;
    long cycleLength;
    long preludeLength;
};

CycleInfo detectCycle(Map m, string start) {
    CycleInfo info;
    string current = start;
    long i = 0;
    while (true) {
        long currentIndex = info.sequence.countUntil(current);
        if (currentIndex != -1) {
            if ((i - currentIndex) % m.commands.length == 0) {
                info.loopStart = current;
                info.cycleLength = i - currentIndex;
                info.preludeLength = currentIndex;
                return info;
            }
        }
        info.sequence ~= current;
        switch (m.commands[i % m.commands.length]) {
        case 'L': current = m.nodes[current].left; break;
        case 'R': current = m.nodes[current].right; break;
        default: assert(false);
        }
        i++;
    }
}

long part2(Map m) {
    CycleInfo[] cycles = m.nodes.byValue.filter!(n => n.name[$-1] == 'A').map!(n => detectCycle(m, n.name)).array;
    assert(cycles.map!(c => c.sequence[c.preludeLength .. $].count!(n => n[$-1] == 'Z')).all!(x => x == 1));
    long[] initialTick = cycles.map!(c => c.sequence.countUntil!(n => n[$-1] == 'Z')).array;
    long[] cycleLen = cycles.map!(c => c.cycleLength).array;
    assert(initialTick == cycleLen); // Below trick relies on this
    return cycleLen.reduce!((x, y) => lcm(x, y));
}

void main() {
    const string example1 = `RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)`;

    const string example2 = `LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)`;

    const string example3 = `LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)`;

    writeln(part1(parseMap(example1)));
    writeln(part1(parseMap(example2)));
    writeln(part1(parseMap(readText("input"))));
    writeln(detectCycle(parseMap(example1), "AAA"));
    writeln(detectCycle(parseMap(example2), "AAA"));
    writeln(detectCycle(parseMap(example3), "11A"));
    writeln(detectCycle(parseMap(example3), "22A"));
    writeln(part2(parseMap(readText("input"))));
}