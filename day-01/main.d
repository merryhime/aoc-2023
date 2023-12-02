import std.stdio;
import std.file;
import std.string;
import std.ascii;
import std.range;
import std.algorithm.searching;
import std.algorithm.iteration;
import std.typecons;

long part1(string[] lines)
{
    long sum = 0;
    foreach (string line; lines)
    {
        dchar first_digit = filter!(isDigit)(line).front;
        dchar last_digit = filter!(isDigit)(line.retro).front;
        int tens = first_digit - '0';
        int ones = last_digit - '0';
        sum += tens * 10;
        sum += ones;
    }
    return sum;
}

long part2(string[] lines)
{
    alias Digit = Tuple!(string, int);
    Digit[] digits = [
        Digit("0", 0),
        Digit("1", 1),
        Digit("2", 2),
        Digit("3", 3),
        Digit("4", 4),
        Digit("5", 5),
        Digit("6", 6),
        Digit("7", 7),
        Digit("8", 8),
        Digit("9", 9),
        Digit("one", 1),
        Digit("two", 2),
        Digit("three", 3),
        Digit("four", 4),
        Digit("five", 5),
        Digit("six", 6),
        Digit("seven", 7),
        Digit("eight", 8),
        Digit("nine", 9),
    ];

    long sum = 0;
    foreach (string line; lines)
    {
        long tens = digits.map!(x => tuple(line.indexOf(x[0]), x[1])).filter!(x => x[0] >= 0).minElement!(i => i[0])[1];
        long ones = digits.map!(x => tuple(line.lastIndexOf(x[0]), x[1])).filter!(x => x[0] >= 0).maxElement!(i => i[0])[1];
        long value = tens * 10 + ones;
        sum += value;
    }
    return sum;
}

void main()
{
    string[] lines = splitLines(readText("input"));

    string[] example1 = [
        "1abc2",
        "pqr3stu8vwx",
        "a1b2c3d4e5f",
        "treb7uchet",
    ];

    writeln(part1(example1));
    writeln(part1(lines));

    string[] example2 = [
        "two1nine",
        "eightwothree",
        "abcone2threexyz",
        "xtwone3four",
        "4nineeightseven2",
        "zoneight234",
        "7pqrstsixteen",
    ];

    writeln(part2(example2));
    writeln(part2(lines));
}
