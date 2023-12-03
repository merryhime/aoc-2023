import std.stdio;
import std.file;
import std.string;
import std.ascii;
import std.range;
import std.algorithm.searching;
import std.algorithm.iteration;
import std.typecons;
import std.conv;

bool isSymbol(dchar ch)
{
    return !isDigit(ch) && ch != '.';
}

struct Coord {
    long line;
    long col;
};

struct Number {
    long value;
    Coord coord;
    long count;
};

struct Map {
    bool[Coord] symbols;
    Number[] numbers;
};

Tuple!(bool[Coord], Number[]) parseLine(string line, long lineNo)
{
    const long expectedLength = line.length;

    bool[Coord] symbols;
    Number[] numbers;
    int col = 0;
    while(!line.empty)
    {
        if (isDigit(line.front))
        {
            const auto p = parse!(long, string, Yes.doCount)(line);
            numbers ~= [Number(p.data, Coord(lineNo, col), p.count)];
            col += p.count;
            continue;
        }

        if (isSymbol(line.front))
        {
            symbols[Coord(lineNo, col)] = true;
        }
        line.popFront();
        col++;
    }

    return tuple(symbols, numbers);
}

Map parseMap(string input)
{
    Map m;
    string[] lines = splitLines(input);
    for (long row = 0; row < lines.length; ++row)
    {
        auto l = parseLine(lines[row], row);
        m.symbols = m.symbols.byPair.chain(l[0].byPair).assocArray;
        m.numbers ~= l[1];
    }
    return m;
}

bool isNeighbour(Number n, Coord s)
{
    return n.coord.line - 1 <= s.line && s.line <= n.coord.line + 1 
        && n.coord.col - 1 <= s.col && s.col <= n.coord.col + n.count;
}

long part1(Map m)
{
    const auto isPartNumber = (Number n) => m.symbols.keys.any!(s => isNeighbour(n, s));
    return m.numbers.filter!(isPartNumber).map!"a.value".sum;
}

void main()
{
    string example1 = `467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..`;

    writeln(part1(parseMap(example1)));
    writeln(part1(parseMap(readText("input"))));
}
