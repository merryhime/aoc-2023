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

struct Pipeline {
    string name;
    Rule[] rules;
};

struct Rule {
    string eval;
    long value;
    string target;
};

struct Part {
    long x, m, a, s;
    long sum() { return x + m + a + s; }
};

Pipeline[string] parseRules(string str) {
    return str.splitLines.map!((string line) {
        string[] l = line.split!(ch => ch == '{' || ch == '}');
        string pipelineName = l[0];
        string[] ruleStrs = l[1].split(',');
        Rule[] rules;
        foreach (string rstr; ruleStrs) {
            if (rstr.canFind(':')) {
                long cmpIndex = rstr.countUntil!(ch => ch == '<' || ch == '>');
                long colonIndex = rstr.countUntil!(ch => ch == ':');
                string valueStr = rstr[cmpIndex + 1 .. colonIndex].text;
                string eval = rstr[0 .. cmpIndex + 1];
                long value = parse!long(valueStr);
                string target = rstr[colonIndex + 1 .. $].text;
                rules ~= Rule(eval, value, target);
            } else {
                rules ~= Rule("true", -1, rstr);
            }
        }
        return tuple(pipelineName, Pipeline(pipelineName, rules));
    }).assocArray;
}

Part[] parseParts(string str) {
    return str.splitLines.map!((string line) {
        string[] l = line.split!(ch => ch == '{' || ch == '}');
        long[] value = l[1].split(',').map!((string kv) {
            long eqIndex = kv.countUntil!(ch => ch == '=');
            string valueStr = kv[eqIndex + 1 .. $].text;
            return parse!long(valueStr);
        }).array;
        return Part(value[0], value[1], value[2], value[3]);
    }).array;
}

auto part1(string str) {
    Pipeline[string] pipelines = parseRules(str.split("\n\n")[0]);
    Part[] parts = parseParts(str.split("\n\n")[1]);
    return parts.map!((Part part) {
        string pl = "in";
        while (pl != "A" && pl != "R") {
            foreach (Rule r; pipelines[pl].rules) {
                bool pass = false;
                switch (r.eval) {
                    case "x>": pass = part.x > r.value; break;
                    case "x<": pass = part.x < r.value; break;
                    case "m>": pass = part.m > r.value; break;
                    case "m<": pass = part.m < r.value; break;
                    case "a>": pass = part.a > r.value; break;
                    case "a<": pass = part.a < r.value; break;
                    case "s>": pass = part.s > r.value; break;
                    case "s<": pass = part.s < r.value; break;
                    case "true": pass = true; break;
                    default: assert(false);
                }
                if (pass) {
                    pl = r.target;
                    break;
                }
            }
        }
        return pl == "A" ? part.sum : 0;
    }).sum;
}

struct Interval {
    long min_, max_;
    long width() { return max_ - min_ + 1; }
}

struct Parts {
    string pl;
    long index;
    Interval x, m, a, s;
    long prod() { return x.width * m.width * a.width * s.width; }
}

auto part2(string str) {
    Pipeline[string] pipelines = parseRules(str.split("\n\n")[0]);
    Parts[] next = [Parts("in", 0, Interval(1, 4000), Interval(1, 4000), Interval(1, 4000), Interval(1, 4000))];
    Parts[] accepted;
    while (!next.empty) {
        Parts current = next.front;
        next.popFront;

        if (current.pl == "A") {
            accepted ~= current;
            continue;
        }
        if (current.pl == "R") {
            continue;
        }

        Rule r = pipelines[current.pl].rules[current.index];

        Interval function(Parts) get;
        Interval function(ref Parts, Interval) set;
        switch (r.eval[0]) {
        case 'x': get = (Parts p) => p.x; set = (ref Parts p, Interval v) => p.x = v; break;
        case 'm': get = (Parts p) => p.m; set = (ref Parts p, Interval v) => p.m = v; break;
        case 'a': get = (Parts p) => p.a; set = (ref Parts p, Interval v) => p.a = v; break;
        case 's': get = (Parts p) => p.s; set = (ref Parts p, Interval v) => p.s = v; break;
        case 't': break;
        default: assert(false);
        }

        if (r.eval == "true") {
            next ~= Parts(r.target, 0, current.x, current.m, current.a, current.s);
        } else {
            Interval pass, fail;
            Interval v = get(current);

            switch (r.eval[1]) {
            case '<':
                pass = Interval(v.min_, r.value - 1);
                fail = Interval(r.value, v.max_);
                break;
            case '>':
                fail = Interval(v.min_, r.value);
                pass = Interval(r.value + 1, v.max_);
                break;
            default:
                assert(false);
            }

            if (pass.min_ <= pass.max_) {
                set(current, pass);
                next ~= Parts(r.target, 0, current.x, current.m, current.a, current.s);
            }
            if (fail.min_ <= fail.max_) {
                set(current, fail);
                next ~= Parts(current.pl, current.index + 1, current.x, current.m, current.a, current.s);
            }
        }
    }

    return accepted.map!(p => p.prod).sum;
}

void main() {
    string example1 = `px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}`;

    writeln(part1(example1));
    writeln(part1(readText("input")));
    writeln(part2(example1));
    writeln(part2(readText("input")));
}