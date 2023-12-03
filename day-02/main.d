import std.stdio;
import std.file;
import std.string;
import std.range;
import std.algorithm.searching;
import std.algorithm.iteration;
import std.conv;

struct Turn {
    long red = 0;
    long green = 0;
    long blue = 0;
};

struct Game {
    long index;
    Turn[] turns;
};

Turn parseTurn(string turnStr)
{
    const string[] parts = split(turnStr, ',');
    Turn turn;
    foreach (string part; parts)
    {
        string[] p = split(part.drop(1), ' ');
        const long count = parse!long(p[0]);
        switch (p[1])
        {
            case "red": turn.red = count; break;
            case "green": turn.green = count; break;
            case "blue": turn.blue = count; break;
            default: assert(false);
        }
    }
    return turn;
}

Game parseGame(string line)
{
    const long colonIndex = line.indexOf(':');
    string indexStr = line[5 .. colonIndex];
    const long index = parse!long(indexStr);
    const string[] turnStrs = split(line.drop(colonIndex + 1), ';');
    return Game(index, turnStrs.map!(parseTurn).array());
}

Game[] parseGames(string input)
{
    const string[] lines = splitLines(input);
    return lines.map!(parseGame).array();
}

long part1(Game[] games)
{
    const auto possible = (Game game) => game.turns.all!(t => (t.red <= 12 && t.green <= 13 && t.blue <= 14));
    return games.filter!(possible).map!"a.index".sum();
}

long part2(Game[] games)
{
    const auto calcPower = (Game game) => game.turns.map!"a.red".maxElement * game.turns.map!"a.green".maxElement * game.turns.map!"a.blue".maxElement;
    return games.map!(calcPower).sum();
}

void main()
{
    string example1 = `Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green`;

    writeln(part1(parseGames(example1)));
    writeln(part1(parseGames(readText("input"))));
    writeln(part2(parseGames(example1)));
    writeln(part2(parseGames(readText("input"))));
}