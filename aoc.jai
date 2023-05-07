/*

6758
5199
-

*/

main :: () {
    // day1();
    // day2();
    day3();
}


day3 :: () {
    priority :: (c: u8) -> int {
        if c >= 97 {  // lower case
            return c - 96;
        } else {  // upper case
            return c - 38;
        }
    }

    data, success := read_entire_file("03-data.txt");
    defer free(data);
    assert(success, "failed to read file");
    char_counts : [123] u8;

    splits := split(data, "\r\n");
    sum := 0;
    for line: splits {
        half := line.count / 2;
        for 0..half-1 {
            char_counts[line[it]] = 1;
        }

        for half..line.count-1 {
            if char_counts[line[it]] == 1 {
                print("found dup: % at %. value: %\n", line[it], it, priority(line[it]));
                sum += priority(line[it]);
                break;
            }
        }

        // reset character counts
        for 0..122 {
            char_counts[it] = 0;
        }
    }

    print("sum of dups: %\n", sum);
}


day2 :: () {
    data, success := read_entire_file("02-data.txt");
    defer free(data);
    assert(success, "failed to read file");

    splits := split(data, "\r\n");
    cheating_score := 0;
    sneaky_score   := 0;
    for combo: splits {
        if combo == {
            case "A X"; cheating_score += 1 + 3;
            case "A Y"; cheating_score += 2 + 6;
            case "A Z"; cheating_score += 3 + 0;
            case "B X"; cheating_score += 1 + 0;
            case "B Y"; cheating_score += 2 + 3;
            case "B Z"; cheating_score += 3 + 6;
            case "C X"; cheating_score += 1 + 6;
            case "C Y"; cheating_score += 2 + 0;
            case "C Z"; cheating_score += 3 + 3;
        }

        if combo == {
            case "A X"; sneaky_score += 3 + 0;
            case "A Y"; sneaky_score += 1 + 3;
            case "A Z"; sneaky_score += 2 + 6;
            case "B X"; sneaky_score += 1 + 0;
            case "B Y"; sneaky_score += 2 + 3;
            case "B Z"; sneaky_score += 3 + 6;
            case "C X"; sneaky_score += 2 + 0;
            case "C Y"; sneaky_score += 3 + 3;
            case "C Z"; sneaky_score += 1 + 6;
        }
    }

    print("cheating_score: %\n", cheating_score);
    print("sneaky_score: %\n", sneaky_score);
}

//
// i would like to find 
day1 :: () {
    data, success := read_entire_file("01-data.txt");
    defer free(data);
    assert(success, "failed to read file");
    splits := split(data, "\r\n");

    all_calories : [..] int;
    calories := 0;
    for s, i : splits {
        calories += to_integer(s);

        if s == "" {
            array_add(*all_calories, calories);
            calories = 0;
        }
    }

    quick_sort(all_calories, x => -x);

    print("max1:  %\n", all_calories[0]);
    print("max2:  %\n", all_calories[1]);
    print("max3:  %\n", all_calories[2]);
    print("total: %\n", all_calories[0] + all_calories[1] + all_calories[2]);
}

#import "File";
#import "Basic";
#import "String";
#import "Sort";