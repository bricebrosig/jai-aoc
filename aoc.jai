/*
*/

# if OS == .MACOS || OS == .LINUX{
    end_of_line :: "\n";
    double_end_of_line :: "\n\n";
} else {
    end_of_line :: "\r\n";
    double_end_of_line :: "\r\n\r\n";
}

// end_of_line        :: "\n";
// double_end_of_line :: "\n\n";

main :: () {
    // day1();
    // day2();
    // day3();
    // day4();
    // day5();
    // day6();
    day7();
}

day7 :: () {
    Node :: struct {
        name:   string;
        is_dir: bool;
        children_visited: int;
        index:  int;
        size:   int;
        parent: int;
        depth:  int;
        children: [..] int;
    }

    init_node :: (node: *Node, name: string, size: int, is_dir: bool, idx: int, parent: int, depth: int) {
        node.size   = size;
        node.name   = name;
        node.is_dir = is_dir;
        node.parent = parent;
        node.index  = idx;
        node.depth  = depth;
    }

    data, success := read_entire_file("data/07-data.txt");
    assert(success, "failed to read file");
    defer free(data);

    root: Node;
    all: [..] Node;
    init_node(*root, "/", 0, true, 0, 0, 0);
    array_add(*all, root);
    curr_idx := 0;
    defer array_free(all);
    
    lines := split(data, end_of_line);
    for i: 1..lines.count-1 {
        line := lines[i];
        print("%\n", line);
        key := slice(line, 0, 4);
        if key == {
            case "$ cd";  // move into a child directory
                name := split(line, " ")[2];
                if name == ".." {
                    curr_idx = all[curr_idx].parent;
                } else {
                    for node, i: all {
                        if node.name == name {
                            curr_idx = i;
                            break;
                        }
                    }
                }
            case "dir ";  // add directory to our nodes
                name := split(line, " ")[1];
                curr_node := *all[curr_idx];
                new_node: Node;
                path := sprint("%/%", curr_node.name, name);
                init_node(*new_node, path, 0, true, all.count, curr_idx, curr_node.depth + 1);
                array_add(*curr_node.children, new_node.index);
                array_add(*all, new_node);
            case "$ ls";  // do nothing

            case;         // regular file
                name := split(line, " ")[1];
                size := to_integer(split(line, " ")[0]);
                curr_node := *all[curr_idx];
                new_node: Node;
                path := sprint("%/%", curr_node.name, name);
                init_node(*new_node, path, size, false, all.count, curr_idx, curr_node.depth + 1);
                array_add(*curr_node.children, new_node.index);
                array_add(*all, new_node);
        }
    }

    print("\n********************************\n");

    curr_idx = 0;
    stack : [..] int;  defer array_free(stack);
    array_add(*stack, 0);
    while stack.count > 0 {
        node := *all[stack[stack.count - 1]];
        
        if !node.is_dir || node.children_visited == node.children.count {
            for 1..node.depth  print("  ");
            if node.is_dir     print("- % (dir, size=%)\n", node.name, node.size);
            else               print("- %, (file, size=%)\n", node.name, node.size);
            all[node.parent].children_visited += 1;
            all[node.parent].size += node.size;
            stack.count -= 1;  // "pop"
        } else {
            for node.children  array_add(*stack, it);
        }
    }

    sum := 0;
    for all {
        if it.is_dir && it.size <= 100000  {
            print("%, size=%\n", it.name, it.size);
            sum += it.size;
        }
    }
    print("sum = %\n", sum);
}


day6 :: () {
    data, success := read_entire_file("data/06-data.txt");
    defer free(data);
    assert(success, "failed to read file");

    // key_size ::  4;  // part 1
    key_size :: 14;  // part 2

    table: Table(u8, u8);
    init(*table, key_size);
    defer deinit(*table);

    for base: 0..data.count - key_size - 1 {
        for i: base..base+key_size-1 {
            table_set(*table, data[i], 1);
        }

        if table.count == key_size {
            print("message starts at %\n", base + key_size);
            break;
        }

        table_reset(*table);
    }
}


day5 :: () {
    data, success := read_entire_file("data/05-data.txt");
    defer free(data);
    assert(success, "failed to read file");

    split_data := split(data, double_end_of_line);
    initial_state := split_data[0];
    moves := split_data[1];

    // initialize the stacks
    num_stacks := initial_state[initial_state.count-2] - 48;  // reading an ascii u8 and subtracting its offset to get its value
    stacks := NewArray(num_stacks, [..] int);
    defer array_free(stacks);
    initial_state.count -= 1;  // don't read the last line of the initial state section as stack data
    lines := split(initial_state, end_of_line);
    lines.count = lines.count - 1;

    for < line: lines {  // this 'for <' means iterate backwards
        i := 1;  // the letters in the stack are lined up starting at index 1 and appear every 4 (if they exist)
        while i < line.count {
            if line[i] != 32 {  // not a space
                array_add(*stacks[(i - 1) / 4], line[i]);
            }
            i += 4;
        }
    }

    print("inital state:\n");
    for stack: stacks {
        for item: stack {
            print("% ", item);
        }
        print("\n");
    }
    print("\n");

    // handle the moves
    for move: split(moves, end_of_line) {
        splits := split(move, " ");
        how_many := to_integer(splits[1]);
        from := to_integer(splits[3]) - 1;  // -1 since these are array indices
        to := to_integer(splits[5]) - 1;  // -1 sinces these are array indices

        // part 1 : moving one at a time
        // for 1..how_many {
        //     if stacks[from].count > 0 {
        //         array_add(*stacks[to], stacks[from][stacks[from].count - 1]);
        //         array_unordered_remove_by_index(*stacks[from], stacks[from].count - 1);
        //     }
        // }

        // part 2 : moving many at a time
        if stacks[from].count >= how_many {
            for i: stacks[from].count - how_many..stacks[from].count - 1 {
                array_add(*stacks[to], stacks[from][i]);
            }
            for i: 0..how_many-1 {
                array_unordered_remove_by_index(*stacks[from], i + (stacks[from].count - how_many));
            }
        } else {
            for item: stacks[from] {
                array_add(*stacks[to], item);
            }
            array_reset(*stacks[from]);  // empty the array but don't free the memory
        }
    }

    print("final state:\n");
    for stack: stacks {
        for item: stack {
            print("% ", to_string(* (cast(u8) item), 1));
        }
        print("\n");
    }
}


day4 :: () {
    data, success := read_entire_file("data/04-data.txt");
    defer free(data);
    assert(success, "failed to read file");
    
    splits := split(data, end_of_line);
    full_overlap_count := 0;
    overlap_count := 0;
    for line: splits {
        halves := split(line, ",");
        left_lower  := to_integer(split(halves[0], "-")[0]);
        left_upper  := to_integer(split(halves[0], "-")[1]);
        right_lower := to_integer(split(halves[1], "-")[0]);
        right_upper := to_integer(split(halves[1], "-")[1]);

        if (left_lower <= right_lower && left_upper >= right_upper) ||  (right_lower <= left_lower && right_upper >= left_upper){
            full_overlap_count += 1;
        }

        if (left_upper >= right_lower && left_lower <= right_lower) || (left_lower <= right_upper && right_lower <= left_lower) {
            overlap_count += 1;
        }
    }

    print("num full overlap: %\n", full_overlap_count);
    print("num overlap: %\n", overlap_count);
}

day3 :: () {
    char_to_priority :: (c: u8) -> int {
        if c >= 97  return c - 96;
        else        return c - 38;
    }

    data, success := read_entire_file("data/03-data.txt");
    defer free(data);
    assert(success, "failed to read file");
    char_counts : [123] u8;

    splits := split(data, end_of_line);
    sum := 0;
    for line: splits {
        half := line.count / 2;
        for 0..half-1 {
            char_counts[line[it]] = 1;
        }

        for half..line.count-1 {
            if char_counts[line[it]] == 1 {
                sum += char_to_priority(line[it]);
                break;
            }
        }

        // reset character counts
        for 0..122 {
            char_counts[it] = 0;
        }
    }

    print("sum of dups: %\n", sum);

    // part two
    group_idx := 1;
    sum = 0;
    set :u64 = 0xffff_ffff_ffff_ffff;
    for line: splits {
        line_bits :u64 = 0;
        for 0..line.count-1 {
            line_bits |= (cast(u64) 1) << char_to_priority(line[it]);
        }
        set &= line_bits;

        // we have finished looking at a group
        if group_idx % 3 == 0 {
            while set > 1 {
                set >>= 1;
                sum += 1;  // add to sum whichever bit is set
            }
            set = 0xffff_ffff_ffff_ffff;
        }
        group_idx += 1;
    }

    print("badge sum: %\n", sum);
}


day2 :: () {
    data, success := read_entire_file("data/02-data.txt");
    defer free(data);
    assert(success, "failed to read file");

    splits := split(data, end_of_line);
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
    data, success := read_entire_file("data/01-data.txt");
    defer free(data);
    assert(success, "failed to read file");
    splits := split(data, end_of_line);

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
#import "Hash_Table";