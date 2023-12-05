import std.conv;
import std.file;
import std.string;
import std.ascii;
import std.range;
import std.stdio;
import std.algorithm.iteration;
import std.algorithm.searching;

struct Card
{
    long index;
    long[] left;
    long[] right;
}

Card parseCard(string s)
{
    const long indexStart = s.countUntil!(isDigit);
    const long colonIndex = s.indexOf(':');
    const long barIndex = s.indexOf('|');
    string indexStr = s[indexStart .. colonIndex];
    return Card(
        parse!(long, string)(indexStr) - 1,
        s[colonIndex + 1 .. barIndex].split(' ').filter!(x => !x.empty).map!(x => parse!(long, string)(x)).array,
        s.drop(barIndex + 1).split(' ').filter!(x => !x.empty).map!(x => parse!(long, string)(x)).array);
}

Card[] parseCards(string s)
{
    return s.splitLines.map!(parseCard).array;
}

long part1(Card[] cards)
{
    auto scoreCard = (Card c) {
        const long n = c.right.filter!(x => c.left.canFind(x)).count;
        return n == 0 ? 0 : 1 << (n - 1);
    };
    return cards.map!(scoreCard).sum;
}

long part2(Card[] cards)
{
    long[][] sources = new long[][cards.length];
    foreach (Card c; cards)
    {
        const long n = c.right.filter!(x => c.left.canFind(x)).count;
        foreach (long i; iota(c.index + 1, c.index + 1 + n))
        {
            sources[i] ~= c.index;
        }
    }

    long[] count = new long[cards.length];
    for(long i = 0; i < cards.length; i++)
    {
        count[i] = 1 + sources[i].map!(j => count[j]).sum;
    }
    return count.sum;
}

void main()
{
    const string example1 = `Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11`;

    writeln(part1(parseCards(example1)));
    writeln(part1(parseCards(readText("input"))));
    writeln(part2(parseCards(example1)));
    writeln(part2(parseCards(readText("input"))));
}