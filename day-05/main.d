import std.string;
import std.conv;
import std.algorithm.searching;
import std.algorithm.iteration;
import std.stdio;
import std.range;
import std.file;

struct MapEntry
{
    long dest;
    long src;
    long size;
};

MapEntry parseEntry(string s)
{
    string[] p = s.split(' ');
    return MapEntry(parse!long(p[0]), parse!long(p[1]), parse!long(p[2]));
}

bool inRange(long x, long start, long size)
{
    return start <= x && x < start + size;
}

bool inSrcRange(MapEntry e, long x)
{
    return inRange(x, e.src, e.size);
}

long mapLookup(long x, MapEntry[] m)
{
    auto result = m.find!(e => e.inSrcRange(x));
    if (result.empty)
        return x;
    MapEntry e = result[0];
    return x - e.src + e.dest;
}

struct Almanac
{
    long[] seeds;
    MapEntry[] seed_to_soil;
    MapEntry[] soil_to_fertilizer;
    MapEntry[] fertilizer_to_water;
    MapEntry[] water_to_light;
    MapEntry[] light_to_temp;
    MapEntry[] temp_to_humidity;
    MapEntry[] humidity_to_location;
}

Almanac parseAlmanac(string str)
{
    string[] s = splitLines(str);
    long[] seeds = s[0].drop(7).split(' ').map!(i => parse!long(i)).array();

    auto r = s.drop(1);
    auto parseMap = () {
        MapEntry[] m;
        r = r.drop(2);
        while (!r.empty && !r.front.empty) {
            m ~= parseEntry(r.front);
            r.popFront();
        }
        return m;
    };

    return Almanac(
        seeds,
        parseMap(),
        parseMap(),
        parseMap(),
        parseMap(),
        parseMap(),
        parseMap(),
        parseMap());
}

long seedToLocation(Almanac a, long seed)
{
    return seed.mapLookup(a.seed_to_soil)
               .mapLookup(a.soil_to_fertilizer)
               .mapLookup(a.fertilizer_to_water)
               .mapLookup(a.water_to_light)
               .mapLookup(a.light_to_temp)
               .mapLookup(a.temp_to_humidity)
               .mapLookup(a.humidity_to_location);
}

long part1(Almanac a)
{
    return a.seeds.map!(s => seedToLocation(a, s)).minElement;
}

struct Range
{
    long start;
    long size;
};

Range[] mapLookup(Range[] ins, MapEntry[] m)
{
    Range[] result;
next_ins:
    while (!ins.empty)
    {
        Range i = ins.front;
        ins.popFront();

        foreach (MapEntry e; m)
        {
            long i0 = i.start;
            long i1 = i.start + i.size;
            long e0 = e.src;
            long e1 = e.src + e.size;

            auto translate = (long x) => x - e.src + e.dest;

            if (i1 <= e0)
                continue;
            if (e1 <= i0)
                continue;
            if (e0 <= i0 && i1 <= e1)
            {
                result ~= Range(translate(i0), i1 - i0);
                continue next_ins;
            }
            if (i0 < e0 && e1 < i1)
            {
                ins ~= Range(i0, e0 - i0);
                result ~= Range(translate(e0), e1 - e0);
                ins ~= Range(e1, i1 - e1);
                continue next_ins;
            }
            if (e0 <= i0 && e1 < i1)
            {
                result ~= Range(translate(i0), e1 - i0);
                ins ~= Range(e1, i1 - e1);
                continue next_ins;
            }
            if (i0 < e0 && i1 <= e1)
            {
                ins ~= Range(i0, e0 - i0);
                result ~= Range(translate(e0), i1 - e0);
                continue next_ins;
            }
            writeln(i, e);
            assert(false);
        }

        result ~= i;
    }
    return result;
}

Range[] seedToLocation(Almanac a, Range[] seed)
{
    return seed.mapLookup(a.seed_to_soil)
               .mapLookup(a.soil_to_fertilizer)
               .mapLookup(a.fertilizer_to_water)
               .mapLookup(a.water_to_light)
               .mapLookup(a.light_to_temp)
               .mapLookup(a.temp_to_humidity)
               .mapLookup(a.humidity_to_location);
}

long part2(Almanac a)
{
    Range[] ins = iota(0, a.seeds.length, 2).map!(i => Range(a.seeds[i], a.seeds[i + 1])).array;
    return seedToLocation(a, ins).map!(r => r.start).minElement;
}

void main()
{
    const string example1 = `seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4`;

    writeln(part1(parseAlmanac(example1)));
    writeln(part1(parseAlmanac(readText("input"))));
    writeln(part2(parseAlmanac(example1)));
    writeln(part2(parseAlmanac(readText("input"))));
}