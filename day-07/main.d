import std.string;
import std.stdio;
import std.range;
import std.algorithm.sorting;
import std.algorithm.iteration;
import std.algorithm.searching;
import std.conv;
import std.file;

const string STRENGTH = "23456789TJQKA";
const string JSTRENGTH = "J23456789TQKA";

enum Type { High, OnePair, TwoPair, Three, FullHouse, Four, Five };

Type type(string hand) {
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

Type jtype(string hand) {
    if (hand == "JJJJJ") return Type.Five;
    dchar r = hand.replace("J", "").array.sort.uniq.maxElement!(c => hand.count(c));
    return type(hand.replace('J', r));
}

// -1 = a is stronger
//  0 = equal strength
// +1 = b is stronger
template compare(alias tfunc, string strength) {
    int compare(string a, string b) {
        Type ta = tfunc(a);
        Type tb = tfunc(b);
        if (ta > tb) return -1;
        if (ta < tb) return +1;
        for (int i = 0; i < 5; i++) {
            long sa = strength.indexOf(a[i]);
            long sb = strength.indexOf(b[i]);
            if (sa > sb) return -1;
            if (sa < sb) return +1;
        }
        return 0;
    }
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

template eval(alias tfunc, string strength) {
    long eval(Hand[] hands) {
        return hands.sort!((x, y) => compare!(tfunc, strength)(x.hand, y.hand) == +1).enumerate.map!(x => (x[0] + 1) * x[1].bid).sum;
    }
}

void main() {
    string example1 = `32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483`;

    writeln(eval!(type, STRENGTH)(parseHands(example1)));
    writeln(eval!(type, STRENGTH)(parseHands(readText("input"))));
    writeln(eval!(jtype, JSTRENGTH)(parseHands(example1)));
    writeln(eval!(jtype, JSTRENGTH)(parseHands(readText("input"))));
}
