import std.string;
import std.stdio;
import std.range;
import std.algorithm.sorting;
import std.algorithm.iteration;
import std.conv;
import std.file;

const string STRENGTH = "23456789TJQKA";

long strength(dchar ch) {
    return STRENGTH.indexOf(ch);
}

enum Type { High, OnePair, TwoPair, Three, FullHouse, Four, Five };

auto type(string hand) {
    ulong[] cnt = hand.array.sort.uniq.map!(c => hand.count(c)).array.sort.retro.array;
    switch (cnt[0]) {
    case 5: return Type.Five;
    case 4: return Type.Four;
    case 3: return cnt[1] == 2 ? Type.FullHouse : Type.Three;
    case 2: return cnt[1] == 2 ? Type.TwoPair : Type.OnePair;
    case 1: return Type.High;
    default: assert(false);
    }
}

// -1 = a is stronger
//  0 = equal strength
// +1 = b is stronger
int compare(string a, string b) {
    Type ta = type(a);
    Type tb = type(b);
    if (ta > tb) return -1;
    if (ta < tb) return +1;
    for (int i = 0; i < 5; i++) {
        long sa = strength(a[i]);
        long sb = strength(b[i]);
        if (sa > sb) return -1;
        if (sa < sb) return +1;
    }
    return 0;
}

struct Hand {
    string hand;
    long bid;
};

Hand[] parseHands(string s) {
    return splitLines(s).map!((string line) {
        string[] p = line.split(' ');
        return Hand(p[0], parse!long(p[1]));
    }).array;
}

long part1(Hand[] hands) {
    hands.sort!((x, y) => compare(x.hand, y.hand) == +1);
    long result = 0;
    for (long i = 0; i < hands.length; i++) {
        result += (i + 1) * hands[i].bid;
    }
    return result;
}

void main() {
    string example1 = `32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483`;

    writeln(part1(parseHands(example1)));
    writeln(part1(parseHands(readText("input"))));
}
