import std.string;
import std.range;
import std.algorithm.iteration;
import std.algorithm.searching;
import std.stdio;
import std.conv;
import std.file;

struct Node {
    string name;
    string left;
    string right;
    string parent;
};

struct Map {
    string commands;
    Node[string] nodes;
};

Node[string] parseNodes(string[] strs) {
    const auto parseNode = (string s) {
        auto p = s.filter!(ch => " ()".indexOf(ch) == -1).text.split!(ch => ch == '=' || ch == ',').array;
        return Node(p[0], p[1], p[2], "");
    };
    Node[string] result;
    foreach(string s; strs) {
        Node n = parseNode(s);
        result[n.name] = n;
    }
    foreach(Node n; result.byValue()) {
        if (n.name == "ZZZ") continue;
        result[n.left].parent = n.name;
        result[n.right].parent = n.name;
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

    writeln(part1(parseMap(example1)));
    writeln(part1(parseMap(example2)));
    writeln(part1(parseMap(readText("input"))));
}