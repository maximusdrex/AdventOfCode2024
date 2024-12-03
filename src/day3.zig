const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;
const ArrayListU8 = std.ArrayList(u8);

const MatchState = enum { unmatched, fn_name, paren_open, num1, num2, dont_name };

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) expect(false) catch std.debug.print("leaked\n", .{});
    }

    const data = try getData(allocator, "data/day3.txt");
    defer {
        allocator.free(data);
    }

    var state: MatchState = MatchState.unmatched;
    const expected_name = "mul";
    const expected_dont = "don't()";
    const expected_do = "do()";

    var matching_do = true;
    var matching_dont = true;
    var enabled = true;
    var matched_name = ArrayListU8.init(allocator);
    defer matched_name.deinit();
    var full_match = ArrayListU8.init(allocator);
    defer full_match.deinit();

    var count: i32 = 0;

    var n1 = ArrayListU8.init(allocator);
    var n2 = ArrayListU8.init(allocator);
    defer {
        n1.deinit();
        n2.deinit();
    }

    for (data) |char| {
        std.debug.print("Matching {c} at {any}\n", .{ char, state });
        switch (state) {
            .unmatched => {
                if (char == 'm') {
                    state = .fn_name;
                    matched_name.clearAndFree();
                    try matched_name.append(char);
                    full_match.clearAndFree();
                } else if (char == 'd') {
                    state = .dont_name;
                    matched_name.clearAndFree();
                    try matched_name.append(char);
                    full_match.clearAndFree();
                    matching_do = true;
                    matching_dont = true;
                } else {
                    state = .unmatched;
                }
            },
            .fn_name => {
                if (char == expected_name[matched_name.items.len]) {
                    try matched_name.append(char);
                } else {
                    state = .unmatched;
                }

                if (state == .fn_name and eql(u8, expected_name, matched_name.items)) {
                    state = .paren_open;
                }
            },
            .dont_name => {
                if (matching_dont and char == expected_dont[matched_name.items.len]) {
                    try matched_name.append(char);
                } else {
                    matching_dont = false;
                }

                if (!matching_dont and matching_do and char == expected_do[matched_name.items.len]) {
                    try matched_name.append(char);
                } else if (!matching_dont) {
                    std.debug.print("No match DO {d} : {d}\n", .{ char, expected_do[matched_name.items.len] });
                    matching_do = false;
                }

                if (!matching_do and !matching_dont) {
                    state = .unmatched;
                }

                if (state == .dont_name and eql(u8, expected_dont, matched_name.items)) {
                    std.debug.print("Disabled: {s}\n", .{matched_name.items});

                    enabled = false;
                    state = .unmatched;
                } else if (state == .dont_name and eql(u8, expected_do, matched_name.items)) {
                    std.debug.print("Enabled: {s}\n", .{matched_name.items});

                    enabled = true;
                    state = .unmatched;
                }
            },
            .paren_open => {
                if (char == '(') {
                    state = .num1;
                    n1.clearAndFree();
                    n2.clearAndFree();
                } else {
                    state = .unmatched;
                }
            },
            .num1 => {
                if (char == ',' and n1.items.len > 0) {
                    state = .num2;
                } else if (isDigit(char) and n1.items.len < 3) {
                    try n1.append(char);
                } else {
                    state = .unmatched;
                }
            },
            .num2 => {
                if (char == ')' and n2.items.len > 0) {
                    if (enabled) count += try std.fmt.parseInt(i32, n1.items, 10) * try std.fmt.parseInt(i32, n2.items, 10);
                    try full_match.append(char);
                    std.debug.print("Match: {s} | Count: {d}\n", .{ full_match.items, count });
                    state = .unmatched;
                } else if (isDigit(char) and n2.items.len < 3) {
                    try n2.append(char);
                } else {
                    state = .unmatched;
                }
            },
        }

        try full_match.append(char);
    }

    try stdout.print("Answer: {d}\n", .{count});

    try bw.flush();
}

fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

fn getData(allocator: std.mem.Allocator, file_name: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    return try file.readToEndAlloc(allocator, 50000);
}

test "read file test" {
    const alloc = std.testing.allocator;

    const expected = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
    const file_data = try getData(alloc, "../data/day3_test.txt");
    defer alloc.free(file_data);

    try expect(eql(u8, file_data, expected));
}
